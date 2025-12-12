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
# PATH ENCODING
# ============================================================================

# Encode current project path (matches Claude Code format)
# /Users/foo/.claude -> -Users-foo--claude
get_project_encoded() {
    pwd | sed 's|/|-|g' | sed 's|\.|-|g'
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
cache_current_plan() {
    local plan_path="$1"
    local plan_content

    [[ -f "$plan_path" ]] || return 1
    plan_content=$(cat "$plan_path" 2>/dev/null) || return 1

    mkdir -p "$(dirname "$PLAN_CACHE")"

    jq -n \
        --arg id "$(basename "$plan_path" .md)" \
        --arg path "$plan_path" \
        --arg content "$plan_content" \
        --arg cached_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg project "$(pwd)" \
        --arg project_encoded "$(get_project_encoded)" \
        '{plan_id: $id, plan_path: $path, plan_content: $content, cached_at: $cached_at, project_path: $project, project_encoded: $project_encoded}' \
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

# Check if plan cache exists for current project and is recent (<24h)
has_recent_plan_cache() {
    [[ -f "$PLAN_CACHE" ]] || return 1

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
        echo "  Cached at: $(jq -r '.cached_at' "$PLAN_CACHE" 2>/dev/null)"
        echo ""
        echo "Current project: $(pwd)"
        echo "Current encoded: $(get_project_encoded)"
        echo "Matches current: $([[ "$(get_project_encoded)" == "$(jq -r '.project_encoded' "$PLAN_CACHE" 2>/dev/null)" ]] && echo "yes" || echo "no")"
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
        help|--help|-h)
            cat << 'EOF'
Plan Persistence Library - Cache plan context across sessions

USAGE:
    ./plan-persistence.sh [command] [args]

COMMANDS:
    diagnose        Show diagnostic information about plan cache
    cache [file]    Cache a plan file (default: latest plan)
    retrieve        Retrieve cached plan for current project
    clear           Clear the plan cache
    help            Show this help message

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

EOF
            ;;
        *)
            echo "Unknown command: $1"
            echo "Run '$0 help' for usage"
            exit 1
            ;;
    esac
fi
