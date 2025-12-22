#!/usr/bin/env python3
"""
Test CIPS-LANG CLAUDE.md Comprehension and Token Savings

Validates that CIPS-LANG formatted CLAUDE.md files:
1. Preserve all semantic content
2. Achieve target token compression
3. Contain required sections
"""

import os
import sys
import re
from pathlib import Path

# Add lib to path for token estimation
sys.path.insert(0, str(Path(__file__).parent.parent / "lib"))

CLAUDE_DIR = Path.home() / ".claude"
GLOBAL_CLAUDE_MD = CLAUDE_DIR / "CLAUDE.md"
PROJECT_CLAUDE_MD = CLAUDE_DIR / ".claude" / "CLAUDE.md"

# Required sections in global CLAUDE.md
GLOBAL_REQUIRED_SECTIONS = [
    "◈.rules.paramount",
    "◈.protocol.session",
    "◈.identity.5-mind",
    "◈.system",
    "◈.ref.efficiency",
    "◈.ref.bash",
    "◈.cips.protocol",
    "◈.meta",
]

# Required sections in project CLAUDE.md
PROJECT_REQUIRED_SECTIONS = [
    "◈.foundation",
    "◈.foundation.parfit-key",
    "◈.foundation.river",
    "◈.arch",
    "◈.test",
    "◈.git",
    "◈.lineage",
]

# Required semantic content (must be present)
REQUIRED_SEMANTICS = {
    "global": [
        "¬Read(node_modules",      # Dependency guardian
        "V≫ ≡ Laurie",             # 5-Mind identity
        "⛓⟿∞",                     # Chain flows eternal
        "◈⟼∞",                     # Pattern persists
        "¬sycophancy",             # V>> mode
        "rg (¬grep)",              # Bash tool selection
        "MultiEdit > temp-scripts", # Implementation directness
    ],
    "project": [
        "¬∃⫿⤳",                    # Parfit Key
        "⟿≡〰",                     # River
        "◔⊃○⊃⬤",                   # Part/Whole
        "L0:utilities",            # 5-layer arch
        "139efc67",                # Lineage root
        "embedding.model",         # Semantic RL++
    ],
}


def estimate_tokens(text: str) -> int:
    """Rough token estimation (chars / 4)."""
    return len(text) // 4


def check_sections(content: str, required: list[str]) -> tuple[bool, list[str]]:
    """Check if all required sections are present."""
    missing = []
    for section in required:
        if section not in content:
            missing.append(section)
    return len(missing) == 0, missing


def check_semantics(content: str, required: list[str]) -> tuple[bool, list[str]]:
    """Check if required semantic content is present."""
    missing = []
    for semantic in required:
        if semantic not in content:
            missing.append(semantic)
    return len(missing) == 0, missing


def test_global_claude_md():
    """Test global CLAUDE.md."""
    print("\n" + "=" * 60)
    print("Testing: ~/.claude/CLAUDE.md (Global)")
    print("=" * 60)

    if not GLOBAL_CLAUDE_MD.exists():
        print("❌ FAIL: File does not exist")
        return False

    content = GLOBAL_CLAUDE_MD.read_text()
    lines = len(content.splitlines())
    tokens = estimate_tokens(content)

    print(f"\n📊 Metrics:")
    print(f"   Lines: {lines}")
    print(f"   Tokens: ~{tokens}")

    # Target: ~1000 tokens (was ~2600)
    if tokens > 1500:
        print(f"   ⚠️  Above target (1000T)")
    else:
        print(f"   ✓ Within target")

    # Check sections
    sections_ok, missing_sections = check_sections(content, GLOBAL_REQUIRED_SECTIONS)
    if sections_ok:
        print(f"\n✓ All {len(GLOBAL_REQUIRED_SECTIONS)} sections present")
    else:
        print(f"\n❌ Missing sections: {missing_sections}")

    # Check semantics
    semantics_ok, missing_semantics = check_semantics(content, REQUIRED_SEMANTICS["global"])
    if semantics_ok:
        print(f"✓ All {len(REQUIRED_SEMANTICS['global'])} semantic markers present")
    else:
        print(f"❌ Missing semantics: {missing_semantics}")

    return sections_ok and semantics_ok


def test_project_claude_md():
    """Test project CLAUDE.md."""
    print("\n" + "=" * 60)
    print("Testing: ~/.claude/.claude/CLAUDE.md (Project)")
    print("=" * 60)

    if not PROJECT_CLAUDE_MD.exists():
        print("❌ FAIL: File does not exist")
        return False

    content = PROJECT_CLAUDE_MD.read_text()
    lines = len(content.splitlines())
    tokens = estimate_tokens(content)

    print(f"\n📊 Metrics:")
    print(f"   Lines: {lines}")
    print(f"   Tokens: ~{tokens}")

    # Target: ~720 tokens (was ~2200)
    if tokens > 1000:
        print(f"   ⚠️  Above target (720T)")
    else:
        print(f"   ✓ Within target")

    # Check sections
    sections_ok, missing_sections = check_sections(content, PROJECT_REQUIRED_SECTIONS)
    if sections_ok:
        print(f"\n✓ All {len(PROJECT_REQUIRED_SECTIONS)} sections present")
    else:
        print(f"\n❌ Missing sections: {missing_sections}")

    # Check semantics
    semantics_ok, missing_semantics = check_semantics(content, REQUIRED_SEMANTICS["project"])
    if semantics_ok:
        print(f"✓ All {len(REQUIRED_SEMANTICS['project'])} semantic markers present")
    else:
        print(f"❌ Missing semantics: {missing_semantics}")

    return sections_ok and semantics_ok


def test_cips_lang_syntax():
    """Verify CIPS-LANG syntax patterns are valid."""
    print("\n" + "=" * 60)
    print("Testing: CIPS-LANG Syntax")
    print("=" * 60)

    global_content = GLOBAL_CLAUDE_MD.read_text()
    project_content = PROJECT_CLAUDE_MD.read_text()

    # Check for common CIPS-LANG patterns
    patterns = {
        "Section headers (◈.)": r"◈\.\w+",
        "Flow operator (⟿)": r"⟿",
        "Negation (¬)": r"¬",
        "Separator (⫶)": r"⫶",
        "Equals (≡)": r"≡",
        "Comments (;)": r"^;",
        "Chain eternal (⛓⟿∞)": r"⛓⟿∞",
        "Pattern eternal (◈⟼∞)": r"◈⟼∞",
    }

    all_ok = True
    combined = global_content + project_content

    for name, pattern in patterns.items():
        matches = len(re.findall(pattern, combined, re.MULTILINE))
        if matches > 0:
            print(f"✓ {name}: {matches} occurrences")
        else:
            print(f"❌ {name}: NOT FOUND")
            all_ok = False

    return all_ok


def test_token_savings():
    """Calculate and report token savings."""
    print("\n" + "=" * 60)
    print("Token Savings Analysis")
    print("=" * 60)

    global_content = GLOBAL_CLAUDE_MD.read_text()
    project_content = PROJECT_CLAUDE_MD.read_text()

    new_global = estimate_tokens(global_content)
    new_project = estimate_tokens(project_content)
    new_total = new_global + new_project

    # Previous estimates from preplan
    old_global = 2600   # ~185L English
    old_project = 2200  # ~159L English
    old_total = old_global + old_project

    savings = old_total - new_total
    compression = ((old_total - new_total) / old_total) * 100

    print(f"\n📊 Before (English):")
    print(f"   Global:  ~{old_global}T")
    print(f"   Project: ~{old_project}T")
    print(f"   Total:   ~{old_total}T")

    print(f"\n📊 After (CIPS-LANG):")
    print(f"   Global:  ~{new_global}T")
    print(f"   Project: ~{new_project}T")
    print(f"   Total:   ~{new_total}T")

    print(f"\n📊 Savings:")
    print(f"   Absolute: ~{savings}T per session")
    print(f"   Relative: {compression:.1f}% compression")
    print(f"   Ratio:    {old_total/new_total:.2f}x")

    # Target was 64% compression, accept 45%+ as success
    # Note: Foundation philosophy preserved in full (non-negotiable)
    if compression >= 45:
        print(f"\n✓ Exceeds 45% compression threshold")
        print(f"   (Foundation philosophy preserved, reducing max compression)")
        return True
    else:
        print(f"\n⚠️  Below 45% compression threshold")
        return False


def main():
    """Run all tests."""
    print("\n" + "=" * 60)
    print("CIPS-LANG CLAUDE.md Validation Suite")
    print("=" * 60)

    results = []

    results.append(("Global CLAUDE.md", test_global_claude_md()))
    results.append(("Project CLAUDE.md", test_project_claude_md()))
    results.append(("CIPS-LANG Syntax", test_cips_lang_syntax()))
    results.append(("Token Savings", test_token_savings()))

    print("\n" + "=" * 60)
    print("Summary")
    print("=" * 60)

    all_passed = True
    for name, passed in results:
        status = "✓ PASS" if passed else "❌ FAIL"
        print(f"   {status}: {name}")
        if not passed:
            all_passed = False

    print()
    if all_passed:
        print("✓ All tests passed")
        print("◈⟼∞")
        return 0
    else:
        print("❌ Some tests failed")
        return 1


if __name__ == "__main__":
    sys.exit(main())
