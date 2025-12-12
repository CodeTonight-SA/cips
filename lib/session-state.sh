#!/usr/bin/env bash
#
# Session State Library
# Programmatic checkpoint functions for session state persistence
#
# PURPOSE:
#   Provides functions to programmatically save session state
#   Used by session-end.sh hook for auto-save on quit
#
# VERSION: 1.0.0
# DATE: 2025-12-12
#

# ============================================================================
# CONSTANTS
# ============================================================================

[[ -z "${CLAUDE_DIR:-}" ]] && readonly CLAUDE_DIR="$HOME/.claude"

# ============================================================================
# CORE FUNCTIONS
# ============================================================================

# Save session checkpoint to state file
# Updates timestamp and status
save_session_checkpoint() {
    local state_file="$1"
    [[ ! -f "$state_file" ]] && return 1

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Update Last Updated timestamp
    sed -i '' "s/\*\*Last Updated\*\*:.*/\*\*Last Updated\*\*: $timestamp/" "$state_file" 2>/dev/null || return 1

    # Update Status to indicate auto-save
    sed -i '' "s/\*\*Status\*\*:.*/\*\*Status\*\*: AUTO-SAVED on session end/" "$state_file" 2>/dev/null || true

    return 0
}

# Get state file for current project
get_state_file() {
    local state_file="$PWD/next_up.md"
    [[ -f "$state_file" ]] && echo "$state_file" && return 0

    state_file="$PWD/SESSION.md"
    [[ -f "$state_file" ]] && echo "$state_file" && return 0

    state_file="$CLAUDE_DIR/next_up.md"
    [[ -f "$state_file" ]] && echo "$state_file" && return 0

    return 1
}

# Check if state file exists
has_state_file() {
    get_state_file >/dev/null 2>&1
}

# Export functions
export -f save_session_checkpoint get_state_file has_state_file
