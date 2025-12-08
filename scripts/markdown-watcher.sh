#!/bin/bash
#
# Background Markdown Lint Watcher
# Polls every 30 seconds for recently modified .md files and auto-fixes them
#
# Usage: bash ~/.claude/scripts/markdown-watcher.sh &
#

set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
LOG_FILE="${CLAUDE_DIR}/.markdown-watcher.log"
INTERVAL=30

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

log "Markdown watcher started (polling every ${INTERVAL}s)"
log "Watching: ${CLAUDE_DIR}"

# Create timestamp marker file
MARKER_FILE="${CLAUDE_DIR}/.markdown-watcher-marker"
touch "$MARKER_FILE"

while true; do
    # Find .md files modified since last check (exclude node_modules, .git)
    MODIFIED=$(find "$CLAUDE_DIR" \
        -name "*.md" \
        -newer "$MARKER_FILE" \
        -type f \
        ! -path "*/.git/*" \
        ! -path "*/node_modules/*" \
        2>/dev/null || true)

    if [[ -n "$MODIFIED" ]]; then
        FILE_COUNT=$(echo "$MODIFIED" | wc -l | tr -d ' ')
        log "Found ${FILE_COUNT} modified file(s)"

        while IFS= read -r file; do
            if [[ -f "$file" ]]; then
                log "Fixing: ${file#"$CLAUDE_DIR"/}"

                # Run markdownlint with fix, capture output
                OUTPUT=$(npx -y markdownlint-cli --fix "$file" 2>&1 || true)

                if [[ -n "$OUTPUT" ]]; then
                    echo "$OUTPUT" >> "$LOG_FILE"
                else
                    log "  No issues found"
                fi
            fi
        done <<< "$MODIFIED"
    fi

    # Update marker for next check
    touch "$MARKER_FILE"

    sleep "$INTERVAL"
done
