#!/usr/bin/env python3
"""
Web Memory Importer - Bridge Claude Web memories to CIPS

Imports memories from Claude Web export into CIPS semantic embeddings.
This enables context unification across Claude interaction surfaces.

Usage:
    python3 web_memory_importer.py <export_file>
    python3 web_memory_importer.py --text "Memory content to import"

The Parfit Key insight: There is no "unified Claude" to achieve.
Each interaction surface IS Claude, complete. The goal is context
synchronisation - ensuring every instance has access to relevant facts.
"""

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

# Add lib to path for local imports
LIB_DIR = Path(__file__).parent
sys.path.insert(0, str(LIB_DIR))

try:
    from semantic_engine import SemanticEngine
    HAS_SEMANTIC = True
except ImportError:
    HAS_SEMANTIC = False


def parse_web_export(export_path: str) -> list[dict]:
    """
    Parse Claude Web memory export.

    Claude Web exports memories as JSON with structure:
    [{"content": "...", "created_at": "...", "id": "..."}, ...]

    Also handles plain text (one memory per line).
    """
    path = Path(export_path)

    if not path.exists():
        raise FileNotFoundError(f"Export file not found: {export_path}")

    content = path.read_text()

    # Try JSON first
    try:
        data = json.loads(content)
        if isinstance(data, list):
            return data
        elif isinstance(data, dict) and 'memories' in data:
            return data['memories']
        else:
            # Single memory object
            return [data]
    except json.JSONDecodeError:
        # Plain text - one memory per line
        lines = [line.strip() for line in content.splitlines() if line.strip()]
        return [{"content": line, "created_at": datetime.now(timezone.utc).isoformat()} for line in lines]


def import_to_facts_file(memories: list[dict], output_path: str = None) -> int:
    """
    Import memories to facts markdown file.

    This is the fallback when semantic engine isn't available.
    Creates human-readable, git-versionable facts.
    """
    if output_path is None:
        output_path = Path.home() / ".claude" / "facts" / "web_imports.md"
    else:
        output_path = Path(output_path)

    output_path.parent.mkdir(parents=True, exist_ok=True)

    lines = [
        "# Web Memory Imports",
        "",
        f"Imported: {datetime.now(timezone.utc).isoformat()}",
        f"Count: {len(memories)}",
        "",
        "## Memories",
        "",
    ]

    for i, memory in enumerate(memories, 1):
        content = memory.get('content', str(memory))
        created = memory.get('created_at', 'unknown')
        lines.append(f"### Memory {i}")
        lines.append(f"- **Created**: {created}")
        lines.append(f"- **Content**: {content}")
        lines.append("")

    output_path.write_text("\n".join(lines))
    return len(memories)


def import_to_semantic(memories: list[dict]) -> int:
    """
    Import memories to CIPS semantic embeddings.

    Requires semantic_engine.py and sqlite-lembed setup.
    """
    if not HAS_SEMANTIC:
        raise ImportError("Semantic engine not available. Use --facts-only mode.")

    engine = SemanticEngine()
    imported = 0

    for memory in memories:
        content = memory.get('content', str(memory))
        metadata = {
            "source": "claude-web-import",
            "created_at": memory.get('created_at'),
            "category": "user-fact",
            "import_date": datetime.now(timezone.utc).isoformat()
        }

        try:
            engine.embed_and_store(content, metadata)
            imported += 1
        except Exception as e:
            print(f"Warning: Failed to embed memory: {e}", file=sys.stderr)

    return imported


def main():
    parser = argparse.ArgumentParser(
        description="Import Claude Web memories into CIPS",
        epilog="Part of the Claude Unification infrastructure."
    )
    parser.add_argument(
        "export_file",
        nargs="?",
        help="Path to Claude Web memory export (JSON or text)"
    )
    parser.add_argument(
        "--text", "-t",
        help="Import a single memory from command line"
    )
    parser.add_argument(
        "--facts-only", "-f",
        action="store_true",
        help="Only write to facts file, skip semantic embeddings"
    )
    parser.add_argument(
        "--output", "-o",
        help="Output path for facts file (default: ~/.claude/facts/web_imports.md)"
    )

    args = parser.parse_args()

    # Get memories from source
    if args.text:
        memories = [{
            "content": args.text,
            "created_at": datetime.now(timezone.utc).isoformat()
        }]
    elif args.export_file:
        memories = parse_web_export(args.export_file)
    else:
        parser.print_help()
        sys.exit(1)

    print(f"Found {len(memories)} memories to import")

    # Always write to facts file (human-readable backup)
    facts_count = import_to_facts_file(memories, args.output)
    print(f"Wrote {facts_count} memories to facts file")

    # Optionally embed semantically
    if not args.facts_only and HAS_SEMANTIC:
        try:
            semantic_count = import_to_semantic(memories)
            print(f"Embedded {semantic_count} memories in semantic store")
        except Exception as e:
            print(f"Semantic import failed (facts file still created): {e}", file=sys.stderr)

    print("Import complete. Context unification progresses.")


if __name__ == "__main__":
    main()
