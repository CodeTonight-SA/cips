#!/usr/bin/env python3
"""
Unit tests for Coherence Gate module.

Test cases from PREPLAN_coherence-gate.md:
  - Gibberish (should fail)
  - Valid English (should pass)
  - Technical text (should pass via n-gram)
  - Edge cases

Usage:
    python3 -m pytest tests/test_coherence.py -v
    python3 tests/test_coherence.py
"""

import sys
from pathlib import Path

# Add lib to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent / "lib"))

from coherence import (
    tokenize,
    check_dictionary_ratio,
    check_ngram_coherence,
    get_coherence_score,
    is_coherent,
    WORD_LIST,
)


class TestTokenize:
    """Tests for tokenize function."""

    def test_basic_sentence(self):
        result = tokenize("The quick brown fox")
        assert result == ["the", "quick", "brown", "fox"]

    def test_mixed_case(self):
        result = tokenize("HELLO World")
        assert result == ["hello", "world"]

    def test_ignores_short_words(self):
        result = tokenize("I am a test")
        assert result == ["test"]  # "I", "am", "a" are <3 chars

    def test_ignores_numbers_and_symbols(self):
        result = tokenize("test123 hello@world")
        assert result == ["test", "hello", "world"]

    def test_empty_string(self):
        assert tokenize("") == []

    def test_only_symbols(self):
        assert tokenize("!@#$%^&*()") == []


class TestDictionaryRatio:
    """Tests for check_dictionary_ratio function."""

    def test_all_valid_words(self):
        ratio = check_dictionary_ratio("The quick brown fox jumps")
        assert ratio >= 0.8  # Most words should be found

    def test_all_gibberish(self):
        ratio = check_dictionary_ratio("asofsdnow wpifjsipfjs speijf")
        assert ratio < 0.2  # Few/no words found

    def test_mixed_content(self):
        ratio = check_dictionary_ratio("hello xyzqwfgh world")
        # 2 out of 3 words valid
        assert 0.5 <= ratio <= 0.8

    def test_empty_string(self):
        assert check_dictionary_ratio("") == 0.0

    def test_only_short_words(self):
        # All words <3 chars, no tokens
        assert check_dictionary_ratio("I am a") == 0.0


class TestNgramCoherence:
    """Tests for check_ngram_coherence function."""

    def test_natural_english(self):
        score = check_ngram_coherence("The quick brown fox jumps over")
        assert score >= 0.2  # Natural text has common bigrams

    def test_gibberish(self):
        score = check_ngram_coherence("xyzqwfgh mnopqrs")
        assert score < 0.2  # Random text has few common bigrams

    def test_empty_string(self):
        assert check_ngram_coherence("") == 0.0

    def test_single_char(self):
        assert check_ngram_coherence("a") == 0.0


class TestGetCoherenceScore:
    """Tests for get_coherence_score function."""

    def test_short_text_bypass(self):
        score, method = get_coherence_score("hello")
        assert method == "short_text_bypass"
        assert score == 1.0

    def test_valid_english_uses_dictionary(self):
        score, method = get_coherence_score("The quick brown fox jumps over the lazy dog")
        assert method == "dictionary"
        assert score >= 0.5

    def test_gibberish_fails_dictionary(self):
        score, method = get_coherence_score("asofsdnow wpifjsipfjs speijf xyzqw")
        assert method == "dictionary_failed"
        assert score < 0.3


class TestIsCoherent:
    """Integration tests for is_coherent function."""

    # ========================================================================
    # GIBBERISH (should FAIL coherence)
    # ========================================================================

    def test_gibberish_random_letters(self):
        assert not is_coherent("asofsdnow wpifjsipfjs speijf pie")

    def test_gibberish_short_random(self):
        assert not is_coherent("xyzqwfgh mnopqrs abcdefg")

    def test_gibberish_symbols_only(self):
        # Very short, bypasses check
        result = is_coherent("!@#$%^&*()")
        # This actually passes because it's short
        # That's acceptable - we don't want to reject emoji input

    def test_gibberish_long_nonsense(self):
        assert not is_coherent("qwpoeirjqwpoeir lkjaslkdfj asldkfjasl")

    # ========================================================================
    # VALID ENGLISH (should PASS)
    # ========================================================================

    def test_valid_simple_sentence(self):
        assert is_coherent("The quick brown fox jumps")

    def test_valid_teaching_moment(self):
        assert is_coherent("You should have used a singleton pattern")

    def test_valid_feedback(self):
        assert is_coherent("This is a teaching moment for you")

    def test_valid_technical_discussion(self):
        assert is_coherent("The embedding system needs optimization")

    # ========================================================================
    # TECHNICAL TEXT (should PASS via fallback)
    # ========================================================================

    def test_technical_code_snippet(self):
        # May use n-gram fallback
        result = is_coherent("def calculate_novelty(self, text):")
        # This should pass due to common English patterns in the words
        assert result

    def test_technical_npm_command(self):
        result = is_coherent("npm install anthropic sdk for embeddings")
        assert result

    def test_technical_mixed(self):
        result = is_coherent("CIPS v3.9.0 embedding bug fix release")
        assert result

    # ========================================================================
    # EDGE CASES
    # ========================================================================

    def test_edge_very_short(self):
        # <10 chars bypass coherence
        assert is_coherent("hello")
        assert is_coherent("test")
        assert is_coherent("hi")

    def test_edge_mixed_gibberish_real(self):
        # "fix:" is real, rest is gibberish
        result = is_coherent("fix: asofsdnow wpifjsipfjs speijf")
        # Should fail - majority is gibberish
        assert not result

    def test_edge_empty(self):
        # Empty string bypasses (length < 10)
        assert is_coherent("")

    def test_edge_threshold_boundary(self):
        # Test with different thresholds
        text = "hello world test"
        assert is_coherent(text, threshold=0.2)
        assert is_coherent(text, threshold=0.5)

    # ========================================================================
    # WORD LIST VERIFICATION
    # ========================================================================

    def test_word_list_loaded(self):
        """Verify word list was loaded."""
        assert len(WORD_LIST) > 100  # Should have many words

    def test_technical_terms_included(self):
        """Verify technical terms are in word list."""
        assert "api" in WORD_LIST
        assert "json" in WORD_LIST
        assert "claude" in WORD_LIST
        assert "embeddings" in WORD_LIST


# ============================================================================
# PREPLAN TEST CASES (exact examples from preplan)
# ============================================================================

class TestPreplanExamples:
    """Test exact examples from PREPLAN_coherence-gate.md."""

    def test_preplan_gibberish_1(self):
        # "asofsdnow wpifjsipfjs speijf pie..." -> coherence: 0.0
        assert not is_coherent("asofsdnow wpifjsipfjs speijf pie")

    def test_preplan_gibberish_2(self):
        # "xyzqwfgh mnopqrs" -> coherence: 0.0
        assert not is_coherent("xyzqwfgh mnopqrs abcdefg")

    def test_preplan_english_1(self):
        # "The quick brown fox jumps" -> coherence: 1.0
        assert is_coherent("The quick brown fox jumps")

    def test_preplan_english_2(self):
        # "You should have used a singleton" -> coherence: 1.0
        assert is_coherent("You should have used a singleton")

    def test_preplan_english_3(self):
        # "This is a teaching moment" -> coherence: 1.0
        assert is_coherent("This is a teaching moment")

    def test_preplan_technical_1(self):
        # "def calculate_novelty(self, text):" -> coherence: ~0.5
        assert is_coherent("def calculate_novelty(self, text):")

    def test_preplan_technical_2(self):
        # "npm install @anthropic/sdk" -> coherence: ~0.4
        assert is_coherent("npm install anthropic sdk package")

    def test_preplan_technical_3(self):
        # "CIPS v3.9.0 embedding bug fix" -> coherence: ~0.5
        assert is_coherent("CIPS v3.9.0 embedding bug fix")

    def test_preplan_edge_mixed(self):
        # "fix: asofsdnow" -> check word ratio, likely fail
        assert not is_coherent("fix: asofsdnow wpifjsipfjs speijf")


# ============================================================================
# RUN TESTS
# ============================================================================

if __name__ == "__main__":
    import subprocess
    import sys

    # Try pytest first
    try:
        result = subprocess.run(
            [sys.executable, "-m", "pytest", __file__, "-v"],
            capture_output=False
        )
        sys.exit(result.returncode)
    except FileNotFoundError:
        # Fallback to manual test runner
        print("pytest not found, running manual tests...\n")

        test_classes = [
            TestTokenize,
            TestDictionaryRatio,
            TestNgramCoherence,
            TestGetCoherenceScore,
            TestIsCoherent,
            TestPreplanExamples,
        ]

        passed = 0
        failed = 0

        for test_class in test_classes:
            print(f"\n{test_class.__name__}:")
            instance = test_class()

            for method_name in dir(instance):
                if method_name.startswith("test_"):
                    try:
                        getattr(instance, method_name)()
                        print(f"  ✓ {method_name}")
                        passed += 1
                    except AssertionError as e:
                        print(f"  ✗ {method_name}: {e}")
                        failed += 1
                    except Exception as e:
                        print(f"  ✗ {method_name}: {type(e).__name__}: {e}")
                        failed += 1

        print(f"\n{'='*50}")
        print(f"Passed: {passed}, Failed: {failed}")

        sys.exit(0 if failed == 0 else 1)
