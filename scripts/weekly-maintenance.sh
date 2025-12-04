#!/usr/bin/env bash
#
# Weekly Maintenance Script
# Automated pattern emergence and embedding maintenance
#
# PURPOSE:
#   1. Run pattern emergence analysis
#   2. Generate new concepts from clusters
#   3. Prune low-value embeddings
#   4. Update embedding statistics
#
# USAGE:
#   ~/.claude/scripts/weekly-maintenance.sh
#   ~/.claude/scripts/weekly-maintenance.sh --dry-run
#
# SCHEDULING (add to crontab):
#   0 3 * * 0 ~/.claude/scripts/weekly-maintenance.sh >> ~/.claude/.maintenance.log 2>&1
#
# VERSION: 1.0.0
# DATE: 2025-12-02
#

set -euo pipefail

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SCRIPTS_DIR="$CLAUDE_DIR/scripts"
LOG_FILE="$CLAUDE_DIR/.maintenance.log"
DRY_RUN="${1:-}"

log() {
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) [MAINTENANCE] $*" | tee -a "$LOG_FILE"
}

log_section() {
    echo "" | tee -a "$LOG_FILE"
    echo "=== $* ===" | tee -a "$LOG_FILE"
}

check_dependencies() {
    if ! command -v python3 &>/dev/null; then
        log "ERROR: python3 not found"
        exit 1
    fi

    if ! python3 -c "import apsw, sqlite_vec" 2>/dev/null; then
        log "ERROR: Required Python packages not installed"
        log "Run: pip3 install apsw sqlite-vec"
        exit 1
    fi
}

run_pattern_emergence() {
    log_section "Pattern Emergence Analysis"

    if [[ "$DRY_RUN" == "--dry-run" ]]; then
        log "DRY RUN: Would run pattern emergence"
        return 0
    fi

    python3 "$SCRIPTS_DIR/pattern-emergence.py" full-analysis 2>&1 | while IFS= read -r line; do
        log "$line"
    done
}

run_embedding_stats() {
    log_section "Embedding Statistics"

    if [[ -f "$CLAUDE_DIR/lib/embeddings.sh" ]]; then
        source "$CLAUDE_DIR/lib/embeddings.sh" 2>/dev/null || true

        if command -v get_embedding_stats &>/dev/null; then
            local stats
            stats=$(get_embedding_stats 2>/dev/null) || true
            if [[ -n "$stats" ]]; then
                log "Stats: $stats"
            fi
        fi
    fi
}

run_success_scoring_stats() {
    log_section "Success Scoring Statistics"

    if [[ -f "$CLAUDE_DIR/lib/success-scorer.sh" ]]; then
        source "$CLAUDE_DIR/lib/success-scorer.sh" 2>/dev/null || true

        if command -v get_scoring_stats &>/dev/null; then
            local stats
            stats=$(get_scoring_stats 2>/dev/null) || true
            if [[ -n "$stats" ]]; then
                log "Scoring stats: $stats"
            fi
        fi
    fi
}

decay_old_scores() {
    log_section "Score Decay"

    if [[ "$DRY_RUN" == "--dry-run" ]]; then
        log "DRY RUN: Would decay scores older than 30 days"
        return 0
    fi

    if [[ -f "$CLAUDE_DIR/lib/success-scorer.sh" ]]; then
        source "$CLAUDE_DIR/lib/success-scorer.sh" 2>/dev/null || true

        if command -v decay_old_scores &>/dev/null; then
            local result
            result=$(decay_old_scores 30 0.9 2>/dev/null) || true
            log "Decay result: $result"
        fi
    fi
}

cleanup_logs() {
    log_section "Log Cleanup"

    local hooks_log="$CLAUDE_DIR/.hooks.log"
    if [[ -f "$hooks_log" ]]; then
        local size
        size=$(wc -c < "$hooks_log" | tr -d ' ')

        if [[ $size -gt 10485760 ]]; then
            log "Rotating hooks.log (size: $size bytes)"

            if [[ "$DRY_RUN" != "--dry-run" ]]; then
                mv "$hooks_log" "$hooks_log.old"
                tail -n 10000 "$hooks_log.old" > "$hooks_log"
                rm "$hooks_log.old"
            fi
        fi
    fi

    if [[ -f "$LOG_FILE" ]]; then
        local maint_size
        maint_size=$(wc -c < "$LOG_FILE" | tr -d ' ')

        if [[ $maint_size -gt 5242880 ]]; then
            log "Rotating maintenance.log"

            if [[ "$DRY_RUN" != "--dry-run" ]]; then
                tail -n 5000 "$LOG_FILE" > "$LOG_FILE.tmp"
                mv "$LOG_FILE.tmp" "$LOG_FILE"
            fi
        fi
    fi
}

main() {
    log_section "Weekly Maintenance Started"
    log "Mode: ${DRY_RUN:-LIVE}"

    check_dependencies

    run_embedding_stats
    run_success_scoring_stats
    run_pattern_emergence
    decay_old_scores
    cleanup_logs

    log_section "Weekly Maintenance Complete"
}

main "$@"
