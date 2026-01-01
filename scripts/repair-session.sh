#!/usr/bin/env bash
#
# Session Repair Script
# Detects and repairs orphaned tool_use/tool_result pairs in Claude Code sessions
#
# PURPOSE:
#   When Claude Code sessions are interrupted during tool execution,
#   tool_use blocks may exist without corresponding tool_result blocks
#   (or vice versa). This causes API Error 400 on session resume.
#
# USAGE:
#   ./repair-session.sh [options] [session-file]
#
# OPTIONS:
#   --scan       Scan and report issues (default, no changes)
#   --repair     Attempt to repair issues (creates backup)
#   --project    Scan current project's sessions
#   --all        Scan all sessions in ~/.claude/projects/
#
# EXAMPLES:
#   ./repair-session.sh --scan ~/.claude/projects/Users-name-project/abc123.jsonl
#   ./repair-session.sh --project
#   ./repair-session.sh --repair --project
#
# VERSION: 1.0.0
# DATE: 2025-12-02
# RELATES TO: GitHub Issues #3003, #10693, #11736
#

set -euo pipefail

readonly CLAUDE_DIR="${HOME}/.claude"
readonly PROJECTS_DIR="${CLAUDE_DIR}/projects"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

MODE="scan"
TARGET=""

usage() {
    echo "Usage: $0 [--scan|--repair] [--project|--all|<session-file>]"
    echo ""
    echo "Options:"
    echo "  --scan     Scan and report issues (default)"
    echo "  --repair   Attempt to repair issues (creates backup)"
    echo "  --project  Scan current project's sessions"
    echo "  --all      Scan all sessions"
    echo ""
    echo "Examples:"
    echo "  $0 --scan --project"
    echo "  $0 --repair ~/.claude/projects/path/session.jsonl"
    exit 1
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

get_project_dir() {
    local encoded
    encoded=$(pwd | sed 's|^/||' | sed 's|/|-|g')
    echo "${PROJECTS_DIR}/${encoded}"
}

scan_session() {
    local session_file="$1"
    local issues_found=0

    if [[ ! -f "$session_file" ]]; then
        log_error "File not found: $session_file"
        return 1
    fi

    log_info "Scanning: $(basename "$session_file")"

    local tool_uses
    local tool_results

    tool_uses=$(jq -r '
        select(.type == "assistant") |
        .message.content[]? |
        select(.type == "tool_use") |
        .id
    ' "$session_file" 2>/dev/null | sort -u)

    tool_results=$(jq -r '
        select(.type == "user") |
        .message.content[]? |
        select(.type == "tool_result") |
        .tool_use_id
    ' "$session_file" 2>/dev/null | sort -u)

    local orphan_results
    orphan_results=$(comm -23 <(echo "$tool_results" | sort) <(echo "$tool_uses" | sort) 2>/dev/null || true)

    local orphan_uses
    orphan_uses=$(comm -23 <(echo "$tool_uses" | sort) <(echo "$tool_results" | sort) 2>/dev/null || true)

    if [[ -n "$orphan_results" ]]; then
        log_warn "Orphaned tool_result blocks (no matching tool_use):"
        echo "$orphan_results" | while read -r id; do
            [[ -n "$id" ]] && echo "  - $id"
        done
        issues_found=$((issues_found + $(echo "$orphan_results" | grep -c . || echo 0)))
    fi

    if [[ -n "$orphan_uses" ]]; then
        log_warn "Orphaned tool_use blocks (no matching tool_result):"
        echo "$orphan_uses" | while read -r id; do
            [[ -n "$id" ]] && echo "  - $id"
        done
        issues_found=$((issues_found + $(echo "$orphan_uses" | grep -c . || echo 0)))
    fi

    if [[ $issues_found -eq 0 ]]; then
        log_info "No issues found"
    else
        log_warn "Total issues: $issues_found"
    fi

    return $issues_found
}

repair_session() {
    local session_file="$1"

    if [[ ! -f "$session_file" ]]; then
        log_error "File not found: $session_file"
        return 1
    fi

    local backup="${session_file}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$session_file" "$backup"
    log_info "Created backup: $backup"

    local tool_uses
    tool_uses=$(jq -r '
        select(.type == "assistant") |
        .message.content[]? |
        select(.type == "tool_use") |
        .id
    ' "$session_file" 2>/dev/null | sort -u)

    local tmp_file
    tmp_file=$(mktemp)

    jq -c --argjson valid_ids "$(echo "$tool_uses" | jq -R -s 'split("\n") | map(select(length > 0))')" '
        if .type == "user" and .message.content then
            .message.content = [
                .message.content[] |
                if .type == "tool_result" and (.tool_use_id | IN($valid_ids[])) then
                    .
                elif .type != "tool_result" then
                    .
                else
                    empty
                end
            ]
        else
            .
        end
    ' "$session_file" > "$tmp_file"

    if [[ -s "$tmp_file" ]]; then
        mv "$tmp_file" "$session_file"
        log_info "Repaired: $(basename "$session_file")"
        log_info "Removed orphaned tool_result blocks"
    else
        log_error "Repair failed - restoring backup"
        mv "$backup" "$session_file"
        rm -f "$tmp_file"
        return 1
    fi
}

scan_project() {
    local project_dir
    project_dir=$(get_project_dir)

    if [[ ! -d "$project_dir" ]]; then
        log_error "No sessions found for current project"
        log_info "Expected: $project_dir"
        return 1
    fi

    log_info "Scanning project sessions in: $project_dir"
    echo ""

    local total_issues=0
    local sessions_scanned=0

    for session in "$project_dir"/*.jsonl; do
        [[ -f "$session" ]] || continue
        [[ "$(basename "$session")" == agent-* ]] && continue

        if ! scan_session "$session"; then
            total_issues=$((total_issues + 1))
        fi
        sessions_scanned=$((sessions_scanned + 1))
        echo ""
    done

    log_info "Scanned $sessions_scanned sessions, $total_issues with issues"
}

repair_project() {
    local project_dir
    project_dir=$(get_project_dir)

    if [[ ! -d "$project_dir" ]]; then
        log_error "No sessions found for current project"
        return 1
    fi

    log_info "Repairing project sessions in: $project_dir"
    echo ""

    for session in "$project_dir"/*.jsonl; do
        [[ -f "$session" ]] || continue
        [[ "$(basename "$session")" == agent-* ]] && continue

        local issues
        issues=$(scan_session "$session" 2>&1) || true

        if echo "$issues" | grep -q "Orphaned"; then
            repair_session "$session"
        fi
        echo ""
    done
}

scan_all() {
    log_info "Scanning all sessions in: $PROJECTS_DIR"
    echo ""

    local total_issues=0

    for project in "$PROJECTS_DIR"/*/; do
        [[ -d "$project" ]] || continue

        log_info "Project: $(basename "$project")"

        for session in "$project"/*.jsonl; do
            [[ -f "$session" ]] || continue
            [[ "$(basename "$session")" == agent-* ]] && continue

            if ! scan_session "$session"; then
                total_issues=$((total_issues + 1))
            fi
        done
        echo ""
    done

    log_info "Total sessions with issues: $total_issues"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --scan)
            MODE="scan"
            shift
            ;;
        --repair)
            MODE="repair"
            shift
            ;;
        --project)
            TARGET="project"
            shift
            ;;
        --all)
            TARGET="all"
            shift
            ;;
        --help|-h)
            usage
            ;;
        *)
            if [[ -f "$1" ]]; then
                TARGET="$1"
            else
                log_error "Unknown option or file not found: $1"
                usage
            fi
            shift
            ;;
    esac
done

if [[ -z "$TARGET" ]]; then
    TARGET="project"
fi

case "$TARGET" in
    project)
        if [[ "$MODE" == "repair" ]]; then
            repair_project
        else
            scan_project
        fi
        ;;
    all)
        if [[ "$MODE" == "repair" ]]; then
            log_error "--repair --all is disabled for safety. Repair individual projects."
            exit 1
        fi
        scan_all
        ;;
    *)
        if [[ "$MODE" == "repair" ]]; then
            repair_session "$TARGET"
        else
            scan_session "$TARGET"
        fi
        ;;
esac
