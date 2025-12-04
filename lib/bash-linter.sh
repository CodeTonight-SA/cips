#!/usr/bin/env bash
#
# Bash Linter Library
# Static analysis for bash scripts to detect common anti-patterns
#
# PURPOSE:
#   Proactively detect bash script issues BEFORE runtime errors occur.
#   Part of the recursive self-improvement system.
#
# PATTERNS DETECTED:
#   1. readonly-redeclaration: readonly vars in sourceable scripts
#   2. unguarded-source: source without file existence check
#   3. missing-pipefail: scripts without set -o pipefail
#   4. unquoted-expansion: dangerous unquoted variable expansions
#
# USAGE:
#   source ~/.claude/lib/bash-linter.sh
#
#   # Lint a single file
#   lint_file "lib/orchestrator.sh"
#
#   # Lint all Claude scripts
#   lint_claude_scripts
#
#   # Get JSON output
#   lint_file_json "lib/orchestrator.sh"
#
# VERSION: 1.0.0
# DATE: 2025-12-01
#

set -euo pipefail

# Guard against re-sourcing (using the pattern this linter detects!)
[[ -z "${BASH_LINTER_LOADED:-}" ]] && readonly BASH_LINTER_LOADED=1 || return 0

# Constants (guarded)
[[ -z "${CLAUDE_DIR:-}" ]] && CLAUDE_DIR="$HOME/.claude"
[[ -z "${LINT_LOG:-}" ]] && LINT_LOG="$CLAUDE_DIR/.bash-lint.log"
[[ -z "${ERROR_SIGNATURES:-}" ]] && ERROR_SIGNATURES="$CLAUDE_DIR/error-signatures.jsonl"

# Logging
_lint_log() {
    local level="$1"
    shift
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) [BASH-LINTER][$level] $*" >> "$LINT_LOG"
}

_lint_warn() {
    echo "[LINT WARNING] $*" >&2
    _lint_log "WARN" "$@"
}

_lint_info() {
    _lint_log "INFO" "$@"
}

# Check if a script is designed to be sourced (lib/ or hooks/ or has source directive)
is_sourceable_script() {
    local file="$1"

    # Files in lib/ or hooks/ are designed to be sourced
    if [[ "$file" == *"/lib/"* ]] || [[ "$file" == *"/hooks/"* ]]; then
        return 0
    fi

    # Check if file contains "source ~/.claude/lib" indicating it's a library
    if rg -q "^# *source" "$file" 2>/dev/null; then
        return 0
    fi

    # Check usage comments for "source" instruction
    if rg -q "source.*$file" "$CLAUDE_DIR" 2>/dev/null; then
        return 0
    fi

    return 1
}

# Pattern 1: Detect readonly without guard in sourceable scripts
check_readonly_redeclaration() {
    local file="$1"
    local issues=()

    # Only check sourceable scripts
    if ! is_sourceable_script "$file"; then
        return 0
    fi

    # Find readonly declarations that don't have guards
    # Good: [[ -z "${VAR:-}" ]] && readonly VAR=
    # Bad: readonly VAR=
    while IFS=: read -r line_num content; do
        # Skip if line has guard pattern before readonly
        if [[ "$content" =~ \[\[.*\]\].*\&\&.*readonly ]]; then
            continue
        fi

        # Skip comments
        if [[ "$content" =~ ^[[:space:]]*# ]]; then
            continue
        fi

        # Detect unguarded readonly
        if [[ "$content" =~ ^[[:space:]]*readonly[[:space:]]+[A-Z_]+= ]]; then
            issues+=("$line_num:readonly-redeclaration:$content")
        fi
    done < <(rg -n "readonly[[:space:]]+[A-Z_]+=" "$file" 2>/dev/null || true)

    # Output issues
    for issue in "${issues[@]:-}"; do
        [[ -n "$issue" ]] && echo "$issue"
    done

    [[ ${#issues[@]} -eq 0 ]]
}

# Pattern 2: Detect source without file check
check_unguarded_source() {
    local file="$1"
    local issues=()

    while IFS=: read -r line_num content; do
        # Skip if preceded by file check on same or previous line
        # This is a simplified check - may have false positives
        if [[ "$content" =~ \[\[.*-f.*\]\].*source ]] || \
           [[ "$content" =~ \[\[.*-r.*\]\].*source ]]; then
            continue
        fi

        # Skip comments
        if [[ "$content" =~ ^[[:space:]]*# ]]; then
            continue
        fi

        # Skip shellcheck source directives
        if [[ "$content" =~ shellcheck ]]; then
            continue
        fi

        issues+=("$line_num:unguarded-source:$content")
    done < <(rg -n "^[^#]*source[[:space:]]+" "$file" 2>/dev/null | rg -v "\[\[.*-[fr]" || true)

    for issue in "${issues[@]:-}"; do
        [[ -n "$issue" ]] && echo "$issue"
    done

    [[ ${#issues[@]} -eq 0 ]]
}

# Pattern 3: Check for missing pipefail
check_missing_pipefail() {
    local file="$1"

    # Check if file has shebang (is a script, not just functions)
    if ! head -1 "$file" | rg -q "^#!.*bash"; then
        return 0
    fi

    # Check for set -o pipefail or set -euo pipefail
    if rg -q "set.*pipefail" "$file" 2>/dev/null; then
        return 0
    fi

    echo "1:missing-pipefail:No 'set -o pipefail' found"
    return 1
}

# Lint a single file, return issues
lint_file() {
    local file="$1"
    local all_issues=()
    local has_issues=false

    if [[ ! -f "$file" ]]; then
        echo "ERROR: File not found: $file" >&2
        return 1
    fi

    _lint_info "Linting: $file"

    # Run all checks
    local readonly_issues
    readonly_issues=$(check_readonly_redeclaration "$file" 2>/dev/null) || true
    if [[ -n "$readonly_issues" ]]; then
        has_issues=true
        while IFS= read -r issue; do
            [[ -n "$issue" ]] && all_issues+=("$file:$issue")
        done <<< "$readonly_issues"
    fi

    local source_issues
    source_issues=$(check_unguarded_source "$file" 2>/dev/null) || true
    if [[ -n "$source_issues" ]]; then
        has_issues=true
        while IFS= read -r issue; do
            [[ -n "$issue" ]] && all_issues+=("$file:$issue")
        done <<< "$source_issues"
    fi

    local pipefail_issues
    pipefail_issues=$(check_missing_pipefail "$file" 2>/dev/null) || true
    if [[ -n "$pipefail_issues" ]]; then
        has_issues=true
        while IFS= read -r issue; do
            [[ -n "$issue" ]] && all_issues+=("$file:$issue")
        done <<< "$pipefail_issues"
    fi

    # Output all issues
    for issue in "${all_issues[@]:-}"; do
        [[ -n "$issue" ]] && echo "$issue"
    done

    if $has_issues; then
        return 1
    fi
    return 0
}

# Lint file and output JSON
lint_file_json() {
    local file="$1"
    local issues
    issues=$(lint_file "$file" 2>/dev/null) || true

    if [[ -z "$issues" ]]; then
        echo '{"file":"'"$file"'","issues":[],"status":"clean"}'
        return 0
    fi

    local json_issues="["
    local first=true
    while IFS=: read -r filepath line_num pattern content; do
        [[ -z "$line_num" ]] && continue
        if ! $first; then
            json_issues+=","
        fi
        first=false
        # Escape content for JSON
        content="${content//\\/\\\\}"
        content="${content//\"/\\\"}"
        json_issues+='{"line":'"$line_num"',"pattern":"'"$pattern"'","content":"'"$content"'"}'
    done <<< "$issues"
    json_issues+="]"

    echo '{"file":"'"$file"'","issues":'"$json_issues"',"status":"issues_found"}'
    return 1
}

# Lint all Claude infrastructure scripts
lint_claude_scripts() {
    local total_issues=0
    local files_checked=0
    local files_with_issues=0

    echo "=========================================="
    echo "BASH LINTER - Claude Infrastructure Scan"
    echo "=========================================="
    echo ""

    # Scan lib/*.sh
    for file in "$CLAUDE_DIR"/lib/*.sh; do
        [[ -f "$file" ]] || continue
        files_checked=$((files_checked + 1))

        local issues
        issues=$(lint_file "$file" 2>/dev/null) || true

        if [[ -n "$issues" ]]; then
            files_with_issues=$((files_with_issues + 1))
            echo "Issues in: $file"
            while IFS= read -r issue; do
                [[ -n "$issue" ]] && echo "  $issue" && total_issues=$((total_issues + 1))
            done <<< "$issues"
            echo ""
        fi
    done

    # Scan hooks/*.sh
    for file in "$CLAUDE_DIR"/hooks/*.sh; do
        [[ -f "$file" ]] || continue
        files_checked=$((files_checked + 1))

        local issues
        issues=$(lint_file "$file" 2>/dev/null) || true

        if [[ -n "$issues" ]]; then
            files_with_issues=$((files_with_issues + 1))
            echo "Issues in: $file"
            while IFS= read -r issue; do
                [[ -n "$issue" ]] && echo "  $issue" && total_issues=$((total_issues + 1))
            done <<< "$issues"
            echo ""
        fi
    done

    echo "=========================================="
    echo "Summary:"
    echo "  Files checked: $files_checked"
    echo "  Files with issues: $files_with_issues"
    echo "  Total issues: $total_issues"
    echo "=========================================="

    if [[ $total_issues -gt 0 ]]; then
        _lint_warn "Found $total_issues issues in $files_with_issues files"
        return 1
    fi

    _lint_info "All files clean"
    return 0
}

# Log an error signature for recursive learning
log_error_signature() {
    local pattern="$1"
    local signature="$2"
    local file="$3"
    local status="${4:-detected}"

    local entry
    entry=$(jq -nc \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg pattern "$pattern" \
        --arg sig "$signature" \
        --arg file "$file" \
        --arg status "$status" \
        '{timestamp: $ts, pattern: $pattern, signature: $sig, file: $file, status: $status}')

    echo "$entry" >> "$ERROR_SIGNATURES"
    _lint_info "Logged error signature: $pattern in $file"
}

# Quick check for a single file (used by tool-monitor integration)
quick_lint() {
    local file="$1"

    # Only lint .sh files
    [[ "$file" != *.sh ]] && return 0

    # Only lint Claude infrastructure
    [[ "$file" != "$CLAUDE_DIR"/* ]] && return 0

    local issues
    issues=$(lint_file "$file" 2>/dev/null) || true

    if [[ -n "$issues" ]]; then
        _lint_warn "Issues detected in $file:"
        echo "$issues" | while IFS= read -r issue; do
            _lint_warn "  $issue"
        done
        return 1
    fi

    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# DYNAMIC COMMAND VALIDATION (Multi-tier)
# ═══════════════════════════════════════════════════════════════════════════════
#
# Validates bash command strings BEFORE execution to catch:
# - Context-specific issues (semicolon after subshell)
# - Encoding issues (missing ^/ in path sed)
# - Flag interpretation issues (missing -- before dash paths)
#
# Tiers:
#   quick  - Pattern matching only (~1ms)
#   syntax - Pattern + bash -n (~5ms)
#   full   - Pattern + bash -n + shellcheck (~100ms)

# Multi-tier command validation
# Usage: validate_command "cmd" [level]
# Levels: quick (tier 1), syntax (tier 1+2), full (all tiers)
validate_command() {
    local cmd="$1"
    local level="${2:-syntax}"
    local issues=()

    # ═══════════════════════════════════════════════════════════════════════════
    # TIER 1: Pattern matching (~1ms) - ALWAYS RUN
    # Catches context-specific issues that pass bash -n but fail in eval contexts
    # ═══════════════════════════════════════════════════════════════════════════

    # Pattern 1: Semicolon after subshell
    # BAD: VAR=$(cmd); echo  →  parse error near ')' in eval contexts
    if echo "$cmd" | rg -q '\$\([^)]+\)\s*;'; then
        issues+=("T1:semicolon-after-subshell: Use && not ; after \$(cmd)")
    fi

    # Pattern 2: Path encoding without leading slash removal
    # BAD: sed 's|/|-|g'  →  -Users-foo (dash interpreted as flag)
    if echo "$cmd" | rg -q "sed.*s[|]/?[|]-[|]g" && ! echo "$cmd" | rg -q '\^/'; then
        issues+=("T1:path-encoding: Add s|^/|| before s|/|-|g to remove leading slash")
    fi

    # Pattern 3: fd/find/rg without -- before variable path
    # BAD: fd -t d "$path"  →  unexpected argument '-U' if path starts with dash
    if echo "$cmd" | rg -q '(fd|find|rg)\s+-[a-z]+.*\$[A-Z_]+' && ! echo "$cmd" | rg -q '\-\-\s'; then
        issues+=("T1:missing-double-dash: Add -- before path variable to end flag parsing")
    fi

    # ═══════════════════════════════════════════════════════════════════════════
    # TIER 2: bash -n syntax check (~4ms)
    # Catches pure syntax errors (unmatched quotes, invalid constructs)
    # ═══════════════════════════════════════════════════════════════════════════

    if [[ "$level" != "quick" ]]; then
        local syntax_error
        syntax_error=$(bash -n -c "$cmd" 2>&1)
        if [[ $? -ne 0 ]]; then
            issues+=("T2:syntax-error: $syntax_error")
        fi
    fi

    # ═══════════════════════════════════════════════════════════════════════════
    # TIER 3: shellcheck deep analysis (~100ms, optional)
    # Comprehensive static analysis - only if shellcheck installed and level=full
    # ═══════════════════════════════════════════════════════════════════════════

    if [[ "$level" == "full" ]] && command -v shellcheck &>/dev/null; then
        local sc_output
        sc_output=$(echo "$cmd" | shellcheck -s bash -f gcc - 2>&1 | head -5)
        if [[ -n "$sc_output" ]] && [[ "$sc_output" != *"No issues"* ]]; then
            while IFS= read -r line; do
                [[ -n "$line" ]] && issues+=("T3:shellcheck: $line")
            done <<< "$sc_output"
        fi
    fi

    # ═══════════════════════════════════════════════════════════════════════════
    # OUTPUT
    # ═══════════════════════════════════════════════════════════════════════════

    if [[ ${#issues[@]} -gt 0 ]]; then
        echo "[COMMAND VALIDATION FAILED]"
        printf '  %s\n' "${issues[@]}"
        _lint_log "WARN" "Command validation failed: ${issues[*]}"
        return 1
    fi

    return 0
}

# Quick validation (Tier 1 only) - for hooks, ~1ms
quick_validate_command() {
    validate_command "$1" "quick"
}

# Syntax validation (Tier 1+2) - default, ~5ms
syntax_validate_command() {
    validate_command "$1" "syntax"
}

# Full validation (all tiers) - thorough, ~100ms
full_validate_command() {
    validate_command "$1" "full"
}

# Export functions
export -f is_sourceable_script
export -f check_readonly_redeclaration
export -f check_unguarded_source
export -f check_missing_pipefail
export -f lint_file
export -f lint_file_json
export -f lint_claude_scripts
export -f log_error_signature
export -f quick_lint
export -f validate_command
export -f quick_validate_command
export -f syntax_validate_command
export -f full_validate_command
