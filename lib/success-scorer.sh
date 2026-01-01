#!/usr/bin/env bash
#
# Success Scorer Library (Bash 3.x Compatible)
# Feedback classification and success score propagation for Semantic RL++
#
# PURPOSE:
#   1. Classify user feedback (positive/negative/retry/etc.)
#   2. Propagate success scores to recent embeddings
#   3. Track cross-project learning via hit counting
#
# USAGE:
#   source ~/.claude/lib/success-scorer.sh
#
#   # Score a user response
#   score_feedback "thanks, that worked perfectly"  # Returns: positive:0.95
#
#   # Propagate score to recent embeddings
#   propagate_success "positive" 0.95
#
#   # Record cross-project hit
#   record_cross_project_hit "/path/to/source/project"
#
# VERSION: 1.0.0
# DATE: 2025-12-02
#

set -euo pipefail

[[ -z "${SUCCESS_SCORER_LOADED:-}" ]] && readonly SUCCESS_SCORER_LOADED=1 || return 0

[[ -z "${CLAUDE_DIR:-}" ]] && CLAUDE_DIR="$HOME/.claude"

if [[ -f "$CLAUDE_DIR/lib/embeddings.sh" ]]; then
    source "$CLAUDE_DIR/lib/embeddings.sh" 2>/dev/null || true
fi

[[ -z "${FEEDBACK_LOOKBACK:-}" ]] && FEEDBACK_LOOKBACK=5
[[ -z "${SCORE_DECAY:-}" ]] && SCORE_DECAY=0.8
[[ -z "${MIN_SCORE_THRESHOLD:-}" ]] && MIN_SCORE_THRESHOLD=0.1

_scorer_log() {
    local level="$1"
    shift
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) [SUCCESS-SCORER][$level] $*" >> "$CLAUDE_DIR/.hooks.log"
}

score_feedback() {
    local text="$1"

    if ! command -v python3 &>/dev/null; then
        _scorer_log "ERROR" "python3 not found"
        return 1
    fi

    if [[ ! -f "$CLAUDE_DIR/lib/embeddings.py" ]]; then
        _scorer_log "ERROR" "embeddings.py not found"
        return 1
    fi

    local result
    result=$(python3 "$CLAUDE_DIR/lib/embeddings.py" feedback "$text" 2>/dev/null) || {
        _scorer_log "ERROR" "Failed to classify feedback"
        return 1
    }

    local feedback_type
    feedback_type=$(echo "$result" | jq -r '.feedback_type // "unknown"')

    local similarity
    similarity=$(echo "$result" | jq -r '.similarity // 0')

    echo "$feedback_type:$similarity"
    _scorer_log "INFO" "Classified feedback: $feedback_type (similarity: $similarity)"
}

get_score_delta() {
    local feedback_type="$1"
    local similarity="$2"

    local base_delta
    case "$feedback_type" in
        positive)
            base_delta="0.2"
            ;;
        negative)
            base_delta="-0.3"
            ;;
        retry)
            base_delta="-0.15"
            ;;
        partial)
            base_delta="0.05"
            ;;
        proceed)
            base_delta="0.1"
            ;;
        clarification)
            base_delta="0.0"
            ;;
        *)
            base_delta="0.0"
            ;;
    esac

    local weighted_delta
    weighted_delta=$(echo "$base_delta * $similarity" | bc -l 2>/dev/null) || weighted_delta="$base_delta"

    printf "%.4f" "$weighted_delta"
}

propagate_success() {
    local feedback_type="$1"
    local similarity="$2"
    local project="${3:-$(pwd)}"
    local lookback="${4:-$FEEDBACK_LOOKBACK}"

    if ! command -v python3 &>/dev/null; then
        _scorer_log "ERROR" "python3 not found"
        return 1
    fi

    local delta
    delta=$(get_score_delta "$feedback_type" "$similarity")

    if (( $(echo "$delta == 0" | bc -l) )); then
        _scorer_log "INFO" "No score change for feedback type: $feedback_type"
        return 0
    fi

    _scorer_log "INFO" "Propagating score delta: $delta to last $lookback embeddings"

    python3 -c "
import sys
sys.path.insert(0, '$CLAUDE_DIR/lib')
from embeddings import EmbeddingEngine

engine = EmbeddingEngine()
delta = float('$delta')
lookback = int('$lookback')
decay = float('$SCORE_DECAY')
project = '$project'

conn = engine.conn
cursor = conn.cursor()

cursor.execute('''
    SELECT id, success_score, project_path
    FROM embeddings
    WHERE project_path = ?
    ORDER BY created_at DESC
    LIMIT ?
''', (project, lookback))

results = cursor.fetchall()

for i, (emb_id, current_score, proj_path) in enumerate(results):
    decayed_delta = delta * (decay ** i)
    new_score = max(0.0, min(1.0, current_score + decayed_delta))

    if abs(new_score - current_score) > 0.001:
        cursor.execute('''
            UPDATE embeddings
            SET success_score = ?, updated_at = datetime('now')
            WHERE id = ?
        ''', (new_score, emb_id))

conn.commit()
engine.close()
print(f'Updated {len(results)} embeddings with delta {delta} (decay: {decay})')
" 2>/dev/null || {
        _scorer_log "ERROR" "Failed to propagate success scores"
        return 1
    }

    _scorer_log "INFO" "Successfully propagated scores"
}

record_cross_project_hit() {
    local source_project="$1"
    local current_project="${2:-$(pwd)}"
    local embedding_id="${3:-}"

    if [[ "$source_project" == "$current_project" ]]; then
        return 0
    fi

    _scorer_log "INFO" "Recording cross-project hit: $source_project -> $current_project"

    python3 -c "
import sys
sys.path.insert(0, '$CLAUDE_DIR/lib')
from embeddings import EmbeddingEngine

engine = EmbeddingEngine()
source = '$source_project'
current = '$current_project'
emb_id = '$embedding_id' or None

conn = engine.conn
cursor = conn.cursor()

if emb_id:
    cursor.execute('''
        UPDATE embeddings
        SET cross_project_hits = cross_project_hits + 1,
            success_score = min(1.0, success_score + 0.05),
            updated_at = datetime('now')
        WHERE id = ?
    ''', (emb_id,))
    print(f'Incremented cross-project hits for embedding {emb_id}')
else:
    cursor.execute('''
        UPDATE embeddings
        SET cross_project_hits = cross_project_hits + 1,
            success_score = min(1.0, success_score + 0.02),
            updated_at = datetime('now')
        WHERE project_path = ?
        AND cross_project_hits > 0
        ORDER BY success_score DESC
        LIMIT 3
    ''', (source,))
    print(f'Incremented cross-project hits for top 3 embeddings from {source}')

conn.commit()
engine.close()
" 2>/dev/null || {
        _scorer_log "ERROR" "Failed to record cross-project hit"
        return 1
    }
}

process_user_message() {
    local message="$1"
    local project="${2:-$(pwd)}"

    local feedback_result
    feedback_result=$(score_feedback "$message") || return 1

    local feedback_type="${feedback_result%%:*}"
    local similarity="${feedback_result#*:}"

    case "$feedback_type" in
        positive|negative|retry|partial)
            propagate_success "$feedback_type" "$similarity" "$project"
            ;;
        proceed|clarification)
            _scorer_log "INFO" "Neutral feedback: $feedback_type - no score propagation"
            ;;
        *)
            _scorer_log "DEBUG" "Unknown feedback type: $feedback_type"
            ;;
    esac

    echo "$feedback_type"
}

get_top_solutions() {
    local limit="${1:-10}"
    local min_score="${2:-0.7}"

    python3 -c "
import sys
import json
sys.path.insert(0, '$CLAUDE_DIR/lib')
from embeddings import EmbeddingEngine

engine = EmbeddingEngine()
cursor = engine.conn.cursor()

cursor.execute('''
    SELECT text, embed_type, success_score, cross_project_hits, project_path
    FROM embeddings
    WHERE success_score >= ?
    AND embed_type IN ('solution', 'response')
    ORDER BY success_score DESC, cross_project_hits DESC
    LIMIT ?
''', (float('$min_score'), int('$limit')))

results = []
for row in cursor.fetchall():
    results.append({
        'text': row[0][:200],
        'type': row[1],
        'score': row[2],
        'cross_hits': row[3],
        'project': row[4]
    })

engine.close()
print(json.dumps(results, indent=2))
" 2>/dev/null
}

get_cross_project_insights() {
    local current_project="${1:-$(pwd)}"
    local limit="${2:-5}"

    python3 -c "
import sys
import json
sys.path.insert(0, '$CLAUDE_DIR/lib')
from embeddings import EmbeddingEngine

engine = EmbeddingEngine()
cursor = engine.conn.cursor()

cursor.execute('''
    SELECT text, embed_type, success_score, cross_project_hits, project_path
    FROM embeddings
    WHERE project_path != ?
    AND cross_project_hits > 0
    ORDER BY cross_project_hits DESC, success_score DESC
    LIMIT ?
''', ('$current_project', int('$limit')))

results = []
for row in cursor.fetchall():
    results.append({
        'text': row[0][:200],
        'type': row[1],
        'score': row[2],
        'cross_hits': row[3],
        'source_project': row[4]
    })

engine.close()
print(json.dumps(results, indent=2))
" 2>/dev/null
}

decay_old_scores() {
    local days="${1:-30}"
    local decay_factor="${2:-0.9}"

    _scorer_log "INFO" "Decaying scores for embeddings older than $days days"

    python3 -c "
import sys
sys.path.insert(0, '$CLAUDE_DIR/lib')
from embeddings import EmbeddingEngine

engine = EmbeddingEngine()
cursor = engine.conn.cursor()

cursor.execute('''
    UPDATE embeddings
    SET success_score = success_score * ?
    WHERE created_at < datetime('now', '-' || ? || ' days')
    AND success_score > 0.1
''', (float('$decay_factor'), int('$days')))

affected = cursor.rowcount
engine.conn.commit()
engine.close()
print(f'Decayed {affected} old embeddings by factor {float(\"$decay_factor\")}')
" 2>/dev/null || {
        _scorer_log "ERROR" "Failed to decay old scores"
        return 1
    }
}

get_scoring_stats() {
    python3 -c "
import sys
import json
sys.path.insert(0, '$CLAUDE_DIR/lib')
from embeddings import EmbeddingEngine

engine = EmbeddingEngine()
cursor = engine.conn.cursor()

stats = {}

cursor.execute('SELECT COUNT(*) FROM embeddings WHERE success_score > 0.7')
stats['high_success'] = cursor.fetchone()[0]

cursor.execute('SELECT COUNT(*) FROM embeddings WHERE success_score < 0.3')
stats['low_success'] = cursor.fetchone()[0]

cursor.execute('SELECT COUNT(*) FROM embeddings WHERE cross_project_hits > 0')
stats['cross_project'] = cursor.fetchone()[0]

cursor.execute('SELECT SUM(cross_project_hits) FROM embeddings')
stats['total_cross_hits'] = cursor.fetchone()[0] or 0

cursor.execute('SELECT AVG(success_score) FROM embeddings')
stats['avg_score'] = round(cursor.fetchone()[0] or 0.5, 3)

cursor.execute('''
    SELECT project_path, AVG(success_score) as avg_score, COUNT(*) as count
    FROM embeddings
    GROUP BY project_path
    ORDER BY avg_score DESC
    LIMIT 5
''')
stats['top_projects'] = [{'project': r[0], 'avg_score': round(r[1], 3), 'count': r[2]} for r in cursor.fetchall()]

engine.close()
print(json.dumps(stats, indent=2))
" 2>/dev/null
}

record_match_for_feedback() {
    local concept_type="$1"
    local prompt="$2"
    local matched_concept="${3:-}"
    local similarity="${4:-0}"

    python3 -c "
import sys
sys.path.insert(0, '$CLAUDE_DIR/lib')
from threshold_manager import ThresholdManager

manager = ThresholdManager()
match_id = manager.record_match('$concept_type', '''$prompt''', '$matched_concept' or None, float('$similarity'))
manager.close()
print(match_id)
" 2>/dev/null || echo "0"
}

record_threshold_feedback() {
    local feedback="$1"
    local concept_type="${2:-}"

    if [[ -z "$feedback" ]]; then
        return 1
    fi

    _scorer_log "INFO" "Recording threshold feedback: $feedback for $concept_type"

    python3 -c "
import sys
import json
sys.path.insert(0, '$CLAUDE_DIR/lib')
from threshold_manager import ThresholdManager

manager = ThresholdManager()
result = manager.record_feedback('$feedback', concept_type='$concept_type' or None)
manager.close()

if result:
    print(json.dumps(result))
" 2>/dev/null || {
        _scorer_log "ERROR" "Failed to record threshold feedback"
        return 1
    }
}

calibrate_thresholds() {
    _scorer_log "INFO" "Running threshold calibration"

    python3 -c "
import sys
import json
sys.path.insert(0, '$CLAUDE_DIR/lib')
from threshold_manager import ThresholdManager

manager = ThresholdManager()
results = manager.calibrate_all()
manager.close()

for r in results:
    print(f'[CALIBRATED] {r[\"concept_type\"]}: {r[\"old_threshold\"]:.3f} -> {r[\"new_threshold\"]:.3f} ({r[\"reason\"]})')

if not results:
    print('No calibrations needed')
" 2>/dev/null || {
        _scorer_log "ERROR" "Threshold calibration failed"
        return 1
    }
}

get_threshold_stats() {
    python3 -c "
import sys
import json
sys.path.insert(0, '$CLAUDE_DIR/lib')
from threshold_manager import ThresholdManager

manager = ThresholdManager()
stats = manager.get_stats()
manager.close()
print(json.dumps(stats, indent=2, default=str))
" 2>/dev/null
}

detect_explicit_feedback() {
    local message="$1"
    local message_lower
    message_lower=$(echo "$message" | tr '[:upper:]' '[:lower:]')

    if echo "$message_lower" | rg -qi "yes.*that|exactly|correct|right.*agent|good.*match|perfect.*suggestion|well done|excellent|great work|thanks.*work|brilliant|awesome|nice work|good job|perfect$"; then
        echo "positive"
        return 0
    fi

    if echo "$message_lower" | rg -qi "wrong|not.*that|different|no.*that|bad.*match|incorrect"; then
        echo "negative"
        return 0
    fi

    if echo "$message_lower" | rg -qi "^(ok|go|do it|proceed|continue|yes)$"; then
        echo "neutral"
        return 0
    fi

    echo "none"
}

process_feedback_and_calibrate() {
    local message="$1"
    local concept_type="${2:-}"

    local explicit_feedback
    explicit_feedback=$(detect_explicit_feedback "$message")

    if [[ "$explicit_feedback" != "none" ]]; then
        _scorer_log "INFO" "Detected explicit feedback: $explicit_feedback"

        local calibration_result
        calibration_result=$(record_threshold_feedback "$explicit_feedback" "$concept_type")

        if [[ -n "$calibration_result" ]] && [[ "$calibration_result" != "null" ]]; then
            _scorer_log "INFO" "Threshold calibrated: $calibration_result"
            echo "$calibration_result"
        fi
    fi
}

export -f score_feedback
export -f get_score_delta
export -f propagate_success
export -f record_cross_project_hit
export -f process_user_message
export -f get_top_solutions
export -f get_cross_project_insights
export -f decay_old_scores
export -f get_scoring_stats
export -f record_match_for_feedback
export -f record_threshold_feedback
export -f calibrate_thresholds
export -f get_threshold_stats
export -f detect_explicit_feedback
export -f process_feedback_and_calibrate
