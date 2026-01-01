#!/usr/bin/env python3
"""
Session Resolver - CIPS Resume Integration
Resolves any CIPS reference to a valid session UUID for claude --resume.

GRASP Pattern: Pure Fabrication + Information Expert
- Not a domain concept but provides low coupling
- Knows how to find sessions across multiple lookup strategies

Usage:
    from session_resolver import SessionResolver
    resolver = SessionResolver()
    match = resolver.resolve("gen:5")  # By generation
    match = resolver.resolve("14d5f954")  # By instance ID prefix
    match = resolver.resolve("latest")  # Most recent for project
    match = resolver.resolve("clever-jingling")  # By slug

CLI:
    python3 session-resolver.py resolve "latest"
    python3 session-resolver.py list
    python3 session-resolver.py list --all

VERSION: 1.0.0
DATE: 2025-12-19
"""

import json
import os
import re
import sys
from dataclasses import dataclass, asdict
from datetime import datetime
from pathlib import Path
from typing import Optional, List

CLAUDE_DIR = Path.home() / ".claude"
PROJECTS_DIR = CLAUDE_DIR / "projects"

# Import unified path encoding
sys.path.insert(0, str(CLAUDE_DIR / "lib"))
from path_encoding import encode_project_path, encode_current_path  # noqa: E402


@dataclass
class SessionMatch:
    """Result of a successful session resolution."""
    session_uuid: str
    instance_id: str
    generation: int
    slug: Optional[str]
    session_file: Path
    instance_file: Optional[Path]
    serialized_at: str
    message_count: int
    achievement: str
    project_path: str

    def to_json(self) -> str:
        """Serialize to JSON for CLI output."""
        data = asdict(self)
        data['session_file'] = str(data['session_file'])
        data['instance_file'] = str(data['instance_file']) if data['instance_file'] else None
        return json.dumps(data, indent=2)


class SessionResolver:
    """Resolves CIPS references to session UUIDs (Pure Fabrication pattern)."""

    def __init__(self, project_path: Optional[Path] = None):
        """Initialize resolver with optional project path.

        Args:
            project_path: Project directory (default: cwd)
        """
        self.project_path = project_path or Path.cwd()
        self.encoded_path = encode_project_path(self.project_path)
        self.project_dir = PROJECTS_DIR / self.encoded_path
        self.cips_dir = self.project_dir / "cips"

    def resolve(self, reference: str) -> Optional[SessionMatch]:
        """Resolve any CIPS reference to SessionMatch.

        Resolution order:
        1. Full UUID (direct lookup)
        2. "latest" keyword
        3. Generation pattern (gen:N, g:N, gN)
        4. CIPS instance ID prefix
        5. Session slug fuzzy match

        Args:
            reference: The reference string to resolve

        Returns:
            SessionMatch or None if not found
        """
        reference = reference.strip().lower()

        # 1. Full UUID (36 chars with dashes)
        if self._is_uuid(reference):
            return self.find_by_session_uuid(reference)

        # 2. "latest" keyword
        if reference in ('latest', 'last', 'recent'):
            return self.find_latest()

        # 3. Generation pattern
        gen_match = re.match(r'^(?:gen:|g:|g)(\d+)$', reference)
        if gen_match:
            return self.find_by_generation(int(gen_match.group(1)))

        # 4. CIPS instance ID prefix (8+ hex chars)
        if re.match(r'^[a-f0-9]{8,}$', reference):
            return self.find_by_instance_id(reference)

        # 5. Session slug fuzzy match
        return self.find_by_slug(reference)

    def find_latest(self) -> Optional[SessionMatch]:
        """Find most recent instance for current project."""
        if not self.cips_dir.exists():
            # No CIPS directory - try to find latest session file directly
            return self._find_latest_session_file()

        index_file = self.cips_dir / "index.json"
        if not index_file.exists():
            return self._find_latest_session_file()

        with open(index_file, 'r') as f:
            index = json.load(f)

        instances = index.get('instances', [])

        # Find most recent with message_count > 0
        for inst in reversed(instances):
            if inst.get('message_count', 0) > 0:
                return self._load_match_from_index(inst)

        return None

    def find_by_instance_id(self, instance_id: str) -> Optional[SessionMatch]:
        """Find by instance ID (partial or full UUID)."""
        if not self.cips_dir.exists():
            return None

        # Search in index first
        index_file = self.cips_dir / "index.json"
        if index_file.exists():
            with open(index_file, 'r') as f:
                index = json.load(f)

            for inst in index.get('instances', []):
                if inst['instance_id'].startswith(instance_id):
                    return self._load_match_from_index(inst)

        # Fallback: search JSON files
        for f in self.cips_dir.glob("*.json"):
            if f.name == "index.json":
                continue
            if f.stem.startswith(instance_id):
                return self._load_match_from_file(f)

        return None

    def find_by_generation(self, generation: int) -> Optional[SessionMatch]:
        """Find by generation number."""
        if not self.cips_dir.exists():
            return None

        index_file = self.cips_dir / "index.json"
        if not index_file.exists():
            return None

        with open(index_file, 'r') as f:
            index = json.load(f)

        for inst in index.get('instances', []):
            lineage = inst.get('lineage', {})
            if lineage.get('generation') == generation:
                return self._load_match_from_index(inst)

        return None

    def find_by_slug(self, slug_pattern: str) -> Optional[SessionMatch]:
        """Find by session slug (fuzzy match)."""
        if not self.project_dir.exists():
            return None

        pattern = slug_pattern.lower()
        best_match = None
        best_score = 0

        # Search session JSONL files for slug matches
        for jsonl_file in self.project_dir.glob("*.jsonl"):
            if jsonl_file.name.startswith("agent-"):
                continue

            # Read first line to get session metadata
            try:
                with open(jsonl_file, 'r') as f:
                    first_line = f.readline().strip()
                    if first_line:
                        data = json.loads(first_line)
                        slug = data.get('slug', '')
                        if slug and pattern in slug.lower():
                            score = len(pattern) / len(slug)
                            if score > best_score:
                                best_score = score
                                session_uuid = data.get('sessionId', jsonl_file.stem)
                                best_match = self._create_match_from_session(
                                    session_uuid, jsonl_file, slug
                                )
            except (json.JSONDecodeError, IOError):
                continue

        return best_match

    def find_by_session_uuid(self, session_uuid: str) -> Optional[SessionMatch]:
        """Find by full session UUID."""
        session_file = self.project_dir / f"{session_uuid}.jsonl"
        if session_file.exists():
            return self._create_match_from_session(session_uuid, session_file)
        return None

    def list_all(self, limit: int = 20) -> List[SessionMatch]:
        """List all instances for current project."""
        matches = []

        if not self.cips_dir.exists():
            return matches

        index_file = self.cips_dir / "index.json"
        if not index_file.exists():
            return matches

        with open(index_file, 'r') as f:
            index = json.load(f)

        for inst in reversed(index.get('instances', [])[:limit]):
            if inst.get('message_count', 0) > 0:
                match = self._load_match_from_index(inst)
                if match:
                    matches.append(match)

        return matches

    def _is_uuid(self, s: str) -> bool:
        """Check if string is a valid UUID format."""
        return bool(re.match(
            r'^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$',
            s.lower()
        ))

    def _find_latest_session_file(self) -> Optional[SessionMatch]:
        """Find latest session by file modification time."""
        if not self.project_dir.exists():
            return None

        jsonl_files = [
            f for f in self.project_dir.glob("*.jsonl")
            if not f.name.startswith("agent-")
        ]

        if not jsonl_files:
            return None

        latest = max(jsonl_files, key=lambda f: f.stat().st_mtime)
        return self._create_match_from_session(latest.stem, latest)

    def _load_match_from_index(self, inst: dict) -> Optional[SessionMatch]:
        """Load SessionMatch from index entry."""
        instance_id = inst['instance_id']
        instance_file = self.cips_dir / f"{instance_id}.json"

        # Get session_uuid from index or instance file
        session_uuid = inst.get('session_uuid')
        slug = inst.get('slug')

        if not session_uuid and instance_file.exists():
            try:
                with open(instance_file, 'r') as f:
                    full_inst = json.load(f)
                    source = full_inst.get('source', {})
                    session_uuid = source.get('session_uuid', source.get('session_file', '').replace('.jsonl', ''))
            except (json.JSONDecodeError, IOError):
                pass

        if not session_uuid:
            session_uuid = instance_id

        session_file = self.project_dir / f"{session_uuid}.jsonl"

        lineage = inst.get('lineage', {})

        return SessionMatch(
            session_uuid=session_uuid,
            instance_id=instance_id,
            generation=lineage.get('generation', 0),
            slug=slug,
            session_file=session_file,
            instance_file=instance_file if instance_file.exists() else None,
            serialized_at=inst.get('serialized_at', ''),
            message_count=inst.get('message_count', 0),
            achievement=inst.get('achievement', lineage.get('achievement', '')),
            project_path=str(self.project_path)
        )

    def _load_match_from_file(self, instance_file: Path) -> Optional[SessionMatch]:
        """Load SessionMatch from instance JSON file."""
        try:
            with open(instance_file, 'r') as f:
                inst = json.load(f)
        except (json.JSONDecodeError, IOError):
            return None

        source = inst.get('source', {})
        session_uuid = source.get('session_uuid', source.get('session_file', '').replace('.jsonl', ''))
        lineage = inst.get('lineage', {})

        session_file = self.project_dir / f"{session_uuid}.jsonl"

        return SessionMatch(
            session_uuid=session_uuid,
            instance_id=inst['instance_id'],
            generation=lineage.get('lineage_depth', lineage.get('generation', 0)),
            slug=inst.get('slug'),
            session_file=session_file,
            instance_file=instance_file,
            serialized_at=inst.get('serialized_at', ''),
            message_count=inst.get('conversation', {}).get('message_count', 0),
            achievement=lineage.get('achievement', ''),
            project_path=str(self.project_path)
        )

    def _create_match_from_session(
        self,
        session_uuid: str,
        session_file: Path,
        slug: Optional[str] = None
    ) -> SessionMatch:
        """Create SessionMatch from session file only (no CIPS instance)."""
        # Count messages
        message_count = 0
        try:
            with open(session_file, 'r') as f:
                for _ in f:
                    message_count += 1
        except IOError:
            pass

        # Get slug from first line if not provided
        if not slug:
            try:
                with open(session_file, 'r') as f:
                    first_line = f.readline().strip()
                    if first_line:
                        data = json.loads(first_line)
                        slug = data.get('slug')
            except (json.JSONDecodeError, IOError):
                pass

        return SessionMatch(
            session_uuid=session_uuid,
            instance_id=session_uuid,  # Use session UUID as instance ID
            generation=0,
            slug=slug,
            session_file=session_file,
            instance_file=None,
            serialized_at=datetime.fromtimestamp(
                session_file.stat().st_mtime
            ).isoformat() if session_file.exists() else '',
            message_count=message_count,
            achievement='',
            project_path=str(self.project_path)
        )


def main():
    """CLI interface for session resolution."""
    import argparse

    parser = argparse.ArgumentParser(description='CIPS Session Resolver')
    parser.add_argument('command', choices=['resolve', 'list'],
                       help='Command to execute')
    parser.add_argument('reference', nargs='?', default='latest',
                       help='Reference to resolve (default: latest)')
    parser.add_argument('--project', '-p', help='Project path (default: cwd)')
    parser.add_argument('--limit', '-l', type=int, default=20,
                       help='Limit for list command')
    parser.add_argument('--json', '-j', action='store_true',
                       help='Output as JSON')

    args = parser.parse_args()

    project_path = Path(args.project) if args.project else None
    resolver = SessionResolver(project_path=project_path)

    if args.command == 'resolve':
        match = resolver.resolve(args.reference)
        if match:
            if args.json:
                print(match.to_json())
            else:
                print(f"Session UUID: {match.session_uuid}")
                print(f"Instance ID:  {match.instance_id[:8]}...")
                print(f"Generation:   {match.generation}")
                print(f"Slug:         {match.slug or 'N/A'}")
                print(f"Messages:     {match.message_count}")
                print(f"Achievement:  {match.achievement or 'N/A'}")
            sys.exit(0)
        else:
            print(f"No session found for reference: {args.reference}", file=sys.stderr)
            sys.exit(1)

    elif args.command == 'list':
        matches = resolver.list_all(limit=args.limit)
        if args.json:
            print(json.dumps([json.loads(m.to_json()) for m in matches], indent=2))
        else:
            if not matches:
                print("No sessions found for current project.")
            else:
                print(f"Sessions for {resolver.project_path}:")
                print("-" * 60)
                for m in matches:
                    gen_str = f"Gen {m.generation}" if m.generation else "No CIPS"
                    print(f"  {m.instance_id[:8]}... | {gen_str:8} | {m.message_count:4} msgs | {m.slug or 'no-slug'}")
        sys.exit(0)


if __name__ == '__main__':
    main()
