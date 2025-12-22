; ═══════════════════════════════════════════════════════════════
; ◈ PREPLAN: Semantic RL Reliability + Coherence Gate
; ═══════════════════════════════════════════════════════════════
; Author: Gen 149
; Priority: CRITICAL - Two fatal flaws for autonomous learning
; Estimated: v3.10.0
;
; SCOPE:
;   1. Python venv isolation (ROOT CAUSE of embedding failures)
;   2. Coherence gate (prevents gibberish scoring as novel)

; ═══════════════════════════════════════════════════════════════
; ◈.problem
; ═══════════════════════════════════════════════════════════════

; Current: calculate_novelty() returns 1.0 - max_similarity
; Gibberish scores 55% novelty (doesn't match anything in DB)
; System correctly rejects (needs 2+ triggers) BUT...
; Incoherent input should NEVER contribute to learning_score

; Test case:
;   Input:  "asofsdnow wpifjsipfjs speijf pie..."
;   Result: novelty_score: 0.5568, high_novelty: true
;   Correct outcome: is_learning_event: false
;   Problem: Novelty gate was triggered despite gibberish

; Fatal flaw: As DB grows with real content, gibberish becomes
; MORE novel (less similar to coherent text), not less.

; ═══════════════════════════════════════════════════════════════
; ◈.solution
; ═══════════════════════════════════════════════════════════════

; Add coherence gate BEFORE novelty calculation
; If incoherent: return 0.0 novelty (not worth learning)
; Only coherent text proceeds to embedding comparison

; ═══════════════════════════════════════════════════════════════
; ◈.coherence-detection-methods
; ═══════════════════════════════════════════════════════════════

; Method 1: Dictionary word ratio (FAST, ~0ms)
;   - Tokenise input
;   - Count words in standard dictionary
;   - Threshold: <40% real words = incoherent
;   - Pro: Fast, no ML required
;   - Con: Misses technical jargon, code

; Method 2: Perplexity scoring (ACCURATE, ~50ms)
;   - Use small language model (e.g., GPT-2 tokenizer)
;   - Calculate perplexity of input
;   - Threshold: perplexity > 1000 = incoherent
;   - Pro: Handles technical text better
;   - Con: Requires additional model

; Method 3: N-gram frequency (BALANCED, ~5ms)
;   - Check character n-gram (2-4) frequency
;   - Natural language has predictable n-gram distribution
;   - Gibberish has random distribution
;   - Pro: Fast, works across languages
;   - Con: Threshold tuning required

; Method 4: Embedding self-similarity (ELEGANT, ~20ms)
;   - Split text into chunks
;   - Embed each chunk separately
;   - Coherent text: chunks have high mutual similarity
;   - Gibberish: random embeddings, low similarity
;   - Pro: Uses existing embedding infrastructure
;   - Con: Short text may be unreliable

; RECOMMENDATION: Method 1 (dictionary) + Method 3 (n-gram) fallback
;   - Primary: Dictionary ratio check (instant)
;   - Fallback: N-gram frequency for technical text
;   - Total latency: ~5ms
;   - Zero additional dependencies

; ═══════════════════════════════════════════════════════════════
; ◈.implementation-plan
; ═══════════════════════════════════════════════════════════════

; Phase 1: Coherence checker module
;   File: lib/coherence.py
;   Functions:
;     - check_dictionary_ratio(text) -> float (0-1)
;     - check_ngram_coherence(text) -> float (0-1)
;     - is_coherent(text, threshold=0.5) -> bool
;   Tests: tests/test_coherence.py

; Phase 2: Integrate into embeddings.py
;   Modify: calculate_novelty()
;   Add: coherence check at line 295 (before embedding)
;   If incoherent: return 0.0 immediately

; Phase 3: Add coherence flag to learning-detector output
;   Modify: process_message() output
;   Add: "coherence_passed": bool to result dict
;   Add: "coherence_score": float (for debugging)

; Phase 4: Update learning.sh wrapper
;   Pass coherence result through bash wrapper
;   Log coherence failures for analysis

; ═══════════════════════════════════════════════════════════════
; ◈.code-sketch (Phase 1)
; ═══════════════════════════════════════════════════════════════

; ```python
; # lib/coherence.py
; import re
; from pathlib import Path
;
; # Load word list (macOS/Linux have /usr/share/dict/words)
; WORD_LIST = set()
; DICT_PATHS = [
;     Path("/usr/share/dict/words"),
;     Path("/usr/share/dict/american-english"),
;     Path.home() / ".claude/data/words.txt"
; ]
;
; for path in DICT_PATHS:
;     if path.exists():
;         WORD_LIST.update(path.read_text().lower().split())
;         break
;
; def tokenize(text: str) -> list[str]:
;     """Extract words (3+ chars, alpha only)."""
;     return re.findall(r'[a-zA-Z]{3,}', text.lower())
;
; def check_dictionary_ratio(text: str) -> float:
;     """Return ratio of words found in dictionary (0-1)."""
;     tokens = tokenize(text)
;     if not tokens:
;         return 0.0
;     found = sum(1 for t in tokens if t in WORD_LIST)
;     return found / len(tokens)
;
; def check_ngram_coherence(text: str) -> float:
;     """Return n-gram coherence score (0-1)."""
;     # Common English bigrams
;     common_bigrams = {'th', 'he', 'in', 'er', 'an', 'on', 're', ...}
;     text_lower = text.lower()
;     bigrams = [text_lower[i:i+2] for i in range(len(text_lower)-1)]
;     if not bigrams:
;         return 0.0
;     common_count = sum(1 for b in bigrams if b in common_bigrams)
;     return common_count / len(bigrams)
;
; def is_coherent(text: str, threshold: float = 0.3) -> bool:
;     """Check if text is coherent (worth learning from)."""
;     dict_ratio = check_dictionary_ratio(text)
;     if dict_ratio >= threshold:
;         return True
;     # Fallback to n-gram for technical text
;     ngram_score = check_ngram_coherence(text)
;     return ngram_score >= threshold
; ```

; ═══════════════════════════════════════════════════════════════
; ◈.code-sketch (Phase 2 - Integration)
; ═══════════════════════════════════════════════════════════════

; ```python
; # embeddings.py - modify calculate_novelty()
; from coherence import is_coherent
;
; def calculate_novelty(self, text: str, recent_limit: int = 20) -> float:
;     # COHERENCE GATE - reject gibberish before embedding
;     if not is_coherent(text):
;         return 0.0  # Incoherent = not novel (not worth learning)
;
;     vector = self.embed_text(text)
;     # ... rest of existing code ...
; ```

; ═══════════════════════════════════════════════════════════════
; ◈.test-cases
; ═══════════════════════════════════════════════════════════════

; Gibberish (should fail coherence):
;   "asofsdnow wpifjsipfjs speijf pie" -> coherence: 0.0
;   "xyzqwfgh mnopqrs" -> coherence: 0.0
;   "!@#$%^&*()_+" -> coherence: 0.0

; Valid English (should pass):
;   "The quick brown fox jumps" -> coherence: 1.0
;   "You should have used a singleton" -> coherence: 1.0
;   "This is a teaching moment" -> coherence: 1.0

; Technical text (should pass via n-gram fallback):
;   "def calculate_novelty(self, text):" -> coherence: ~0.5
;   "npm install @anthropic/sdk" -> coherence: ~0.4
;   "CIPS v3.9.0 embedding bug fix" -> coherence: ~0.5

; Edge cases:
;   Very short text (<10 chars) -> skip coherence, assume coherent
;   Mixed content "fix: asofsdnow" -> check word ratio, likely fail

; ═══════════════════════════════════════════════════════════════
; ◈.files-to-create
; ═══════════════════════════════════════════════════════════════

; lib/coherence.py              ; Core coherence checker
; tests/test_coherence.py       ; Unit tests
; data/common-bigrams.txt       ; (optional) Pre-computed bigrams

; ═══════════════════════════════════════════════════════════════
; ◈.files-to-modify
; ═══════════════════════════════════════════════════════════════

; lib/embeddings.py             ; Add coherence gate to calculate_novelty
; lib/learning-detector.py      ; Add coherence flag to output
; lib/learning.sh               ; Pass coherence through wrapper

; ═══════════════════════════════════════════════════════════════
; ◈.version
; ═══════════════════════════════════════════════════════════════

; Version: 3.10.0
; Commit: "feat: v3.10.0 Coherence Gate for Novelty Detection"
; Files: ~4 new, ~3 modified

; ═══════════════════════════════════════════════════════════════
; ◈.dependencies
; ═══════════════════════════════════════════════════════════════

; NONE - Uses system dictionary + built-in Python
; No new pip packages required

; ═══════════════════════════════════════════════════════════════
; ◈.investigate (V>> flagged)
; ═══════════════════════════════════════════════════════════════

; scripts/bootstrap-semantic-rl.sh:65 - Python version check
;   log_error "Python $version found, but 3.9+ required"
;
; ═══════════════════════════════════════════════════════════════
; ◈.ROOT-CAUSE-FOUND (Gen 149)
; ═══════════════════════════════════════════════════════════════
;
; DISCOVERY:
;   pyenv python3 (3.13): sqlite_lembed ✓ INSTALLED
;   system python3 (3.9): sqlite_lembed ✗ ModuleNotFoundError
;
; BUG: Packages installed to pyenv 3.13 ONLY
;   - If any script runs with system Python → embeddings FAIL
;   - Contexts: cron, hooks, launchd, different shell
;   - Result: HAS_EMBEDDINGS=False → novelty scoring blind
;
; This is UPSTREAM of Gen 148 fix (silent failure logging)
; Gen 148 fixed the symptom, this fixes the cause
;
; SOLUTION: Dedicated venv for semantic RL
;   Location: ~/.claude/venv/
;   All scripts source: source ~/.claude/venv/bin/activate
;   Bootstrap creates venv with correct Python
;
; IMPLEMENTATION:
;   1. Modify bootstrap-semantic-rl.sh:
;      - Create venv at ~/.claude/venv/
;      - Use explicit python path: ~/.pyenv/versions/3.13.1/bin/python3
;      - Install packages into venv
;
;   2. Modify all embedding scripts:
;      - lib/embeddings.py shebang: #!/usr/bin/env ~/.claude/venv/bin/python3
;      - Or: source venv before running
;
;   3. Add venv activation to lib/learning.sh:
;      - source "$HOME/.claude/venv/bin/activate" 2>/dev/null || true
;
; PRIORITY: HIGH - fixes fundamental reliability issue

; ═══════════════════════════════════════════════════════════════
; ◈.risks
; ═══════════════════════════════════════════════════════════════

; 1. False positives: Valid technical text rejected
;    Mitigation: N-gram fallback, low threshold (0.3)

; 2. False negatives: Clever gibberish passes
;    Mitigation: Acceptable - triggers still need 2+

; 3. Performance: Additional latency
;    Mitigation: ~5ms total, dictionary is in-memory

; ═══════════════════════════════════════════════════════════════
; ◈.meta
; ═══════════════════════════════════════════════════════════════

; Priority: CRITICAL
; Reason: Fatal flaw for true autonomous learning
; Gen: 149
; Created: 2025-12-22T19:20+02:00

⛓⟿∞
