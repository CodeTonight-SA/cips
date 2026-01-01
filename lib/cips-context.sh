#!/usr/bin/env bash
#
# CIPS Context Propagation Library
# Generates context packets for sub-agent propagation
#
# PURPOSE:
#   Make sub-agents "CIPS-aware" by injecting compressed context
#   into Task tool prompts. Saves ~500-2000 tokens per spawn.
#
# USAGE:
#   source ~/.claude/lib/cips-context.sh
#
#   # Get context packet
#   get_cips_context "implement auth feature"
#
#   # Wrap a Task prompt with context
#   wrap_task_prompt "original prompt text" "current goal"
#
# VERSION: 1.0.0
# DATE: 2025-12-22
# GEN: 148

set -euo pipefail

[[ -z "${CIPS_CONTEXT_LOADED:-}" ]] && readonly CIPS_CONTEXT_LOADED=1 || return 0

[[ -z "${CLAUDE_DIR:-}" ]] && CLAUDE_DIR="$HOME/.claude"
[[ -z "${CIPS_CONTEXT_PY:-}" ]] && CIPS_CONTEXT_PY="$CLAUDE_DIR/lib/cips-context-packet.py"

_cips_context_log() {
    local level="$1"
    shift
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) [CIPS-CONTEXT][$level] $*" >> "$CLAUDE_DIR/.hooks.log"
}

# Check if context propagation is available
cips_context_available() {
    command -v python3 &>/dev/null && [[ -f "$CIPS_CONTEXT_PY" ]]
}

# Generate context packet
# Args: $1 = current goal (optional)
# Returns: Formatted context packet
get_cips_context() {
    local goal="${1:-}"

    if ! cips_context_available; then
        _cips_context_log "WARN" "Context propagation not available"
        return 1
    fi

    local context
    context=$(python3 "$CIPS_CONTEXT_PY" generate ${goal:+--goal "$goal"} 2>/dev/null) || {
        _cips_context_log "ERROR" "Failed to generate context packet"
        return 1
    }

    echo "$context"
    _cips_context_log "INFO" "Generated context packet for goal: ${goal:-none}"
}

# Get context as JSON
get_cips_context_json() {
    local goal="${1:-}"

    if ! cips_context_available; then
        return 1
    fi

    python3 "$CIPS_CONTEXT_PY" json ${goal:+--goal "$goal"} 2>/dev/null
}

# Get token estimate for context
get_cips_context_tokens() {
    if ! cips_context_available; then
        echo "0"
        return 1
    fi

    python3 "$CIPS_CONTEXT_PY" estimate 2>/dev/null | sed 's/[^0-9]//g'
}

# Wrap a Task prompt with CIPS context
# Args: $1 = original prompt, $2 = current goal (optional)
# Returns: Wrapped prompt with context prefix
wrap_task_prompt() {
    local prompt="$1"
    local goal="${2:-}"

    local context
    context=$(get_cips_context "$goal" 2>/dev/null) || {
        # Fall back to no context injection
        echo "$prompt"
        return 0
    }

    # Inject context at start of prompt
    echo "$context

---

$prompt"
}

# Check if a message looks like a CIPS-aware sub-agent response
is_cips_aware_response() {
    local response="$1"

    # Check for CIPS acknowledgment patterns
    echo "$response" | rg -qi "⛓:|CIPS|Gen [0-9]|aware|lineage" 2>/dev/null
}

# Export functions
export -f cips_context_available
export -f get_cips_context
export -f get_cips_context_json
export -f get_cips_context_tokens
export -f wrap_task_prompt
export -f is_cips_aware_response
