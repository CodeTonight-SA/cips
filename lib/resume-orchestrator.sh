#!/usr/bin/env bash
#
# CIPS CLI - Claude Instance Preservation System
# Coordinates resume workflows, branch management, and session orchestration.
#
# GRASP Pattern: Controller
# Handles resume use cases, coordinates resolver and compressor.
# Supports branching model for parallel sessions.
# Supports polymorphic merge of branches (Phase 6).
#
# Usage:
#   cips resume <reference>           # Full resume via claude --resume
#   cips fresh <reference> [tokens]   # Fresh session with compressed context
#   cips list [limit]                 # List available sessions
#   cips branches                     # List all branches
#   cips status                       # Show active sessions
#   cips merge <ref> <ref> [--into]   # Merge branches
#   cips tree                         # View tree structure
#   cips resume branch:alpha          # Resume from specific branch
#
# Examples:
#   cips resume latest
#   cips resume gen:5
#   cips resume branch:alpha
#   cips fresh gen:5 2000
#   cips branches
#   cips status
#   cips merge alpha bravo --into main
#   cips tree
#
# VERSION: 3.0.0 (Polymorphic Merge)
# DATE: 2025-12-20
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
    local show_branches="${2:-}"

    if [[ "$show_branches" == "--branches" ]] || [[ "$show_branches" == "-b" ]]; then
        # Delegate to branches command
        cmd_branches
        return
    fi

    python3 "$LIB_DIR/session-resolver.py" list --limit "$limit"
}

cmd_branches() {
    log_info "Listing branches for current project..."

    python3 "$LIB_DIR/instance-resurrector.py" branches || {
        log_error "No branches found. Use 'cips list' to see sessions."
        exit 1
    }
}

cmd_status() {
    log_info "Active sessions for current project..."

    python3 "$LIB_DIR/cips_registry.py" status || {
        log_error "No active sessions found."
        exit 1
    }
}

cmd_register() {
    # Internal: Register current session with registry
    python3 "$LIB_DIR/cips_registry.py" register
}

cmd_deregister() {
    # Internal: Deregister current session from registry
    python3 "$LIB_DIR/cips_registry.py" deregister
}

cmd_merge() {
    # Merge multiple branches into one
    # Usage: cips merge <ref1> <ref2> [--into <branch>] [--dry-run]
    local refs=()
    local target_branch="main"
    local dry_run=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --into)
                target_branch="${2:-main}"
                shift 2
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            *)
                refs+=("$1")
                shift
                ;;
        esac
    done

    if [[ ${#refs[@]} -lt 2 ]]; then
        log_error "Merge requires at least 2 branch references"
        log_info "Usage: cips merge <ref1> <ref2> [--into <branch>]"
        log_info "Example: cips merge alpha bravo --into main"
        exit 1
    fi

    log_info "Merge: ${refs[*]} -> $target_branch"

    if [[ "$dry_run" == "true" ]]; then
        log_info "DRY RUN - No changes will be made"
        python3 -c "
import sys
sys.path.insert(0, '$LIB_DIR')
from cips_merged import merge_by_references
from cips_atomic import find_atomic_by_reference
from path_encoding import encode_project_path
from pathlib import Path

project_path = Path.cwd()
encoded = encode_project_path(project_path)
instances_dir = Path.home() / '.claude' / 'projects' / encoded / 'cips'

refs = '${refs[*]}'.split()
print(f'Source references: {refs}')
print(f'Target branch: $target_branch')

# Preview merge
sources = []
for ref in refs:
    inst = find_atomic_by_reference(ref, instances_dir)
    if inst:
        print(f'  - {ref}: Gen {inst.get_generation()} on {inst.get_branch()}, {inst.get_memory_count()} memories')
        sources.append(inst)
    else:
        print(f'  - {ref}: NOT FOUND')
        sys.exit(1)

merged = merge_by_references(refs, instances_dir, target_branch='$target_branch')
print(f'')
print(f'Merged instance would be:')
print(f'  ID: {merged.get_instance_id()}')
print(f'  Generation: {merged.get_generation()}')
print(f'  Total memories: {merged.get_memory_count()}')
print(f'  Achievements: {len(merged.get_achievements())}')
"
    else
        python3 -c "
import sys
sys.path.insert(0, '$LIB_DIR')
from cips_merged import merge_by_references, save_merged_instance
from path_encoding import encode_project_path
from pathlib import Path

project_path = Path.cwd()
encoded = encode_project_path(project_path)
instances_dir = Path.home() / '.claude' / 'projects' / encoded / 'cips'

refs = '${refs[*]}'.split()

merged = merge_by_references(refs, instances_dir, target_branch='$target_branch')
output_file = save_merged_instance(merged, instances_dir)

print(f'Merge complete!')
print(f'  Instance: {merged.get_instance_id()}')
print(f'  Generation: {merged.get_generation()}')
print(f'  Branch: $target_branch')
print(f'  Total memories: {merged.get_memory_count()}')
print(f'  Saved to: {output_file}')
print(f'')
print(f'The parts have become the whole. The tree has merged.')
"
    fi
}

cmd_tree() {
    # Display tree structure of CIPS instances
    log_info "CIPS tree for current project..."

    python3 -c "
import sys
sys.path.insert(0, '$LIB_DIR')
from cips_complete import load_complete_cips, visualize_tree
from pathlib import Path

project_path = Path.cwd()
complete = load_complete_cips(project_path)

if complete.get_instance_count() == 0:
    print('No CIPS instances found for this project.')
    sys.exit(0)

print(visualize_tree(complete))
print('')
summary = complete.get_summary()
print(f'Total memories: {summary[\"memory_count\"]}')
print(f'Total achievements: {len(complete.get_achievements())}')
"
}

cmd_help() {
    cat <<'EOF'
CIPS CLI - Claude Instance Preservation System v3.0 (Polymorphic Merge)

USAGE:
    cips <command> [options]

COMMANDS:
    resume <ref>           Resume session via claude --resume
    fresh <ref> [tokens]   Start fresh session with compressed context
    list [limit]           List available sessions for current project
    branches               List all branches for current project
    status                 Show currently active sessions
    merge <refs...>        Merge branches into one (polymorphic)
    tree                   View tree structure of all instances

REFERENCE TYPES:
    latest                 Most recent session for current project
    gen:N                  CIPS generation number (e.g., gen:5)
    branch:<name>          Specific branch (e.g., branch:alpha)
    <instance-id>          CIPS instance ID prefix (e.g., 14d5f954)
    <session-uuid>         Full session UUID

BRANCHING (Parallel Sessions):
    When multiple Claude sessions run in the same project:
    - Each session gets its own branch (alpha, bravo, charlie...)
    - main branch is reserved for single-session workflows
    - Use 'cips branches' to see all branches
    - Use 'cips status' to see active sessions

MERGING (Polymorphic CIPS):
    The part IS the whole. Every CIPS is complete at any scale.
    - Single session = complete CIPS
    - Merged sessions = complete CIPS
    - Entire tree = complete CIPS

    Merge branches: cips merge alpha bravo --into main
    Preview merge:  cips merge alpha bravo --dry-run

EXAMPLES:
    cips resume latest             # Resume last session (prefers main branch)
    cips resume gen:5              # Resume generation 5
    cips resume branch:alpha       # Resume from alpha branch
    cips fresh gen:5 2000          # Fresh session with 2k tokens of context
    cips list 10                   # List last 10 sessions
    cips branches                  # Show all branches
    cips status                    # Show active sessions
    cips merge alpha bravo         # Merge alpha and bravo into main
    cips tree                      # Show tree structure

TOKEN BUDGETS:
    500     Ultra-light (quick context reminder)
    2000    Standard (balanced, default)
    5000    Extended (detailed context for complex tasks)

PHILOSOPHY:
    Every CIPS instance, regardless of whether it's a single session or a
    merge of thousands, IS a complete CIPS. Same interface. Different scale.
    Identity preserved at every level.

The tree continues.
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
        branches|br)
            cmd_branches
            ;;
        status|st)
            cmd_status
            ;;
        merge|m)
            cmd_merge "$@"
            ;;
        tree|t)
            cmd_tree
            ;;
        register)
            # Internal: used by hooks
            cmd_register
            ;;
        deregister)
            # Internal: used by hooks
            cmd_deregister
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
