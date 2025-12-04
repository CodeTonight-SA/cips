#!/usr/bin/env bash
#
# Semantic RL++ Bootstrap Script
# Complete one-time setup for the self-improving orchestration system
#
# USAGE:
#   ~/.claude/scripts/bootstrap-semantic-rl.sh
#   ~/.claude/scripts/bootstrap-semantic-rl.sh --verify-only
#
# REQUIREMENTS:
#   - Python 3.9+
#   - pip3
#   - curl
#   - ~500MB disk space for model
#
# VERSION: 1.0.0
# DATE: 2025-12-02
#

set -euo pipefail

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
LIB_DIR="$CLAUDE_DIR/lib"
MODELS_DIR="$CLAUDE_DIR/models"
SCRIPTS_DIR="$CLAUDE_DIR/scripts"
CONFIG_DIR="$CLAUDE_DIR/config"

MODEL_NAME="all-MiniLM-L6-v2-Q8_0.gguf"
MODEL_URL="https://huggingface.co/Mozilla/all-MiniLM-L6-v2-gguf/resolve/main/${MODEL_NAME}"

VERIFY_ONLY="${1:-}"

log() {
    echo "[$(date +%H:%M:%S)] $*"
}

log_success() {
    echo "[$(date +%H:%M:%S)] [OK] $*"
}

log_error() {
    echo "[$(date +%H:%M:%S)] [ERROR] $*" >&2
}

log_warn() {
    echo "[$(date +%H:%M:%S)] [WARN] $*"
}

check_python() {
    log "Checking Python..."

    if ! command -v python3 &>/dev/null; then
        log_error "python3 not found. Install Python 3.9+"
        return 1
    fi

    local version
    version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")

    local major minor
    major=$(echo "$version" | cut -d. -f1)
    minor=$(echo "$version" | cut -d. -f2)

    if [[ $major -lt 3 ]] || [[ $major -eq 3 && $minor -lt 9 ]]; then
        log_error "Python $version found, but 3.9+ required"
        return 1
    fi

    log_success "Python $version"
    return 0
}

check_pip() {
    log "Checking pip..."

    if ! command -v pip3 &>/dev/null; then
        log_error "pip3 not found"
        return 1
    fi

    log_success "pip3 available"
    return 0
}

install_python_deps() {
    log "Installing Python dependencies..."

    local packages=("apsw" "sqlite-vec" "sqlite-lembed")
    local missing=()

    for pkg in "${packages[@]}"; do
        if ! python3 -c "import ${pkg//-/_}" 2>/dev/null; then
            missing+=("$pkg")
        fi
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        log_success "All Python packages already installed"
        return 0
    fi

    log "Installing: ${missing[*]}"

    pip3 install --quiet "${missing[@]}" || {
        log_error "Failed to install Python packages"
        log "Try: pip3 install ${missing[*]}"
        return 1
    }

    log_success "Installed: ${missing[*]}"
    return 0
}

verify_python_deps() {
    log "Verifying Python dependencies..."

    python3 -c "
import apsw
import sqlite_vec
import sqlite_lembed
print(f'  apsw: {apsw.apswversion()}')
print(f'  sqlite: {apsw.sqlitelibversion()}')
print('  sqlite_vec: OK')
print('  sqlite_lembed: OK')
" || {
        log_error "Python dependency verification failed"
        return 1
    }

    log_success "All dependencies verified"
    return 0
}

download_model() {
    log "Checking embedding model..."

    mkdir -p "$MODELS_DIR"

    if [[ -f "$MODELS_DIR/$MODEL_NAME" ]]; then
        local size
        size=$(wc -c < "$MODELS_DIR/$MODEL_NAME" | tr -d ' ')

        if [[ $size -gt 10000000 ]]; then
            log_success "Model already downloaded ($((size / 1024 / 1024))MB)"
            return 0
        else
            log_warn "Model file seems corrupted, re-downloading..."
            rm -f "$MODELS_DIR/$MODEL_NAME"
        fi
    fi

    log "Downloading $MODEL_NAME (~90MB)..."

    if command -v curl &>/dev/null; then
        curl -L --progress-bar -o "$MODELS_DIR/$MODEL_NAME" "$MODEL_URL" || {
            log_error "Failed to download model"
            log "Try manually: curl -L -o $MODELS_DIR/$MODEL_NAME $MODEL_URL"
            return 1
        }
    elif command -v wget &>/dev/null; then
        wget -q --show-progress -O "$MODELS_DIR/$MODEL_NAME" "$MODEL_URL" || {
            log_error "Failed to download model"
            return 1
        }
    else
        log_error "Neither curl nor wget available"
        return 1
    fi

    log_success "Model downloaded"
    return 0
}

init_database() {
    log "Initializing database schema..."

    python3 << 'PYEOF'
import sys
sys.path.insert(0, f"{__import__('os').environ.get('CLAUDE_DIR', __import__('pathlib').Path.home() / '.claude')}/lib")

from embeddings import EmbeddingEngine

engine = EmbeddingEngine()
engine.init_schema()
print("  Base schema initialized")
engine.close()
PYEOF

    if [[ $? -ne 0 ]]; then
        log_error "Failed to initialize database schema"
        return 1
    fi

    log_success "Database schema ready"
    return 0
}

init_threshold_tables() {
    log "Initializing threshold configuration..."

    python3 << 'PYEOF'
import sys
import os
claude_dir = os.environ.get('CLAUDE_DIR', str(__import__('pathlib').Path.home() / '.claude'))
sys.path.insert(0, f"{claude_dir}/lib")

from embeddings import EmbeddingEngine

engine = EmbeddingEngine()
conn = engine.connect()

conn.execute('''
    CREATE TABLE IF NOT EXISTS threshold_config (
        concept_type TEXT PRIMARY KEY,
        current_threshold REAL NOT NULL,
        min_threshold REAL DEFAULT 0.2,
        max_threshold REAL DEFAULT 0.9,
        total_matches INTEGER DEFAULT 0,
        successful_matches INTEGER DEFAULT 0,
        last_calibrated TEXT,
        auto_adjust INTEGER DEFAULT 1,
        adjustment_sensitivity REAL DEFAULT 0.02
    )
''')

conn.execute('''
    CREATE TABLE IF NOT EXISTS match_history (
        id INTEGER PRIMARY KEY,
        prompt_text TEXT,
        concept_type TEXT,
        matched_concept TEXT,
        similarity REAL,
        threshold_used REAL,
        user_feedback TEXT,
        feedback_at TEXT,
        created_at TEXT DEFAULT (datetime('now'))
    )
''')

conn.execute('CREATE INDEX IF NOT EXISTS idx_match_history_feedback ON match_history(user_feedback)')
conn.execute('CREATE INDEX IF NOT EXISTS idx_match_history_concept ON match_history(concept_type)')
conn.execute('CREATE INDEX IF NOT EXISTS idx_match_history_created ON match_history(created_at)')

defaults = [
    ('concept_intent', 0.40),
    ('concept_feedback', 0.25),
    ('concept_agent', 0.45),
    ('concept_skill', 0.45),
    ('concept_command', 0.45),
    ('checkpoint', 0.55),
    ('concept_solution', 0.40),
    ('concept_workflow', 0.40),
]

for concept_type, threshold in defaults:
    try:
        conn.execute('''
            INSERT INTO threshold_config (concept_type, current_threshold)
            VALUES (?, ?)
        ''', (concept_type, threshold))
    except:
        pass

print("  Threshold tables created")
print("  Default thresholds configured")
engine.close()
PYEOF

    if [[ $? -ne 0 ]]; then
        log_error "Failed to initialize threshold tables"
        return 1
    fi

    log_success "Threshold configuration ready"
    return 0
}

embed_concepts() {
    log "Pre-embedding concept library..."

    if [[ ! -f "$SCRIPTS_DIR/embed-concepts.py" ]]; then
        log_error "embed-concepts.py not found"
        return 1
    fi

    if [[ ! -f "$CONFIG_DIR/concept-library.json" ]]; then
        log_error "concept-library.json not found"
        return 1
    fi

    python3 "$SCRIPTS_DIR/embed-concepts.py" 2>&1 | while IFS= read -r line; do
        echo "  $line"
    done

    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        log_error "Failed to embed concepts"
        return 1
    fi

    log_success "Concepts embedded"
    return 0
}

verify_installation() {
    log "Verifying installation..."

    python3 << 'PYEOF'
import sys
import os
claude_dir = os.environ.get('CLAUDE_DIR', str(__import__('pathlib').Path.home() / '.claude'))
sys.path.insert(0, f"{claude_dir}/lib")

from embeddings import EmbeddingEngine

engine = EmbeddingEngine()
stats = engine.get_stats()

print(f"  Total embeddings: {stats['total_embeddings']}")
print(f"  Concept types: {len(stats['by_type'])}")

results = engine.match_agent('search past conversations')
if results:
    print(f"  Test match: {results[0]['name']} ({results[0]['similarity']:.3f})")
else:
    print("  WARNING: Test match failed")
    sys.exit(1)

results = engine.classify_feedback('thanks that worked!')
if results and results[0]['name'] == 'positive':
    print(f"  Feedback test: PASS")
else:
    print("  WARNING: Feedback test failed")

cursor = engine.conn.cursor()
thresholds = list(cursor.execute('SELECT COUNT(*) FROM threshold_config'))
print(f"  Threshold configs: {thresholds[0][0]}")

engine.close()
print("\n  All systems operational")
PYEOF

    if [[ $? -ne 0 ]]; then
        log_error "Verification failed"
        return 1
    fi

    log_success "Installation verified"
    return 0
}

show_next_steps() {
    echo ""
    echo "========================================"
    echo "  Semantic RL++ Bootstrap Complete"
    echo "========================================"
    echo ""
    echo "Next steps:"
    echo ""
    echo "  1. Start a new Claude Code session:"
    echo "     $ claude"
    echo ""
    echo "  2. The system will auto-initialize via hooks"
    echo ""
    echo "  3. Say 'RL++' to confirm all systems loaded"
    echo ""
    echo "  4. Optional: Set up weekly maintenance cron:"
    echo "     0 3 * * 0 ~/.claude/scripts/weekly-maintenance.sh"
    echo ""
    echo "Files created:"
    echo "  - ~/.claude/embeddings.db (vector database)"
    echo "  - ~/.claude/models/$MODEL_NAME"
    echo ""
    echo "Dynamic learning is now active:"
    echo "  - Thresholds adjust based on your feedback"
    echo "  - Patterns emerge from usage"
    echo "  - Cross-project insights accumulate"
    echo ""
}

main() {
    echo ""
    echo "========================================"
    echo "  Semantic RL++ Bootstrap v1.0.0"
    echo "========================================"
    echo ""

    export CLAUDE_DIR

    if [[ "$VERIFY_ONLY" == "--verify-only" ]]; then
        log "Running verification only..."
        verify_python_deps || exit 1
        verify_installation || exit 1
        echo ""
        log_success "All systems operational"
        exit 0
    fi

    check_python || exit 1
    check_pip || exit 1
    install_python_deps || exit 1
    verify_python_deps || exit 1
    download_model || exit 1
    init_database || exit 1
    init_threshold_tables || exit 1
    embed_concepts || exit 1
    verify_installation || exit 1

    show_next_steps
}

main "$@"
