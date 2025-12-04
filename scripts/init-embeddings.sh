#!/usr/bin/env bash
#
# Semantic RL++ Embedding System Initialisation
# One-time setup script for the embedding infrastructure
#
# USAGE:
#   ~/.claude/scripts/init-embeddings.sh
#
# WHAT IT DOES:
#   1. Checks Python dependencies (apsw, sqlite-vec, sqlite-lembed)
#   2. Verifies GGUF model exists
#   3. Initialises embeddings.db schema
#   4. Tests embedding generation
#   5. Reports status
#
# VERSION: 1.0.0
# DATE: 2025-12-02
#

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
MODEL_PATH="$CLAUDE_DIR/models/all-MiniLM-L6-v2.gguf"
MODEL_URL="https://huggingface.co/asg017/sqlite-lembed-model-examples/resolve/main/all-MiniLM-L6-v2/all-MiniLM-L6-v2.e4ce9877.q8_0.gguf"

echo "=== Semantic RL++ Embedding System Initialisation ==="
echo ""

echo "[1/5] Checking Python dependencies..."
if ! command -v python3 &>/dev/null; then
    echo "ERROR: python3 not found"
    exit 1
fi
echo "  Python: $(python3 --version)"

missing_deps=()
for pkg in apsw sqlite_vec sqlite_lembed; do
    if ! python3 -c "import $pkg" 2>/dev/null; then
        missing_deps+=("$pkg")
    fi
done

if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo "  Missing packages: ${missing_deps[*]}"
    echo "  Installing..."
    pip3 install apsw sqlite-vec sqlite-lembed
fi
echo "  All Python dependencies installed"

echo ""
echo "[2/5] Checking GGUF model..."
if [[ ! -f "$MODEL_PATH" ]]; then
    echo "  Model not found at $MODEL_PATH"
    echo "  Downloading all-MiniLM-L6-v2 GGUF model (~24MB)..."
    mkdir -p "$(dirname "$MODEL_PATH")"
    curl -sL "$MODEL_URL" -o "$MODEL_PATH"
fi
model_size=$(ls -lh "$MODEL_PATH" | awk '{print $5}')
echo "  Model: $MODEL_PATH ($model_size)"

echo ""
echo "[3/5] Checking SQLite extensions..."
vec_path=$(python3 -c "import sqlite_vec; print(sqlite_vec.loadable_path())")
lembed_path=$(python3 -c "import sqlite_lembed; print(sqlite_lembed.loadable_path())")
echo "  sqlite-vec: $vec_path"
echo "  sqlite-lembed: $lembed_path"

echo ""
echo "[4/5] Initialising database schema..."
python3 "$CLAUDE_DIR/lib/embeddings.py" init
echo "  Database: $CLAUDE_DIR/embeddings.db"

echo ""
echo "[5/5] Testing embedding generation..."
test_result=$(python3 "$CLAUDE_DIR/lib/embeddings.py" embed "hello world test embedding")
dimensions=$(echo "$test_result" | jq -r '.dimensions')
echo "  Test embedding: $dimensions dimensions"

echo ""
echo "=== Initialisation Complete ==="
echo ""
echo "System ready. Usage:"
echo "  source ~/.claude/lib/embeddings.sh"
echo "  embed_text 'your text here'"
echo "  search_similar 'query text'"
echo "  smart_embed 'auto-prioritised embedding'"
echo ""
echo "Stats:"
python3 "$CLAUDE_DIR/lib/embeddings.py" stats
