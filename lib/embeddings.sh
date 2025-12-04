#!/usr/bin/env bash
#
# Semantic RL++ Embedding Engine - Bash Interface
# Wrapper for Python embedding engine with CLI integration
#
# USAGE:
#   source ~/.claude/lib/embeddings.sh
#
#   # Generate embedding (returns dimensions)
#   embed_text "hello world"
#
#   # Search similar
#   search_similar "authentication error" --type solution --limit 5
#
#   # Calculate novelty
#   calculate_novelty "new concept text"
#
#   # Queue for batch processing
#   queue_embedding "text" --type prompt --priority high
#
#   # Process queue
#   process_embedding_queue --priority high
#
# VERSION: 1.0.0
# DATE: 2025-12-02
#

set -euo pipefail

[[ -z "${EMBEDDINGS_LOADED:-}" ]] && readonly EMBEDDINGS_LOADED=1 || return 0

[[ -z "${CLAUDE_DIR:-}" ]] && CLAUDE_DIR="$HOME/.claude"
[[ -z "${EMBEDDINGS_PY:-}" ]] && EMBEDDINGS_PY="$CLAUDE_DIR/lib/embeddings.py"
[[ -z "${EMBEDDINGS_DB:-}" ]] && EMBEDDINGS_DB="$CLAUDE_DIR/embeddings.db"

_embeddings_log() {
    local level="$1"
    shift
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) [EMBEDDINGS][$level] $*" >> "$CLAUDE_DIR/.hooks.log"
}

embeddings_check_deps() {
    if ! command -v python3 &>/dev/null; then
        _embeddings_log "ERROR" "python3 not found"
        return 1
    fi

    if ! python3 -c "import apsw, sqlite_vec, sqlite_lembed" 2>/dev/null; then
        _embeddings_log "ERROR" "Required Python packages not installed"
        echo "ERROR: Missing Python packages. Run: pip3 install apsw sqlite-vec sqlite-lembed" >&2
        return 1
    fi

    if [[ ! -f "$EMBEDDINGS_PY" ]]; then
        _embeddings_log "ERROR" "embeddings.py not found at $EMBEDDINGS_PY"
        return 1
    fi

    return 0
}

embeddings_init() {
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" init
    _embeddings_log "INFO" "Database initialised"
}

embed_text() {
    local text="$1"
    shift
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" embed "$text" "$@"
}

embed_and_store() {
    local text="$1"
    local type="${2:-prompt}"
    local project="${3:-$(pwd)}"
    local session="${4:-}"

    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" embed "$text" --type "$type" --project "$project" ${session:+--session "$session"} --store
}

search_similar() {
    local text="$1"
    shift
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" search "$text" "$@"
}

search_cross_project() {
    local text="$1"
    local current_project="${2:-$(pwd)}"
    local limit="${3:-5}"

    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" search "$text" --exclude-project "$current_project" --limit "$limit"
}

calculate_novelty() {
    local text="$1"
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" novelty "$text"
}

get_novelty_score() {
    local text="$1"
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" novelty "$text" | jq -r '.novelty_score'
}

get_priority() {
    local text="$1"
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" novelty "$text" | jq -r '.priority'
}

queue_embedding() {
    local text="$1"
    shift
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" queue "$text" "$@"
}

process_embedding_queue() {
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" process "$@"
}

process_high_priority() {
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" process --priority high
}

get_embedding_stats() {
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" stats
}

prune_embeddings() {
    local days="${1:-30}"
    local min_success="${2:-0.3}"
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" prune --days "$days" --min-success "$min_success"
}

should_embed_now() {
    local text="$1"
    local novelty_score

    embeddings_check_deps || return 1
    novelty_score=$(get_novelty_score "$text")

    if (( $(echo "$novelty_score > 0.5" | bc -l) )); then
        return 0
    else
        return 1
    fi
}

smart_embed() {
    local text="$1"
    local type="${2:-prompt}"
    local project="${3:-$(pwd)}"

    embeddings_check_deps || return 1

    local novelty_result
    novelty_result=$(calculate_novelty "$text")

    local novelty_score
    novelty_score=$(echo "$novelty_result" | jq -r '.novelty_score')

    local priority
    priority=$(echo "$novelty_result" | jq -r '.priority')

    _embeddings_log "INFO" "smart_embed: novelty=$novelty_score priority=$priority"

    if [[ "$priority" == "high" ]]; then
        embed_and_store "$text" "$type" "$project"
        echo '{"action": "embedded_now", "priority": "high", "novelty": '"$novelty_score"'}'
    else
        queue_embedding "$text" --type "$type" --priority "$priority" --project "$project"
        echo '{"action": "queued", "priority": "'"$priority"'", "novelty": '"$novelty_score"'}'
    fi
}

detect_checkpoint() {
    local text="$1"
    local threshold="${2:-0.7}"
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" checkpoint "$text" --threshold "$threshold"
}

is_checkpoint_triggered() {
    local text="$1"
    embeddings_check_deps || return 1
    local result
    result=$(python3 "$EMBEDDINGS_PY" checkpoint "$text" 2>/dev/null)
    local triggered
    triggered=$(echo "$result" | jq -r '.triggered')
    [[ "$triggered" == "true" ]]
}

get_checkpoint_type() {
    local text="$1"
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" checkpoint "$text" | jq -r '.checkpoint.name // empty'
}

classify_text() {
    local text="$1"
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" classify "$text"
}

classify_intent() {
    local text="$1"
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" intent "$text"
}

classify_feedback() {
    local text="$1"
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" feedback "$text"
}

match_agent() {
    local text="$1"
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" match "$text" --type agent
}

match_skill() {
    local text="$1"
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" match "$text" --type skill
}

match_command() {
    local text="$1"
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" match "$text" --type command
}

get_suggested_agent() {
    local text="$1"
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" classify "$text" | jq -r '.suggested_agent.name // empty'
}

get_suggested_command() {
    local text="$1"
    embeddings_check_deps || return 1
    python3 "$EMBEDDINGS_PY" classify "$text" | jq -r '.suggested_command.name // empty'
}

smart_process() {
    local text="$1"
    local type="${2:-prompt}"
    local project="${3:-$(pwd)}"

    embeddings_check_deps || return 1

    local classification
    classification=$(classify_text "$text")

    local should_process
    should_process=$(echo "$classification" | jq -r '.should_process_queue')

    local priority
    priority=$(echo "$classification" | jq -r '.priority')

    local checkpoint_name
    checkpoint_name=$(echo "$classification" | jq -r '.checkpoint.name // empty')

    if [[ "$should_process" == "true" ]]; then
        _embeddings_log "INFO" "Checkpoint triggered: $checkpoint_name - processing queue"
        process_embedding_queue --priority high 2>/dev/null
        process_embedding_queue --priority medium 2>/dev/null
    fi

    if [[ "$priority" == "high" ]]; then
        embed_and_store "$text" "$type" "$project"
        echo '{"action": "embedded_now", "checkpoint": "'"$checkpoint_name"'", "priority": "high"}'
    else
        queue_embedding "$text" --type "$type" --priority "$priority" --project "$project"
        echo '{"action": "queued", "checkpoint": "'"$checkpoint_name"'", "priority": "'"$priority"'"}'
    fi
}

export -f embeddings_check_deps
export -f embeddings_init
export -f embed_text
export -f embed_and_store
export -f search_similar
export -f search_cross_project
export -f calculate_novelty
export -f get_novelty_score
export -f get_priority
export -f queue_embedding
export -f process_embedding_queue
export -f process_high_priority
export -f get_embedding_stats
export -f prune_embeddings
export -f should_embed_now
export -f smart_embed
export -f detect_checkpoint
export -f is_checkpoint_triggered
export -f get_checkpoint_type
export -f classify_text
export -f classify_intent
export -f classify_feedback
export -f match_agent
export -f match_skill
export -f match_command
export -f get_suggested_agent
export -f get_suggested_command
export -f smart_process
