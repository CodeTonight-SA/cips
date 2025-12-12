#!/usr/bin/env bash
#
# Path Resolver Library
# Fixes critical history path bug in self-improvement engine
#
# PROBLEM:
#   optim.sh references ~/.claude/history.jsonl (doesn't exist)
#   Actual history is in ~/.claude/projects/{encoded-path}/*.jsonl
#
# SOLUTION:
#   This library provides functions to:
#   1. Detect current project
#   2. Encode path for Claude's storage format
#   3. Locate actual history files
#   4. Aggregate history from multiple session files
#
# USAGE:
#   source ~/.claude/lib/path-resolver.sh
#   history_files=$(locate_project_history)
#   history=$(aggregate_project_history 24)  # Last 24 hours
#
# VERSION: 1.0.0
# DATE: 2025-11-27
#

set -euo pipefail

# ============================================================================
# CONSTANTS
# ============================================================================

[[ -z "${CLAUDE_PROJECTS_DIR:-}" ]] && readonly CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"
[[ -z "${MAX_HISTORY_LINES:-}" ]] && readonly MAX_HISTORY_LINES=5000
[[ -z "${DEFAULT_HOURS_BACK:-}" ]] && readonly DEFAULT_HOURS_BACK=4

# ============================================================================
# PATH ENCODING (Matches Claude Code's internal format)
# ============================================================================

# Encode a filesystem path to Claude's project directory format
# Cross-platform: macOS, Linux, Windows Git Bash
# Input (macOS/Linux): /Users/name/project → -Users-name-project
# Input (Windows):     /c/Users/Name/project → c--Users-Name-project
encode_path() {
    local path="$1"

    # Cross-platform path normalisation
    case "$(uname -s)" in
        MINGW*|MSYS*|CYGWIN*)
            # Windows Git Bash: /c/Users/... → c--Users-...
            # Claude Code stores Windows paths as: c--Users-Name-...
            if [[ "$path" =~ ^/([a-zA-Z])/ ]]; then
                local drive="${BASH_REMATCH[1]}"
                path="${drive}--${path:3}"  # /c/foo → c--foo
            fi
            ;;
        Darwin*|Linux*)
            # macOS/Linux: /Users/name/... → -Users-name-...
            # Keep existing behaviour (leading slash → leading dash)
            ;;
    esac

    # Universal: Replace slashes, dots, spaces with dashes
    echo "$path" | sed 's|/|-|g' | sed 's|\.|-|g' | sed 's| |-|g'
}

# Decode a Claude project directory name back to filesystem path
# Input: -Users-lauriescheepers--claude
# Output: /Users/lauriescheepers/.claude
# Note: Decoding is lossy - cannot distinguish . from / in original
decode_path() {
    local encoded="$1"

    # Remove leading dash, replace remaining dashes with slashes
    # Note: This assumes dots were originally slashes (best effort)
    echo "$encoded" | sed 's|^-|/|' | sed 's|-|/|g'
}

# Get encoded path for current working directory
get_current_project_encoded() {
    encode_path "$(pwd)"
}

# ============================================================================
# PROJECT DETECTION
# ============================================================================

# Find the Claude projects directory for current working directory
# Returns: Full path to project directory, or empty if not found
find_project_dir() {
    local cwd="${1:-$(pwd)}"
    local encoded=$(encode_path "$cwd")
    local project_dir="$CLAUDE_PROJECTS_DIR/$encoded"

    # Direct match
    if [[ -d "$project_dir" ]]; then
        echo "$project_dir"
        return 0
    fi

    # Fuzzy match: search for directories containing the project name
    local basename=$(basename "$cwd")
    local fuzzy_match=$(fd -t d -1 "*$basename*" "$CLAUDE_PROJECTS_DIR" 2>/dev/null | head -1)

    if [[ -n "$fuzzy_match" ]]; then
        echo "$fuzzy_match"
        return 0
    fi

    # No match found
    return 1
}

# Check if current directory has Claude history
has_project_history() {
    local project_dir=$(find_project_dir 2>/dev/null)

    if [[ -z "$project_dir" ]]; then
        return 1
    fi

    # Check for any JSONL files
    local jsonl_count=$(fd -e jsonl . "$project_dir" 2>/dev/null | wc -l | tr -d ' ')

    [[ $jsonl_count -gt 0 ]]
}

# ============================================================================
# HISTORY FILE LOCATION
# ============================================================================

# Locate all history JSONL files for current project
# Returns: Newline-separated list of file paths (newest first)
# Cross-platform: macOS (BSD stat), Linux/Windows (GNU stat)
locate_project_history() {
    local project_dir=$(find_project_dir 2>/dev/null)

    if [[ -z "$project_dir" ]]; then
        # Fallback: check legacy location
        if [[ -f "$HOME/.claude/history.jsonl" ]]; then
            echo "$HOME/.claude/history.jsonl"
            return 0
        fi
        return 1
    fi

    # Cross-platform stat format for modification time + filename
    local stat_fmt
    case "$(uname -s)" in
        Darwin*)
            # BSD stat (macOS): -f format
            stat_fmt="-f %m"
            ;;
        *)
            # GNU stat (Linux, Windows Git Bash): -c format
            stat_fmt="-c %Y"
            ;;
    esac

    # Find all JSONL files, get mtime, sort by newest first
    fd -e jsonl . "$project_dir" -t f 2>/dev/null | while read -r file; do
        local mtime=$(stat $stat_fmt "$file" 2>/dev/null)
        [[ -n "$mtime" ]] && echo "$mtime $file"
    done | sort -rn | cut -d' ' -f2- | head -20
}

# Get the most recent history file
get_latest_history_file() {
    locate_project_history | head -1
}

# Count total history entries across all files
count_history_entries() {
    local total=0

    while IFS= read -r file; do
        [[ -f "$file" ]] || continue
        local count=$(wc -l < "$file" | tr -d ' ')
        total=$((total + count))
    done < <(locate_project_history)

    echo "$total"
}

# ============================================================================
# TIMESTAMP UTILITIES (Cross-platform)
# ============================================================================

# Get current epoch milliseconds
current_epoch_ms() {
    echo "$(date +%s)000"
}

# Get epoch milliseconds N hours ago
hours_ago_epoch_ms() {
    local hours="${1:-$DEFAULT_HOURS_BACK}"
    echo $(( ($(date +%s) - (hours * 3600)) * 1000 ))
}

# Convert ISO 8601 timestamp to epoch milliseconds
# Handles both formats:
#   - "2025-11-27T10:30:00.000Z" (ISO 8601)
#   - 1732704600000 (already epoch ms)
timestamp_to_epoch_ms() {
    local timestamp="$1"

    # Already epoch milliseconds
    if [[ "$timestamp" =~ ^[0-9]+$ ]]; then
        echo "$timestamp"
        return 0
    fi

    # ISO 8601 format - extract date/time parts
    local date_part=$(echo "$timestamp" | cut -dT -f1)
    local time_part=$(echo "$timestamp" | cut -dT -f2 | sed 's/Z$//' | cut -d. -f1)

    case "$(uname -s)" in
        Darwin*)
            # BSD date (macOS)
            date -j -f "%Y-%m-%d %H:%M:%S" "$date_part $time_part" "+%s" 2>/dev/null | \
                awk '{print $1 "000"}'
            ;;
        *)
            # GNU date (Linux/Windows Git Bash)
            date -d "$date_part $time_part" "+%s" 2>/dev/null | \
                awk '{print $1 "000"}' || echo "0"
            ;;
    esac
}

# ============================================================================
# HISTORY AGGREGATION
# ============================================================================

# Aggregate history from all project files with timestamp filtering
# Args: $1 = hours_back (default: 4)
# Returns: JSONL entries within time window
aggregate_project_history() {
    local hours_back="${1:-$DEFAULT_HOURS_BACK}"
    local start_epoch=$(hours_ago_epoch_ms "$hours_back")
    local end_epoch=$(current_epoch_ms)

    local history_files=$(locate_project_history)

    if [[ -z "$history_files" ]]; then
        echo "[]"
        return 0
    fi

    # Read all files, filter by timestamp, limit total lines
    local combined=""
    local line_count=0

    while IFS= read -r file; do
        [[ -f "$file" ]] || continue

        # Process each line, filtering by timestamp
        while IFS= read -r line; do
            # Skip empty lines
            [[ -z "$line" ]] && continue

            # Extract timestamp (handle both formats)
            local ts=$(echo "$line" | jq -r '.timestamp // .ts // empty' 2>/dev/null)

            if [[ -n "$ts" ]]; then
                local ts_epoch=$(timestamp_to_epoch_ms "$ts")

                # Check if within time window
                if [[ $ts_epoch -ge $start_epoch && $ts_epoch -le $end_epoch ]]; then
                    echo "$line"
                    line_count=$((line_count + 1))

                    # Respect max lines limit
                    if [[ $line_count -ge $MAX_HISTORY_LINES ]]; then
                        return 0
                    fi
                fi
            fi
        done < "$file"
    done <<< "$history_files"
}

# Get raw history without timestamp filtering (for full analysis)
get_raw_history() {
    local max_lines="${1:-$MAX_HISTORY_LINES}"

    local history_files=$(locate_project_history)

    if [[ -z "$history_files" ]]; then
        return 1
    fi

    # Concatenate all files, newest first
    local line_count=0
    while IFS= read -r file; do
        [[ -f "$file" ]] || continue

        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            echo "$line"
            line_count=$((line_count + 1))

            if [[ $line_count -ge $max_lines ]]; then
                return 0
            fi
        done < "$file"
    done <<< "$history_files"
}

# ============================================================================
# SEARCH UTILITIES
# ============================================================================

# Search history for pattern (uses rg for performance)
search_history() {
    local pattern="$1"
    local hours_back="${2:-$DEFAULT_HOURS_BACK}"

    aggregate_project_history "$hours_back" | \
        rg -i "$pattern" 2>/dev/null || true
}

# Count pattern occurrences in history
count_pattern_in_history() {
    local pattern="$1"
    local hours_back="${2:-$DEFAULT_HOURS_BACK}"

    search_history "$pattern" "$hours_back" | wc -l | tr -d ' '
}

# ============================================================================
# SESSION DETECTION
# ============================================================================

# List all sessions for current project
list_project_sessions() {
    local project_dir=$(find_project_dir 2>/dev/null)

    if [[ -z "$project_dir" ]]; then
        return 1
    fi

    # Find session directories or files
    fd -t f -e jsonl . "$project_dir" 2>/dev/null | \
        xargs -I{} basename {} .jsonl | \
        sort -u
}

# Get session count for current project
count_project_sessions() {
    list_project_sessions 2>/dev/null | wc -l | tr -d ' '
}

# ============================================================================
# DIAGNOSTIC FUNCTIONS
# ============================================================================

# Print diagnostic information about history storage
diagnose_history() {
    echo "=== History Storage Diagnosis ==="
    echo ""
    echo "Current directory: $(pwd)"
    echo "Encoded path: $(get_current_project_encoded)"
    echo ""

    local project_dir=$(find_project_dir 2>/dev/null)
    if [[ -n "$project_dir" ]]; then
        echo "Project directory: $project_dir"
        echo "Directory exists: yes"
    else
        echo "Project directory: NOT FOUND"
        echo "Directory exists: no"
        echo ""
        echo "Searching for similar directories..."
        fd -t d . "$CLAUDE_PROJECTS_DIR" 2>/dev/null | head -5
    fi
    echo ""

    echo "History files:"
    local files=$(locate_project_history 2>/dev/null)
    if [[ -n "$files" ]]; then
        echo "$files" | while read -r f; do
            local lines=$(wc -l < "$f" 2>/dev/null | tr -d ' ')
            echo "  $f ($lines entries)"
        done
    else
        echo "  (none found)"
    fi
    echo ""

    echo "Total entries: $(count_history_entries)"
    echo "Sessions: $(count_project_sessions 2>/dev/null || echo 0)"
    echo ""

    echo "Legacy file check:"
    if [[ -f "$HOME/.claude/history.jsonl" ]]; then
        local legacy_lines=$(wc -l < "$HOME/.claude/history.jsonl" | tr -d ' ')
        echo "  ~/.claude/history.jsonl exists ($legacy_lines entries)"
    else
        echo "  ~/.claude/history.jsonl does not exist"
    fi

    echo ""
    echo "=== End Diagnosis ==="
}

# ============================================================================
# EXPORTS (for sourcing)
# ============================================================================

# Export functions for use by other scripts
export -f encode_path
export -f decode_path
export -f get_current_project_encoded
export -f find_project_dir
export -f has_project_history
export -f locate_project_history
export -f get_latest_history_file
export -f count_history_entries
export -f current_epoch_ms
export -f hours_ago_epoch_ms
export -f timestamp_to_epoch_ms
export -f aggregate_project_history
export -f get_raw_history
export -f search_history
export -f count_pattern_in_history
export -f list_project_sessions
export -f count_project_sessions
export -f diagnose_history

# ============================================================================
# MAIN (if run directly)
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-diagnose}" in
        diagnose|--diagnose|-d)
            diagnose_history
            ;;
        locate|--locate|-l)
            locate_project_history
            ;;
        aggregate|--aggregate|-a)
            aggregate_project_history "${2:-4}"
            ;;
        search|--search|-s)
            search_history "${2:-}" "${3:-4}"
            ;;
        help|--help|-h)
            cat << 'EOF'
Path Resolver Library - Fix Claude Code history path resolution

USAGE:
    ./path-resolver.sh [command] [args]

COMMANDS:
    diagnose        Show diagnostic information about history storage
    locate          List all history files for current project
    aggregate [h]   Get history entries from last h hours (default: 4)
    search <pat> [h] Search history for pattern
    help            Show this help message

AS LIBRARY:
    source ~/.claude/lib/path-resolver.sh

    # Find history files
    files=$(locate_project_history)

    # Get recent history
    history=$(aggregate_project_history 24)  # Last 24 hours

    # Search for pattern
    count=$(count_pattern_in_history "Read(" 4)

EOF
            ;;
        *)
            echo "Unknown command: $1"
            echo "Run '$0 help' for usage"
            exit 1
            ;;
    esac
fi
