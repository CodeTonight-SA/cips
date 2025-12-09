#!/usr/bin/env bash
#
# Tool Monitor Hook
# Real-time efficiency monitoring for Claude Code tool calls
#
# PURPOSE:
#   This hook intercepts tool calls to:
#   1. Detect efficiency violations in real-time
#   2. Block dangerous operations (node_modules reads)
#   3. Track token usage patterns
#   4. Suggest optimisations
#
# INTEGRATION:
#   Add to ~/.claude/settings.json:
#   {
#     "hooks": {
#       "tool_call": "~/.claude/hooks/tool-monitor.sh"
#     }
#   }
#
# ARGUMENTS:
#   $1 = Tool name (Read, Edit, Write, Bash, etc.)
#   $2 = Tool arguments (JSON)
#
# VERSION: 1.0.0
# DATE: 2025-11-27
#

set -euo pipefail

# ============================================================================
# CONSTANTS
# ============================================================================

[[ -z "${CLAUDE_DIR:-}" ]] && readonly CLAUDE_DIR="$HOME/.claude"
[[ -z "${LIB_DIR:-}" ]] && readonly LIB_DIR="$CLAUDE_DIR/lib"
[[ -z "${HOOK_LOG:-}" ]] && readonly HOOK_LOG="$CLAUDE_DIR/.hooks.log"

# ============================================================================
# SOURCE LIBRARIES
# ============================================================================

if [[ -f "$LIB_DIR/agent-matcher.sh" ]]; then
    source "$LIB_DIR/agent-matcher.sh" 2>/dev/null || true
fi

if [[ -f "$LIB_DIR/session-lifecycle.sh" ]]; then
    source "$LIB_DIR/session-lifecycle.sh" 2>/dev/null || true
fi

if [[ -f "$LIB_DIR/embeddings.sh" ]]; then
    source "$LIB_DIR/embeddings.sh" 2>/dev/null || true
fi

if [[ -f "$LIB_DIR/success-scorer.sh" ]]; then
    source "$LIB_DIR/success-scorer.sh" 2>/dev/null || true
fi
[[ -z "${VIOLATIONS_REGISTRY:-}" ]] && readonly VIOLATIONS_REGISTRY="$CLAUDE_DIR/violations-registry.json"
[[ -z "${READ_CACHE:-}" ]] && readonly READ_CACHE="$CLAUDE_DIR/.read-cache.json"

# Blocked patterns (critical violations)
if [[ -z "${BLOCKED_PATTERNS[*]:-}" ]]; then
    readonly BLOCKED_PATTERNS=(
        "node_modules"
        "__pycache__"
        ".venv"
        "venv"
        "dist/"
        "build/"
        ".next/"
        "target/"
        "vendor/"
    )
fi

# ============================================================================
# LOGGING
# ============================================================================

log_hook() {
    local level="$1"
    shift
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) [TOOL-MONITOR][$level] $*" >> "$HOOK_LOG"
}

log_info() {
    log_hook "INFO" "$@"
}

log_warn() {
    log_hook "WARN" "$@"
}

log_error() {
    log_hook "ERROR" "$@"
}

log_block() {
    log_hook "BLOCK" "$@"
}

# ============================================================================
# BASH LINTING
# ============================================================================

# Lint bash file if it's in Claude infrastructure
lint_bash_file() {
    local file_path="$1"

    # Only lint .sh files in Claude directory
    [[ "$file_path" != *.sh ]] && return 0
    [[ "$file_path" != "$CLAUDE_DIR"/* ]] && return 0

    # Source linter if available
    if [[ -f "$CLAUDE_DIR/lib/bash-linter.sh" ]]; then
        source "$CLAUDE_DIR/lib/bash-linter.sh" 2>/dev/null || return 0

        local issues
        issues=$(lint_file "$file_path" 2>/dev/null) || true

        if [[ -n "$issues" ]]; then
            log_warn "Bash lint issues in $file_path"
            echo "LINT WARNING: Issues detected in $file_path:"
            echo "$issues" | while IFS= read -r issue; do
                echo "  $issue"
            done
            echo "Run './optim.sh lint-bash' for full scan."
        fi
    fi
}

# ============================================================================
# VIOLATION DETECTION
# ============================================================================

# Check if path matches blocked patterns
is_blocked_path() {
    local path="$1"

    for pattern in "${BLOCKED_PATTERNS[@]}"; do
        if [[ "$path" == *"$pattern"* ]]; then
            return 0  # Blocked
        fi
    done

    return 1  # Not blocked
}

# Check for duplicate read
is_duplicate_read() {
    local path="$1"

    if [[ ! -f "$READ_CACHE" ]]; then
        echo '{"reads":{}}' > "$READ_CACHE"
        return 1
    fi

    # Check if path was recently read
    local count=$(jq -r ".reads[\"$path\"].count // 0" "$READ_CACHE")

    if [[ $count -gt 2 ]]; then
        return 0  # Duplicate
    fi

    return 1
}

# Track file read
track_read() {
    local path="$1"

    if [[ ! -f "$READ_CACHE" ]]; then
        echo '{"reads":{}}' > "$READ_CACHE"
    fi

    # Update count
    local tmp_file=$(mktemp)
    jq --arg path "$path" \
       '.reads[$path].count = ((.reads[$path].count // 0) + 1) | .reads[$path].last_read = now' \
       "$READ_CACHE" > "$tmp_file"
    mv "$tmp_file" "$READ_CACHE"
}

# ============================================================================
# TOOL-SPECIFIC MONITORS
# ============================================================================

# Monitor Read tool
monitor_read() {
    local args="$1"

    # Extract file path - handle both JSON and direct path
    local file_path
    if [[ "$args" == "{"* ]]; then
        file_path=$(echo "$args" | jq -r '.file_path // empty' 2>/dev/null)
    else
        file_path="$args"
    fi

    if [[ -z "$file_path" ]]; then
        return 0
    fi

    log_info "Read: $file_path"

    # Check for blocked path
    if is_blocked_path "$file_path"; then
        log_block "BLOCKED: Read from dependency folder: $file_path"
        echo "BLOCKED: Cannot read from dependency/build folders."
        echo "Path: $file_path"
        echo "This would waste 50,000+ tokens."
        echo ""
        echo "Use: rg 'pattern' --glob '!node_modules/*' instead"
        return 1
    fi

    # Check for duplicate read
    if is_duplicate_read "$file_path"; then
        log_warn "Duplicate read detected: $file_path"
        echo "WARNING: This file was recently read."
        echo "Consider using cached information from conversation buffer."
    fi

    # Track the read
    track_read "$file_path"

    return 0
}

# Monitor Bash tool
monitor_bash() {
    local args="$1"

    # Extract command - handle both JSON and direct command
    local command
    if [[ "$args" == "{"* ]]; then
        command=$(echo "$args" | jq -r '.command // empty' 2>/dev/null)
    else
        command="$args"
    fi

    if [[ -z "$command" ]]; then
        return 0
    fi

    log_info "Bash: ${command:0:50}..."

    # Check for grep instead of rg
    if [[ "$command" == *"grep"* ]] && [[ "$command" != *"rg"* ]]; then
        log_warn "grep detected: Use rg instead"
        echo "SUGGESTION: Use 'rg' instead of 'grep' for better performance and automatic exclusions."
    fi

    # Check for find instead of fd
    if [[ "$command" == *"find "* ]] && [[ "$command" != *"fd"* ]]; then
        log_warn "find detected: Use fd instead"
        echo "SUGGESTION: Use 'fd' instead of 'find' for better performance."
    fi

    # Check for cat instead of Read tool
    if [[ "$command" == *"cat "* ]]; then
        log_warn "cat detected: Use Read tool instead"
        echo "SUGGESTION: Use the Read tool instead of 'cat' for file reading."
    fi

    # Detect workflow end patterns
    if command -v detect_workflow_end &>/dev/null; then
        local workflow_msg
        workflow_msg=$(detect_workflow_end "$command" 2>/dev/null) || true
        if [[ -n "$workflow_msg" ]]; then
            echo ""
            echo "$workflow_msg"
        fi
    fi

    return 0
}

# Monitor Edit tool
monitor_edit() {
    local args="$1"

    # Extract file path - handle both JSON and direct path
    local file_path
    if [[ "$args" == "{"* ]]; then
        file_path=$(echo "$args" | jq -r '.file_path // empty' 2>/dev/null)
    else
        file_path="$args"
    fi

    if [[ -z "$file_path" ]]; then
        return 0
    fi

    log_info "Edit: $file_path"

    # Check for blocked path
    if is_blocked_path "$file_path"; then
        log_block "BLOCKED: Edit in dependency folder: $file_path"
        echo "BLOCKED: Cannot edit files in dependency/build folders."
        return 1
    fi

    # Lint bash scripts in Claude infrastructure
    lint_bash_file "$file_path"

    return 0
}

# Monitor Write tool
monitor_write() {
    local args="$1"

    # Extract file path - handle both JSON and direct path
    local file_path
    if [[ "$args" == "{"* ]]; then
        file_path=$(echo "$args" | jq -r '.file_path // empty' 2>/dev/null)
    else
        file_path="$args"
    fi

    if [[ -z "$file_path" ]]; then
        return 0
    fi

    log_info "Write: $file_path"

    # Lint bash scripts in Claude infrastructure
    lint_bash_file "$file_path"

    # Check for temp script creation
    if [[ "$file_path" == *"temp"* ]] || [[ "$file_path" == *"tmp"* ]] || [[ "$file_path" == *"script"* ]]; then
        log_warn "Temp script creation detected: $file_path"
        echo "WARNING: Creating temporary script."
        echo "Consider using direct CLI commands or MultiEdit instead."
        echo "This could waste 3,000-8,000 tokens."
    fi

    return 0
}

# ============================================================================
# MAIN MONITOR LOGIC
# ============================================================================

main() {
    local tool_name="${1:-}"
    local tool_args="${2:-{}}"

    if [[ -z "$tool_name" ]]; then
        log_error "No tool name provided"
        return 0
    fi

    # Route to specific monitor
    case "$tool_name" in
        Read)
            monitor_read "$tool_args"
            ;;
        Bash)
            monitor_bash "$tool_args"
            ;;
        Edit)
            monitor_edit "$tool_args"
            ;;
        Write)
            monitor_write "$tool_args"
            ;;
        Task)
            # Check for agent invocation patterns
            monitor_task "$tool_args"
            ;;
        *)
            # No specific monitoring for other tools
            log_info "Tool: $tool_name (no specific monitoring)"
            ;;
    esac
}

monitor_task() {
    local args="$1"

    local prompt
    if [[ "$args" == "{"* ]]; then
        prompt=$(echo "$args" | jq -r '.prompt // empty' 2>/dev/null)
    else
        prompt="$args"
    fi

    if [[ -z "$prompt" ]]; then
        return 0
    fi

    log_info "Task: ${prompt:0:50}..."

    # Check for agent suggestions based on prompt
    if command -v get_agent_suggestion &>/dev/null; then
        local suggestion
        suggestion=$(get_agent_suggestion "$prompt" 2>/dev/null) || true
        if [[ -n "$suggestion" ]]; then
            echo ""
            echo "$suggestion"
        fi
    fi

    return 0
}

# Monitor user prompts for feedback classification and embedding
monitor_user_prompt() {
    local prompt="$1"
    local project="${2:-$(pwd)}"

    if [[ -z "$prompt" ]]; then
        return 0
    fi

    log_info "User prompt: ${prompt:0:50}..."

    # Check for explicit feedback on agent suggestions (for threshold learning)
    if command -v process_feedback_and_calibrate &>/dev/null; then
        local calibration_result
        calibration_result=$(process_feedback_and_calibrate "$prompt" 2>/dev/null) || true

        if [[ -n "$calibration_result" ]]; then
            log_info "Threshold calibration triggered: $calibration_result"
        fi
    fi

    # Check if this looks like feedback on previous response
    if command -v score_feedback &>/dev/null; then
        local feedback_result
        feedback_result=$(score_feedback "$prompt" 2>/dev/null) || true

        if [[ -n "$feedback_result" ]]; then
            local feedback_type="${feedback_result%%:*}"
            local similarity="${feedback_result#*:}"

            # Only propagate if similarity is high enough (semantic match)
            if (( $(echo "$similarity > 0.6" | bc -l 2>/dev/null || echo 0) )); then
                log_info "Feedback detected: $feedback_type (similarity: $similarity)"
                propagate_success "$feedback_type" "$similarity" "$project" 2>/dev/null || true
            fi
        fi
    fi

    # Smart embed: only embed if novel enough
    if command -v smart_embed &>/dev/null; then
        smart_embed "$prompt" "prompt" "$project" 2>/dev/null || true
    fi

    return 0
}

# ============================================================================
# EXECUTION
# ============================================================================

main "$@"
