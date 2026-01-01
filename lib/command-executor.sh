#!/usr/bin/env bash
#
# Command Executor Library
# Maps slash commands to skills/agents and executes them
#
# PURPOSE:
#   Commands exist as .md files but have no execution mechanism.
#   This library provides:
#   1. Command discovery and registration
#   2. Command → Skill/Agent mapping
#   3. Execution with result capture
#   4. Integration with orchestrator
#
# USAGE:
#   source ~/.claude/lib/command-executor.sh
#
#   # List available commands
#   list_commands
#
#   # Execute command
#   execute_command "refresh-context"
#
#   # Get command info
#   get_command_info "create-pr"
#
# VERSION: 1.0.0
# DATE: 2025-11-27
#

set -euo pipefail

# ============================================================================
# CONSTANTS
# ============================================================================

[[ -z "${COMMANDS_DIR:-}" ]] && readonly COMMANDS_DIR="$HOME/.claude/commands"
[[ -z "${COMMANDS_INDEX:-}" ]] && readonly COMMANDS_INDEX="$HOME/.claude/commands-index.json"
[[ -z "${LIB_DIR:-}" ]] && readonly LIB_DIR="$HOME/.claude/lib"

# ============================================================================
# DEPENDENCIES
# ============================================================================

# Source skill loader if available
if [[ -f "$LIB_DIR/skill-loader.sh" ]]; then
    # shellcheck source=skill-loader.sh
    source "$LIB_DIR/skill-loader.sh"
fi

# ============================================================================
# LOGGING
# ============================================================================

_cmd_log_info() {
    echo "[CMD-EXECUTOR][INFO] $*" >&2
}

_cmd_log_warn() {
    echo "[CMD-EXECUTOR][WARN] $*" >&2
}

_cmd_log_error() {
    echo "[CMD-EXECUTOR][ERROR] $*" >&2
}

_cmd_log_success() {
    echo "[CMD-EXECUTOR][SUCCESS] $*" >&2
}

# ============================================================================
# COMMAND DISCOVERY
# ============================================================================

# Find all command files (.md files in commands directory)
discover_commands() {
    if [[ ! -d "$COMMANDS_DIR" ]]; then
        _cmd_log_warn "Commands directory not found: $COMMANDS_DIR"
        return 1
    fi

    fd -e md . "$COMMANDS_DIR" -t f 2>/dev/null | \
        xargs -I{} basename {} .md
}

# Count total commands
count_commands() {
    discover_commands 2>/dev/null | wc -l | tr -d ' '
}

# Check if command exists
command_exists() {
    local cmd_name="$1"
    local cmd_file="$COMMANDS_DIR/${cmd_name}.md"

    [[ -f "$cmd_file" ]]
}

# Get command file path
get_command_path() {
    local cmd_name="$1"
    echo "$COMMANDS_DIR/${cmd_name}.md"
}

# ============================================================================
# COMMAND METADATA EXTRACTION
# ============================================================================

# Extract frontmatter from command file and convert to JSON
# Uses shared extract_frontmatter from yaml-utils.sh (via skill-loader.sh)
extract_command_frontmatter() {
    local cmd_file="$1"

    if [[ ! -f "$cmd_file" ]]; then
        echo "{}"
        return 1
    fi

    # Extract YAML frontmatter using shared utility
    local frontmatter
    frontmatter=$(extract_frontmatter "$cmd_file")

    if [[ -z "$frontmatter" ]]; then
        echo "{}"
        return 0
    fi

    # Parse key: value pairs to JSON
    local json="{"
    local first=true

    while IFS=: read -r key value; do
        [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue

        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs | sed 's/^"//' | sed 's/"$//')

        # Handle special values
        if [[ "$value" == "true" || "$value" == "false" ]]; then
            :
        elif [[ "$value" =~ ^[0-9]+$ ]]; then
            :
        else
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

# Get command description
get_command_description() {
    local cmd_name="$1"
    local cmd_file
    cmd_file=$(get_command_path "$cmd_name")

    extract_command_frontmatter "$cmd_file" | jq -r '.description // empty'
}

# Get linked skill for command
get_command_skill() {
    local cmd_name="$1"
    local cmd_file
    cmd_file=$(get_command_path "$cmd_name")

    # First check frontmatter
    local skill
    skill=$(extract_command_frontmatter "$cmd_file" | jq -r '.skill // empty')

    if [[ -n "$skill" ]]; then
        echo "$skill"
        return 0
    fi

    # Fallback: search for skill reference in content
    rg -o 'skills/([a-z-]+)/' "$cmd_file" 2>/dev/null | \
        head -1 | \
        sed 's|skills/||' | \
        sed 's|/||'
}

# Get linked agent for command
get_command_agent() {
    local cmd_name="$1"
    local cmd_file
    cmd_file=$(get_command_path "$cmd_name")

    extract_command_frontmatter "$cmd_file" | jq -r '.agent // empty'
}

# ============================================================================
# COMMAND INDEXING
# ============================================================================

# Build index of all commands
index_all_commands() {
    _cmd_log_info "Indexing commands from: $COMMANDS_DIR"

    local index="{\"commands\":{},\"meta\":{}}"
    local cmd_count=0

    while IFS= read -r cmd_name; do
        [[ -z "$cmd_name" ]] && continue

        local cmd_file
        cmd_file=$(get_command_path "$cmd_name")

        if [[ -f "$cmd_file" ]]; then
            # Extract metadata
            local metadata
            metadata=$(extract_command_frontmatter "$cmd_file")

            # Add derived fields
            local skill
            skill=$(get_command_skill "$cmd_name")
            local agent
            agent=$(get_command_agent "$cmd_name")

            metadata=$(echo "$metadata" | jq \
                --arg name "$cmd_name" \
                --arg path "$cmd_file" \
                --arg skill "$skill" \
                --arg agent "$agent" \
                '. + {
                    command_name: $name,
                    file_path: $path,
                    linked_skill: (if $skill == "" then null else $skill end),
                    linked_agent: (if $agent == "" then null else $agent end)
                }')

            # Add to index
            index=$(echo "$index" | jq \
                --arg name "$cmd_name" \
                --argjson meta "$metadata" \
                '.commands[$name] = $meta')

            cmd_count=$((cmd_count + 1))
        fi
    done < <(discover_commands)

    # Add meta
    index=$(echo "$index" | jq \
        --arg count "$cmd_count" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '.meta = {
            total_commands: ($count | tonumber),
            indexed_at: $timestamp
        }')

    echo "$index" | jq '.' > "$COMMANDS_INDEX"

    _cmd_log_success "Indexed $cmd_count commands"
    echo "$index"
}

# Get command metadata from index
get_command_info() {
    local cmd_name="$1"

    if [[ ! -f "$COMMANDS_INDEX" ]]; then
        index_all_commands > /dev/null
    fi

    jq -r ".commands[\"$cmd_name\"] // empty" "$COMMANDS_INDEX"
}

# List all commands
list_commands() {
    if [[ ! -f "$COMMANDS_INDEX" ]]; then
        index_all_commands > /dev/null
    fi

    jq -r '.commands | keys[]' "$COMMANDS_INDEX"
}

# ============================================================================
# COMMAND EXECUTION
# ============================================================================

# Execute a command by name
execute_command() {
    local cmd_name="$1"
    shift
    local args=("$@")

    _cmd_log_info "Executing command: /$cmd_name"

    if ! command_exists "$cmd_name"; then
        _cmd_log_error "Command not found: $cmd_name"
        return 1
    fi

    # Get command info
    local info
    info=$(get_command_info "$cmd_name")
    local skill
    skill=$(echo "$info" | jq -r '.linked_skill // empty')
    local agent
    agent=$(echo "$info" | jq -r '.linked_agent // empty')

    # Strategy 1: If there's a linked skill, load it
    if [[ -n "$skill" ]] && type load_skill &>/dev/null; then
        _cmd_log_info "Loading linked skill: $skill"
        local skill_content
        skill_content=$(load_skill "$skill" 2>/dev/null)

        if [[ -n "$skill_content" ]]; then
            echo "=== Skill Protocol: $skill ==="
            echo "$skill_content"
            echo ""
            return 0
        fi
    fi

    # Strategy 2: If there's a handler script, execute it
    local handler_script="$COMMANDS_DIR/handlers/${cmd_name}.sh"
    if [[ -x "$handler_script" ]]; then
        _cmd_log_info "Running handler script: $handler_script"
        "$handler_script" "${args[@]}"
        return $?
    fi

    # Strategy 3: Output command content as instructions
    _cmd_log_info "No handler found, outputting command content"
    local cmd_file
    cmd_file=$(get_command_path "$cmd_name")

    echo "=== Command: /$cmd_name ==="
    echo ""

    # Skip frontmatter, output rest
    awk '
        /^---$/ { if(in_fm) in_fm=0; else in_fm=1; next }
        !in_fm { print }
    ' "$cmd_file"

    return 0
}

# Execute command and capture result
execute_command_capture() {
    local cmd_name="$1"
    shift

    local output
    local exit_code

    output=$(execute_command "$cmd_name" "$@" 2>&1)
    exit_code=$?

    # Return JSON result
    jq -nc \
        --arg cmd "$cmd_name" \
        --arg output "$output" \
        --arg code "$exit_code" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{
            command: $cmd,
            output: $output,
            exit_code: ($code | tonumber),
            executed_at: $timestamp
        }'
}

# ============================================================================
# COMMAND REGISTRATION
# ============================================================================

# Register a new command
register_command() {
    local cmd_name="$1"
    local description="$2"
    local skill="${3:-}"
    local agent="${4:-}"

    local cmd_file="$COMMANDS_DIR/${cmd_name}.md"

    if [[ -f "$cmd_file" ]]; then
        _cmd_log_warn "Command already exists: $cmd_name"
        return 1
    fi

    # Generate command file
    cat > "$cmd_file" << EOF
---
description: $description
skill: $skill
agent: $agent
created: $(date -u +%Y-%m-%dT%H:%M:%SZ)
---

# /$cmd_name

$description

## Usage

\`\`\`
/$cmd_name
\`\`\`

## Integration

EOF

    if [[ -n "$skill" ]]; then
        echo "Loads the \`$skill\` skill from:" >> "$cmd_file"
        echo "\`~/.claude/skills/$skill/SKILL.md\`" >> "$cmd_file"
    fi

    if [[ -n "$agent" ]]; then
        echo "" >> "$cmd_file"
        echo "Invokes the \`$agent\` agent." >> "$cmd_file"
    fi

    _cmd_log_success "Registered command: /$cmd_name"

    # Re-index
    index_all_commands > /dev/null

    echo "$cmd_file"
}

# ============================================================================
# COMMAND MAPPING
# ============================================================================

# Built-in command mappings (command -> skill:agent)
# Note: Using function instead of associative array for compatibility
get_command_mapping() {
    local cmd_name="$1"

    case "$cmd_name" in
        refresh-context)
            echo "context-refresh:context-refresh-agent"
            ;;
        create-pr)
            echo "pr-automation:pr-workflow-agent"
            ;;
        remind-yourself)
            echo "chat-history-search:history-mining-agent"
            ;;
        audit-efficiency)
            echo "self-improvement-engine:efficiency-auditor-agent"
            ;;
        contract-formal|contract-simplification)
            echo "legal-ops:"
            ;;
        setup-github-secrets)
            echo "github-secrets-setup:"
            ;;
        save-session-state)
            echo "session-state-persistence:"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Parse mapping into skill and agent
parse_command_mapping() {
    local mapping="$1"

    local skill
    skill=$(echo "$mapping" | cut -d: -f1)
    local agent
    agent=$(echo "$mapping" | cut -d: -f2)

    echo "$skill"
    echo "$agent"
}

# ============================================================================
# DIAGNOSTICS
# ============================================================================

# Diagnose command
diagnose_command() {
    local cmd_name="$1"

    echo "=== Command Diagnosis: /$cmd_name ==="
    echo ""

    if ! command_exists "$cmd_name"; then
        echo "Status: NOT FOUND"
        echo "Expected path: $(get_command_path "$cmd_name")"
        return 1
    fi

    local cmd_file
    cmd_file=$(get_command_path "$cmd_name")
    echo "Path: $cmd_file"
    echo "Size: $(wc -c < "$cmd_file" | tr -d ' ') bytes"
    echo ""

    echo "Metadata:"
    extract_command_frontmatter "$cmd_file" | jq '.'
    echo ""

    local skill
    skill=$(get_command_skill "$cmd_name")
    local agent
    agent=$(get_command_agent "$cmd_name")

    echo "Linked skill: ${skill:-none}"
    echo "Linked agent: ${agent:-none}"
    echo ""

    local handler="$COMMANDS_DIR/handlers/${cmd_name}.sh"
    if [[ -x "$handler" ]]; then
        echo "Handler script: $handler (executable)"
    else
        echo "Handler script: none"
    fi

    echo ""
    echo "=== End Diagnosis ==="
}

# Diagnose all commands
diagnose_all_commands() {
    echo "=== Commands Summary ==="
    echo ""
    echo "Commands directory: $COMMANDS_DIR"
    echo "Index file: $COMMANDS_INDEX"
    echo ""

    if [[ ! -f "$COMMANDS_INDEX" ]]; then
        index_all_commands > /dev/null
    fi

    echo "Total commands: $(count_commands)"
    echo ""

    echo "Command list:"
    printf "  %-25s %-25s %s\n" "COMMAND" "SKILL" "AGENT"
    printf "  %-25s %-25s %s\n" "-------" "-----" "-----"

    while IFS= read -r cmd; do
        local info
        info=$(get_command_info "$cmd")
        local skill
        skill=$(echo "$info" | jq -r '.linked_skill // "-"')
        local agent
        agent=$(echo "$info" | jq -r '.linked_agent // "-"')

        printf "  %-25s %-25s %s\n" "/$cmd" "$skill" "$agent"
    done < <(list_commands)

    echo ""
    echo "=== End Summary ==="
}

# ============================================================================
# EXPORTS
# ============================================================================

export -f discover_commands
export -f count_commands
export -f command_exists
export -f get_command_path
export -f extract_command_frontmatter
export -f get_command_description
export -f get_command_skill
export -f get_command_agent
export -f index_all_commands
export -f get_command_info
export -f list_commands
export -f execute_command
export -f execute_command_capture
export -f register_command
export -f get_command_mapping
export -f parse_command_mapping
export -f diagnose_command
export -f diagnose_all_commands

# ============================================================================
# MAIN
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-help}" in
        index|--index|-i)
            index_all_commands
            ;;
        list|--list|-l)
            list_commands
            ;;
        exec|--exec|-e)
            execute_command "${2:-}" "${@:3}"
            ;;
        info|--info)
            get_command_info "${2:-}"
            ;;
        register|--register|-r)
            register_command "${2:-}" "${3:-}" "${4:-}" "${5:-}"
            ;;
        diagnose|--diagnose|-d)
            if [[ -n "${2:-}" ]]; then
                diagnose_command "$2"
            else
                diagnose_all_commands
            fi
            ;;
        help|--help|-h)
            cat << 'EOF'
Command Executor Library - Map and execute slash commands

USAGE:
    ./command-executor.sh [command] [args]

COMMANDS:
    index               Build index of all commands
    list                List all commands
    exec <cmd> [args]   Execute a command
    info <cmd>          Get command metadata
    register <n> <d>    Register new command
    diagnose [cmd]      Diagnose command(s)
    help                Show this help message

AS LIBRARY:
    source ~/.claude/lib/command-executor.sh

    # Execute command
    execute_command "refresh-context"

    # Get command info
    info=$(get_command_info "create-pr")

EOF
            ;;
        *)
            echo "Unknown command: $1"
            echo "Run '$0 help' for usage"
            exit 1
            ;;
    esac
fi
