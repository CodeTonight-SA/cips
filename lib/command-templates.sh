#!/usr/bin/env bash
#
# Command Templates Library
# Pre-validated patterns for common bash operations
#
# PURPOSE:
#   Provides correct, tested command patterns to avoid common errors:
#   1. Semicolon after subshell (parse error in eval contexts)
#   2. Path encoding without leading slash removal (dash prefix issues)
#   3. fd/find without -- before variable paths (flag interpretation)
#
# USAGE:
#   source ~/.claude/lib/command-templates.sh
#
#   # Encode project path correctly
#   PROJ=$(encode_project_path) && echo "$PROJ"
#
#   # Find project history
#   find_project_history
#
# VERSION: 1.0.0
# DATE: 2025-12-01
#

set -euo pipefail

# Guard against re-sourcing
[[ -z "${CMD_TEMPLATES_LOADED:-}" ]] && readonly CMD_TEMPLATES_LOADED=1 || return 0

# ═══════════════════════════════════════════════════════════════════════════════
# PATH ENCODING
# ═══════════════════════════════════════════════════════════════════════════════
#
# CRITICAL: Must remove leading slash FIRST to avoid -Users-... prefix
# /Users/foo → Users-foo (CORRECT)
# NOT: /Users/foo → -Users-foo (WRONG - dash interpreted as flag)

# Encode filesystem path for Claude project directory format
# Input:  /Users/username/project
# Output: -Users-username-project (WITH leading dash, dots become dashes)
# Claude Code's ACTUAL encoding: replace / with -, replace . with -
# Example: /Users/foo/.claude → -Users-foo--claude
encode_project_path() {
    local path="${1:-$(pwd)}"
    # Step 1: Replace all slashes with dashes (keeps leading dash from /)
    # Step 2: Replace all dots with dashes
    echo "$path" | sed 's|/|-|g' | sed 's|\.|-|g'
}

# Decode Claude project directory back to filesystem path
decode_project_path() {
    local encoded="$1"
    echo "/$encoded" | sed 's|-|/|g'
}

# ═══════════════════════════════════════════════════════════════════════════════
# PROJECT HISTORY
# ═══════════════════════════════════════════════════════════════════════════════
#
# CRITICAL: Use -- before path variable to prevent flag interpretation
# fd -t d -- "$path" (CORRECT)
# NOT: fd -t d "$path" (WRONG if path starts with dash)

# Find Claude project history directory for current working directory
find_project_history() {
    local encoded
    # Use && not ; after command substitution
    encoded=$(encode_project_path) && fd -t d -- "$encoded" ~/.claude/projects 2>/dev/null | head -1
}

# Get latest history file for current project
get_latest_history() {
    local dir
    dir=$(find_project_history)
    [[ -n "$dir" ]] && fd -e jsonl . "$dir" -t f --exec stat -f '%m %N' {} 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-
}

# Count history entries for current project
count_project_history() {
    local dir
    dir=$(find_project_history)
    [[ -n "$dir" ]] && fd -e jsonl . "$dir" -t f --exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}'
}

# ═══════════════════════════════════════════════════════════════════════════════
# SAFE COMMAND PATTERNS
# ═══════════════════════════════════════════════════════════════════════════════
#
# CRITICAL: Use && not ; after $() to avoid parse errors in eval contexts

# Safe echo after command substitution
# Usage: safe_echo "$(some_command)" "Label"
safe_echo() {
    local value="$1"
    local label="${2:-Result}"
    [[ -n "$value" ]] && echo "$label: $value" || echo "$label: (empty)"
}

# Safe variable assignment with echo
# Usage: result=$(safe_assign "$(pwd | some_transform)")
safe_assign() {
    local value="$1"
    echo "$value"
}

# ═══════════════════════════════════════════════════════════════════════════════
# DIAGNOSTICS
# ═══════════════════════════════════════════════════════════════════════════════

# Show correct patterns for reference
show_correct_patterns() {
    cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
CORRECT BASH PATTERNS (memorise these!)
═══════════════════════════════════════════════════════════════════════════════

1. PATH ENCODING (Claude Code's actual format - leading dash + dots become dashes)
   ✗ WRONG: pwd | sed 's|^/||' | sed 's|/|-|g'   → Users-foo-.claude (FAILS!)
   ✓ RIGHT: pwd | sed 's|/|-|g' | sed 's|\.|-|g' → -Users-foo--claude (MATCHES!)

2. COMMAND CHAINING (avoid parse errors)
   ✗ BAD:  VAR=$(cmd); echo $VAR         → parse error near ')'
   ✓ GOOD: VAR=$(cmd) && echo "$VAR"

3. DASH-PREFIXED PATHS (use -- to end flag parsing)
   ✗ BAD:  fd -t d "$path"               → unexpected argument '-U'
   ✓ GOOD: fd -t d -- "$path"            → works with -Users-foo--claude

4. COMPLETE PROJECT HISTORY PATTERN
   ✓ GOOD: PROJECT_DIR=$(pwd | sed 's|/|-|g' | sed 's|\.|-|g') && fd -t d -- "$PROJECT_DIR" ~/.claude/projects

═══════════════════════════════════════════════════════════════════════════════
EOF
}

# ═══════════════════════════════════════════════════════════════════════════════
# EXPORTS
# ═══════════════════════════════════════════════════════════════════════════════

export -f encode_project_path
export -f decode_project_path
export -f find_project_history
export -f get_latest_history
export -f count_project_history
export -f safe_echo
export -f safe_assign
export -f show_correct_patterns
