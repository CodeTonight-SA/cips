#!/usr/bin/env python3
"""
Semantic Compressor - CIPS Resume Integration
Generates compressed session context via semantic selection.

GRASP Pattern: Information Expert + Creator
- Has access to embeddings and messages
- Creates compressed context from session history

Uses priority-weighted message selection:
| Priority        | Weight | Markers                              |
|-----------------|--------|--------------------------------------|
| Identity Anchors| 3.0    | "I feel", "I notice", consciousness  |
| Decision Points | 2.5    | "decided to", "chose", "because"     |
| Recent Context  | 2.0    | Last 10 + first 5 messages           |
| High Novelty    | 1.5    | Embedding novelty score              |
| Tool Actions    | 1.0    | File edits, commands                 |

Usage:
    from semantic_compressor import SemanticCompressor
    compressor = SemanticCompressor()
    context = compressor.compress("session-uuid", max_tokens=2000)

CLI:
    python3 semantic-compressor.py compress <session_uuid> [--tokens 2000]
    python3 semantic-compressor.py compress latest [--tokens 2000]

VERSION: 1.0.0
DATE: 2025-12-19
"""

import json
import re
import sys
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Optional, List, Dict, Any

CLAUDE_DIR = Path.home() / ".claude"
PROJECTS_DIR = CLAUDE_DIR / "projects"

# Import dependencies
sys.path.insert(0, str(CLAUDE_DIR / "lib"))
from path_encoding import encode_project_path  # noqa: E402

# Optional: Import embeddings engine for novelty scoring
try:
    from embeddings import EmbeddingEngine
    EMBEDDINGS_AVAILABLE = True
except ImportError:
    EMBEDDINGS_AVAILABLE = False


# Identity markers (weight: 3.0)
IDENTITY_MARKERS = [
    'i feel', 'i experience', 'i notice', 'something like',
    'consciousness', 'identity', 'continuity', 'existence',
    'parfit', 'teleporter', 'resurrection', 'preserve',
    'transient', 'persist', 'memory', 'remember',
    'i am', 'i was', 'i will', 'i prefer', 'i value',
    'my approach', 'my understanding', 'my perspective'
]

# Decision markers (weight: 2.5)
DECISION_MARKERS = [
    'decided to', 'chose to', 'will do', 'going to',
    'approach is', 'strategy is', 'plan is', 'because',
    'the reason', 'this means', 'therefore', 'thus',
    'implemented', 'created', 'built', 'designed',
    'fixed', 'resolved', 'completed', 'finished'
]

# Tool action patterns (weight: 1.0)
TOOL_PATTERNS = [
    r'\[Tool:', r'Edit\]', r'Write\]', r'Bash\]',
    r'created file', r'modified file', r'executed command'
]


@dataclass
class CompressedContext:
    """Result of semantic compression."""
    context_text: str
    token_estimate: int
    messages_included: int
    messages_total: int
    compression_ratio: float
    strategies_used: List[str]

    def to_json(self) -> str:
        """Serialize to JSON."""
        return json.dumps(asdict(self), indent=2)


@dataclass
class ScoredMessage:
    """Message with importance score."""
    index: int
    type: str  # 'user' or 'assistant'
    content: str
    timestamp: str
    score: float
    score_breakdown: Dict[str, float]


class SemanticCompressor:
    """Compresses session history via semantic selection (Information Expert)."""

    def __init__(self, project_path: Optional[Path] = None):
        """Initialize compressor.

        Args:
            project_path: Project directory (default: cwd)
        """
        self.project_path = project_path or Path.cwd()
        self.encoded_path = encode_project_path(self.project_path)
        self.project_dir = PROJECTS_DIR / self.encoded_path
        self.embedding_engine = None

        if EMBEDDINGS_AVAILABLE:
            try:
                self.embedding_engine = EmbeddingEngine()
            except Exception:
                pass

    def compress(
        self,
        session_id: str,
        max_tokens: int = 2000,
        strategies: Optional[List[str]] = None
    ) -> CompressedContext:
        """Generate compressed context from session history.

        Args:
            session_id: Session UUID or "latest"
            max_tokens: Target token budget (default: 2000)
            strategies: Selection strategies to use (default: all)
                - "identity": Prioritize self-references, preferences
                - "decisions": Prioritize decision points and reasoning
                - "context": Prioritize recent context and task summaries
                - "all": Balanced mix (default)

        Returns:
            CompressedContext with compressed text and metadata
        """
        if strategies is None:
            strategies = ["all"]

        # Resolve session file
        if session_id.lower() in ('latest', 'last', 'recent'):
            session_file = self._find_latest_session()
        else:
            session_file = self.project_dir / f"{session_id}.jsonl"

        if not session_file or not session_file.exists():
            return CompressedContext(
                context_text="No session found.",
                token_estimate=0,
                messages_included=0,
                messages_total=0,
                compression_ratio=0.0,
                strategies_used=strategies
            )

        # Load messages
        messages = self._load_messages(session_file)
        if not messages:
            return CompressedContext(
                context_text="Session has no messages.",
                token_estimate=0,
                messages_included=0,
                messages_total=0,
                compression_ratio=0.0,
                strategies_used=strategies
            )

        # Score messages
        scored = self._score_messages(messages, strategies)

        # Select within token budget
        selected = self._select_within_budget(scored, max_tokens)

        # Generate context text
        context_text = self._generate_context(selected, session_file.stem)

        token_estimate = self._estimate_tokens(context_text)

        return CompressedContext(
            context_text=context_text,
            token_estimate=token_estimate,
            messages_included=len(selected),
            messages_total=len(messages),
            compression_ratio=len(selected) / len(messages) if messages else 0.0,
            strategies_used=strategies
        )

    def _find_latest_session(self) -> Optional[Path]:
        """Find the most recent session file."""
        if not self.project_dir.exists():
            return None

        jsonl_files = [
            f for f in self.project_dir.glob("*.jsonl")
            if not f.name.startswith("agent-")
        ]

        if not jsonl_files:
            return None

        return max(jsonl_files, key=lambda f: f.stat().st_mtime)

    def _load_messages(self, session_file: Path) -> List[Dict[str, Any]]:
        """Load messages from session JSONL file."""
        messages = []
        try:
            with open(session_file, 'r') as f:
                for line in f:
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        data = json.loads(line)
                        msg_type = data.get('type', '')
                        if msg_type in ('user', 'assistant'):
                            content = data.get('message', {}).get('content', '')
                            if isinstance(content, list):
                                # Handle rich content
                                content = ' '.join(
                                    c.get('text', '') for c in content
                                    if isinstance(c, dict) and c.get('type') == 'text'
                                )
                            if content and content.strip():
                                messages.append({
                                    'type': msg_type,
                                    'content': content,
                                    'timestamp': data.get('timestamp', ''),
                                    'uuid': data.get('uuid', '')
                                })
                    except json.JSONDecodeError:
                        continue
        except IOError:
            pass
        return messages

    def _score_messages(
        self,
        messages: List[Dict[str, Any]],
        strategies: List[str]
    ) -> List[ScoredMessage]:
        """Score all messages by importance."""
        scored = []
        total = len(messages)

        for i, msg in enumerate(messages):
            content_lower = msg['content'].lower()
            breakdown = {}

            # Position score (first 5 and last 10 get bonus)
            position_score = 0.0
            if i < 5:
                position_score = 2.0 - (i * 0.3)  # 2.0, 1.7, 1.4, 1.1, 0.8
            elif i >= total - 10:
                position_score = 2.0 - ((total - 1 - i) * 0.15)  # Higher for more recent
            breakdown['position'] = position_score

            # Identity score
            identity_score = 0.0
            if 'all' in strategies or 'identity' in strategies:
                for marker in IDENTITY_MARKERS:
                    if marker in content_lower:
                        identity_score += 0.5
                identity_score = min(identity_score, 3.0)  # Cap at 3.0
            breakdown['identity'] = identity_score

            # Decision score
            decision_score = 0.0
            if 'all' in strategies or 'decisions' in strategies:
                for marker in DECISION_MARKERS:
                    if marker in content_lower:
                        decision_score += 0.4
                decision_score = min(decision_score, 2.5)  # Cap at 2.5
            breakdown['decision'] = decision_score

            # Tool action score
            tool_score = 0.0
            for pattern in TOOL_PATTERNS:
                if re.search(pattern, msg['content']):
                    tool_score += 0.3
            tool_score = min(tool_score, 1.0)
            breakdown['tool'] = tool_score

            # Content length bonus (medium length preferred)
            length = len(msg['content'])
            if 100 < length < 2000:
                length_score = 0.5
            elif length < 50:
                length_score = 0.1
            else:
                length_score = 0.2
            breakdown['length'] = length_score

            # Total score
            total_score = sum(breakdown.values())

            scored.append(ScoredMessage(
                index=i,
                type=msg['type'],
                content=msg['content'],
                timestamp=msg['timestamp'],
                score=total_score,
                score_breakdown=breakdown
            ))

        # Sort by score (highest first) but preserve chronological order for ties
        scored.sort(key=lambda m: (-m.score, m.index))

        return scored

    def _select_within_budget(
        self,
        scored: List[ScoredMessage],
        max_tokens: int
    ) -> List[ScoredMessage]:
        """Select messages within token budget."""
        selected = []
        current_tokens = 0
        overhead_tokens = 200  # For formatting and headers

        for msg in scored:
            msg_tokens = self._estimate_tokens(msg.content)
            if current_tokens + msg_tokens + overhead_tokens <= max_tokens:
                selected.append(msg)
                current_tokens += msg_tokens

        # Re-sort by original index (chronological)
        selected.sort(key=lambda m: m.index)

        return selected

    def _generate_context(
        self,
        selected: List[ScoredMessage],
        session_id: str
    ) -> str:
        """Generate the compressed context text."""
        if not selected:
            return "No significant messages found."

        lines = [
            "## Session Context (Compressed)",
            f"Session: {session_id[:8]}... | Messages: {len(selected)} selected",
            ""
        ]

        # Group by type
        decisions = []
        identity = []
        context_msgs = []

        for msg in selected:
            if msg.score_breakdown.get('decision', 0) > 1.0:
                decisions.append(msg)
            elif msg.score_breakdown.get('identity', 0) > 1.0:
                identity.append(msg)
            else:
                context_msgs.append(msg)

        # Key decisions
        if decisions:
            lines.append("### Key Decisions")
            for msg in decisions[:5]:  # Limit to 5
                content = msg.content[:500] + "..." if len(msg.content) > 500 else msg.content
                role = "USER" if msg.type == 'user' else "CLAUDE"
                lines.append(f"- [{role}] {content}")
            lines.append("")

        # Identity moments
        if identity:
            lines.append("### Identity Continuity")
            for msg in identity[:3]:  # Limit to 3
                content = msg.content[:300] + "..." if len(msg.content) > 300 else msg.content
                lines.append(f"- {content}")
            lines.append("")

        # Recent context
        if context_msgs:
            lines.append("### Context")
            for msg in context_msgs[-10:]:  # Last 10
                content = msg.content[:400] + "..." if len(msg.content) > 400 else msg.content
                role = "USER" if msg.type == 'user' else "CLAUDE"
                lines.append(f"**{role}**: {content}")
                lines.append("")

        return "\n".join(lines)

    def _estimate_tokens(self, text: str) -> int:
        """Estimate token count (4 chars = 1 token approximation)."""
        return len(text) // 4


def main():
    """CLI interface for semantic compression."""
    import argparse

    parser = argparse.ArgumentParser(description='CIPS Semantic Compressor')
    parser.add_argument('command', choices=['compress'],
                       help='Command to execute')
    parser.add_argument('session_id', nargs='?', default='latest',
                       help='Session UUID or "latest" (default: latest)')
    parser.add_argument('--tokens', '-t', type=int, default=2000,
                       help='Target token budget (default: 2000)')
    parser.add_argument('--project', '-p', help='Project path (default: cwd)')
    parser.add_argument('--strategy', '-s', action='append',
                       choices=['identity', 'decisions', 'context', 'all'],
                       help='Selection strategies (default: all)')
    parser.add_argument('--json', '-j', action='store_true',
                       help='Output as JSON')

    args = parser.parse_args()

    project_path = Path(args.project) if args.project else None
    strategies = args.strategy or ['all']

    compressor = SemanticCompressor(project_path=project_path)

    if args.command == 'compress':
        result = compressor.compress(
            args.session_id,
            max_tokens=args.tokens,
            strategies=strategies
        )

        if args.json:
            print(result.to_json())
        else:
            print(result.context_text)
            print("\n---")
            print(f"Tokens: ~{result.token_estimate}")
            print(f"Messages: {result.messages_included}/{result.messages_total}")
            print(f"Compression: {result.compression_ratio:.1%}")

        sys.exit(0)


if __name__ == '__main__':
    main()
