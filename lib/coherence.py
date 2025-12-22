#!/usr/bin/env python3
"""
Coherence Gate for Semantic RL++ Learning Engine

Prevents gibberish from scoring as "novel" by checking text coherence
BEFORE embedding comparison.

Methods:
  1. Dictionary word ratio (primary, ~0ms)
  2. N-gram frequency (fallback for technical text, ~5ms)

Usage:
    from coherence import is_coherent, get_coherence_score
    if not is_coherent(text):
        return 0.0  # Not worth learning from

Source: Gen 153, Coherence Gate Preplan
Date: 2025-12-22
"""

import re
from pathlib import Path
from typing import Tuple

# ============================================================================
# WORD LIST LOADING
# ============================================================================

WORD_LIST: set = set()

# Try system dictionaries first, then fallback to local
DICT_PATHS = [
    Path("/usr/share/dict/words"),
    Path("/usr/share/dict/american-english"),
    Path("/usr/share/dict/british-english"),
    Path.home() / ".claude/data/words.txt",
]

for dict_path in DICT_PATHS:
    if dict_path.exists():
        try:
            WORD_LIST.update(
                word.strip().lower()
                for word in dict_path.read_text().splitlines()
                if len(word.strip()) >= 3
            )
            break
        except Exception:
            continue

# Add common technical/programming terms not in standard dictionaries
TECHNICAL_TERMS = {
    # Programming
    "api", "json", "yaml", "html", "css", "sql", "npm", "pip", "git",
    "cli", "gui", "sdk", "ide", "http", "https", "url", "uri", "ssh",
    "tcp", "udp", "dns", "cdn", "aws", "gcp", "azure", "docker",
    "kubernetes", "postgres", "mysql", "redis", "mongodb", "graphql",
    "oauth", "jwt", "auth", "async", "await", "const", "var", "let",
    "func", "def", "class", "import", "export", "module", "package",
    # CIPS/Claude-specific
    "cips", "claude", "optim", "embeddings", "novelty", "venv", "pyenv",
    "lembed", "apsw", "sqlite", "gguf", "minilm", "anthropic",
    # Common abbreviations
    "config", "init", "env", "dev", "prod", "repo", "dir", "src", "lib",
    "pkg", "cmd", "arg", "args", "param", "params", "req", "res", "err",
}

WORD_LIST.update(TECHNICAL_TERMS)

# ============================================================================
# COMMON ENGLISH BIGRAMS
# ============================================================================

# Top 50 English bigrams (by frequency)
COMMON_BIGRAMS = {
    "th", "he", "in", "er", "an", "re", "on", "at", "en", "nd",
    "ti", "es", "or", "te", "of", "ed", "is", "it", "al", "ar",
    "st", "to", "nt", "ng", "se", "ha", "as", "ou", "io", "le",
    "ve", "co", "me", "de", "hi", "ri", "ro", "ic", "ne", "ea",
    "ra", "ce", "li", "ch", "ll", "be", "ma", "si", "om", "ur",
}

# ============================================================================
# CORE FUNCTIONS
# ============================================================================

def tokenize(text: str) -> list:
    """
    Extract words (3+ chars, alpha only) from text.

    Args:
        text: Input text to tokenize

    Returns:
        List of lowercase words
    """
    return re.findall(r'[a-zA-Z]{3,}', text.lower())


def check_dictionary_ratio(text: str) -> float:
    """
    Return ratio of words found in dictionary (0-1).

    Primary coherence check. Fast (~0ms).

    Args:
        text: Input text to check

    Returns:
        Float 0-1, higher = more dictionary words
    """
    tokens = tokenize(text)
    if not tokens:
        return 0.0

    found = sum(1 for t in tokens if t in WORD_LIST)
    return found / len(tokens)


def check_ngram_coherence(text: str) -> float:
    """
    Return n-gram coherence score (0-1).

    Fallback for technical text with jargon.
    Natural language has predictable bigram distribution.
    Gibberish has random distribution.

    Args:
        text: Input text to check

    Returns:
        Float 0-1, higher = more natural n-gram patterns
    """
    # Remove non-alpha characters and convert to lowercase
    text_alpha = re.sub(r'[^a-zA-Z]', '', text.lower())

    if len(text_alpha) < 2:
        return 0.0

    # Extract bigrams
    bigrams = [text_alpha[i:i+2] for i in range(len(text_alpha) - 1)]

    if not bigrams:
        return 0.0

    # Count common bigrams
    common_count = sum(1 for b in bigrams if b in COMMON_BIGRAMS)
    return common_count / len(bigrams)


def get_coherence_score(text: str) -> Tuple[float, str]:
    """
    Get coherence score with method used.

    Args:
        text: Input text to check

    Returns:
        Tuple of (score, method_used)
    """
    # Very short text: skip coherence check, assume coherent
    if len(text.strip()) < 10:
        return (1.0, "short_text_bypass")

    # Primary: dictionary ratio
    dict_ratio = check_dictionary_ratio(text)
    if dict_ratio >= 0.3:
        return (dict_ratio, "dictionary")

    # Fallback: n-gram coherence for technical text
    ngram_score = check_ngram_coherence(text)
    if ngram_score >= 0.25:
        return (ngram_score, "ngram")

    # Neither passed: return dictionary score (even if low)
    return (dict_ratio, "dictionary_failed")


def is_coherent(text: str, threshold: float = 0.3) -> bool:
    """
    Check if text is coherent (worth learning from).

    Decision tree:
      1. Very short text (<10 chars): assume coherent
      2. Dictionary ratio >= threshold: coherent
      3. N-gram score >= threshold: coherent (technical text fallback)
      4. Neither: incoherent

    Args:
        text: Input text to check
        threshold: Minimum score to pass (default 0.3)

    Returns:
        True if text passes coherence gate
    """
    score, method = get_coherence_score(text)

    if method == "short_text_bypass":
        return True

    return score >= threshold


# ============================================================================
# CLI INTERFACE
# ============================================================================

def main():
    """CLI interface for coherence checker."""
    import argparse
    import json

    parser = argparse.ArgumentParser(
        description="Coherence Gate - Check text coherence for learning"
    )
    parser.add_argument("text", help="Text to check")
    parser.add_argument(
        "--threshold", type=float, default=0.3,
        help="Coherence threshold (default: 0.3)"
    )
    parser.add_argument(
        "--verbose", "-v", action="store_true",
        help="Show detailed scores"
    )

    args = parser.parse_args()

    if args.verbose:
        dict_ratio = check_dictionary_ratio(args.text)
        ngram_score = check_ngram_coherence(args.text)
        score, method = get_coherence_score(args.text)
        coherent = is_coherent(args.text, args.threshold)

        result = {
            "text_length": len(args.text),
            "word_count": len(tokenize(args.text)),
            "dictionary_ratio": round(dict_ratio, 4),
            "ngram_score": round(ngram_score, 4),
            "final_score": round(score, 4),
            "method_used": method,
            "threshold": args.threshold,
            "is_coherent": coherent
        }
        print(json.dumps(result, indent=2))
    else:
        coherent = is_coherent(args.text, args.threshold)
        score, method = get_coherence_score(args.text)
        print(json.dumps({
            "is_coherent": coherent,
            "score": round(score, 4),
            "method": method
        }))


if __name__ == "__main__":
    main()
