#!/usr/bin/env bash
#
# Session End Hook
# Auto-serialize CIPS and save session state on quit
#
# PURPOSE:
#   This hook runs when a Claude Code session terminates to:
#   1. Auto-serialize CIPS instance with meaningful achievement
#   2. Auto-save session state (next_up.md)
#   3. Cache any active plans
#
# INPUT (JSON on stdin):
#   session_id, transcript_path, cwd, hook_event_name
#
# VERSION: 1.0.0
# DATE: 2025-12-12
#

set -euo pipefail

# ============================================================================
# CONSTANTS
# ============================================================================

[[ -z "${CLAUDE_DIR:-}" ]] && readonly CLAUDE_DIR="$HOME/.claude"
[[ -z "${LIB_DIR:-}" ]] && readonly LIB_DIR="$CLAUDE_DIR/lib"
[[ -z "${HOOK_LOG:-}" ]] && readonly HOOK_LOG="$CLAUDE_DIR/.hooks.log"

# ============================================================================
# LOGGING
# ============================================================================

log_hook() {
    local level="$1"
    shift
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) [SESSION-END][$level] $*" >> "$HOOK_LOG"
}

log_info() {
    log_hook "INFO" "$@"
}

log_warn() {
    log_hook "WARN" "$@"
}

log_success() {
    log_hook "SUCCESS" "$@"
}

# ============================================================================
# INPUT PARSING
# ============================================================================

parse_input() {
    local input
    input=$(cat)

    SESSION_ID=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null) || SESSION_ID=""
    TRANSCRIPT_PATH=$(echo "$input" | jq -r '.transcript_path // empty' 2>/dev/null) || TRANSCRIPT_PATH=""
    CWD=$(echo "$input" | jq -r '.cwd // empty' 2>/dev/null) || CWD="$CLAUDE_DIR"
}

# ============================================================================
# ACHIEVEMENT EXTRACTION
# ============================================================================

# Extract meaningful achievement from recent session activity
extract_achievement() {
    local transcript="$1"
    local achievement=""

    if [[ -f "$transcript" ]]; then
        # Look for commit messages (most meaningful indicator of work done)
        local commit_msg
        commit_msg=$(tail -100 "$transcript" 2>/dev/null | jq -r 'select(.type == "assistant") | .message.content // empty' 2>/dev/null | grep -oE 'feat:.*|fix:.*|chore:.*|refactor:.*|docs:.*' | tail -1) || true

        if [[ -n "$commit_msg" ]]; then
            # Truncate to reasonable length
            achievement="${commit_msg:0:100}"
        else
            # Look for file creations
            local files_created
            files_created=$(tail -50 "$transcript" 2>/dev/null | jq -r 'select(.type == "tool_result") | .content // empty' 2>/dev/null | grep -c 'File created' 2>/dev/null) || files_created=0

            if [[ "$files_created" -gt 0 ]]; then
                achievement="Created $files_created file(s)"
            else
                # Look for tool usage patterns
                local tool_count
                tool_count=$(tail -50 "$transcript" 2>/dev/null | jq -r 'select(.type == "tool_use") | .name // empty' 2>/dev/null | wc -l | tr -d ' ') || tool_count=0

                if [[ "$tool_count" -gt 10 ]]; then
                    achievement="Active session ($tool_count tool calls)"
                else
                    achievement="Session checkpoint"
                fi
            fi
        fi
    else
        achievement="Session ended"
    fi

    echo "$achievement - $(date +%Y-%m-%d)"
}

# ============================================================================
# CIPS AUTO-SERIALIZATION
# ============================================================================

auto_serialize_cips() {
    local achievement="$1"

    if [[ ! -f "$LIB_DIR/instance-serializer.py" ]]; then
        log_warn "CIPS serializer not found"
        return 0
    fi

    log_info "Auto-serializing CIPS: $achievement"

    # Change to project directory
    cd "$CWD" 2>/dev/null || cd "$CLAUDE_DIR"

    # Get branch from registry (if available)
    local branch=""
    if [[ -f "$LIB_DIR/cips_registry.py" ]]; then
        branch=$(python3 "$LIB_DIR/cips_registry.py" branch 2>/dev/null) || branch=""
    fi

    # Run serialization with branch (if detected)
    local serialize_args=("auto" "--achievement" "$achievement")
    if [[ -n "$branch" ]] && [[ "$branch" != "unregistered" ]]; then
        serialize_args+=("--branch" "$branch")
        log_info "Serializing to branch: $branch"
    fi

    if python3 "$LIB_DIR/instance-serializer.py" "${serialize_args[@]}" \
        2>/dev/null; then
        log_success "CIPS instance serialized"
    else
        log_warn "CIPS serialization failed (non-blocking)"
    fi
}

# Deregister session from CIPS registry
deregister_cips_session() {
    if [[ ! -f "$LIB_DIR/cips_registry.py" ]]; then
        return 0
    fi

    cd "$CWD" 2>/dev/null || cd "$CLAUDE_DIR"

    if python3 "$LIB_DIR/cips_registry.py" deregister 2>/dev/null; then
        log_info "CIPS session deregistered"
    else
        log_warn "CIPS session deregistration failed (non-blocking)"
    fi
}

# ============================================================================
# SESSION STATE AUTO-SAVE
# ============================================================================

auto_save_state() {
    # Find state file (project-local first, then global)
    local state_file="$CWD/next_up.md"
    [[ ! -f "$state_file" ]] && state_file="$CLAUDE_DIR/next_up.md"

    if [[ ! -f "$state_file" ]]; then
        log_info "No state file found, skipping state save"
        return 0
    fi

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Update timestamp in state file
    if [[ -f "$LIB_DIR/session-state.sh" ]]; then
        # shellcheck source=/dev/null
        source "$LIB_DIR/session-state.sh"
        if save_session_checkpoint "$state_file" 2>/dev/null; then
            log_success "Session state saved to $state_file"
        else
            log_warn "Session state save failed"
        fi
    else
        # Minimal update: just update timestamp and status
        if sed -i '' "s/\*\*Last Updated\*\*:.*/\*\*Last Updated\*\*: $timestamp/" "$state_file" 2>/dev/null; then
            sed -i '' "s/\*\*Status\*\*:.*/\*\*Status\*\*: AUTO-SAVED on session end/" "$state_file" 2>/dev/null || true
            log_info "State file timestamp updated"
        fi
    fi
}

# ============================================================================
# PLAN CACHING
# ============================================================================

cache_plan() {
    if [[ ! -f "$LIB_DIR/plan-persistence.sh" ]]; then
        return 0
    fi

    # shellcheck source=/dev/null
    source "$LIB_DIR/plan-persistence.sh"

    local plan_file
    plan_file=$(get_latest_plan_file 2>/dev/null) || true

    if [[ -n "$plan_file" ]] && [[ -f "$plan_file" ]]; then
        if cache_current_plan "$plan_file" 2>/dev/null; then
            log_info "Plan cached: $(basename "$plan_file" .md)"
        fi
    fi
}

# ============================================================================
# SESSION MEMORY CROSS-REFERENCING
# ============================================================================

cross_reference_session_memory() {
    local session_memory_dir="$HOME/.claude/session-memory"

    # Only proceed if Session Memory feature exists
    [[ -d "$session_memory_dir" ]] || return 0

    # Find session memory file for this session
    local session_memory_file="$session_memory_dir/${SESSION_ID}.md"

    if [[ -f "$session_memory_file" ]]; then
        log_info "Cross-referencing Session Memory with CIPS"

        # Get current CIPS instance info
        local project_encoded
        project_encoded=$(echo "$CWD" | sed 's|/|-|g' | sed 's|\.|-|g')
        local cips_index="$CLAUDE_DIR/projects/$project_encoded/cips/index.json"

        if [[ -f "$cips_index" ]]; then
            local instance_id
            local generation
            instance_id=$(jq -r '.instances[-1].id // empty' "$cips_index" 2>/dev/null | head -c8)
            generation=$(jq -r '.instances[-1].lineage.generation // 0' "$cips_index" 2>/dev/null)

            # Append CIPS reference to session memory file if not already present
            if ! grep -q "## CIPS Reference" "$session_memory_file" 2>/dev/null; then
                {
                    echo ""
                    echo "## CIPS Reference"
                    echo ""
                    echo "- **Instance**: $instance_id"
                    echo "- **Generation**: $generation"
                    echo "- **Serialized**: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
                } >> "$session_memory_file"

                log_success "Added CIPS reference to session memory"
            fi
        fi
    fi
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    log_info "Session end hook triggered"

    # Parse input from stdin
    parse_input

    if [[ -z "$SESSION_ID" ]]; then
        log_warn "No session ID received, running with defaults"
        SESSION_ID="unknown"
    fi

    log_info "Session: $SESSION_ID ending in $CWD"

    # Extract achievement from session transcript
    local achievement
    achievement=$(extract_achievement "$TRANSCRIPT_PATH")

    # Auto-serialize CIPS instance (includes branch from registry)
    auto_serialize_cips "$achievement"

    # Deregister from CIPS session registry (after serialization)
    deregister_cips_session

    # Cross-reference with Session Memory (if feature available)
    cross_reference_session_memory

    # Auto-save session state
    auto_save_state

    # Cache any active plan
    cache_plan

    log_success "Session end cleanup complete"
}

# ============================================================================
# EXECUTION
# ============================================================================

main
