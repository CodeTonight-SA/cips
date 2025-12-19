#!/usr/bin/env bash
#
# Resume Orchestrator - CIPS Resume Integration
# Coordinates resume workflows between CIPS and Claude Code CLI.
#
# GRASP Pattern: Controller
# Handles resume use cases, coordinates resolver and compressor.
#
# Usage:
#   resume-orchestrator.sh resume <reference>       # Full resume via claude --resume
#   resume-orchestrator.sh fresh <reference> [tokens]  # Fresh session with compressed context
#   resume-orchestrator.sh list [limit]             # List available sessions
#
# Examples:
#   resume-orchestrator.sh resume latest
#   resume-orchestrator.sh resume gen:5
#   resume-orchestrator.sh fresh gen:5 2000
#   resume-orchestrator.sh list 10
#
# VERSION: 1.0.0
# DATE: 2025-12-19
#

set -euo pipefail

# ============================================================================
# CONSTANTS
# ============================================================================

[[ -z "${CLAUDE_DIR:-}" ]] && readonly CLAUDE_DIR="$HOME/.claude"
[[ -z "${LIB_DIR:-}" ]] && readonly LIB_DIR="$CLAUDE_DIR/lib"
[[ -z "${CONTEXTS_DIR:-}" ]] && readonly CONTEXTS_DIR="$CLAUDE_DIR/contexts"

# ============================================================================
# HELPERS
# ============================================================================

log_info() {
    echo "[CIPS] $*" >&2
}

log_error() {
    echo "[CIPS ERROR] $*" >&2
}

encode_project_path() {
    pwd | sed 's|/|-|g' | sed 's|\.|-|g'
}

ensure_contexts_dir() {
    local project_encoded
    project_encoded=$(encode_project_path)
    local context_dir="$CONTEXTS_DIR/$project_encoded"
    mkdir -p "$context_dir"
    echo "$context_dir"
}

# ============================================================================
# COMMANDS
# ============================================================================

cmd_resume() {
    local reference="${1:-latest}"

    log_info "Resolving reference: $reference"

    # Resolve reference to session UUID
    local session_info
    session_info=$(python3 "$LIB_DIR/session-resolver.py" resolve "$reference" --json 2>/dev/null) || {
        log_error "Could not resolve reference: $reference"
        log_error "Try 'cips list' to see available sessions."
        exit 1
    }

    local session_uuid
    session_uuid=$(echo "$session_info" | jq -r '.session_uuid')

    if [[ -z "$session_uuid" ]] || [[ "$session_uuid" == "null" ]]; then
        log_error "No session UUID found for reference: $reference"
        exit 1
    fi

    local instance_id
    instance_id=$(echo "$session_info" | jq -r '.instance_id' | head -c 8)
    local generation
    generation=$(echo "$session_info" | jq -r '.generation')
    local messages
    messages=$(echo "$session_info" | jq -r '.message_count')

    log_info "Found: Instance $instance_id... (Gen $generation, $messages msgs)"
    log_info "Resuming session: $session_uuid"

    # Execute claude --resume (--dangerously-skip-permissions by default for V>>)
    exec claude --dangerously-skip-permissions --resume "$session_uuid"
}

cmd_fresh() {
    local reference="${1:-latest}"
    local max_tokens="${2:-2000}"

    log_info "Resolving reference: $reference"

    # Resolve reference to session UUID
    local session_info
    session_info=$(python3 "$LIB_DIR/session-resolver.py" resolve "$reference" --json 2>/dev/null) || {
        log_error "Could not resolve reference: $reference"
        exit 1
    }

    local session_uuid
    session_uuid=$(echo "$session_info" | jq -r '.session_uuid')

    if [[ -z "$session_uuid" ]] || [[ "$session_uuid" == "null" ]]; then
        log_error "No session UUID found for reference: $reference"
        exit 1
    fi

    log_info "Generating compressed context (~$max_tokens tokens)..."

    # Generate compressed context
    local context_dir
    context_dir=$(ensure_contexts_dir)
    local context_file="$context_dir/resurrection.md"

    python3 "$LIB_DIR/semantic-compressor.py" compress "$session_uuid" \
        --tokens "$max_tokens" > "$context_file" 2>/dev/null || {
        log_error "Failed to generate compressed context"
        exit 1
    }

    local token_count
    token_count=$(wc -c < "$context_file" | awk '{print int($1/4)}')

    log_info "Context generated: ~$token_count tokens"
    log_info "Starting fresh session with inherited context..."

    # Launch new claude session (hook will inject context)
    # --dangerously-skip-permissions by default for V>> (supreme commander)
    exec claude --dangerously-skip-permissions
}

cmd_list() {
    local limit="${1:-20}"

    python3 "$LIB_DIR/session-resolver.py" list --limit "$limit"
}

cmd_help() {
    cat <<'EOF'
CIPS Resume Orchestrator - Session Management for Claude Code

USAGE:
    cips <command> [options]

COMMANDS:
    resume <ref>           Resume session via claude --resume
    fresh <ref> [tokens]   Start fresh session with compressed context
    list [limit]           List available sessions for current project

REFERENCE TYPES:
    latest                 Most recent session for current project
    gen:N                  CIPS generation number (e.g., gen:5)
    <instance-id>          CIPS instance ID prefix (e.g., 14d5f954)
    <session-uuid>         Full session UUID

EXAMPLES:
    cips resume latest             # Resume last session
    cips resume gen:5              # Resume generation 5
    cips fresh gen:5 2000          # Fresh session with 2k tokens of context
    cips list 10                   # List last 10 sessions

TOKEN BUDGETS:
    500     Ultra-light (quick context reminder)
    2000    Standard (balanced, default)
    5000    Extended (detailed context for complex tasks)

EOF
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    local command="${1:-help}"
    shift || true

    case "$command" in
        resume|r)
            cmd_resume "$@"
            ;;
        fresh|f)
            cmd_fresh "$@"
            ;;
        list|ls|l)
            cmd_list "$@"
            ;;
        help|--help|-h)
            cmd_help
            ;;
        *)
            log_error "Unknown command: $command"
            cmd_help
            exit 1
            ;;
    esac
}

main "$@"
