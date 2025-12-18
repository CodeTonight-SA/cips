#!/usr/bin/env bash
#
# YAML Utilities Library
# DRY extraction of frontmatter parsing used across multiple scripts
#
# PURPOSE:
#   Extract YAML frontmatter from markdown files following the Jekyll/Hugo
#   convention of --- delimited blocks at file start.
#
# USAGE:
#   source ~/.claude/lib/yaml-utils.sh
#   frontmatter=$(extract_frontmatter "/path/to/file.md")
#
# VERSION: 1.0.0
# DATE: 2025-12-18
#

# Guard against multiple sourcing
[[ -n "${_YAML_UTILS_LOADED:-}" ]] && return 0
readonly _YAML_UTILS_LOADED=1

set -euo pipefail

# ============================================================================
# FRONTMATTER EXTRACTION
# ============================================================================

# Extract YAML frontmatter from a markdown file
# The frontmatter is the content between the first two --- lines
#
# Args: $1 = path to markdown file
# Returns: YAML content on stdout (without --- delimiters)
# Exit: 0 on success, 1 if file not found
#
# Example:
#   ---
#   title: My Document
#   tags: [foo, bar]
#   ---
#   Content here...
#
#   Returns:
#   title: My Document
#   tags: [foo, bar]
#
extract_frontmatter() {
    local file="$1"

    [[ -f "$file" ]] || return 1

    awk '/^---$/{if(p)exit;p=1;next}p' "$file"
}

# Check if a file has valid YAML frontmatter
# Returns: 0 if frontmatter exists, 1 otherwise
has_frontmatter() {
    local file="$1"

    [[ -f "$file" ]] || return 1

    # Check if first line is ---
    local first_line
    first_line=$(head -1 "$file" 2>/dev/null)
    [[ "$first_line" == "---" ]]
}

# Extract a specific key from frontmatter (simple parsing)
# Only works for simple key: value pairs, not nested YAML
#
# Args: $1 = file path, $2 = key name
# Returns: Value on stdout
get_frontmatter_value() {
    local file="$1"
    local key="$2"

    extract_frontmatter "$file" | grep "^${key}:" | head -1 | sed "s/^${key}:[[:space:]]*//"
}

# ============================================================================
# EXPORTS
# ============================================================================

export -f extract_frontmatter
export -f has_frontmatter
export -f get_frontmatter_value
