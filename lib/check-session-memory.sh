#!/usr/bin/env bash
#
# Check Session Memory Availability
# Detects if Anthropic's Session Memory feature is available
#
# VERSION: 1.0.0
# DATE: 2025-12-19
#

set -euo pipefail

check_session_memory() {
    if [[ -d "$HOME/.claude/session-memory" ]]; then
        echo "SESSION_MEMORY_AVAILABLE=true"

        # Count existing session files
        local session_count
        session_count=$(find "$HOME/.claude/session-memory" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        echo "SESSION_COUNT=$session_count"

        # Check for custom config
        if [[ -f "$HOME/.claude/session-memory/config/template.md" ]]; then
            echo "CUSTOM_TEMPLATE=true"
        else
            echo "CUSTOM_TEMPLATE=false"
        fi

        if [[ -f "$HOME/.claude/session-memory/config/prompt.md" ]]; then
            echo "CUSTOM_PROMPT=true"
        else
            echo "CUSTOM_PROMPT=false"
        fi
    else
        echo "SESSION_MEMORY_AVAILABLE=false"

        # Check Claude Code version for hints
        local claude_version
        claude_version=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1) || claude_version="unknown"
        echo "CLAUDE_VERSION=$claude_version"

        # Check if we're close to expected release version
        if [[ "$claude_version" =~ ^2\.0\.7[2-9] ]] || [[ "$claude_version" =~ ^2\.0\.[8-9] ]] || [[ "$claude_version" =~ ^2\.[1-9] ]]; then
            echo "VERSION_HINT=Session Memory may be available in this version"
        fi
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_session_memory
fi
