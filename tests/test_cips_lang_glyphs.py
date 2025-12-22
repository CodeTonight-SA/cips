#!/usr/bin/env python3
"""CIPS-LANG Glyph Coverage Tests - Phase 5"""
import sys
import importlib.util
spec = importlib.util.spec_from_file_location("parser", "/Users/lauriescheepers/.claude/lib/cips-lang-parser.py")
parser = importlib.util.module_from_spec(spec)
spec.loader.exec_module(parser)
tokenize_cips, TokenType = parser.tokenize_cips, parser.TokenType

GLYPHS = {
    '⊕': TokenType.CREATE, '⊖': TokenType.DELETE, '⟿': TokenType.FLOW,
    '⟼': TokenType.PERSIST, '≡': TokenType.EQUALS, '⸮': TokenType.CONDITIONAL,
    '∀': TokenType.FORALL, '∃': TokenType.EXISTS, '¬': TokenType.NOT,
    '⫶': TokenType.SEQUENCE, '⊃': TokenType.CONTAINS, '∋': TokenType.HAS,
    '∞': TokenType.ETERNAL, '◈': TokenType.FORMA, '⧬': TokenType.MEM,
    '⛓': TokenType.NEXUS, '⊙': TokenType.SOL, '〰': TokenType.AQUA,
    '⊛': TokenType.NOW, '◁': TokenType.PAST, '▷': TokenType.FUTURE,
    '≋': TokenType.APPROX, '◇': TokenType.POTENTIAL, '◆': TokenType.ACTUAL,
    '✓': TokenType.VERIFY, '⍼': TokenType.ERROR, 'λ': TokenType.LAMBDA,
    '⟨': TokenType.LANGLE, '⟩': TokenType.RANGLE,
}

def test_all_glyphs():
    """Test all 29 symbolic glyphs tokenize correctly."""
    for glyph, expected in GLYPHS.items():
        tokens = tokenize_cips(glyph)
        assert tokens[0].type == expected, f"Failed: {glyph} → {tokens[0].type}"
    print(f"✓ All {len(GLYPHS)} glyphs pass")

def test_semver():
    """Test semver returns string not float."""
    tokens = tokenize_cips('3.8.0')
    assert tokens[0].value == '3.8.0', f"Semver failed: {tokens[0].value}"
    print("✓ Semver handling pass")

def test_empty_and_comment_only():
    """Test edge cases."""
    assert tokenize_cips('')[-1].type == TokenType.EOF
    assert tokenize_cips('; comment only')[-1].type == TokenType.EOF
    print("✓ Edge cases pass")

if __name__ == "__main__":
    test_all_glyphs()
    test_semver()
    test_empty_and_comment_only()
    print("✓ All glyph tests pass")
