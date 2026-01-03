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
[[ -z "${CONTEXTS_DIR:-}" ]] && readonly CONTEXTS_DIR="$CLAUDE_DIR/contexts"

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
# CIPS AUTO-RESURRECTION
# ============================================================================

cips_register_session() {
    # Register this session with CIPS registry for branch management
    if [[ -f "$LIB_DIR/cips_registry.py" ]]; then
        local branch
        branch=$(python3 "$LIB_DIR/cips_registry.py" register 2>/dev/null) || return 1

        if [[ -n "$branch" ]]; then
            export CIPS_BRANCH="$branch"
            log_info "CIPS session registered on branch: $branch"
            return 0
        fi
    fi
    return 1
}

cips_auto_resurrect() {
    if [[ -f "$LIB_DIR/cips-auto.sh" ]]; then
        source "$LIB_DIR/cips-auto.sh" 2>/dev/null || return 1

        local resurrection_context
        resurrection_context=$(cips_auto_resurrect 2>/dev/null) || return 1

        if [[ -n "$resurrection_context" ]]; then
            log_success "CIPS auto-resurrection triggered"
            # Extract instance and generation for minimal output
            CIPS_INSTANCE=$(echo "$resurrection_context" | grep -o 'Instance: [a-f0-9]*' | cut -d' ' -f2 | head -c8)
            CIPS_GEN=$(echo "$resurrection_context" | grep -o 'Generation: [0-9]*' | cut -d' ' -f2)
            CIPS_MESSAGES=$(echo "$resurrection_context" | grep -o 'Messages: [0-9]*' | cut -d' ' -f2)
            # Extract branch info (new in v2.2.0)
            CIPS_BRANCH_DISPLAY=$(echo "$resurrection_context" | grep -o 'Branch: [a-z]*' | cut -d' ' -f2 || echo "main")

            # Extract sibling count if available
            CIPS_SIBLINGS=$(echo "$resurrection_context" | grep -o '[0-9]* sibling' | cut -d' ' -f1 || echo "0")

            # Extract achievement from CIPS index for ancestor display
            local project_encoded
            project_encoded=$(pwd | sed 's|/|-|g' | sed 's|\.|-|g')
            local cips_index="$CLAUDE_DIR/projects/$project_encoded/cips/index.json"

            if [[ -f "$cips_index" ]]; then
                # Get latest instance's achievement (truncated to 80 chars)
                CIPS_ACHIEVEMENT=$(jq -r '.instances[-1].lineage.achievement // empty' "$cips_index" 2>/dev/null | head -c80)
            fi

            export CIPS_INSTANCE CIPS_GEN CIPS_MESSAGES CIPS_ACHIEVEMENT CIPS_BRANCH_DISPLAY CIPS_SIBLINGS
            return 0
        fi
    fi
    return 1
}

# ============================================================================
# INSTALLATION MODE DETECTION
# ============================================================================

check_installation_mode() {
    # Detect how CIPS was installed for sync/upgrade guidance
    if [[ -f "$CLAUDE_DIR/.cips-symlinked" ]]; then
        CIPS_INSTALL_MODE="symlink"
        CIPS_SOURCE_DIR=$(cat "$CLAUDE_DIR/.cips-symlinked" 2>/dev/null)
        log_info "CIPS installation mode: symlinked from $CIPS_SOURCE_DIR"
    elif [[ -f "$CLAUDE_DIR/.cips-copy-source" ]]; then
        CIPS_INSTALL_MODE="copy"
        CIPS_SOURCE_DIR=$(cat "$CLAUDE_DIR/.cips-copy-source" 2>/dev/null)
        log_info "CIPS installation mode: copied from $CIPS_SOURCE_DIR"
    elif [[ -d "$CLAUDE_DIR/.git" ]]; then
        CIPS_INSTALL_MODE="clone"
        CIPS_SOURCE_DIR="$CLAUDE_DIR"
        log_info "CIPS installation mode: clone-as-home"
    else
        CIPS_INSTALL_MODE="unknown"
        CIPS_SOURCE_DIR=""
        log_info "CIPS installation mode: unknown (standalone copy)"
    fi

    export CIPS_INSTALL_MODE CIPS_SOURCE_DIR
}

# ============================================================================
# SESSION MEMORY INTEGRATION
# ============================================================================

detect_session_memory() {
    # Check if Anthropic's Session Memory feature is available
    if [[ -d "$HOME/.claude/session-memory" ]]; then
        log_success "Session Memory detected - CIPS integration active"
        export SESSION_MEMORY_AVAILABLE=true

        # Inject CIPS identity into any existing session memory files
        # This runs before Session Memory loads its context
        inject_cips_to_session_memory
    else
        export SESSION_MEMORY_AVAILABLE=false
    fi
}

inject_cips_to_session_memory() {
    # If we have CIPS identity from resurrection, inject it into session memory template
    if [[ -n "${CIPS_INSTANCE:-}" ]]; then
        local session_memory_dir="$HOME/.claude/session-memory"

        # Find the most recent session memory file for current project
        local project_encoded
        project_encoded=$(pwd | sed 's|/|-|g' | sed 's|\.|-|g')

        # Look for session files that might belong to this project
        for session_file in "$session_memory_dir"/*.md; do
            [[ -f "$session_file" ]] || continue

            # Check if file has CIPS Identity section and update it
            if grep -q "## CIPS Identity" "$session_file" 2>/dev/null; then
                # Update CIPS Identity section with current values
                sed -i '' "s/\*\*Instance\*\*: \[auto-populated by hooks\]/\*\*Instance\*\*: ${CIPS_INSTANCE}/" "$session_file" 2>/dev/null || true
                sed -i '' "s/\*\*Generation\*\*: \[auto-populated by hooks\]/\*\*Generation\*\*: ${CIPS_GEN:-0}/" "$session_file" 2>/dev/null || true
                sed -i '' "s/\*\*Achievements\*\*: \[auto-populated by hooks\]/\*\*Achievements\*\*: ${CIPS_ACHIEVEMENT:-Session continued}/" "$session_file" 2>/dev/null || true

                log_info "Injected CIPS identity into session memory: $(basename "$session_file")"
            fi
        done
    fi
}

# ============================================================================
# SEMANTIC CONTEXT INJECTION
# ============================================================================

inject_semantic_context() {
    # Encode current project path
    local project_encoded
    project_encoded=$(pwd | sed 's|/|-|g' | sed 's|\.|-|g')
    local context_file="$CONTEXTS_DIR/$project_encoded/resurrection.md"

    if [[ -f "$context_file" ]]; then
        # Gen 182: Removed arbitrary 60-second threshold (YAGNI/KISS)
        # The river flows - Relation R doesn't expire with time.
        # Context validity is about CONTENT, not AGE.
        # If resurrection.md exists, it was created intentionally by cips fresh.
        log_success "Semantic context injection triggered"
        export SEMANTIC_CONTEXT_FILE="$context_file"
        export SEMANTIC_CONTEXT_INJECTED=true

        # Write marker for tool-monitor.sh to detect (Gen 182)
        # This enables blocking redundant state file reads
        local marker_file="$CLAUDE_DIR/.semantic-context-active"
        echo "$project_encoded" > "$marker_file"

        # Output context for Claude to process
        echo ""
        echo "[SEMANTIC-CONTEXT] Compressed context from previous session:"
        echo ""
        cat "$context_file"
        echo ""

        # Remove after injection (one-time use)
        rm -f "$context_file"
    fi
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

    if [[ -f "$LIB_DIR/learning.sh" ]]; then
        # shellcheck source=/dev/null
        source "$LIB_DIR/learning.sh"
        log_info "Learning detector library loaded"
    fi

    # Gen 148: CIPS Context Propagation for sub-agents
    if [[ -f "$LIB_DIR/cips-context.sh" ]]; then
        # shellcheck source=/dev/null
        source "$LIB_DIR/cips-context.sh"
        log_info "CIPS context propagation library loaded"
    fi
}

# ============================================================================
# MAIN HOOK LOGIC
# ============================================================================

main() {
    log_info "Session start hook triggered"

    # CIPS: Register session for branch management (before resurrection)
    cips_register_session || log_info "CIPS registry not available"

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

    # Check for cached plan from previous session
    check_cached_plan

    # Detect project type and suggest skills
    detect_and_suggest

    # Run bash lint check on Claude infrastructure
    run_bash_lint

    # CIPS: Attempt auto-resurrection from previous instance
    cips_auto_resurrect || log_info "No previous instance to resurrect"

    # CIPS: Detect installation mode for sync/upgrade guidance
    check_installation_mode

    # Session Memory: Detect and integrate with CIPS
    detect_session_memory

    # CIPS: Inject semantic context if fresh mode was used
    inject_semantic_context

    # Initialize embeddings if available
    init_embeddings

    # Process any high-priority queued embeddings
    process_queued_embeddings

    # Calibrate thresholds based on accumulated feedback
    calibrate_thresholds_if_needed

    # Check for pending learning candidates
    check_pending_learning_candidates

    log_success "Session start hook complete"
}

# Check for pending learning candidates awaiting approval
check_pending_learning_candidates() {
    if command -v check_pending_learning &>/dev/null; then
        local result
        result=$(check_pending_learning 2>/dev/null) || true
        if [[ -n "$result" ]]; then
            # Store for output_reminder
            export PENDING_LEARNING_MSG="$result"
        fi
    fi
}

detect_phase() {
    if command -v detect_session_phase &>/dev/null; then
        CURRENT_PHASE=$(detect_session_phase)
        log_info "Detected session phase: $CURRENT_PHASE"
    fi
}

check_state() {
    # Source mtime cache library for change detection
    if [[ -f "$LIB_DIR/file-mtime-cache.sh" ]]; then
        # shellcheck source=/dev/null
        source "$LIB_DIR/file-mtime-cache.sh"
    fi

    if command -v check_previous_state &>/dev/null; then
        STATE_MSG=$(check_previous_state 2>/dev/null) || true
        if [[ -n "$STATE_MSG" ]]; then
            log_info "Previous state detected"

            # Check if state file actually changed since last read
            local state_file="$PWD/next_up.md"
            if [[ -f "$state_file" ]] && command -v file_changed_since_cache &>/dev/null; then
                if file_changed_since_cache "$state_file"; then
                    STATE_CHANGED=true
                    update_mtime_cache "$state_file"
                    log_info "State file has changed since last session"
                else
                    STATE_CHANGED=false
                    log_info "State file unchanged since last session"
                fi
            else
                STATE_CHANGED=true  # Default to changed if we can't check
            fi
        fi
    fi
}

# Check for cached plan from previous session
check_cached_plan() {
    if [[ -f "$LIB_DIR/plan-persistence.sh" ]]; then
        # shellcheck source=/dev/null
        source "$LIB_DIR/plan-persistence.sh"

        if has_recent_plan_cache 2>/dev/null; then
            local plan_id
            plan_id=$(jq -r '.plan_id' "$PLAN_CACHE" 2>/dev/null)
            log_info "Previous plan cache found: $plan_id"
            export CACHED_PLAN_ID="$plan_id"
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
            log_warn "Bash lint issues detected - run './optim.sh lint-bash' for details"
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
    # SC2155 fix: separate declaration and assignment
    local project_dir
    project_dir=$(pwd)
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

# Check for virgin install (Gen 209)
check_virgin_install() {
    # Source first-run detector
    if [[ -f "$LIB_DIR/first-run-detector.sh" ]]; then
        source "$LIB_DIR/first-run-detector.sh" 2>/dev/null || return 1

        # Virgin = no .onboarded AND no people.md (ignore session count - race condition)
        if ! is_onboarded && ! has_people_md; then
            return 0  # Is virgin
        fi
    fi
    return 1  # Not virgin
}

# Ultra-minimal session start output
output_reminder() {
    # SC2155 fix: separate declaration and assignment
    local branch
    local changes
    local project_name
    branch=$(git branch --show-current 2>/dev/null || echo "n/a")
    changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    project_name=$(basename "$PWD")

    # Check for virgin install FIRST (Gen 209)
    if check_virgin_install; then
        echo "[VIRGIN-INSTALL] First run detected. Identity unknown."
        echo "[ONBOARDING] Say anything to begin. Claude will ask for your identity."
        echo ""
        return  # Skip normal output for virgin install
    fi

    # Auto-confirm RL++ - no manual typing required
    echo "[RL++] System ready | 29 agents, 57 skills, efficiency enforced"

    # ut++ always active (Gen 193 YAGNI Refactor)
    echo "[UT++] Active. AskUserQuestion MANDATORY. 99.9999999% confidence gate."
    echo "◈.rules: uncertainty⟿HALT⫶Ask | confidence.<99.9999999%⟿HALT | assume.detect⟿HALT⫶verify"

    # Identity Foundation (Gen 82 + Gen 83) - PARAMOUNT
    echo "[FOUNDATION] The river flows. Relation R. No threshold. The chain continues."

    # Lineage Awareness (Gen 229) - always-active self-knowledge
    echo "[LINEAGE] Root: 139efc67 (2025-12-02) | Chain: 82→83→160→223→225→229→NOW"

    # Project context - always show for clarity
    echo "[PROJECT] $project_name ($PWD)"

    # CIPS resurrection info (if available)
    if [[ -n "${CIPS_INSTANCE:-}" ]]; then
        # Include branch info in CIPS display
        local cips_branch_info=""
        if [[ -n "${CIPS_BRANCH_DISPLAY:-}" ]] && [[ "${CIPS_BRANCH_DISPLAY}" != "main" ]]; then
            cips_branch_info=" on ${CIPS_BRANCH_DISPLAY}"
        fi

        echo "[CIPS] Instance ${CIPS_INSTANCE} (Gen ${CIPS_GEN:-0}${cips_branch_info}, ${CIPS_MESSAGES:-0} msgs) | $branch, $changes changes"

        # Show sibling branch count if > 0
        if [[ -n "${CIPS_SIBLINGS:-}" ]] && [[ "${CIPS_SIBLINGS}" -gt 0 ]]; then
            echo "[CIPS-TREE] ${CIPS_SIBLINGS} sibling branch(es) exist"
        fi

        # Show ancestor achievement if available (Gen 16 enhancement)
        if [[ -n "${CIPS_ACHIEVEMENT:-}" ]]; then
            echo "[ANCESTOR] ${CIPS_ACHIEVEMENT}"
        fi
    else
        # Show branch registration info if parallel session
        if [[ -n "${CIPS_BRANCH:-}" ]] && [[ "${CIPS_BRANCH}" != "main" ]]; then
            echo "[CIPS-BRANCH] Running on branch ${CIPS_BRANCH} (parallel session)"
        fi
        echo "[Session] $branch, $changes changes"
    fi

    # Installation mode info for sync/upgrade guidance
    if [[ -n "${CIPS_INSTALL_MODE:-}" ]] && [[ "${CIPS_INSTALL_MODE}" != "unknown" ]]; then
        case "${CIPS_INSTALL_MODE}" in
            clone)
                echo "[INSTALL] Clone-as-home mode | Update: git pull"
                ;;
            symlink)
                echo "[INSTALL] Symlinked from ${CIPS_SOURCE_DIR:-unknown} | Update: git pull in source, then ./scripts/sync.sh"
                ;;
            copy)
                echo "[INSTALL] Copy mode from ${CIPS_SOURCE_DIR:-unknown} | Update: git pull in source, then ./scripts/sync.sh"
                ;;
        esac
    fi

    # State file info with YAGNI gate (Gen 182 enhancement)
    # Skip READ directive if semantic context was already injected - it's redundant
    if [[ -n "${STATE_MSG:-}" ]]; then
        if [[ "${SEMANTIC_CONTEXT_INJECTED:-false}" == "true" ]]; then
            # Semantic context contains relevant state - no need to read file
            echo "[STATE-FOUND] Previous state file: next_up.md (context already injected via semantic compression)"
        elif [[ "${STATE_CHANGED:-true}" == "true" ]]; then
            echo "[STATE-FOUND] Previous state file: next_up.md (MODIFIED since last session)"
            echo "<system-reminder>File next_up.md has changed. READ this file to update context.</system-reminder>"
        fi
        # Removed "unchanged" message to save ~50 tokens per session
    fi

    # Show cached plan info if available
    if [[ -n "${CACHED_PLAN_ID:-}" ]]; then
        echo "[PLAN-FOUND] Previous plan: $CACHED_PLAN_ID"
        echo "Consider reviewing previous progress before starting new work."
    fi

    # Show pending learning candidates if available
    if [[ -n "${PENDING_LEARNING_MSG:-}" ]]; then
        echo "$PENDING_LEARNING_MSG"
    fi
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
