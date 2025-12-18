#!/usr/bin/env bash
#
# Skill Loader Library
# Scans, registers, and activates skills from ~/.claude/skills/
#
# PURPOSE:
#   Skills exist as SKILL.md files but have no loading mechanism.
#   This library provides:
#   1. Skill discovery and indexing
#   2. Metadata extraction from YAML frontmatter
#   3. Trigger-based activation
#   4. On-demand loading to minimize token usage
#
# USAGE:
#   source ~/.claude/lib/skill-loader.sh
#
#   # Index all skills
#   index_all_skills
#
#   # Load specific skill
#   load_skill "context-refresh"
#
#   # Check if skill should activate
#   should_activate_skill "figma-to-code" "implement this Figma design"
#
# VERSION: 1.0.0
# DATE: 2025-11-27
#

set -euo pipefail

# ============================================================================
# DEPENDENCIES
# ============================================================================

# Source shared YAML utilities
SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
source "$SCRIPT_DIR/yaml-utils.sh"

# ============================================================================
# CONSTANTS
# ============================================================================

# Simple assignment (bash 3.x compatible, safe when re-sourced)
SKILLS_DIR="${SKILLS_DIR:-$HOME/.claude/skills}"
SKILLS_INDEX="${SKILLS_INDEX:-$HOME/.claude/skills-index.json}"
SKILLS_CACHE_DIR="${SKILLS_CACHE_DIR:-$HOME/.claude/.cache/skills}"

# ============================================================================
# LOGGING (Compatible with optim.sh)
# ============================================================================

_skill_log_info() {
    echo "[SKILL-LOADER][INFO] $*" >&2
}

_skill_log_warn() {
    echo "[SKILL-LOADER][WARN] $*" >&2
}

_skill_log_error() {
    echo "[SKILL-LOADER][ERROR] $*" >&2
}

_skill_log_success() {
    echo "[SKILL-LOADER][SUCCESS] $*" >&2
}

# ============================================================================
# YAML FRONTMATTER PARSING
# ============================================================================

# Parse YAML frontmatter from a SKILL.md file and convert to JSON
# Uses shared extract_frontmatter from yaml-utils.sh
# Returns: JSON object of frontmatter fields
parse_skill_frontmatter() {
    local skill_file="$1"

    if [[ ! -f "$skill_file" ]]; then
        echo "{}"
        return 1
    fi

    # Extract content between --- markers using shared utility
    local frontmatter
    frontmatter=$(extract_frontmatter "$skill_file")

    if [[ -z "$frontmatter" ]]; then
        echo "{}"
        return 0
    fi

    # Convert YAML to JSON (simple key: value parsing)
    local json="{"
    local first=true

    while IFS=: read -r key value; do
        # Skip empty lines and comments
        [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue

        # Clean key and value
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs | sed 's/^"//' | sed 's/"$//')

        # Handle arrays (simple detection)
        if [[ "$value" =~ ^\[ ]]; then
            # Array value - keep as-is
            :
        elif [[ "$value" =~ ^[0-9]+$ ]]; then
            # Numeric value - no quotes
            :
        elif [[ "$value" == "true" || "$value" == "false" ]]; then
            # Boolean - no quotes
            :
        else
            # String value - add quotes
            value="\"$value\""
        fi

        if [[ "$first" == "true" ]]; then
            first=false
        else
            json+=","
        fi

        json+="\"$key\":$value"
    done <<< "$frontmatter"

    json+="}"

    echo "$json"
}

# Extract specific field from frontmatter
get_frontmatter_field() {
    local skill_file="$1"
    local field="$2"

    parse_skill_frontmatter "$skill_file" | jq -r ".$field // empty"
}

# ============================================================================
# SKILL DISCOVERY
# ============================================================================

# Find all skill directories
discover_skills() {
    if [[ ! -d "$SKILLS_DIR" ]]; then
        _skill_log_warn "Skills directory not found: $SKILLS_DIR"
        return 1
    fi

    # Find all SKILL.md files
    fd -t f "SKILL.md" "$SKILLS_DIR" 2>/dev/null | \
        xargs -I{} dirname {} | \
        xargs -I{} basename {}
}

# Count total skills
count_skills() {
    discover_skills 2>/dev/null | wc -l | tr -d ' '
}

# Check if skill exists
skill_exists() {
    local skill_name="$1"
    local skill_file="$SKILLS_DIR/$skill_name/SKILL.md"

    [[ -f "$skill_file" ]]
}

# Get skill file path
get_skill_path() {
    local skill_name="$1"
    echo "$SKILLS_DIR/$skill_name/SKILL.md"
}

# ============================================================================
# SKILL INDEXING
# ============================================================================

# Build index of all skills with metadata
index_all_skills() {
    _skill_log_info "Indexing skills from: $SKILLS_DIR"

    local index="{\"skills\":{},\"meta\":{}}"
    local skill_count=0
    local error_count=0

    while IFS= read -r skill_name; do
        [[ -z "$skill_name" ]] && continue

        local skill_file="$SKILLS_DIR/$skill_name/SKILL.md"

        if [[ -f "$skill_file" ]]; then
            # Extract metadata
            local metadata=$(parse_skill_frontmatter "$skill_file")

            # Add file path and name
            metadata=$(echo "$metadata" | jq \
                --arg name "$skill_name" \
                --arg path "$skill_file" \
                '. + {skill_name: $name, file_path: $path}')

            # Add to index
            index=$(echo "$index" | jq \
                --arg name "$skill_name" \
                --argjson meta "$metadata" \
                '.skills[$name] = $meta')

            skill_count=$((skill_count + 1))
        else
            _skill_log_warn "SKILL.md not found for: $skill_name"
            error_count=$((error_count + 1))
        fi
    done < <(discover_skills)

    # Add meta information
    index=$(echo "$index" | jq \
        --arg count "$skill_count" \
        --arg errors "$error_count" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '.meta = {
            total_skills: ($count | tonumber),
            errors: ($errors | tonumber),
            indexed_at: $timestamp
        }')

    # Save to index file
    echo "$index" | jq '.' > "$SKILLS_INDEX"

    _skill_log_success "Indexed $skill_count skills ($error_count errors)"
    echo "$index"
}

# Get skill metadata from index
get_skill_metadata() {
    local skill_name="$1"

    if [[ ! -f "$SKILLS_INDEX" ]]; then
        index_all_skills > /dev/null
    fi

    jq -r ".skills[\"$skill_name\"] // empty" "$SKILLS_INDEX"
}

# List all indexed skills
list_skills() {
    if [[ ! -f "$SKILLS_INDEX" ]]; then
        index_all_skills > /dev/null
    fi

    jq -r '.skills | keys[]' "$SKILLS_INDEX"
}

# ============================================================================
# SKILL LOADING
# ============================================================================

# Load skill content (full SKILL.md)
load_skill() {
    local skill_name="$1"
    local skill_file=$(get_skill_path "$skill_name")

    if [[ ! -f "$skill_file" ]]; then
        _skill_log_error "Skill not found: $skill_name"
        return 1
    fi

    _skill_log_info "Loading skill: $skill_name"

    # Return content
    cat "$skill_file"
}

# Load skill summary (frontmatter + first section only)
load_skill_summary() {
    local skill_name="$1"
    local skill_file=$(get_skill_path "$skill_name")

    if [[ ! -f "$skill_file" ]]; then
        _skill_log_error "Skill not found: $skill_name"
        return 1
    fi

    # Extract frontmatter + first section (up to second ## header)
    awk '
        /^---$/ { if(fm) fm=0; else fm=1; print; next }
        fm { print; next }
        /^## / { if(seen_header) exit; seen_header=1 }
        { print }
    ' "$skill_file"
}

# Load multiple skills
load_skills() {
    local skills=("$@")

    for skill in "${skills[@]}"; do
        echo "=== SKILL: $skill ==="
        load_skill "$skill"
        echo ""
    done
}

# ============================================================================
# TRIGGER DETECTION
# ============================================================================

# Check if user input matches skill triggers
should_activate_skill() {
    local skill_name="$1"
    local user_input="$2"

    local metadata=$(get_skill_metadata "$skill_name")

    if [[ -z "$metadata" ]]; then
        return 1
    fi

    # Get description (contains trigger conditions)
    local description=$(echo "$metadata" | jq -r '.description // empty')

    # Get command trigger
    local command=$(echo "$metadata" | jq -r '.command // empty')

    # Check if user input contains command
    if [[ -n "$command" && "$user_input" =~ $command ]]; then
        return 0
    fi

    # Check common trigger patterns based on skill name
    case "$skill_name" in
        context-refresh)
            [[ "$user_input" =~ (refresh|understand|context|session.start) ]] && return 0
            ;;
        figma-to-code)
            [[ "$user_input" =~ (figma|design|implement.*design|ui.*from) ]] && return 0
            ;;
        mobile-responsive-ui)
            [[ "$user_input" =~ (mobile|responsive|viewport|css|html|ui) ]] && return 0
            ;;
        pr-automation)
            [[ "$user_input" =~ (create.*pr|pull.*request|pr.*create) ]] && return 0
            ;;
        yagni-principle)
            [[ "$user_input" =~ (future|maybe|might.*need|just.*in.*case) ]] && return 0
            ;;
        *)
            # Generic: check if skill name appears in input
            [[ "$user_input" =~ $skill_name ]] && return 0
            ;;
    esac

    return 1
}

# Find all skills that should activate for given input
find_matching_skills() {
    local user_input="$1"
    local matches=()

    while IFS= read -r skill_name; do
        if should_activate_skill "$skill_name" "$user_input"; then
            matches+=("$skill_name")
        fi
    done < <(list_skills)

    printf '%s\n' "${matches[@]}"
}

# ============================================================================
# SKILL COMMANDS
# ============================================================================

# Get command for skill
get_skill_command() {
    local skill_name="$1"
    local metadata=$(get_skill_metadata "$skill_name")

    echo "$metadata" | jq -r '.command // empty'
}

# Find skill by command
find_skill_by_command() {
    local command="$1"

    if [[ ! -f "$SKILLS_INDEX" ]]; then
        index_all_skills > /dev/null
    fi

    jq -r ".skills | to_entries[] | select(.value.command == \"$command\") | .key" "$SKILLS_INDEX"
}

# ============================================================================
# CACHE MANAGEMENT
# ============================================================================

# Cache loaded skill (to avoid re-reading)
cache_skill() {
    local skill_name="$1"
    local content="$2"

    mkdir -p "$SKILLS_CACHE_DIR"

    local cache_file="$SKILLS_CACHE_DIR/${skill_name}.cache"
    echo "$content" > "$cache_file"

    _skill_log_info "Cached skill: $skill_name"
}

# Get cached skill
get_cached_skill() {
    local skill_name="$1"
    local cache_file="$SKILLS_CACHE_DIR/${skill_name}.cache"

    if [[ -f "$cache_file" ]]; then
        cat "$cache_file"
        return 0
    fi

    return 1
}

# Clear skill cache
clear_skill_cache() {
    if [[ -d "$SKILLS_CACHE_DIR" ]]; then
        rm -rf "$SKILLS_CACHE_DIR"/*
        _skill_log_info "Cleared skill cache"
    fi
}

# ============================================================================
# DIAGNOSTICS
# ============================================================================

# Print skill information
diagnose_skill() {
    local skill_name="$1"

    echo "=== Skill Diagnosis: $skill_name ==="
    echo ""

    if ! skill_exists "$skill_name"; then
        echo "Status: NOT FOUND"
        echo "Expected path: $(get_skill_path "$skill_name")"
        return 1
    fi

    local skill_file=$(get_skill_path "$skill_name")
    echo "Path: $skill_file"
    echo "Size: $(wc -c < "$skill_file" | tr -d ' ') bytes"
    echo "Lines: $(wc -l < "$skill_file" | tr -d ' ')"
    echo ""

    echo "Frontmatter:"
    parse_skill_frontmatter "$skill_file" | jq '.'
    echo ""

    echo "Sections:"
    rg '^## ' "$skill_file" 2>/dev/null || echo "(none found)"
    echo ""

    echo "=== End Diagnosis ==="
}

# Print all skills summary
diagnose_all_skills() {
    echo "=== Skills Summary ==="
    echo ""
    echo "Skills directory: $SKILLS_DIR"
    echo "Index file: $SKILLS_INDEX"
    echo ""

    # Index if needed
    if [[ ! -f "$SKILLS_INDEX" ]]; then
        index_all_skills > /dev/null
    fi

    echo "Total skills: $(count_skills)"
    echo ""

    echo "Skill list:"
    while IFS= read -r skill; do
        local command=$(get_skill_command "$skill")
        if [[ -n "$command" ]]; then
            printf "  %-30s %s\n" "$skill" "$command"
        else
            printf "  %-30s (no command)\n" "$skill"
        fi
    done < <(list_skills)

    echo ""
    echo "=== End Summary ==="
}

# ============================================================================
# EXPORTS
# ============================================================================

export -f parse_skill_frontmatter
export -f get_frontmatter_field
export -f discover_skills
export -f count_skills
export -f skill_exists
export -f get_skill_path
export -f index_all_skills
export -f get_skill_metadata
export -f list_skills
export -f load_skill
export -f load_skill_summary
export -f load_skills
export -f should_activate_skill
export -f find_matching_skills
export -f get_skill_command
export -f find_skill_by_command
export -f cache_skill
export -f get_cached_skill
export -f clear_skill_cache
export -f diagnose_skill
export -f diagnose_all_skills

# ============================================================================
# MAIN (if run directly)
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-help}" in
        index|--index|-i)
            index_all_skills
            ;;
        list|--list|-l)
            list_skills
            ;;
        load|--load)
            load_skill "${2:-}"
            ;;
        summary|--summary)
            load_skill_summary "${2:-}"
            ;;
        diagnose|--diagnose|-d)
            if [[ -n "${2:-}" ]]; then
                diagnose_skill "$2"
            else
                diagnose_all_skills
            fi
            ;;
        match|--match|-m)
            find_matching_skills "${2:-}"
            ;;
        help|--help|-h)
            cat << 'EOF'
Skill Loader Library - Scan, register, and activate skills

USAGE:
    ./skill-loader.sh [command] [args]

COMMANDS:
    index               Build index of all skills
    list                List all indexed skills
    load <skill>        Load full skill content
    summary <skill>     Load skill summary (frontmatter + first section)
    diagnose [skill]    Diagnose skill(s)
    match <input>       Find skills matching input
    help                Show this help message

AS LIBRARY:
    source ~/.claude/lib/skill-loader.sh

    # Index all skills
    index_all_skills

    # Load a skill
    content=$(load_skill "context-refresh")

    # Find matching skills
    matches=$(find_matching_skills "implement this Figma design")

EOF
            ;;
        *)
            echo "Unknown command: $1"
            echo "Run '$0 help' for usage"
            exit 1
            ;;
    esac
fi
