#!/usr/bin/env bash
#
# Pre-execution Python Syntax Validator
# Runs py_compile on Python files before writing to catch syntax errors
#
# Usage: source this file, then call validate_python_content "$content"
# Returns: JSON with continue: true/false
#
# VERSION: 1.0.0
# DATE: 2025-12-22

set -euo pipefail

# Validate Python content using py_compile
# Args: $1 = Python script content
# Returns: JSON {"continue": true/false, "reason": "..."}
validate_python_content() {
    local content="$1"

    # Skip empty content
    if [[ -z "$content" ]]; then
        echo '{"continue": true}'
        return 0
    fi

    # Check if python3 is available
    if ! command -v python3 &>/dev/null; then
        echo '{"continue": true}'
        return 0
    fi

    local tmp_file
    tmp_file=$(mktemp /tmp/python-validate-XXXXXX.py)

    # Write content to temp file
    printf '%s' "$content" > "$tmp_file"

    # Run py_compile for syntax validation
    local errors
    errors=$(python3 -m py_compile "$tmp_file" 2>&1) || true

    rm -f "$tmp_file"

    # Check if there are syntax errors
    if [[ -n "$errors" ]]; then
        # Extract error message, escape for JSON
        local error_msg
        error_msg=$(echo "$errors" | grep -E "(SyntaxError|IndentationError|TabError)" | head -1 | sed 's/"/\\"/g' | tr -d '\n')

        if [[ -z "$error_msg" ]]; then
            # Fallback: use first line of error
            error_msg=$(echo "$errors" | head -1 | sed 's/"/\\"/g' | tr -d '\n')
        fi

        printf '{"continue": false, "reason": "py_compile: %s"}' "$error_msg"
        return 1
    fi

    echo '{"continue": true}'
    return 0
}

# Validate Python file path (for Edit tool)
# Args: $1 = file path, $2 = new content (after edit)
validate_python_file() {
    local file_path="$1"
    local content="$2"

    # Only validate .py files
    if [[ "$file_path" != *.py ]]; then
        echo '{"continue": true}'
        return 0
    fi

    validate_python_content "$content"
}

# Main execution if called directly (for testing)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 'python code to validate'"
        exit 1
    fi
    validate_python_content "$1"
fi
