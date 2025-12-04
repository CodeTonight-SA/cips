#!/usr/bin/env bash
#
# Session Start Hook
# Automatically runs at Claude Code session start
#
# PURPOSE:
#   This hook integrates with Claude Code to automatically:
#   1. Run context refresh protocol
#   2. Index skills and commands
#   3. Initialize efficiency monitoring
#   4. Load relevant skills based on project
#
# INTEGRATION:
#   Add to ~/.claude/settings.json:
#   {
#     "hooks": {
#       "session_start": "~/.claude/hooks/session-start.sh"
#     }
#   }
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
# LOGGING
# ============================================================================

log_hook() {
    local level="$1"
    shift
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) [SESSION-START][$level] $*" >> "$HOOK_LOG"
}

log_info() {
    log_hook "INFO" "$@"
}

log_error() {
    log_hook "ERROR" "$@"
}

log_success() {
    log_hook "SUCCESS" "$@"
}

log_warn() {
    log_hook "WARN" "$@"
}

# ============================================================================
# SOURCE LIBRARIES
# ============================================================================

source_libraries() {
    if [[ -f "$LIB_DIR/session-lifecycle.sh" ]]; then
        # shellcheck source=/dev/null
        source "$LIB_DIR/session-lifecycle.sh"
        log_info "Session lifecycle library loaded"
    fi

    if [[ -f "$LIB_DIR/agent-matcher.sh" ]]; then
        # shellcheck source=/dev/null
        source "$LIB_DIR/agent-matcher.sh"
        log_info "Agent matcher library loaded"
    fi

    if [[ -f "$LIB_DIR/embeddings.sh" ]]; then
        # shellcheck source=/dev/null
        source "$LIB_DIR/embeddings.sh"
        log_info "Embeddings library loaded"
    fi

    if [[ -f "$LIB_DIR/success-scorer.sh" ]]; then
        # shellcheck source=/dev/null
        source "$LIB_DIR/success-scorer.sh"
        log_info "Success scorer library loaded"
    fi
}

# ============================================================================
# MAIN HOOK LOGIC
# ============================================================================

main() {
    log_info "Session start hook triggered"

    # Source new orchestration libraries
    source_libraries

    # Source orchestrator if available
    if [[ -f "$LIB_DIR/orchestrator.sh" ]]; then
        # shellcheck source=/dev/null
        source "$LIB_DIR/orchestrator.sh"

        # Run session start orchestration
        orchestrate session-start 2>/dev/null

        log_success "Orchestrator session start complete"
    else
        log_info "Orchestrator not available, running basic setup"

        # Basic setup without orchestrator
        basic_session_setup
    fi

    # Detect session phase
    detect_phase

    # Check for previous state
    check_state

    # Detect project type and suggest skills
    detect_and_suggest

    # Run bash lint check on Claude infrastructure
    run_bash_lint

    # Initialize embeddings if available
    init_embeddings

    # Process any high-priority queued embeddings
    process_queued_embeddings

    # Calibrate thresholds based on accumulated feedback
    calibrate_thresholds_if_needed

    log_success "Session start hook complete"
}

detect_phase() {
    if command -v detect_session_phase &>/dev/null; then
        CURRENT_PHASE=$(detect_session_phase)
        log_info "Detected session phase: $CURRENT_PHASE"
    fi
}

check_state() {
    if command -v check_previous_state &>/dev/null; then
        STATE_MSG=$(check_previous_state 2>/dev/null) || true
        if [[ -n "$STATE_MSG" ]]; then
            log_info "Previous state detected"
        fi
    fi
}

# Initialize embeddings database
init_embeddings() {
    if command -v embeddings_check_deps &>/dev/null; then
        if embeddings_check_deps 2>/dev/null; then
            log_info "Embeddings system ready"
        else
            log_warn "Embeddings dependencies not available"
        fi
    fi
}

# Process queued embeddings from previous sessions
process_queued_embeddings() {
    if command -v process_high_priority &>/dev/null; then
        local result
        result=$(process_high_priority 2>/dev/null) || true
        if [[ -n "$result" ]]; then
            log_info "Processed queued embeddings: $result"
        fi
    fi
}

# Calibrate thresholds based on accumulated feedback
calibrate_thresholds_if_needed() {
    if command -v calibrate_thresholds &>/dev/null; then
        local result
        result=$(calibrate_thresholds 2>/dev/null) || true
        if [[ -n "$result" ]] && [[ "$result" != "No calibrations needed" ]]; then
            log_info "Threshold calibration: $result"
            echo ""
            echo "$result"
        fi
    fi
}

# Run bash linter on Claude infrastructure scripts
run_bash_lint() {
    if [[ -f "$LIB_DIR/bash-linter.sh" ]]; then
        source "$LIB_DIR/bash-linter.sh" 2>/dev/null || return 0

        local issues
        issues=$(lint_claude_scripts 2>&1) || true

        if echo "$issues" | rg -q "Issues in:"; then
            log_warn "Bash lint issues detected - run './crazy_script.sh lint-bash' for details"
        else
            log_info "Bash lint check passed"
        fi
    fi
}

# Basic session setup (fallback)
basic_session_setup() {
    log_info "Running basic session setup"

    # Index skills
    if [[ -f "$LIB_DIR/skill-loader.sh" ]]; then
        source "$LIB_DIR/skill-loader.sh"
        index_all_skills > /dev/null 2>&1 || true
        log_info "Skills indexed"
    fi

    # Index commands
    if [[ -f "$LIB_DIR/command-executor.sh" ]]; then
        source "$LIB_DIR/command-executor.sh"
        index_all_commands > /dev/null 2>&1 || true
        log_info "Commands indexed"
    fi
}

# Detect project type and suggest relevant skills
detect_and_suggest() {
    local project_dir=$(pwd)
    local suggestions=()

    # Detect Node.js project
    if [[ -f "$project_dir/package.json" ]]; then
        suggestions+=("gitignore-auto-setup")
        log_info "Detected Node.js project"
    fi

    # Detect Python project
    if [[ -f "$project_dir/requirements.txt" ]] || [[ -f "$project_dir/pyproject.toml" ]]; then
        suggestions+=("gitignore-auto-setup")
        log_info "Detected Python project"
    fi

    # Detect Figma integration
    if rg -q "figma" "$project_dir" 2>/dev/null; then
        suggestions+=("figma-to-code")
        log_info "Detected Figma references"
    fi

    # Detect frontend project
    if [[ -f "$project_dir/tailwind.config.js" ]] || [[ -f "$project_dir/postcss.config.js" ]]; then
        suggestions+=("mobile-responsive-ui")
        log_info "Detected frontend project"
    fi

    # Log suggestions
    if [[ ${#suggestions[@]} -gt 0 ]]; then
        log_info "Suggested skills: ${suggestions[*]}"
    fi
}

# ============================================================================
# OUTPUT TO CLAUDE
# ============================================================================

# Output context refresh reminder
output_reminder() {
    echo ""
    echo "=== SESSION START ==="
    echo ""

    # Show phase and state if available
    if [[ -n "${CURRENT_PHASE:-}" ]]; then
        echo "Phase: $CURRENT_PHASE"
    fi

    if [[ -n "${STATE_MSG:-}" ]]; then
        echo "$STATE_MSG"
        echo ""
    fi

    echo "Orchestrator has initialized:"
    echo "- Skills indexed"
    echo "- Commands indexed"
    echo "- Efficiency monitoring active"
    echo ""

    # Show available agents if matcher loaded
    if command -v get_top_agents &>/dev/null; then
        get_top_agents
        echo ""
    fi

    echo "Available commands:"
    echo "- /refresh-context  - Rebuild mental model"
    echo "- /create-pr        - PR automation"
    echo "- /remind-yourself  - Search past sessions"
    echo "- /audit-efficiency - Check efficiency"
    echo ""

    # Show efficiency rules summary if available
    if command -v get_efficiency_rules_summary &>/dev/null; then
        get_efficiency_rules_summary
        echo ""
    fi

    echo "Tip: Say \"RL++\" to confirm all systems loaded."
    echo ""
    echo "==================="
    echo ""
}

# ============================================================================
# EXECUTION
# ============================================================================

# Run main and capture any errors
if ! main 2>&1; then
    log_error "Session start hook failed"
    exit 1
fi

# Output reminder to Claude
output_reminder
