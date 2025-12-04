#!/usr/bin/env bash
#
# Session Lifecycle Library
# Manages session phases and state transitions
#
# PURPOSE:
#   Central lifecycle management that:
#   1. Detects current session phase (START, PLANNING, IMPLEMENTATION, PR, END)
#   2. Manages state file detection and restoration
#   3. Coordinates phase transitions
#   4. Provides lifecycle hooks for orchestration
#
# USAGE:
#   source ~/.claude/lib/session-lifecycle.sh
#
#   # Detect phase from git/context
#   detect_session_phase
#
#   # Check for previous state
#   check_previous_state
#
#   # Get phase-appropriate context
#   get_phase_context "PLANNING"
#
# VERSION: 1.0.0
# DATE: 2025-12-02
#

set -euo pipefail

[[ -z "${SESSION_LIFECYCLE_LOADED:-}" ]] && readonly SESSION_LIFECYCLE_LOADED=1 || return 0

[[ -z "${CLAUDE_DIR:-}" ]] && CLAUDE_DIR="$HOME/.claude"
[[ -z "${STATE_FILES:-}" ]] && STATE_FILES="next_up.md SESSION.md PROGRESS.md"

_lifecycle_log() {
    local level="$1"
    shift
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) [SESSION-LIFECYCLE][$level] $*" >> "$CLAUDE_DIR/.hooks.log"
}

detect_session_phase() {
    local phase="START"

    if ! command -v git &>/dev/null; then
        echo "$phase"
        return
    fi

    if ! git rev-parse --git-dir &>/dev/null 2>&1; then
        echo "$phase"
        return
    fi

    local staged_count
    staged_count=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')

    local unstaged_count
    unstaged_count=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')

    local branch
    branch=$(git branch --show-current 2>/dev/null || echo "")

    if [[ "$branch" == *"pr/"* ]] || [[ "$branch" == *"feature/"* ]]; then
        if [[ $staged_count -gt 0 ]] || [[ $unstaged_count -gt 0 ]]; then
            phase="IMPLEMENTATION"
        else
            phase="PR"
        fi
    elif [[ $staged_count -gt 0 ]]; then
        phase="PR"
    elif [[ $unstaged_count -gt 0 ]]; then
        phase="IMPLEMENTATION"
    fi

    _lifecycle_log "INFO" "Detected phase: $phase (staged=$staged_count, unstaged=$unstaged_count, branch=$branch)"
    echo "$phase"
}

check_previous_state() {
    local state_file=""
    local project_dir
    project_dir=$(pwd)

    for f in $STATE_FILES; do
        if [[ -f "$project_dir/$f" ]]; then
            state_file="$f"
            break
        fi
    done

    if [[ -n "$state_file" ]]; then
        local last_modified
        last_modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$project_dir/$state_file" 2>/dev/null || echo "unknown")

        echo "[STATE-FOUND] Previous state file: $state_file (modified: $last_modified)"
        echo "Consider reviewing previous progress before starting new work."

        _lifecycle_log "INFO" "Found state file: $state_file"
        return 0
    fi

    _lifecycle_log "INFO" "No state file found in $project_dir"
    return 1
}

get_state_file_path() {
    local project_dir
    project_dir=$(pwd)

    for f in $STATE_FILES; do
        if [[ -f "$project_dir/$f" ]]; then
            echo "$project_dir/$f"
            return 0
        fi
    done

    echo "$project_dir/next_up.md"
}

get_phase_context() {
    local phase="${1:-START}"

    case "$phase" in
        START)
            cat << 'EOF'
SESSION START CONTEXT:
- Run /refresh-context to build mental model
- Check for state file (next_up.md) for previous progress
- Efficiency rules are active (see below)
- Available agents ready for on-demand use
EOF
            ;;
        PLANNING)
            cat << 'EOF'
PLANNING PHASE CONTEXT:
- Apply YAGNI: Build only what's needed NOW
- Apply KISS: Simplest solution that works
- Apply DRY: Rule of Three before abstracting
- Challenge "future-proof" and "flexible" requests
EOF
            ;;
        IMPLEMENTATION)
            cat << 'EOF'
IMPLEMENTATION PHASE CONTEXT:
- Use direct implementation (no temp scripts)
- Batch operations with MultiEdit
- Read files once, trust mental model
- Code-agentic verification gates active
EOF
            ;;
        PR)
            cat << 'EOF'
PR PHASE CONTEXT:
- Use /create-pr for automated workflow
- Stage, commit, push in batch operations
- Use HEREDOC for commit messages
- Verify no secrets in staged files
EOF
            ;;
        END)
            cat << 'EOF'
SESSION END CONTEXT:
- Run /audit-efficiency for scoring
- Save state with /save-session-state
- Log patterns to error-signatures.jsonl
- Document learnings in CLAUDE.md if generalizable
EOF
            ;;
    esac
}

get_session_summary() {
    echo "=== SESSION SUMMARY ==="

    local phase
    phase=$(detect_session_phase)
    echo "Current Phase: $phase"

    if check_previous_state >/dev/null 2>&1; then
        local state_file
        state_file=$(get_state_file_path)
        echo "State File: $state_file"
    else
        echo "State File: None found"
    fi

    if command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null 2>&1; then
        local branch
        branch=$(git branch --show-current 2>/dev/null || echo "detached")
        local status_summary
        status_summary=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        echo "Git: $branch ($status_summary changes)"
    fi

    echo "======================="
}

should_suggest_audit() {
    local phase
    phase=$(detect_session_phase)

    [[ "$phase" == "PR" ]] || [[ "$phase" == "END" ]]
}

should_suggest_state_save() {
    local phase
    phase=$(detect_session_phase)

    if [[ "$phase" == "PR" ]] || [[ "$phase" == "END" ]]; then
        return 0
    fi

    return 1
}

export -f detect_session_phase
export -f check_previous_state
export -f get_state_file_path
export -f get_phase_context
export -f get_session_summary
export -f should_suggest_audit
export -f should_suggest_state_save
