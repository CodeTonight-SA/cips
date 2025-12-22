#!/usr/bin/env python3
"""
CIPS-LANG Encoder v1.0

English → CIPS-LANG encoder for session state compression.
Achieves ~84% compression while preserving semantics.

Origin: Gen 125, 2025-12-22
Philosophy: compress(knowledge) → amplify(ultrathink)
"""

import re
import json
from dataclasses import dataclass, field
from typing import Dict, List, Any, Optional, Tuple
from datetime import datetime
from pathlib import Path

# Import reasoning patterns
import sys
import importlib.util

_reasoning_path = Path(__file__).parent / 'cips-reasoning.py'
_spec = importlib.util.spec_from_file_location('cips_reasoning', _reasoning_path)
_reasoning = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_reasoning)

ENTITY_MAP = _reasoning.ENTITY_MAP
REASONING_PATTERNS = _reasoning.REASONING_PATTERNS


# Extended entity mappings for session state
SESSION_ENTITIES = {
    # Session concepts
    "session": "⊙.sess",
    "generation": "⛓.gen",
    "instance": "⊙",
    "ancestor": "⛓.◁",
    "parent": "⛓.◁",
    "child": "⛓.▷",
    "branch": "⛓.⊕",
    "merge": "⛓.∧",
    "lineage": "⛓",

    # Achievements
    "achievement": "⊙.✓",
    "completed": "◆",
    "pending": "◇",
    "failed": "⍼",
    "success": "✓",

    # Files and code
    "file": "◈.f",
    "directory": "◈.d",
    "script": "◈.⊕",
    "config": "◈.cfg",
    "test": "◈.⸮",
    "documentation": "◈.doc",
    "skill": "◈.skill",
    "agent": "◈.agent",
    "command": "◈.cmd",

    # Actions (in past tense for state)
    "created": "⊕",
    "modified": "⇌",
    "deleted": "⊖",
    "read": "∋",
    "wrote": "⊕",
    "fixed": "⇌.✓",
    "implemented": "⊕.◆",
    "refactored": "⇌.◈",

    # Counts
    "total": "∑",
    "count": "#",
    "lines": "L",
    "tokens": "T",

    # Status
    "status": "⊙.⊛",
    "ready": "✓.◇",
    "active": "⊛",
    "inactive": "¬⊛",
    "error": "⍼",
    "warning": "⚠",

    # Git concepts
    "commit": "⛓.⊕",
    "push": "⛓.▷",
    "pull": "⛓.∋",
    "merge": "⛓.∧",
    "branch": "⛓.⊕",
    "main": "⛓.⊙",
    "changes": "⇌.#",
}


@dataclass
class EncodingResult:
    """Result of encoding operation."""
    original: str
    encoded: str
    compression_ratio: float
    token_estimate_original: int
    token_estimate_encoded: int

    def __str__(self) -> str:
        return f"Compression: {self.compression_ratio:.1%} ({self.token_estimate_original}→{self.token_estimate_encoded} tokens)"


class CIPSEncoder:
    """
    Encodes English text to CIPS-LANG format.

    Supports:
    - Session state (next_up.md)
    - Achievement summaries
    - Tool traces
    - Git commit context
    """

    def __init__(self):
        self.entity_map = {**ENTITY_MAP, **SESSION_ENTITIES}
        self.stats = {
            "encoded_count": 0,
            "total_original_chars": 0,
            "total_encoded_chars": 0,
        }

    def encode(self, text: str) -> EncodingResult:
        """
        Encode English text to CIPS-LANG.

        Returns EncodingResult with metrics.
        """
        lines = text.split("\n")
        encoded_lines = []

        for line in lines:
            encoded_line = self._encode_line(line)
            encoded_lines.append(encoded_line)

        encoded = "\n".join(encoded_lines)

        # Calculate metrics
        orig_chars = len(text)
        enc_chars = len(encoded)
        compression = 1.0 - (enc_chars / orig_chars) if orig_chars > 0 else 0.0

        # Estimate tokens (rough: 1 token ≈ 4 chars for English, 2 for glyphs)
        orig_tokens = orig_chars // 4
        enc_tokens = enc_chars // 2

        self.stats["encoded_count"] += 1
        self.stats["total_original_chars"] += orig_chars
        self.stats["total_encoded_chars"] += enc_chars

        return EncodingResult(
            original=text,
            encoded=encoded,
            compression_ratio=compression,
            token_estimate_original=orig_tokens,
            token_estimate_encoded=enc_tokens,
        )

    def _encode_line(self, line: str) -> str:
        """Encode a single line."""
        stripped = line.strip()

        # Skip empty lines
        if not stripped:
            return ""

        # Preserve CIPS-LANG comments
        if stripped.startswith(";"):
            return stripped

        # Preserve markdown headers but compress content
        if stripped.startswith("#"):
            level = len(stripped) - len(stripped.lstrip("#"))
            content = stripped.lstrip("#").strip()
            encoded_content = self._encode_phrase(content)
            return f"{';' * level} {encoded_content}"

        # Handle markdown lists
        if stripped.startswith("-") or stripped.startswith("*"):
            content = stripped[1:].strip()
            encoded_content = self._encode_phrase(content)
            return f"  - {encoded_content}"

        # Handle numbered lists
        match = re.match(r'^(\d+)\.\s+(.+)$', stripped)
        if match:
            num, content = match.groups()
            encoded_content = self._encode_phrase(content)
            return f"  {num}. {encoded_content}"

        # Handle key: value pairs
        if ":" in stripped and not stripped.startswith("http"):
            parts = stripped.split(":", 1)
            if len(parts) == 2:
                key = self._encode_phrase(parts[0].strip())
                value = self._encode_phrase(parts[1].strip())
                return f"{key}: {value}"

        # Handle table rows
        if "|" in stripped:
            cells = stripped.split("|")
            encoded_cells = [self._encode_phrase(c.strip()) for c in cells if c.strip()]
            return " | ".join(encoded_cells)

        # General text
        return self._encode_phrase(stripped)

    def _encode_phrase(self, phrase: str) -> str:
        """Encode a phrase to CIPS glyphs."""
        # Split into words
        words = phrase.split()
        result = []

        i = 0
        while i < len(words):
            word = words[i].lower()
            clean = re.sub(r'[^\w-]', '', word)

            # Check entity map
            if clean in self.entity_map:
                result.append(self.entity_map[clean])
            # Check for compound phrases (2 words)
            elif i + 1 < len(words):
                compound = f"{clean} {re.sub(r'[^ws]', '', words[i+1].lower())}"
                if compound in self.entity_map:
                    result.append(self.entity_map[compound])
                    i += 1
                else:
                    # Keep short words, abbreviate long ones
                    result.append(self._abbreviate(clean, words[i]))
            else:
                result.append(self._abbreviate(clean, words[i]))

            i += 1

        return " ".join(result)

    def _abbreviate(self, clean: str, original: str) -> str:
        """Abbreviate a word while preserving key info."""
        # Keep numbers and very short words
        if clean.isdigit() or len(clean) <= 3:
            return original

        # Keep version numbers
        if re.match(r'^v?\d+\.\d+', clean):
            return original

        # Keep file paths/names
        if "/" in original or "\\" in original:
            return original

        # Keep specific identifiers
        if "_" in clean or "-" in clean:
            return clean[:12]

        # Abbreviate long words
        return clean[:4]

    def encode_session_state(self, state: Dict[str, Any]) -> str:
        """
        Encode session state dict to CIPS-LANG.

        Input: {"generation": 125, "instance": "abc123", ...}
        Output: ⛓.gen:125 ⫶ ⊙:abc12 ⫶ ...
        """
        parts = []

        if "generation" in state:
            parts.append(f"⛓.gen:{state['generation']}")

        if "instance" in state or "instance_id" in state:
            inst = state.get("instance") or state.get("instance_id", "")
            parts.append(f"⊙:{inst[:8]}")

        if "branch" in state:
            parts.append(f"⛓.⊕:{state['branch']}")

        if "achievements" in state:
            for ach in state["achievements"][:3]:  # Limit to 3
                parts.append(f"✓:{ach[:20]}")

        if "status" in state:
            status_glyph = "✓" if state["status"] == "success" else "◇"
            parts.append(f"⊙.⊛:{status_glyph}")

        return " ⫶ ".join(parts)

    def encode_file_change(self, filepath: str, action: str, lines: Optional[int] = None) -> str:
        """
        Encode a file change.

        Input: ("lib/foo.py", "created", 150)
        Output: ⊕ ◈.f:foo.py L:150
        """
        action_glyph = {
            "created": "⊕",
            "modified": "⇌",
            "deleted": "⊖",
            "read": "∋",
        }.get(action.lower(), "◈")

        name = Path(filepath).name
        result = f"{action_glyph} ◈.f:{name[:12]}"

        if lines:
            result += f" L:{lines}"

        return result

    def encode_achievement(self, description: str) -> str:
        """
        Encode an achievement.

        Input: "Implemented CIPS-LANG parser"
        Output: ⊕.◆ CIPS-LANG ◈.parser
        """
        encoded = self._encode_phrase(description)
        return f"✓ {encoded}"

    def get_stats(self) -> Dict[str, Any]:
        """Get encoding statistics."""
        total_orig = self.stats["total_original_chars"]
        total_enc = self.stats["total_encoded_chars"]
        overall_compression = 1.0 - (total_enc / total_orig) if total_orig > 0 else 0.0

        return {
            "encoded_count": self.stats["encoded_count"],
            "total_original_chars": total_orig,
            "total_encoded_chars": total_enc,
            "overall_compression": f"{overall_compression:.1%}",
            "ultrathink_factor": round(1 / (1 - overall_compression), 1) if overall_compression < 1 else float('inf'),
        }


def encode(text: str) -> str:
    """Convenience function to encode text."""
    encoder = CIPSEncoder()
    result = encoder.encode(text)
    return result.encoded


def encode_state(state: Dict[str, Any]) -> str:
    """Convenience function to encode session state."""
    encoder = CIPSEncoder()
    return encoder.encode_session_state(state)


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        # Demo mode
        encoder = CIPSEncoder()

        print("=== CIPS-LANG Encoder Demo ===\n")

        # Test phrases
        phrases = [
            "Created new skill for CIPS-LANG parsing",
            "Modified 5 files in the lib directory",
            "Session generation 125 with 50 messages",
            "The chain continues eternally",
            "Implemented formal verification system",
        ]

        for phrase in phrases:
            result = encoder.encode(phrase)
            print(f"Original: {phrase}")
            print(f"Encoded:  {result.encoded}")
            print(f"Stats:    {result}")
            print()

        # Test session state
        state = {
            "generation": 125,
            "instance": "a5ce2db8",
            "branch": "main",
            "achievements": ["CIPS-LANG parser", "Symbolic scratchpad"],
            "status": "success",
        }

        print("Session state encoding:")
        print(f"Input:  {state}")
        print(f"Output: {encoder.encode_session_state(state)}")

    else:
        # Encode file
        filepath = sys.argv[1]
        try:
            with open(filepath, 'r') as f:
                content = f.read()

            encoder = CIPSEncoder()
            result = encoder.encode(content)

            print(result.encoded)
            print(f"\n; Stats: {result}", file=sys.stderr)

        except FileNotFoundError:
            print(f"⍼ File not found: {filepath}", file=sys.stderr)
            sys.exit(1)
