#!/usr/bin/env bash
#
# Agent Matcher Library (Bash 3.x Compatible)
# Pattern-based matching of user input/tool calls to agents, skills, and commands
#
# PURPOSE:
#   Intelligent orchestration layer that:
#   1. Matches input patterns to appropriate agents
#   2. Suggests (not auto-invokes) agents based on context
#   3. Maps patterns to slash commands for easy invocation
#   4. Detects workflow phases for skill loading
#
# USAGE:
#   source ~/.claude/lib/agent-matcher.sh
#
#   # Match pattern to agent
#   match_to_agent "have we done this before"  # Returns: history-mining:/remind-yourself:desc
#
#   # Get suggestion tag
#   get_agent_suggestion "create a PR"  # Outputs: [AGENT-AVAILABLE: pr-workflow] Use /create-pr
#
# VERSION: 1.1.0
# DATE: 2025-12-02
#

set -euo pipefail

[[ -z "${AGENT_MATCHER_LOADED:-}" ]] && readonly AGENT_MATCHER_LOADED=1 || return 0

[[ -z "${CLAUDE_DIR:-}" ]] && CLAUDE_DIR="$HOME/.claude"

if [[ -f "$CLAUDE_DIR/lib/embeddings.sh" ]]; then
    source "$CLAUDE_DIR/lib/embeddings.sh" 2>/dev/null || true
fi

[[ -z "${SEMANTIC_ENABLED:-}" ]] && SEMANTIC_ENABLED=true
[[ -z "${SEMANTIC_THRESHOLD:-}" ]] && SEMANTIC_THRESHOLD=0.75

_match_log() {
    local level="$1"
    shift
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) [AGENT-MATCHER][$level] $*" >> "$CLAUDE_DIR/.hooks.log"
}

match_to_agent() {
    local input="$1"
    local input_lower
    input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')

    # History mining patterns
    if echo "$input_lower" | rg -qi "have we.*before|search.*history|past.*solution|previous.*session|remind.*yourself" 2>/dev/null; then
        echo "history-mining:/remind-yourself:Search past sessions"
        return 0
    fi

    # PR workflow patterns
    if echo "$input_lower" | rg -qi "create.*pr|open.*pull.*request|ready.*commit|push.*changes" 2>/dev/null; then
        echo "pr-workflow:/create-pr:Automate PR creation"
        return 0
    fi

    # YAGNI patterns
    if echo "$input_lower" | rg -qi "make.*flexible|future.*proof|just.*in.*case|might.*need|could.*use.*later" 2>/dev/null; then
        echo "yagni-enforcer:SUGGEST:Challenge over-engineering"
        return 0
    fi

    # Direct implementation patterns
    if echo "$input_lower" | rg -qi "temp.*script|temporary.*file|one.*off.*script|extract.*to.*script" 2>/dev/null; then
        echo "direct-implementation:WARN:Avoid temp scripts, use direct path"
        return 0
    fi

    # Efficiency audit patterns
    if echo "$input_lower" | rg -qi "audit.*efficiency|check.*tokens|efficiency.*score|wasted.*tokens" 2>/dev/null; then
        echo "efficiency-auditor:/audit-efficiency:Run efficiency audit"
        return 0
    fi

    # Auth debugging patterns
    if echo "$input_lower" | rg -qi "oauth.*error|AADSTS|cognito.*error|callback.*failed" 2>/dev/null; then
        echo "auth-debugging:SUGGEST:Debug OAuth flow"
        return 0
    fi

    # Markdown patterns
    if echo "$input_lower" | rg -qi "markdown.*lint|md.*error|documentation.*format" 2>/dev/null; then
        echo "markdown-expert:/markdown-lint:Fix markdown issues"
        return 0
    fi

    # Context refresh patterns
    if echo "$input_lower" | rg -qi "refresh.*context|understand.*repo|session.*start" 2>/dev/null; then
        echo "context-refresh:/refresh-context:Rebuild mental model"
        return 0
    fi

    # Session state patterns
    if echo "$input_lower" | rg -qi "save.*state|preserve.*progress|before.*compact" 2>/dev/null; then
        echo "session-state:/save-session-state:Checkpoint progress"
        return 0
    fi

    # Branch cleanup patterns
    if echo "$input_lower" | rg -qi "clean.*branch|prune.*branch" 2>/dev/null; then
        echo "branch-cleanup:/prune-branches:Clean merged branches"
        return 0
    fi

    # E2E test patterns
    if echo "$input_lower" | rg -qi "e2e.*test|playwright.*setup" 2>/dev/null; then
        echo "e2e-test:/generate-e2e-tests:Setup E2E testing"
        return 0
    fi

    # API reverse engineering patterns
    if echo "$input_lower" | rg -qi "reverse.*engineer.*api|api.*from.*browser" 2>/dev/null; then
        echo "api-reverse:/reverse-engineer-api:Reverse engineer API"
        return 0
    fi

    if [[ "$SEMANTIC_ENABLED" == "true" ]] && command -v python3 &>/dev/null; then
        local semantic_result
        semantic_result=$(semantic_match_to_agent "$input" 2>/dev/null) || true
        if [[ -n "$semantic_result" ]]; then
            _match_log "INFO" "Semantic fallback matched: $semantic_result"
            echo "$semantic_result"
            return 0
        fi
    fi

    return 1
}

semantic_match_to_agent() {
    local input="$1"

    if ! command -v python3 &>/dev/null; then
        return 1
    fi

    if [[ ! -f "$CLAUDE_DIR/lib/embeddings.py" ]]; then
        return 1
    fi

    local result
    result=$(python3 "$CLAUDE_DIR/lib/embeddings.py" classify "$input" 2>/dev/null) || return 1

    local agent_name
    agent_name=$(echo "$result" | jq -r '.suggested_agent.name // empty')

    local agent_similarity
    agent_similarity=$(echo "$result" | jq -r '.suggested_agent.similarity // 0')

    if [[ -z "$agent_name" ]]; then
        return 1
    fi

    if (( $(echo "$agent_similarity < $SEMANTIC_THRESHOLD" | bc -l) )); then
        return 1
    fi

    local command_name
    command_name=$(echo "$result" | jq -r '.suggested_command.name // empty')

    local description=""
    case "$agent_name" in
        context-refresh) description="Rebuild mental model" ;;
        history-mining) description="Search past sessions" ;;
        pr-workflow) description="Automate PR workflow" ;;
        efficiency-auditor) description="Run efficiency audit" ;;
        auth-debugging) description="Debug OAuth flow" ;;
        yagni-enforcer) description="Challenge over-engineering" ;;
        direct-implementation) description="Use direct implementation" ;;
        markdown-expert) description="Fix markdown issues" ;;
        dependency-guardian) description="Block dependency reads" ;;
        file-read-optimizer) description="Optimise file reads" ;;
        bash-lint) description="Lint bash scripts" ;;
        *) description="Semantic match ($agent_similarity)" ;;
    esac

    if [[ -n "$command_name" ]]; then
        echo "$agent_name:/$command_name:$description"
    else
        echo "$agent_name:SUGGEST:$description"
    fi
}

get_agent_suggestion() {
    local input="$1"
    local match

    match=$(match_to_agent "$input") || return 0

    local agent="${match%%:*}"
    local rest="${match#*:}"
    local action="${rest%%:*}"
    local description="${rest#*:}"

    case "$action" in
        SUGGEST)
            echo "[AGENT-SUGGEST: $agent] $description"
            ;;
        WARN)
            echo "[AGENT-WARN: $agent] $description"
            ;;
        /*)
            echo "[AGENT-AVAILABLE: $agent] Use $action - $description"
            ;;
    esac

    _match_log "INFO" "Matched '$input' to $agent ($action)"

    # Record match for threshold learning feedback
    if command -v record_match_for_feedback &>/dev/null; then
        record_match_for_feedback "concept_agent" "$input" "$agent" "0.5" 2>/dev/null || true
    fi
}

detect_workflow_end() {
    local cmd="$1"

    if [[ "$cmd" == *"git push"* ]]; then
        echo "[WORKFLOW-END: PR/push detected] Consider /audit-efficiency before session end"
        _match_log "INFO" "Workflow end detected: git push"
        return 0
    fi

    if [[ "$cmd" == *"gh pr create"* ]]; then
        echo "[WORKFLOW-END: PR created] Consider /audit-efficiency before session end"
        _match_log "INFO" "Workflow end detected: gh pr create"
        return 0
    fi

    if [[ "$cmd" == *"git commit"* ]]; then
        echo "[WORKFLOW-END: Commit made] Consider /audit-efficiency before session end"
        _match_log "INFO" "Workflow end detected: git commit"
        return 0
    fi

    return 1
}

get_phase_skills() {
    local phase="$1"

    case "$phase" in
        START) echo "context-refresh,session-state-persistence" ;;
        PLANNING) echo "yagni-principle,dry-kiss-principles,solid-principles" ;;
        IMPLEMENTATION) echo "code-agentic,programming-principles,direct-implementation" ;;
        TESTING) echo "e2e-test-generation" ;;
        PR) echo "pr-automation,gitops,branch-cleanup" ;;
        END) echo "recursive-learning,session-state-persistence,efficiency-auditor" ;;
        *) echo "" ;;
    esac
}

get_phase_agents() {
    local phase="$1"

    case "$phase" in
        START) echo "context-refresh" ;;
        PLANNING) echo "yagni-enforcer" ;;
        IMPLEMENTATION) echo "direct-implementation,file-read-optimizer" ;;
        PR) echo "pr-workflow" ;;
        END) echo "efficiency-auditor" ;;
        *) echo "" ;;
    esac
}

detect_phase_from_context() {
    local context="$1"
    local context_lower
    context_lower=$(echo "$context" | tr '[:upper:]' '[:lower:]')

    if echo "$context_lower" | rg -qi "plan|design|architect|approach"; then
        echo "PLANNING"
    elif echo "$context_lower" | rg -qi "implement|code|build|create|add"; then
        echo "IMPLEMENTATION"
    elif echo "$context_lower" | rg -qi "test|verify|check|validate"; then
        echo "TESTING"
    elif echo "$context_lower" | rg -qi "pr|pull request|merge|push"; then
        echo "PR"
    elif echo "$context_lower" | rg -qi "done|complete|finish|end"; then
        echo "END"
    else
        echo "IMPLEMENTATION"
    fi
}

get_top_agents() {
    cat << 'EOF'
CRITICAL (Auto via hooks):
  - dependency-guardian: Blocks node_modules reads (FREE)
  - file-read-optimizer: Tracks duplicate reads (FREE)
  - bash-linter: Validates bash scripts (FREE)

ON-DEMAND (via commands):
  - /refresh-context: Build mental model (3k tokens)
  - /remind-yourself: Search history (2k tokens)
  - /create-pr: Automate PR workflow (2k tokens)
  - /audit-efficiency: Score efficiency (3k tokens)
  - /save-session-state: Checkpoint progress (500 tokens)
EOF
}

get_efficiency_rules_summary() {
    cat << 'EOF'
EFFICIENCY RULES (from @rules/efficiency-rules.md):
1. File Read Optimization: Read once, cache mentally
2. Plan Evaluation Gate: 99.9999999% confidence before execution
3. Implementation Directness: No temp scripts, choose direct path
4. Concise Communication: No preambles/postambles
5. YAGNI: Build only what's requested NOW
6. Markdown Linting: MD040/022/031/032/012/013
EOF
}

export -f match_to_agent
export -f semantic_match_to_agent
export -f get_agent_suggestion
export -f detect_workflow_end
export -f get_phase_skills
export -f get_phase_agents
export -f detect_phase_from_context
export -f get_top_agents
export -f get_efficiency_rules_summary
