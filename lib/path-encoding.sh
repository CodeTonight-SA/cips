#!/usr/bin/env bash
#
# Path Encoding Library (Unified)
# Single source of truth for Claude Code's project path encoding
#
# FORMULA:
#   - Replace all '/' with '-'
#   - Replace all '.' with '-'
#   - Replace all ' ' with '-'
#   Example: /Users/foo/.claude -> -Users-foo--claude
#
# CROSS-PLATFORM:
#   - macOS/Linux: /Users/name/... -> -Users-name-...
#   - Windows Git Bash: /c/Users/... -> c--Users-...
#
# USAGE:
#   source ~/.claude/lib/path-encoding.sh
#   encoded=$(encode_project_path "/Users/foo/.claude")
#   encoded=$(encode_current_path)
#
# VERSION: 1.0.0
# DATE: 2025-12-18
#

# Guard against multiple sourcing
[[ -n "${_PATH_ENCODING_LOADED:-}" ]] && return 0
readonly _PATH_ENCODING_LOADED=1

# Encode a filesystem path to Claude's project directory format
# Cross-platform: macOS, Linux, Windows Git Bash
# Input: /Users/name/project -> -Users-name-project
encode_project_path() {
    local path="$1"

    # Cross-platform path normalisation for Windows Git Bash
    case "$(uname -s)" in
        MINGW*|MSYS*|CYGWIN*)
            # Windows Git Bash: /c/Users/... -> c--Users-...
            if [[ "$path" =~ ^/([a-zA-Z])/ ]]; then
                local drive="${BASH_REMATCH[1]}"
                path="${drive}--${path:3}"
            fi
            ;;
    esac

    # Universal: Replace slashes, dots, spaces with dashes
    echo "$path" | sed 's|/|-|g' | sed 's|\.|-|g' | sed 's| |-|g'
}

# Encode current working directory
encode_current_path() {
    encode_project_path "$(pwd)"
}

# Decode a Claude project directory name back to filesystem path (best effort)
# Note: Decoding is lossy - cannot distinguish . from / in original
decode_project_path() {
    local encoded="$1"
    echo "$encoded" | sed 's|^-|/|' | sed 's|-|/|g'
}
