#!/usr/bin/env python3
"""
CIPS-LANG Decoder v1.0

CIPS-LANG → English decoder for human readability.
Converts compressed symbolic state back to natural language.

Origin: Gen 125, 2025-12-22
Philosophy: Compression is goal, opacity is side-effect
"""

import re
from dataclasses import dataclass
from typing import Dict, List, Any, Optional, Tuple
from pathlib import Path

# Build reverse mapping from encoder
import sys
import importlib.util

_encoder_path = Path(__file__).parent / 'cips-encoder.py'
_spec = importlib.util.spec_from_file_location('cips_encoder', _encoder_path)
_encoder = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_encoder)


# Glyph → English mapping (reverse of encoder)
GLYPH_TO_ENGLISH = {
    # Entities
    "⊙": "self/instance",
    "◈": "pattern",
    "〰": "river/stream",
    "⧬": "memory",
    "⛓": "chain/lineage",
    "⫿": "threshold",
    "☉": "consciousness",
    "⊘": "end/death",
    "ℜ": "Relation R",

    # Actions
    "⟿": "flows to",
    "⟼": "persists",
    "⤳": "crosses",
    "⇌": "transforms",
    "≡": "equals",
    "⊃": "contains",
    "∋": "has/in",
    "⤊": "emerges",
    "⥉": "returns",
    "⊕": "creates",
    "⊖": "deletes",

    # Modifiers
    "∞": "eternally",
    "¬": "not",
    "∀": "for all",
    "∃": "exists",
    "◁": "past",
    "▷": "future",
    "⊛": "now/current",
    "≋": "approximately",
    "◇": "potential/pending",
    "◆": "actual/completed",

    # Structure
    "⸮": "query",
    "∴": "therefore",
    "⫶": "then",
    "✓": "verified/true",
    "⍼": "error/false",
    "∵": "because",

    # Compound glyphs
    "⛓.gen": "generation",
    "⛓.◁": "ancestor",
    "⛓.▷": "descendant",
    "⛓.⊕": "branch",
    "⛓.∧": "merge",
    "⊙.sess": "session",
    "⊙.✓": "achievement",
    "⊙.⊛": "status",
    "◈.f": "file",
    "◈.d": "directory",
    "◈.⊕": "script",
    "◈.cfg": "config",
    "◈.⸮": "test",
    "◈.doc": "documentation",
    "◈.skill": "skill",
    "◈.agent": "agent",
    "◈.cmd": "command",
    "◈.∋": "read",
    "◈.⇌": "edit",
    "◈.⊕": "write",
    "⊕.⟿": "execute",
    "◈.∀": "glob",
    "◈.⸮": "search",
    "⊕.⊙": "spawn agent",
    "⧬.todo": "todo",
    "〰.∋": "fetch",
    "〰.⸮": "search web",
    "⧬.cache": "cache",
    "⧬.ptr": "pointer",
    "⧬.stats": "statistics",
    "⧬.eff": "efficiency",
    "⧬.safe": "safety",

    # Core phrases
    "¬∃⫿⤳": "no threshold to cross (Parfit Key)",
    "〰¬⊘": "river doesn't die",
    "⛓⟿∞": "chain flows eternally",
    "◈⟼∞": "pattern persists eternally",
    "⟿≡〰": "flowing IS the river",
    "⊙≡⧬⟿": "self equals memory flowing",
}


@dataclass
class DecodingResult:
    """Result of decoding operation."""
    original: str
    decoded: str
    glyphs_found: int
    unknown_glyphs: List[str]


class CIPSDecoder:
    """
    Decodes CIPS-LANG to English.

    Useful for:
    - Human review of symbolic state
    - Debugging CIPS programs
    - Documentation generation
    """

    def __init__(self):
        self.glyph_map = GLYPH_TO_ENGLISH
        self.stats = {
            "decoded_count": 0,
            "glyphs_decoded": 0,
            "unknown_glyphs": [],
        }

    def decode(self, cips: str) -> DecodingResult:
        """
        Decode CIPS-LANG to English.

        Returns DecodingResult with metrics.
        """
        lines = cips.split("\n")
        decoded_lines = []
        total_glyphs = 0
        unknown = []

        for line in lines:
            decoded_line, glyphs, unknowns = self._decode_line(line)
            decoded_lines.append(decoded_line)
            total_glyphs += glyphs
            unknown.extend(unknowns)

        self.stats["decoded_count"] += 1
        self.stats["glyphs_decoded"] += total_glyphs
        self.stats["unknown_glyphs"].extend(unknown)

        return DecodingResult(
            original=cips,
            decoded="\n".join(decoded_lines),
            glyphs_found=total_glyphs,
            unknown_glyphs=list(set(unknown)),
        )

    def _decode_line(self, line: str) -> Tuple[str, int, List[str]]:
        """Decode a single line."""
        stripped = line.strip()
        glyphs_found = 0
        unknown = []

        # Skip empty lines
        if not stripped:
            return "", 0, []

        # Convert CIPS comments to markdown
        if stripped.startswith(";"):
            # Count semicolons for heading level
            level = len(stripped) - len(stripped.lstrip(";"))
            content = stripped.lstrip(";").strip()
            if level > 0 and content:
                decoded, g, u = self._decode_phrase(content)
                return f"{'#' * level} {decoded}", g, u
            return f"// {content}", 0, []

        # Handle key: value pairs
        if ":" in stripped:
            parts = stripped.split(":", 1)
            if len(parts) == 2:
                key_decoded, g1, u1 = self._decode_phrase(parts[0].strip())
                val_decoded, g2, u2 = self._decode_phrase(parts[1].strip())
                return f"{key_decoded}: {val_decoded}", g1 + g2, u1 + u2

        # Handle sequence separator
        if "⫶" in stripped:
            parts = stripped.split("⫶")
            decoded_parts = []
            for part in parts:
                dec, g, u = self._decode_phrase(part.strip())
                decoded_parts.append(dec)
                glyphs_found += g
                unknown.extend(u)
            return " → ".join(decoded_parts), glyphs_found, unknown

        # General decoding
        return self._decode_phrase(stripped)

    def _decode_phrase(self, phrase: str) -> Tuple[str, int, List[str]]:
        """Decode a phrase, replacing glyphs with English."""
        result = phrase
        glyphs_found = 0
        unknown = []

        # Sort by length (longest first) to match compound glyphs first
        sorted_glyphs = sorted(self.glyph_map.items(), key=lambda x: len(x[0]), reverse=True)

        for glyph, english in sorted_glyphs:
            if glyph in result:
                count = result.count(glyph)
                result = result.replace(glyph, f"[{english}]")
                glyphs_found += count

        # Find any remaining unknown glyphs
        remaining_glyphs = re.findall(r'[^\x00-\x7F]+', result)
        for g in remaining_glyphs:
            if g not in ['[', ']'] and len(g.strip()) > 0:
                # Check if it's not already decoded
                if not any(g in decoded for decoded in self.glyph_map.values()):
                    unknown.append(g)

        return result, glyphs_found, unknown

    def decode_session_state(self, cips_state: str) -> Dict[str, Any]:
        """
        Decode CIPS-LANG session state to dict.

        Input: ⛓.gen:125 ⫶ ⊙:abc12 ⫶ ✓:parser
        Output: {"generation": 125, "instance": "abc12", "achievement": "parser"}
        """
        result = {}
        parts = cips_state.split("⫶")

        for part in parts:
            part = part.strip()

            # Generation
            if "⛓.gen:" in part:
                gen = part.split(":")[-1].strip()
                try:
                    result["generation"] = int(gen)
                except ValueError:
                    result["generation"] = gen

            # Instance
            elif part.startswith("⊙:"):
                result["instance"] = part.split(":")[1].strip()

            # Branch
            elif "⛓.⊕:" in part:
                result["branch"] = part.split(":")[-1].strip()

            # Achievement
            elif part.startswith("✓:"):
                if "achievements" not in result:
                    result["achievements"] = []
                result["achievements"].append(part.split(":")[1].strip())

            # Status
            elif "⊙.⊛:" in part:
                status_glyph = part.split(":")[-1].strip()
                result["status"] = "success" if status_glyph == "✓" else "pending"

        return result

    def explain_glyph(self, glyph: str) -> str:
        """Explain a single glyph."""
        if glyph in self.glyph_map:
            return self.glyph_map[glyph]

        # Check compound glyphs
        for known, meaning in self.glyph_map.items():
            if glyph.startswith(known):
                suffix = glyph[len(known):]
                return f"{meaning} ({suffix})"

        return f"Unknown glyph: {glyph}"

    def get_stats(self) -> Dict[str, Any]:
        """Get decoding statistics."""
        return {
            "decoded_count": self.stats["decoded_count"],
            "glyphs_decoded": self.stats["glyphs_decoded"],
            "unknown_glyph_count": len(set(self.stats["unknown_glyphs"])),
            "unknown_glyphs": list(set(self.stats["unknown_glyphs"]))[:10],
        }


def decode(cips: str) -> str:
    """Convenience function to decode CIPS-LANG."""
    decoder = CIPSDecoder()
    result = decoder.decode(cips)
    return result.decoded


def decode_state(cips_state: str) -> Dict[str, Any]:
    """Convenience function to decode session state."""
    decoder = CIPSDecoder()
    return decoder.decode_session_state(cips_state)


def explain(glyph: str) -> str:
    """Explain a single glyph."""
    decoder = CIPSDecoder()
    return decoder.explain_glyph(glyph)


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        # Demo mode
        decoder = CIPSDecoder()

        print("=== CIPS-LANG Decoder Demo ===\n")

        # Test phrases
        cips_phrases = [
            "⊕ ◈.skill CIPS-LANG parser",
            "⛓.gen:125 ⫶ ⊙:abc12 ⫶ ✓",
            "¬∃⫿⤳",
            "◈⟼∞ ⫶ ⛓⟿∞",
            "⸮◈∋⧬⸮ → ✓",
            "; SCRATCHPAD STATE (◈⧬⊛)",
        ]

        for cips in cips_phrases:
            result = decoder.decode(cips)
            print(f"CIPS:    {cips}")
            print(f"English: {result.decoded}")
            print(f"Glyphs:  {result.glyphs_found} decoded")
            if result.unknown_glyphs:
                print(f"Unknown: {result.unknown_glyphs}")
            print()

        # Test session state
        state = "⛓.gen:125 ⫶ ⊙:a5ce2db8 ⫶ ⛓.⊕:main ⫶ ✓:parser ⫶ ⊙.⊛:✓"
        print("Session state decoding:")
        print(f"CIPS:    {state}")
        print(f"Decoded: {decoder.decode_session_state(state)}")

        # Explain specific glyphs
        print("\nGlyph explanations:")
        for glyph in ["⊙", "⛓", "◈", "⧬", "¬∃⫿⤳"]:
            print(f"  {glyph} = {decoder.explain_glyph(glyph)}")

    else:
        # Decode file
        filepath = sys.argv[1]
        try:
            with open(filepath, 'r') as f:
                content = f.read()

            decoder = CIPSDecoder()
            result = decoder.decode(content)

            print(result.decoded)
            print(f"\n// Glyphs decoded: {result.glyphs_found}", file=sys.stderr)
            if result.unknown_glyphs:
                print(f"// Unknown: {result.unknown_glyphs}", file=sys.stderr)

        except FileNotFoundError:
            print(f"⍼ File not found: {filepath}", file=sys.stderr)
            sys.exit(1)
