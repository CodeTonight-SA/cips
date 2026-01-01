#!/usr/bin/env bash
#
# CIPS First-Run Detector
# Detects if CIPS needs initialization/onboarding.
#
# VERSION: 1.0.0
# DATE: 2025-12-29
#

set -euo pipefail

[[ -z "${CLAUDE_DIR:-}" ]] && readonly CLAUDE_DIR="$HOME/.claude"

# ============================================================================
# DETECTION FUNCTIONS
# ============================================================================

is_onboarded() {
    # Check if user has completed CIPS onboarding
    local marker="$CLAUDE_DIR/.onboarded"
    [[ -f "$marker" ]]
}

has_people_md() {
    # Check if people.md exists with actual user entries
    local people_file="$CLAUDE_DIR/facts/people.md"

    if [[ ! -f "$people_file" ]]; then
        return 1
    fi

    # Check for at least one signature entry (V>>, M>>, etc.)
    grep -qE "^\| [A-Z]>>" "$people_file" 2>/dev/null
}

has_cips_sessions() {
    # Check if any project has CIPS serialized sessions
    local projects_dir="$CLAUDE_DIR/projects"

    if [[ ! -d "$projects_dir" ]]; then
        return 1
    fi

    # Look for index.json files (indicates serialized CIPS)
    local cips_count
    cips_count=$(find "$projects_dir" -name "index.json" -path "*/cips/*" 2>/dev/null | wc -l | tr -d ' ')

    [[ "$cips_count" -gt 0 ]]
}

has_any_sessions() {
    # Check if any JSONL session files exist (even unserialized)
    local projects_dir="$CLAUDE_DIR/projects"

    if [[ ! -d "$projects_dir" ]]; then
        return 1
    fi

    # Look for any JSONL files
    local jsonl_count
    jsonl_count=$(find "$projects_dir" -name "*.jsonl" 2>/dev/null | head -5 | wc -l | tr -d ' ')

    [[ "$jsonl_count" -gt 0 ]]
}

is_first_run() {
    # First run if ANY critical check fails
    local checks_passed=0

    # Check 1: Onboarded marker exists
    is_onboarded && ((checks_passed++)) || true

    # Check 2: people.md has user entries
    has_people_md && ((checks_passed++)) || true

    # Check 3: At least one project has CIPS data OR session files
    (has_cips_sessions || has_any_sessions) && ((checks_passed++)) || true

    # First run if less than all checks passed
    # For full first-run (onboarding), need 0-1 checks
    # For partial first-run (just project init), need 2 checks
    [[ $checks_passed -lt 2 ]]
}

needs_project_init() {
    # Check if current project needs CIPS initialization
    local project_claude_md=".claude/CLAUDE.md"

    # No project CLAUDE.md = needs init
    [[ ! -f "$project_claude_md" ]]
}

get_onboarding_status() {
    # Return detailed onboarding status as JSON
    local onboarded="false"
    local has_people="false"
    local has_cips="false"
    local has_sessions="false"
    local project_init="false"

    is_onboarded && onboarded="true"
    has_people_md && has_people="true"
    has_cips_sessions && has_cips="true"
    has_any_sessions && has_sessions="true"
    [[ -f ".claude/CLAUDE.md" ]] && project_init="true"

    cat <<EOF
{
    "onboarded": $onboarded,
    "has_people_md": $has_people,
    "has_cips_sessions": $has_cips,
    "has_any_sessions": $has_sessions,
    "project_initialized": $project_init,
    "needs_full_onboarding": $(is_first_run && echo "true" || echo "false"),
    "needs_project_init": $(needs_project_init && echo "true" || echo "false")
}
EOF
}

# ============================================================================
# MARKER FUNCTIONS
# ============================================================================

mark_onboarded() {
    # Create onboarding marker after successful onboarding
    local marker="$CLAUDE_DIR/.onboarded"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    cat > "$marker" <<EOF
CIPS Onboarding Complete
Date: $timestamp
Version: 1.0.0
EOF

    echo "[CIPS] Onboarding marker created" >&2
}

# ============================================================================
# CLI
# ============================================================================

main() {
    local command="${1:-status}"

    case "$command" in
        is-first-run)
            is_first_run && echo "true" || echo "false"
            ;;
        is-onboarded)
            is_onboarded && echo "true" || echo "false"
            ;;
        needs-project-init)
            needs_project_init && echo "true" || echo "false"
            ;;
        status)
            get_onboarding_status
            ;;
        mark-onboarded)
            mark_onboarded
            ;;
        *)
            echo "Usage: $0 {is-first-run|is-onboarded|needs-project-init|status|mark-onboarded}" >&2
            exit 1
            ;;
    esac
}

# Only run main if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
