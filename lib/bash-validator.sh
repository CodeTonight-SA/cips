#!/usr/bin/env bash
#
# Pre-execution Bash Syntax Validator
# Runs shellcheck on commands before execution to catch errors early
# Also enforces tool selection rules (rg > grep, fd > find)
#
# Usage: source this file, then call validate_bash_command "$cmd"
# Returns: JSON with continue: true/false
#
# VERSION: 1.1.0
# DATE: 2025-12-22

set -euo pipefail

# Check for banned tool usage
# Args: $1 = command string
# Returns: JSON if violation found, empty string otherwise
check_tool_enforcement() {
    local cmd="$1"

    # Skip if command is defining aliases or functions
    [[ "$cmd" =~ ^alias ]] && return 0
    [[ "$cmd" =~ ^function ]] && return 0

    # Check for grep usage (should use rg)
    # Allow: grep inside pipes from other tools, grep -v in conditionals
    # Block: standalone grep for searching files
    if echo "$cmd" | rg -q '^\s*grep\s|[;&|]\s*grep\s' 2>/dev/null; then
        # Check if it's a file search pattern (grep + filename)
        if echo "$cmd" | rg -q 'grep\s+(-[a-zA-Z]+\s+)*["\x27]?[^|<>]+["\x27]?\s+[^\s|;&]+' 2>/dev/null; then
            printf '{"continue": false, "reason": "Tool violation: Use rg instead of grep for file searches. See rules/bash-safety.md"}'
            return 1
        fi
    fi

    # Check for find usage (should use fd)
    # Allow: find in complex expressions with -exec
    # Block: simple find for file discovery
    if echo "$cmd" | rg -q '^\s*find\s|[;&|]\s*find\s' 2>/dev/null; then
        # Simple find patterns (find . -name, find /path -type)
        if echo "$cmd" | rg -q 'find\s+[.\w/]+\s+-(name|type|iname)' 2>/dev/null; then
            printf '{"continue": false, "reason": "Tool violation: Use fd instead of find for file discovery. See rules/bash-safety.md"}'
            return 1
        fi
    fi

    # Check for cat usage for file display (should use bat)
    # Only block: cat file | less, cat file for viewing
    # Allow: cat for heredocs, cat in pipes as producer

    return 0
}

# Validate bash command using shellcheck
# Args: $1 = command string
# Returns: JSON {"continue": true/false, "reason": "..."}
validate_bash_command() {
    local cmd="$1"

    # Skip empty commands
    if [[ -z "$cmd" ]]; then
        echo '{"continue": true}'
        return 0
    fi

    # Skip simple commands that shellcheck struggles with
    # (single word commands, variable assignments only)
    if [[ "$cmd" =~ ^[a-zA-Z_][a-zA-Z0-9_]*=.* ]] && [[ "$cmd" != *$'\n'* ]]; then
        echo '{"continue": true}'
        return 0
    fi

    # Check tool enforcement FIRST (rg > grep, fd > find)
    local tool_check
    tool_check=$(check_tool_enforcement "$cmd") || {
        echo "$tool_check"
        return 1
    }

    # Check if shellcheck is available
    if ! command -v shellcheck &>/dev/null; then
        # Can't validate without shellcheck, allow execution
        echo '{"continue": true}'
        return 0
    fi

    local tmp_file
    tmp_file=$(mktemp /tmp/bash-validate-XXXXXX.sh)

    # Write command as script with shebang
    {
        echo "#!/usr/bin/env bash"
        echo "$cmd"
    } > "$tmp_file"

    # Run shellcheck
    # -s bash: use bash dialect
    # -e SC2148: ignore missing shebang (we add it)
    # -e SC2086: ignore word splitting (common in CLI usage)
    # -e SC2046: ignore word splitting in command substitution
    # -e SC1091: ignore can't follow sourced files
    # -e SC2034: ignore unused variables (common in snippets)
    # -S error: only report errors, not warnings/info
    local errors
    errors=$(shellcheck -s bash -S error \
        -e SC2148 -e SC2086 -e SC2046 -e SC1091 -e SC2034 \
        -f gcc "$tmp_file" 2>&1) || true

    rm -f "$tmp_file"

    # Check if there are actual errors
    if [[ -n "$errors" ]] && echo "$errors" | grep -q ":.*:.*: error:"; then
        # Extract first error message, escape for JSON
        local first_error
        first_error=$(echo "$errors" | grep ": error:" | head -1 | sed 's/.*: error: //' | sed 's/"/\\"/g' | tr -d '\n')

        # Return block decision with reason
        printf '{"continue": false, "reason": "shellcheck: %s"}' "$first_error"
        return 1
    fi

    echo '{"continue": true}'
    return 0
}

# Main execution if called directly (for testing)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 'command to validate'"
        exit 1
    fi
    validate_bash_command "$1"
fi
