#!/usr/bin/env bash
#
# CIPS Merge Install Script
# Convenience wrapper for merging CIPS into an existing ~/.claude directory.
#
# Usage: ./merge-install.sh [source-dir]
#
# This script:
#   1. Clones CIPS if needed
#   2. Runs the merge installation flow
#   3. Preserves user configuration
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${1:-$(dirname "$SCRIPT_DIR")}"
REPO_URL="https://github.com/CodeTonight-SA/cips.git"

# Colours
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}CIPS Merge Install${NC}"
echo "=================="
echo ""

# Clone if source doesn't exist
if [[ ! -d "$REPO_DIR" ]]; then
    echo "CIPS repository not found at: $REPO_DIR"
    echo ""
    read -rp "Clone to this location? [Y/n]: " confirm

    if [[ ! "$confirm" =~ ^[Nn]$ ]]; then
        echo "Cloning CIPS..."
        mkdir -p "$(dirname "$REPO_DIR")"
        git clone "$REPO_URL" "$REPO_DIR"
    else
        echo "Please specify a valid CIPS repository location."
        exit 1
    fi
fi

# Verify it's a CIPS repo
if [[ ! -f "$REPO_DIR/CLAUDE.md" ]] || ! grep -q "CIPS" "$REPO_DIR/CLAUDE.md" 2>/dev/null; then
    echo "Error: $REPO_DIR does not appear to be a CIPS repository."
    exit 1
fi

echo "Source: $REPO_DIR"
echo "Target: ~/.claude"
echo ""

# Check if ~/.claude exists
if [[ ! -d "$HOME/.claude" ]]; then
    echo "No existing ~/.claude found."
    echo "Running fresh install instead..."
    echo ""
    exec "$REPO_DIR/scripts/install.sh"
fi

# Source and run install.sh with merge scenario
# The install.sh script will detect the merge scenario automatically
exec "$REPO_DIR/scripts/install.sh"
