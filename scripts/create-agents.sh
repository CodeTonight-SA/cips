#!/usr/bin/env bash
#
# Agent Creator Script
# Generates agent definitions from templates and patterns
#
# PURPOSE:
#   crazy_script.sh references this script but it didn't exist.
#   This script provides:
#   1. Agent template filling
#   2. Agent registration
#   3. Agent validation
#   4. Integration with metrics
#
# USAGE:
#   ./create-agents.sh create --name <name> --description <desc> [options]
#   ./create-agents.sh list
#   ./create-agents.sh diagnose <name>
#
# VERSION: 1.0.0
# DATE: 2025-11-27
#

set -euo pipefail

# ============================================================================
# CONSTANTS
# ============================================================================

readonly CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
readonly AGENTS_DIR="${AGENTS_DIR:-$CLAUDE_DIR/agents}"
readonly TEMPLATES_DIR="${TEMPLATES_DIR:-$CLAUDE_DIR/templates}"
readonly AGENT_TEMPLATE="${AGENT_TEMPLATE:-$TEMPLATES_DIR/agent.template.md}"
readonly AGENTS_REGISTRY="${AGENTS_REGISTRY:-$CLAUDE_DIR/agents-registry.json}"
readonly METRICS_FILE="${METRICS_FILE:-$CLAUDE_DIR/metrics.jsonl}"

# ============================================================================
# LOGGING
# ============================================================================

log_info() {
    echo "[AGENT-CREATOR][INFO] $*" >&2
}

log_warn() {
    echo "[AGENT-CREATOR][WARN] $*" >&2
}

log_error() {
    echo "[AGENT-CREATOR][ERROR] $*" >&2
}

log_success() {
    echo "[AGENT-CREATOR][SUCCESS] $*" >&2
}

# ============================================================================
# UTILITIES
# ============================================================================

timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

current_epoch() {
    echo "$(date +%s)000"
}

# Convert kebab-case to Title Case
to_title_case() {
    echo "$1" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1'
}

# ============================================================================
# AGENT CREATION
# ============================================================================

# Create agent from parameters
create_agent() {
    local name=""
    local description=""
    local model="haiku"
    local tools=""
    local token_budget="3000"
    local priority="medium"
    local activation=""
    local skill=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --name)
                name="$2"
                shift 2
                ;;
            --description)
                description="$2"
                shift 2
                ;;
            --model)
                model="$2"
                shift 2
                ;;
            --tools)
                tools="$2"
                shift 2
                ;;
            --token-budget)
                token_budget="$2"
                shift 2
                ;;
            --priority)
                priority="$2"
                shift 2
                ;;
            --activation)
                activation="$2"
                shift 2
                ;;
            --skill)
                skill="$2"
                shift 2
                ;;
            *)
                log_error "Unknown argument: $1"
                return 1
                ;;
        esac
    done

    # Validate required fields
    if [[ -z "$name" ]]; then
        log_error "Agent name is required (--name)"
        return 1
    fi

    if [[ -z "$description" ]]; then
        log_error "Agent description is required (--description)"
        return 1
    fi

    # Check if agent already exists
    local agent_file="$AGENTS_DIR/${name}.md"
    if [[ -f "$agent_file" ]]; then
        log_warn "Agent already exists: $name"
        echo "$agent_file"
        return 0
    fi

    # Ensure directories exist
    mkdir -p "$AGENTS_DIR"

    # Generate agent content
    local title=$(to_title_case "$name")
    local tools_list=""
    if [[ -n "$tools" ]]; then
        tools_list=$(echo "$tools" | tr ',' '\n' | sed 's/^/- /')
    fi

    cat > "$agent_file" << EOF
---
name: $name
description: $description
model: $model
token_budget: $token_budget
priority: $priority
status: active
created: $(timestamp)
---

# $title Agent

## Purpose

$description

## Configuration

| Property | Value |
|----------|-------|
| Model | $model |
| Token Budget | $token_budget |
| Priority | $priority |
| Status | Active |

## Activation

EOF

    if [[ -n "$activation" ]]; then
        echo "Triggers:" >> "$agent_file"
        echo "$activation" | tr ',' '\n' | sed 's/^/- /' >> "$agent_file"
    else
        echo "Manual invocation or orchestrator delegation." >> "$agent_file"
    fi

    cat >> "$agent_file" << EOF

## Tools

EOF

    if [[ -n "$tools_list" ]]; then
        echo "$tools_list" >> "$agent_file"
    else
        echo "- All available tools" >> "$agent_file"
    fi

    if [[ -n "$skill" ]]; then
        cat >> "$agent_file" << EOF

## Linked Skill

Implements the \`$skill\` skill protocol.
See: \`~/.claude/skills/$skill/SKILL.md\`
EOF
    fi

    cat >> "$agent_file" << EOF

## Protocol

1. Receive task from orchestrator or user
2. Load relevant context
3. Execute task within token budget
4. Return structured result
5. Log metrics

## Metrics

Track:
- Invocation count
- Average token usage
- Success rate
- Common trigger patterns
EOF

    log_success "Created agent: $name"

    # Register in registry
    register_agent "$name" "$description" "$model" "$token_budget" "$priority" "$skill"

    # Log to metrics
    log_agent_creation "$name"

    echo "$agent_file"
}

# Register agent in registry
register_agent() {
    local name="$1"
    local description="$2"
    local model="$3"
    local token_budget="$4"
    local priority="$5"
    local skill="${6:-}"

    # Initialize registry if needed
    if [[ ! -f "$AGENTS_REGISTRY" ]]; then
        echo '{"agents":{}}' > "$AGENTS_REGISTRY"
    fi

    # Add agent to registry
    local agent_entry=$(jq -nc \
        --arg name "$name" \
        --arg desc "$description" \
        --arg model "$model" \
        --arg budget "$token_budget" \
        --arg priority "$priority" \
        --arg skill "$skill" \
        --arg file "$AGENTS_DIR/${name}.md" \
        --arg created "$(timestamp)" \
        '{
            name: $name,
            description: $desc,
            model: $model,
            token_budget: ($budget | tonumber),
            priority: $priority,
            linked_skill: (if $skill == "" then null else $skill end),
            file_path: $file,
            status: "active",
            created_at: $created,
            invocations: 0
        }')

    local tmp_file=$(mktemp)
    jq --arg name "$name" --argjson agent "$agent_entry" \
        '.agents[$name] = $agent' "$AGENTS_REGISTRY" > "$tmp_file"
    mv "$tmp_file" "$AGENTS_REGISTRY"

    log_info "Registered agent in registry: $name"
}

# Log agent creation to metrics
log_agent_creation() {
    local name="$1"

    local metric=$(jq -nc \
        --arg timestamp "$(timestamp)" \
        --arg epoch "$(current_epoch)" \
        --arg agent "$name" \
        '{
            event: "agent_created",
            timestamp: $timestamp,
            epoch_ms: ($epoch | tonumber),
            agent_name: $agent,
            created_by: "create-agents.sh"
        }')

    echo "$metric" >> "$METRICS_FILE"
}

# ============================================================================
# AGENT MANAGEMENT
# ============================================================================

# List all agents
list_agents() {
    if [[ ! -d "$AGENTS_DIR" ]]; then
        log_warn "Agents directory not found"
        return 0
    fi

    fd -e md . "$AGENTS_DIR" -t f 2>/dev/null | \
        xargs -I{} basename {} .md
}

# Count agents
count_agents() {
    list_agents 2>/dev/null | wc -l | tr -d ' '
}

# Get agent info
get_agent_info() {
    local name="$1"

    if [[ ! -f "$AGENTS_REGISTRY" ]]; then
        return 1
    fi

    jq -r ".agents[\"$name\"] // empty" "$AGENTS_REGISTRY"
}

# Delete agent
delete_agent() {
    local name="$1"

    local agent_file="$AGENTS_DIR/${name}.md"

    if [[ -f "$agent_file" ]]; then
        rm "$agent_file"
        log_info "Deleted agent file: $agent_file"
    fi

    # Remove from registry
    if [[ -f "$AGENTS_REGISTRY" ]]; then
        local tmp_file=$(mktemp)
        jq --arg name "$name" 'del(.agents[$name])' "$AGENTS_REGISTRY" > "$tmp_file"
        mv "$tmp_file" "$AGENTS_REGISTRY"
        log_info "Removed from registry: $name"
    fi

    log_success "Deleted agent: $name"
}

# ============================================================================
# BATCH CREATION
# ============================================================================

# Create predefined agents
create_predefined_agents() {
    log_info "Creating predefined agents..."

    # Context Refresh Agent
    create_agent \
        --name "context-refresh-agent" \
        --description "Session start optimization using multi-source semantic understanding" \
        --model "haiku" \
        --token-budget "3000" \
        --priority "critical" \
        --activation "session_start,/refresh-context" \
        --skill "context-refresh"

    # Dependency Guardian Agent
    create_agent \
        --name "dependency-guardian-agent" \
        --description "Real-time monitoring to block node_modules and build folder reads" \
        --model "haiku" \
        --token-budget "100" \
        --priority "critical" \
        --activation "file_read,Read_tool" \
        --skill "code-agentic"

    # File Read Optimizer Agent
    create_agent \
        --name "file-read-optimizer-agent" \
        --description "Session-level cache to prevent redundant file reads" \
        --model "haiku" \
        --token-budget "200" \
        --priority "critical" \
        --activation "Read_tool"

    # PR Workflow Agent
    create_agent \
        --name "pr-workflow-agent" \
        --description "Complete PR automation from branch creation to submission" \
        --model "sonnet" \
        --token-budget "2000" \
        --priority "high" \
        --activation "create_pr,pull_request,/create-pr" \
        --skill "pr-automation"

    # History Mining Agent
    create_agent \
        --name "history-mining-agent" \
        --description "Search past conversations to prevent duplicate problem-solving" \
        --model "haiku" \
        --token-budget "800" \
        --priority "high" \
        --activation "search_history,remind,/remind-yourself" \
        --skill "chat-history-search"

    # Efficiency Auditor Agent
    create_agent \
        --name "efficiency-auditor-agent" \
        --description "Real-time workflow analysis with violation scoring" \
        --model "haiku" \
        --token-budget "600" \
        --priority "medium" \
        --activation "/audit-efficiency,workflow_complete" \
        --skill "self-improvement-engine"

    # YAGNI Enforcer Agent
    create_agent \
        --name "yagni-enforcer-agent" \
        --description "Prevents over-engineering by challenging speculative features" \
        --model "haiku" \
        --token-budget "400" \
        --priority "medium" \
        --activation "planning_phase,architecture_discussion" \
        --skill "yagni-principle"

    # Direct Implementation Agent
    create_agent \
        --name "direct-implementation-agent" \
        --description "Eliminates intermediate temp scripts by choosing most direct path" \
        --model "sonnet" \
        --token-budget "1000" \
        --priority "medium" \
        --activation "multi_step_workflow,temp_script_detected"

    # Markdown Expert Agent
    create_agent \
        --name "markdown-expert-agent" \
        --description "Auto-fix markdown linting violations" \
        --model "haiku" \
        --token-budget "600" \
        --priority "low" \
        --activation "md_file_edit,/markdown-lint" \
        --skill "markdown-expert"

    log_success "Created $(count_agents) predefined agents"
}

# ============================================================================
# DIAGNOSTICS
# ============================================================================

diagnose_agent() {
    local name="$1"

    echo "=== Agent Diagnosis: $name ==="
    echo ""

    local agent_file="$AGENTS_DIR/${name}.md"

    if [[ ! -f "$agent_file" ]]; then
        echo "Status: NOT FOUND"
        echo "Expected path: $agent_file"
        return 1
    fi

    echo "File: $agent_file"
    echo "Size: $(wc -c < "$agent_file" | tr -d ' ') bytes"
    echo ""

    echo "Registry entry:"
    get_agent_info "$name" | jq '.' 2>/dev/null || echo "(not in registry)"
    echo ""

    echo "Frontmatter:"
    awk '/^---$/{if(p)exit;p=1;next}p' "$agent_file"
    echo ""

    echo "=== End Diagnosis ==="
}

diagnose_all_agents() {
    echo "=== Agents Summary ==="
    echo ""
    echo "Agents directory: $AGENTS_DIR"
    echo "Registry file: $AGENTS_REGISTRY"
    echo ""
    echo "Total agents: $(count_agents)"
    echo ""

    if [[ -f "$AGENTS_REGISTRY" ]]; then
        echo "Registered agents:"
        jq -r '.agents | to_entries[] | "  \(.key): \(.value.priority) priority, \(.value.model) model"' "$AGENTS_REGISTRY"
    fi

    echo ""
    echo "=== End Summary ==="
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    local command="${1:-help}"
    shift || true

    case "$command" in
        create)
            create_agent "$@"
            ;;
        create-predefined)
            create_predefined_agents
            ;;
        list)
            list_agents
            ;;
        count)
            count_agents
            ;;
        info)
            get_agent_info "${1:-}"
            ;;
        delete)
            delete_agent "${1:-}"
            ;;
        diagnose)
            if [[ -n "${1:-}" ]]; then
                diagnose_agent "$1"
            else
                diagnose_all_agents
            fi
            ;;
        help|--help|-h)
            cat << 'EOF'
Agent Creator - Generate and manage Claude Code agents

USAGE:
    ./create-agents.sh <command> [options]

COMMANDS:
    create              Create new agent
        --name          Agent name (required)
        --description   Agent description (required)
        --model         Model to use (haiku/sonnet, default: haiku)
        --tools         Comma-separated tools
        --token-budget  Token budget (default: 3000)
        --priority      Priority (critical/high/medium/low)
        --activation    Comma-separated activation triggers
        --skill         Linked skill name

    create-predefined   Create all 9 predefined agents
    list                List all agents
    count               Count agents
    info <name>         Get agent info
    delete <name>       Delete agent
    diagnose [name]     Diagnose agent(s)
    help                Show this help

EXAMPLES:
    ./create-agents.sh create \
        --name my-agent \
        --description "My custom agent" \
        --model haiku \
        --token-budget 2000

    ./create-agents.sh create-predefined
    ./create-agents.sh list
    ./create-agents.sh diagnose context-refresh-agent

EOF
            ;;
        *)
            log_error "Unknown command: $command"
            echo "Run '$0 help' for usage"
            return 1
            ;;
    esac
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
