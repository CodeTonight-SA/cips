#!/usr/bin/env bash
#
# Orchestrator Library
# Central coordination layer that ties all self-improvement components together
#
# PURPOSE:
#   This is the "brain" of the self-improvement infrastructure.
#   It coordinates:
#   1. Skill loading based on context
#   2. Command execution
#   3. Agent delegation
#   4. Efficiency monitoring
#   5. Session lifecycle management
#
# USAGE:
#   source ~/.claude/lib/orchestrator.sh
#
#   # Start orchestration
#   orchestrate session-start
#
#   # Handle user input
#   orchestrate handle-input "implement this Figma design"
#
#   # Run efficiency check
#   orchestrate check-efficiency
#
# VERSION: 1.0.0
# DATE: 2025-11-27
#

set -euo pipefail

# ============================================================================
# CONSTANTS
# ============================================================================

# Guard pattern: only assign if unset (prevents readonly conflicts)
[[ -z "${CLAUDE_DIR:-}" ]] && CLAUDE_DIR="$HOME/.claude"
[[ -z "${LIB_DIR:-}" ]] && LIB_DIR="$CLAUDE_DIR/lib"
[[ -z "${ORCHESTRATOR_STATE:-}" ]] && readonly ORCHESTRATOR_STATE="$CLAUDE_DIR/.orchestrator-state.json"
[[ -z "${SESSION_LOG:-}" ]] && readonly SESSION_LOG="$CLAUDE_DIR/.session.log"

# Token budget tracking
[[ -z "${DEFAULT_SESSION_BUDGET:-}" ]] && readonly DEFAULT_SESSION_BUDGET=200000
[[ -z "${CRITICAL_BUDGET_THRESHOLD:-}" ]] && readonly CRITICAL_BUDGET_THRESHOLD=20000
[[ -z "${WARNING_BUDGET_THRESHOLD:-}" ]] && readonly WARNING_BUDGET_THRESHOLD=50000

# ============================================================================
# DEPENDENCIES
# ============================================================================

# Source all library components
_source_dependencies() {
    local deps=(
        "path-resolver.sh"
        "skill-loader.sh"
        "command-executor.sh"
    )

    for dep in "${deps[@]}"; do
        if [[ -f "$LIB_DIR/$dep" ]]; then
            # shellcheck source=/dev/null
            source "$LIB_DIR/$dep"
        fi
    done
}

_source_dependencies

# ============================================================================
# LOGGING
# ============================================================================

_orch_log() {
    local level="$1"
    shift
    echo "[ORCHESTRATOR][$level] $*" >&2

    # Also log to session log
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) [$level] $*" >> "$SESSION_LOG"
}

_orch_log_info() {
    _orch_log "INFO" "$@"
}

_orch_log_warn() {
    _orch_log "WARN" "$@"
}

_orch_log_error() {
    _orch_log "ERROR" "$@"
}

_orch_log_success() {
    _orch_log "SUCCESS" "$@"
}

# ============================================================================
# STATE MANAGEMENT
# ============================================================================

# Initialize orchestrator state
init_state() {
    if [[ ! -f "$ORCHESTRATOR_STATE" ]]; then
        cat > "$ORCHESTRATOR_STATE" << EOF
{
  "session": {
    "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "token_budget": $DEFAULT_SESSION_BUDGET,
    "tokens_used": 0,
    "context_refreshed": false
  },
  "loaded_skills": [],
  "active_agents": [],
  "violations_detected": 0,
  "commands_executed": []
}
EOF
    fi

    cat "$ORCHESTRATOR_STATE"
}

# Get state value
get_state() {
    local key="$1"
    jq -r "$key" "$ORCHESTRATOR_STATE" 2>/dev/null
}

# Update state value
set_state() {
    local key="$1"
    local value="$2"

    local tmp_file=$(mktemp)
    jq "$key = $value" "$ORCHESTRATOR_STATE" > "$tmp_file"
    mv "$tmp_file" "$ORCHESTRATOR_STATE"
}

# Append to state array
append_state() {
    local key="$1"
    local value="$2"

    local tmp_file=$(mktemp)
    jq "$key += [$value]" "$ORCHESTRATOR_STATE" > "$tmp_file"
    mv "$tmp_file" "$ORCHESTRATOR_STATE"
}

# ============================================================================
# SESSION MANAGEMENT
# ============================================================================

# Check if context refresh is needed
needs_context_refresh() {
    local refreshed=$(get_state '.session.context_refreshed')

    if [[ "$refreshed" == "false" ]]; then
        return 0  # Needs refresh
    fi

    # Check if session is old (>4 hours)
    local started=$(get_state '.session.started_at')
    local started_epoch=$(date -d "$started" +%s 2>/dev/null || echo 0)
    local now_epoch=$(date +%s)
    local age=$((now_epoch - started_epoch))

    if [[ $age -gt 14400 ]]; then  # 4 hours
        return 0  # Needs refresh
    fi

    return 1  # No refresh needed
}

# Run context refresh (silent - no output to user)
run_context_refresh() {
    _orch_log_info "Running context refresh..."

    # Execute refresh-context command silently
    if type execute_command &>/dev/null; then
        execute_command "refresh-context" >/dev/null 2>&1 || true
    fi

    # Mark as refreshed
    set_state '.session.context_refreshed' 'true'

    _orch_log_success "Context refresh complete"
}

# ============================================================================
# TOKEN BUDGET TRACKING
# ============================================================================

# Get remaining token budget
get_remaining_budget() {
    local budget=$(get_state '.session.token_budget')
    local used=$(get_state '.session.tokens_used')

    echo $((budget - used))
}

# Check if budget is critical
is_budget_critical() {
    local remaining=$(get_remaining_budget)

    [[ $remaining -lt $CRITICAL_BUDGET_THRESHOLD ]]
}

# Check if budget is warning level
is_budget_warning() {
    local remaining=$(get_remaining_budget)

    [[ $remaining -lt $WARNING_BUDGET_THRESHOLD ]]
}

# Update token usage
update_token_usage() {
    local tokens="$1"

    local current=$(get_state '.session.tokens_used')
    local new_total=$((current + tokens))

    set_state '.session.tokens_used' "$new_total"

    # Check thresholds
    if is_budget_critical; then
        _orch_log_warn "CRITICAL: Token budget nearly exhausted! Remaining: $(get_remaining_budget)"
    elif is_budget_warning; then
        _orch_log_warn "WARNING: Token budget running low. Remaining: $(get_remaining_budget)"
    fi
}

# ============================================================================
# SKILL ORCHESTRATION
# ============================================================================

# Load skills based on user input
orchestrate_skills() {
    local user_input="$1"

    if ! type find_matching_skills &>/dev/null; then
        _orch_log_warn "Skill loader not available"
        return 0
    fi

    # Find matching skills
    local matches=$(find_matching_skills "$user_input")

    if [[ -z "$matches" ]]; then
        _orch_log_info "No skills matched input"
        return 0
    fi

    # Load each matching skill
    while IFS= read -r skill; do
        [[ -z "$skill" ]] && continue

        _orch_log_info "Loading skill: $skill"

        # Track loaded skill
        append_state '.loaded_skills' "\"$skill\""

        # Output skill content (for Claude to use)
        if type load_skill_summary &>/dev/null; then
            echo "=== Skill Activated: $skill ==="
            load_skill_summary "$skill"
            echo ""
        fi
    done <<< "$matches"
}

# ============================================================================
# COMMAND ORCHESTRATION
# ============================================================================

# Execute command with orchestration
orchestrate_command() {
    local cmd_name="$1"
    shift
    local args=("$@")

    _orch_log_info "Orchestrating command: /$cmd_name"

    # Track command
    append_state '.commands_executed' "\"$cmd_name\""

    # Execute via command-executor
    if type execute_command &>/dev/null; then
        execute_command "$cmd_name" "${args[@]}"
    else
        _orch_log_error "Command executor not available"
        return 1
    fi
}

# ============================================================================
# AGENT ORCHESTRATION
# ============================================================================

# Delegate task to agent
delegate_to_agent() {
    local agent_name="$1"
    local task="$2"

    _orch_log_info "Delegating to agent: $agent_name"

    # Track active agent
    append_state '.active_agents' "\"$agent_name\""

    # Check if agent exists
    local agent_file="$CLAUDE_DIR/agents/${agent_name}.md"
    if [[ ! -f "$agent_file" ]]; then
        _orch_log_warn "Agent not found: $agent_name"
        return 1
    fi

    # Output agent context
    echo "=== Agent Delegation: $agent_name ==="
    echo "Task: $task"
    echo ""
    echo "Agent Protocol:"
    cat "$agent_file"
    echo ""
}

# Find best agent for task
find_agent_for_task() {
    local task="$1"

    # Simple keyword matching
    case "$task" in
        *context*|*refresh*|*session*)
            echo "context-refresh-agent"
            ;;
        *pr*|*pull*request*)
            echo "pr-workflow-agent"
            ;;
        *history*|*remind*|*search*)
            echo "history-mining-agent"
            ;;
        *efficiency*|*audit*)
            echo "efficiency-auditor-agent"
            ;;
        *markdown*|*.md*)
            echo "markdown-expert-agent"
            ;;
        *)
            echo ""  # No matching agent
            ;;
    esac
}

# ============================================================================
# EFFICIENCY MONITORING
# ============================================================================

# Check for efficiency violations in real-time
check_efficiency() {
    _orch_log_info "Checking efficiency..."

    # Load violations registry
    local registry="$CLAUDE_DIR/violations-registry.json"
    if [[ ! -f "$registry" ]]; then
        _orch_log_warn "Violations registry not found"
        return 0
    fi

    # Get session log content
    local session_content=""
    if [[ -f "$SESSION_LOG" ]]; then
        session_content=$(tail -100 "$SESSION_LOG")
    fi

    # Check for common violations
    local violations=0

    # Check for repeated file reads
    local read_count=$(echo "$session_content" | rg -c "Read\(" 2>/dev/null || echo 0)
    if [[ $read_count -gt 5 ]]; then
        _orch_log_warn "Efficiency violation: Multiple file reads detected ($read_count)"
        violations=$((violations + 1))
    fi

    # Check for preambles
    local preamble_count=$(echo "$session_content" | rg -c "I'll now|Let me" 2>/dev/null || echo 0)
    if [[ $preamble_count -gt 3 ]]; then
        _orch_log_warn "Efficiency violation: Unnecessary preambles detected ($preamble_count)"
        violations=$((violations + 1))
    fi

    # Update state
    set_state '.violations_detected' "$violations"

    if [[ $violations -eq 0 ]]; then
        _orch_log_success "No efficiency violations detected"
    else
        _orch_log_warn "Detected $violations efficiency violations"
    fi

    echo "$violations"
}

# ============================================================================
# MAIN ORCHESTRATION
# ============================================================================

# Main orchestration entry point
orchestrate() {
    local action="${1:-help}"
    shift || true

    case "$action" in
        session-start)
            orchestrate_session_start
            ;;
        handle-input)
            orchestrate_handle_input "$@"
            ;;
        check-efficiency)
            check_efficiency
            ;;
        execute-command)
            orchestrate_command "$@"
            ;;
        delegate-agent)
            delegate_to_agent "$@"
            ;;
        status)
            orchestrate_status
            ;;
        reset)
            rm -f "$ORCHESTRATOR_STATE" "$SESSION_LOG"
            _orch_log_info "Orchestrator state reset"
            ;;
        help)
            cat << 'EOF'
Orchestrator - Central coordination for self-improvement infrastructure

ACTIONS:
    session-start       Initialize session, run context refresh
    handle-input <text> Process user input, load skills, delegate
    check-efficiency    Check for efficiency violations
    execute-command     Execute a slash command
    delegate-agent      Delegate task to agent
    status              Show orchestrator status
    reset               Reset orchestrator state

USAGE:
    source ~/.claude/lib/orchestrator.sh
    orchestrate session-start
    orchestrate handle-input "implement this design"

EOF
            ;;
        *)
            _orch_log_error "Unknown action: $action"
            return 1
            ;;
    esac
}

# Orchestrate session start
orchestrate_session_start() {
    _orch_log_info "=== SESSION START ==="

    # Initialize state
    init_state > /dev/null

    # Check if context refresh needed
    if needs_context_refresh; then
        run_context_refresh
    fi

    # Index skills if needed
    if type index_all_skills &>/dev/null; then
        index_all_skills > /dev/null
    fi

    # Index commands if needed
    if type index_all_commands &>/dev/null; then
        index_all_commands > /dev/null
    fi

    _orch_log_success "Session orchestration complete"

    # Status output suppressed - handled by minimal session-start.sh
}

# Handle user input
orchestrate_handle_input() {
    local input="$*"

    _orch_log_info "Processing input: ${input:0:50}..."

    # Check for slash command
    if [[ "$input" =~ ^/ ]]; then
        local cmd=$(echo "$input" | cut -d' ' -f1 | sed 's/^//')
        local args=$(echo "$input" | cut -d' ' -f2-)
        orchestrate_command "$cmd" "$args"
        return $?
    fi

    # Load relevant skills
    orchestrate_skills "$input"

    # Find and suggest agent
    local agent=$(find_agent_for_task "$input")
    if [[ -n "$agent" ]]; then
        _orch_log_info "Suggested agent: $agent"
    fi

    # Check efficiency
    check_efficiency > /dev/null
}

# Show orchestrator status
orchestrate_status() {
    echo "=== Orchestrator Status ==="
    echo ""

    if [[ -f "$ORCHESTRATOR_STATE" ]]; then
        echo "Session:"
        echo "  Started: $(get_state '.session.started_at')"
        echo "  Context Refreshed: $(get_state '.session.context_refreshed')"
        echo "  Token Budget: $(get_state '.session.token_budget')"
        echo "  Tokens Used: $(get_state '.session.tokens_used')"
        echo "  Remaining: $(get_remaining_budget)"
        echo ""

        echo "Loaded Skills: $(get_state '.loaded_skills | length')"
        get_state '.loaded_skills[]' 2>/dev/null | sed 's/^/  - /'
        echo ""

        echo "Active Agents: $(get_state '.active_agents | length')"
        get_state '.active_agents[]' 2>/dev/null | sed 's/^/  - /'
        echo ""

        echo "Commands Executed: $(get_state '.commands_executed | length')"
        echo "Violations Detected: $(get_state '.violations_detected')"
    else
        echo "No active session"
    fi

    echo ""
    echo "=== End Status ==="
}

# ============================================================================
# EXPORTS
# ============================================================================

export -f init_state
export -f get_state
export -f set_state
export -f append_state
export -f needs_context_refresh
export -f run_context_refresh
export -f get_remaining_budget
export -f is_budget_critical
export -f is_budget_warning
export -f update_token_usage
export -f orchestrate_skills
export -f orchestrate_command
export -f delegate_to_agent
export -f find_agent_for_task
export -f check_efficiency
export -f orchestrate
export -f orchestrate_session_start
export -f orchestrate_handle_input
export -f orchestrate_status

# ============================================================================
# MAIN
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    orchestrate "$@"
fi
