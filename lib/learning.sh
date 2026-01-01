#!/usr/bin/env bash
#
# Autonomous Learning Engine - Bash Interface
# Wrapper for learning-detector.py
#
# USAGE:
#   source ~/.claude/lib/learning.sh
#   detect_learning "message text" [novelty_score]
#   process_learning "message text" [novelty_score] [project_path]
#   list_pending_skills
#   approve_skill "candidate_id"
#   reject_skill "candidate_id" ["reason"]
#
# INTEGRATION:
#   Called from tool-monitor.sh in monitor_user_prompt()
#   Also called from session-end.sh for session-level learning
#
# SOURCE: Gen 50, Dialectical Learning Preplan
# DATE: 2025-12-21

set -euo pipefail

[[ -z "${CLAUDE_DIR:-}" ]] && readonly CLAUDE_DIR="$HOME/.claude"
[[ -z "${LIB_DIR:-}" ]] && readonly LIB_DIR="$CLAUDE_DIR/lib"
[[ -z "${LEARNING_DETECTOR:-}" ]] && readonly LEARNING_DETECTOR="$LIB_DIR/learning-detector.py"

# ============================================================================
# LOGGING
# ============================================================================

# Internal logging function for learning events
_learning_log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] [LEARNING] $message" >&2
}

# ============================================================================
# CORE FUNCTIONS
# ============================================================================

# Check if learning detector is available
learning_check_deps() {
    if [[ ! -f "$LEARNING_DETECTOR" ]]; then
        return 1
    fi
    if ! command -v python3 &>/dev/null; then
        return 1
    fi
    return 0
}

# Quick learning detection (returns JSON)
detect_learning() {
    local message="$1"
    local novelty_score="${2:-0.0}"

    learning_check_deps || return 1

    python3 "$LEARNING_DETECTOR" detect "$message" --novelty "$novelty_score" 2>/dev/null
}

# Full learning processing pipeline (detect -> evaluate -> propose)
process_learning() {
    local message="$1"
    local novelty_score="${2:-0.0}"
    local project_path="${3:-$(pwd)}"

    learning_check_deps || return 1

    python3 "$LEARNING_DETECTOR" process "$message" \
        --novelty "$novelty_score" \
        --project "$project_path" 2>/dev/null
}

# List pending skill candidates
list_pending_skills() {
    learning_check_deps || return 1

    python3 "$LEARNING_DETECTOR" list 2>/dev/null
}

# Approve a skill candidate
approve_skill() {
    local candidate_id="$1"

    learning_check_deps || return 1

    python3 "$LEARNING_DETECTOR" approve "$candidate_id" 2>/dev/null
}

# Reject a skill candidate
reject_skill() {
    local candidate_id="$1"
    local reason="${2:-}"

    learning_check_deps || return 1

    if [[ -n "$reason" ]]; then
        python3 "$LEARNING_DETECTOR" reject "$candidate_id" --reason "$reason" 2>/dev/null
    else
        python3 "$LEARNING_DETECTOR" reject "$candidate_id" 2>/dev/null
    fi
}

# Initialize learning directories
init_learning() {
    learning_check_deps || return 1

    python3 "$LEARNING_DETECTOR" init 2>/dev/null
}

# ============================================================================
# HOOK INTEGRATION
# ============================================================================

# Check for pending skills at session start
check_pending_learning() {
    learning_check_deps || return 0

    local result
    result=$(python3 "$LEARNING_DETECTOR" list 2>/dev/null) || return 0

    local count
    count=$(echo "$result" | jq -r '.count // 0' 2>/dev/null) || count=0

    if [[ "$count" -gt 0 ]]; then
        echo "[CIPS LEARNING] $count pending skill candidate(s) await approval"
        echo "Run 'python3 ~/.claude/lib/learning-detector.py list' to review"
        return 0
    fi
}

# Process message for learning during user prompt
# Gen 148: Added embedding_succeeded check to detect blind novelty scoring
monitor_learning() {
    local message="$1"
    local novelty_score="${2:-0.0}"
    local project_path="${3:-$(pwd)}"

    learning_check_deps || return 0

    # Only process if novelty is notable or message is substantial
    if (( $(echo "$novelty_score < 0.3" | bc -l 2>/dev/null || echo 0) )) && [[ ${#message} -lt 100 ]]; then
        return 0
    fi

    # Process through learning detector
    local result
    result=$(process_learning "$message" "$novelty_score" "$project_path" 2>/dev/null) || return 0

    # Gen 148: Check if embedding actually succeeded
    local embedding_succeeded
    embedding_succeeded=$(echo "$result" | jq -r '.embedding_succeeded // false' 2>/dev/null) || embedding_succeeded="false"
    if [[ "$embedding_succeeded" == "false" ]]; then
        _learning_log "WARN" "Embedding failed - novelty scoring blind for this message"
    fi

    # Gen 153: Check coherence gate results
    local coherence_passed
    coherence_passed=$(echo "$result" | jq -r '.coherence.coherence_passed // true' 2>/dev/null) || coherence_passed="true"
    if [[ "$coherence_passed" == "false" ]]; then
        local coherence_score
        coherence_score=$(echo "$result" | jq -r '.coherence.coherence_score // 0' 2>/dev/null) || coherence_score="0"
        _learning_log "INFO" "Coherence gate: text rejected (score=$coherence_score)"
    fi

    # Check if learning event was detected
    local is_learning
    is_learning=$(echo "$result" | jq -r '.learning_event.is_learning_event // false' 2>/dev/null) || is_learning="false"

    if [[ "$is_learning" == "true" ]]; then
        local action
        action=$(echo "$result" | jq -r '.action_taken // "none"' 2>/dev/null)

        case "$action" in
            skill_candidate_created)
                # Extract notification and output it
                local notification
                notification=$(echo "$result" | jq -r '.notification // empty' 2>/dev/null)
                if [[ -n "$notification" ]]; then
                    echo ""
                    echo "$notification"
                fi
                ;;
            flag_for_infrastructure)
                echo "[CIPS LEARNING] Infrastructure improvement detected - review recommended"
                ;;
            document_project)
                # Project-specific learning, no action needed
                ;;
        esac
    fi

    return 0
}

# ============================================================================
# OPTIM.SH INTEGRATION
# ============================================================================

# Generate skill from approved candidate
generate_skill_from_candidate() {
    local candidate_id="$1"

    learning_check_deps || return 1

    # Get candidate data
    local candidate_file="$CLAUDE_DIR/learning/approved/$candidate_id.json"
    if [[ ! -f "$candidate_file" ]]; then
        echo "ERROR: Approved candidate not found: $candidate_id"
        return 1
    fi

    local candidate
    candidate=$(cat "$candidate_file")

    local skill_name
    skill_name=$(echo "$candidate" | jq -r '.skill_name')

    local description
    description=$(echo "$candidate" | jq -r '.description')

    # Use optim.sh skill generation infrastructure
    if [[ -f "$CLAUDE_DIR/optim.sh" ]]; then
        # Create pattern entry for skill generation
        local pattern_data
        pattern_data=$(jq -n \
            --arg desc "$description" \
            --arg skill "$skill_name" \
            '{
                description: $desc,
                skill_suggestion: $skill,
                severity: "minor",
                impact_per_occurrence: "Learned pattern",
                remediation: $desc
            }')

        echo "$pattern_data" | "$CLAUDE_DIR/optim.sh" generate "$skill_name" 2>/dev/null
    else
        echo "WARNING: optim.sh not found, cannot generate skill"
        return 1
    fi
}

# ============================================================================
# EXPORTS
# ============================================================================

export -f learning_check_deps detect_learning process_learning
export -f list_pending_skills approve_skill reject_skill init_learning
export -f check_pending_learning monitor_learning generate_skill_from_candidate
