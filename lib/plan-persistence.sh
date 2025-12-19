#!/usr/bin/env bash
#
# Plan Persistence Library
# Global cache with project identifier for cross-session plan context
#
# PURPOSE:
#   Automatically cache and retrieve plan context across Claude Code sessions.
#   Implements the unified skill/command/agent architecture pattern.
#
# ARCHITECTURE:
#   - Global cache: ~/.claude/cache/last-plan.json
#   - Project-aware retrieval (default: current project only)
#   - Cross-project access via retrieve_any_cached_plan()
#
# USAGE:
#   source ~/.claude/lib/plan-persistence.sh
#   cache_current_plan "/path/to/plan.md"
#   retrieve_cached_plan  # Returns JSON if project matches
#
# VERSION: 1.0.0
# DATE: 2025-12-12
#

set -euo pipefail

# ============================================================================
# CONSTANTS
# ============================================================================

[[ -z "${CLAUDE_DIR:-}" ]] && readonly CLAUDE_DIR="$HOME/.claude"
[[ -z "${PLANS_DIR:-}" ]] && readonly PLANS_DIR="$CLAUDE_DIR/plans"
[[ -z "${PLAN_CACHE:-}" ]] && readonly PLAN_CACHE="$CLAUDE_DIR/cache/last-plan.json"

# ============================================================================
# PATH ENCODING (Unified - sourced from path-encoding.sh)
# ============================================================================

# Source unified path encoding library
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
else
    SCRIPT_DIR="${SCRIPT_DIR:-$LIB_DIR}"
fi
source "$SCRIPT_DIR/path-encoding.sh" 2>/dev/null || source "$LIB_DIR/path-encoding.sh" 2>/dev/null || true

# Alias for backwards compatibility
get_project_encoded() {
    encode_current_path
}

# ============================================================================
# PLAN FILE DISCOVERY
# ============================================================================

# Find most recent plan file by mtime
# Cross-platform: macOS (BSD stat) and Linux (GNU stat)
get_latest_plan_file() {
    local stat_fmt

    case "$(uname -s)" in
        Darwin*)
            stat_fmt="-f %m"
            ;;
        *)
            stat_fmt="-c %Y"
            ;;
    esac

    fd -e md . "$PLANS_DIR" -t f 2>/dev/null | while read -r file; do
        local mtime
        mtime=$(stat $stat_fmt "$file" 2>/dev/null)
        [[ -n "$mtime" ]] && echo "$mtime $file"
    done | sort -rn | head -1 | cut -d' ' -f2-
}

# ============================================================================
# CACHE OPERATIONS
# ============================================================================

# Cache current plan to JSON (global with project identifier)
# Args: $1 = path to plan file
# Note: If plan is in ~/.claude/plans/, uses ~/.claude as project (meta-project)
#       Otherwise uses current working directory
cache_current_plan() {
    local plan_path="$1"
    local plan_content
    local project_path
    local project_encoded

    [[ -f "$plan_path" ]] || return 1
    plan_content=$(cat "$plan_path" 2>/dev/null) || return 1

    # Determine project: if plan is in ~/.claude/plans/, use ~/.claude as project
    # This fixes bug where plans created for Claude-Optim were cached with wrong project
    if [[ "$plan_path" == "$CLAUDE_DIR/plans/"* ]] || [[ "$plan_path" == "$HOME/.claude/plans/"* ]]; then
        project_path="$CLAUDE_DIR"
        project_encoded=$(echo "$CLAUDE_DIR" | sed 's|/|-|g' | sed 's|\.|-|g')
    else
        project_path="$(pwd)"
        project_encoded="$(get_project_encoded)"
    fi

    mkdir -p "$(dirname "$PLAN_CACHE")"

    jq -n \
        --arg id "$(basename "$plan_path" .md)" \
        --arg path "$plan_path" \
        --arg content "$plan_content" \
        --arg cached_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg project "$project_path" \
        --arg project_encoded "$project_encoded" \
        --arg status "active" \
        '{plan_id: $id, plan_path: $path, plan_content: $content, cached_at: $cached_at, project_path: $project, project_encoded: $project_encoded, status: $status}' \
        > "$PLAN_CACHE"
}

# ============================================================================
# RETRIEVAL OPERATIONS
# ============================================================================

# Retrieve cached plan for CURRENT project only (default behaviour)
# Returns: JSON on stdout, exit 0 if match, exit 1 if no cache, exit 2 if different project
retrieve_cached_plan() {
    [[ -f "$PLAN_CACHE" ]] || return 1

    local current_encoded cached_encoded
    current_encoded=$(get_project_encoded)
    cached_encoded=$(jq -r '.project_encoded' "$PLAN_CACHE" 2>/dev/null) || return 1

    if [[ "$current_encoded" == "$cached_encoded" ]]; then
        cat "$PLAN_CACHE"
        return 0
    else
        return 2  # Exists but different project
    fi
}

# Retrieve ANY cached plan (global mode, ignores project)
retrieve_any_cached_plan() {
    [[ -f "$PLAN_CACHE" ]] && cat "$PLAN_CACHE"
}

# Get just the plan ID from cache (for display)
get_cached_plan_id() {
    [[ -f "$PLAN_CACHE" ]] && jq -r '.plan_id' "$PLAN_CACHE" 2>/dev/null
}

# Get the project path from cache
get_cached_plan_project() {
    [[ -f "$PLAN_CACHE" ]] && jq -r '.project_path' "$PLAN_CACHE" 2>/dev/null
}

# ============================================================================
# VALIDATION OPERATIONS
# ============================================================================

# Check if plan cache exists for current project, is recent (<24h), and is active
has_recent_plan_cache() {
    [[ -f "$PLAN_CACHE" ]] || return 1

    # Check status (only active plans count)
    local status
    status=$(jq -r '.status // "active"' "$PLAN_CACHE" 2>/dev/null) || return 1
    [[ "$status" == "active" ]] || return 1

    # Check project match
    local current_encoded cached_encoded
    current_encoded=$(get_project_encoded)
    cached_encoded=$(jq -r '.project_encoded' "$PLAN_CACHE" 2>/dev/null) || return 1
    [[ "$current_encoded" == "$cached_encoded" ]] || return 1

    # Check recency (24 hours = 86400 seconds)
    local cached_at cache_epoch current_epoch

    cached_at=$(jq -r '.cached_at' "$PLAN_CACHE" 2>/dev/null) || return 1

    case "$(uname -s)" in
        Darwin*)
            cache_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$cached_at" +%s 2>/dev/null) || return 1
            ;;
        *)
            cache_epoch=$(date -d "$cached_at" +%s 2>/dev/null) || return 1
            ;;
    esac

    current_epoch=$(date +%s)
    [[ $((current_epoch - cache_epoch)) -lt 86400 ]]
}

# Check if ANY plan cache exists (regardless of project)
has_any_plan_cache() {
    [[ -f "$PLAN_CACHE" ]]
}

# Check if plan cache exists but for different project
has_other_project_plan_cache() {
    [[ -f "$PLAN_CACHE" ]] || return 1

    local current_encoded cached_encoded
    current_encoded=$(get_project_encoded)
    cached_encoded=$(jq -r '.project_encoded' "$PLAN_CACHE" 2>/dev/null) || return 1

    [[ "$current_encoded" != "$cached_encoded" ]]
}

# ============================================================================
# LIFECYCLE OPERATIONS
# ============================================================================

# Mark current plan as executed (won't show in future sessions)
mark_plan_executed() {
    [[ -f "$PLAN_CACHE" ]] || return 1

    local tmp_file
    tmp_file=$(mktemp)

    jq '.status = "executed" | .executed_at = (now | todate)' "$PLAN_CACHE" > "$tmp_file" && \
        mv "$tmp_file" "$PLAN_CACHE"
}

# Mark current plan as stale (superceded by newer work)
mark_plan_stale() {
    [[ -f "$PLAN_CACHE" ]] || return 1

    local tmp_file
    tmp_file=$(mktemp)

    jq '.status = "stale"' "$PLAN_CACHE" > "$tmp_file" && \
        mv "$tmp_file" "$PLAN_CACHE"
}

# Get plan status
get_plan_status() {
    [[ -f "$PLAN_CACHE" ]] && jq -r '.status // "active"' "$PLAN_CACHE" 2>/dev/null
}

# ============================================================================
# CLEANUP OPERATIONS
# ============================================================================

# Clear the plan cache
clear_plan_cache() {
    rm -f "$PLAN_CACHE"
}

# ============================================================================
# DIAGNOSTIC FUNCTIONS
# ============================================================================

# Print diagnostic information about plan cache
diagnose_plan_cache() {
    echo "=== Plan Cache Diagnosis ==="
    echo ""
    echo "Cache location: $PLAN_CACHE"
    echo "Cache exists: $([[ -f "$PLAN_CACHE" ]] && echo "yes" || echo "no")"
    echo ""

    if [[ -f "$PLAN_CACHE" ]]; then
        echo "Cached plan:"
        echo "  ID: $(get_cached_plan_id)"
        echo "  Project: $(get_cached_plan_project)"
        echo "  Status: $(get_plan_status)"
        echo "  Cached at: $(jq -r '.cached_at' "$PLAN_CACHE" 2>/dev/null)"
        local executed_at
        executed_at=$(jq -r '.executed_at // empty' "$PLAN_CACHE" 2>/dev/null)
        [[ -n "$executed_at" ]] && echo "  Executed at: $executed_at"
        echo ""
        echo "Current project: $(pwd)"
        echo "Current encoded: $(get_project_encoded)"
        echo "Matches current: $([[ "$(get_project_encoded)" == "$(jq -r '.project_encoded' "$PLAN_CACHE" 2>/dev/null)" ]] && echo "yes" || echo "no")"
        echo "Would show [PLAN-FOUND]: $(has_recent_plan_cache && echo "yes" || echo "no")"
    fi

    echo ""
    echo "Plans directory: $PLANS_DIR"
    echo "Plans found: $(fd -e md . "$PLANS_DIR" -t f 2>/dev/null | wc -l | tr -d ' ')"
    echo "Latest plan: $(get_latest_plan_file)"
    echo ""
    echo "=== End Diagnosis ==="
}

# ============================================================================
# EXPORTS
# ============================================================================

export -f get_project_encoded
export -f get_latest_plan_file
export -f cache_current_plan
export -f retrieve_cached_plan
export -f retrieve_any_cached_plan
export -f get_cached_plan_id
export -f get_cached_plan_project
export -f has_recent_plan_cache
export -f has_any_plan_cache
export -f has_other_project_plan_cache
export -f mark_plan_executed
export -f mark_plan_stale
export -f get_plan_status
export -f clear_plan_cache
export -f diagnose_plan_cache

# ============================================================================
# MAIN (if run directly)
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-diagnose}" in
        diagnose|--diagnose|-d)
            diagnose_plan_cache
            ;;
        cache|--cache|-c)
            if [[ -n "${2:-}" ]]; then
                cache_current_plan "$2"
                echo "Cached: $2"
            else
                latest=$(get_latest_plan_file)
                if [[ -n "$latest" ]]; then
                    cache_current_plan "$latest"
                    echo "Cached: $latest"
                else
                    echo "No plan file found to cache"
                    exit 1
                fi
            fi
            ;;
        retrieve|--retrieve|-r)
            retrieve_cached_plan
            ;;
        clear|--clear)
            clear_plan_cache
            echo "Plan cache cleared"
            ;;
        executed|--executed|-e)
            if mark_plan_executed; then
                echo "Plan marked as executed"
            else
                echo "No plan cache to mark"
                exit 1
            fi
            ;;
        stale|--stale)
            if mark_plan_stale; then
                echo "Plan marked as stale"
            else
                echo "No plan cache to mark"
                exit 1
            fi
            ;;
        status|--status|-s)
            local status
            status=$(get_plan_status)
            if [[ -n "$status" ]]; then
                echo "Plan status: $status"
            else
                echo "No plan cache"
                exit 1
            fi
            ;;
        help|--help|-h)
            cat << 'EOF'
Plan Persistence Library - Cache plan context across sessions

USAGE:
    ./plan-persistence.sh [command] [args]

COMMANDS:
    diagnose        Show diagnostic information about plan cache
    cache [file]    Cache a plan file (default: latest plan)
    retrieve        Retrieve cached plan for current project
    executed        Mark current plan as executed (won't show again)
    stale           Mark current plan as stale (superceded)
    status          Show plan status (active/executed/stale)
    clear           Clear the plan cache
    help            Show this help message

PLAN LIFECYCLE:
    active    -> Plan will show in [PLAN-FOUND] for matching project
    executed  -> Plan completed, won't show in future sessions
    stale     -> Plan superceded, won't show in future sessions

AS LIBRARY:
    source ~/.claude/lib/plan-persistence.sh

    # Cache current plan
    cache_current_plan "/path/to/plan.md"

    # Retrieve for current project
    plan_json=$(retrieve_cached_plan)

    # Check if cache exists for current project
    if has_recent_plan_cache; then
        echo "Plan available"
    fi

    # Mark plan as executed after completing it
    mark_plan_executed

EOF
            ;;
        *)
            echo "Unknown command: $1"
            echo "Run '$0 help' for usage"
            exit 1
            ;;
    esac
fi
