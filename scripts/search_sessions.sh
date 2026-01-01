#!/usr/bin/env bash
#
# search_sessions.sh - Efficient Claude Code conversation history search
#
# Purpose: Search past conversations stored in per-project JSONL files
# Storage: ~/.claude/projects/{encoded-path}/{session-uuid}.jsonl
# Format: ISO 8601 timestamps, one file per session
#
# Usage:
#   search_sessions.sh [keyword] [days-back]
#   search_sessions.sh                    # List recent sessions
#   search_sessions.sh "prisma"           # Search for keyword
#   search_sessions.sh "database" 30      # Search last 30 days
#
# See: ~/.claude/HISTORY_STORAGE_ANALYSIS.md for detailed specification

set -euo pipefail

# Configuration
KEYWORD="${1:-}"
DAYS_BACK="${2:-7}"
MAX_RESULTS=20

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
  echo -e "${BLUE}===================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}===================================================${NC}"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_info() {
  echo -e "${YELLOW}ℹ${NC} $1"
}

# Find project history directory
find_history_dir() {
  local project_dir=$(pwd | sed 's|^/||' | sed 's|/|-|g')

  # No leading hyphen removal needed - encoding is now correct
  local search_pattern="$project_dir"

  local history_dir=$(fd -t d "$search_pattern" ~/.claude/projects 2>/dev/null | head -1)

  if [[ -z "$history_dir" ]]; then
    print_error "No history found for current project: $(pwd)"
    print_info "Encoded path: $project_dir"
    echo ""
    print_info "Available projects:"
    fd -t d . ~/.claude/projects --max-depth 1 2>/dev/null | while read dir; do
      echo "  - $(basename "$dir" | sed 's|-|/|g')"
    done
    exit 1
  fi

  echo "$history_dir"
}

# List recent sessions
list_sessions() {
  local history_dir="$1"

  print_header "Recent Sessions for $(pwd)"
  echo ""

  local count=0
  for file in $(ls -t "$history_dir"/*.jsonl 2>/dev/null | grep -v agent | head -5); do
    ((count++))
    local session_name=$(basename "$file" .jsonl)
    local first_timestamp=$(jq -r 'select(.type == "user") | .timestamp' "$file" 2>/dev/null | head -1)
    local last_timestamp=$(jq -r 'select(.type == "user") | .timestamp' "$file" 2>/dev/null | tail -1)
    local user_count=$(jq -r 'select(.type == "user")' "$file" 2>/dev/null | wc -l | tr -d ' ')
    local file_size=$(ls -lh "$file" | awk '{print $5}')

    echo -e "${GREEN}Session $count:${NC} $session_name"
    echo "  Started:  $first_timestamp"
    echo "  Ended:    $last_timestamp"
    echo "  Messages: $user_count"
    echo "  Size:     $file_size"

    # Show first 2 user messages as preview
    echo "  Preview:"
    jq -r 'select(.type == "user" and (.message.content | type) == "string") | "    - \(.message.content | .[0:100])"' "$file" 2>/dev/null | head -2

    echo ""
  done

  if [[ $count -eq 0 ]]; then
    print_error "No sessions found"
  else
    print_success "Found $count recent sessions"
  fi
}

# Search sessions by keyword
search_keyword() {
  local history_dir="$1"
  local keyword="$2"
  local cutoff_date=$(date -v-${DAYS_BACK}d -u +"%Y-%m-%dT%H:%M:%S" 2>/dev/null || date -d "$DAYS_BACK days ago" -u +"%Y-%m-%dT%H:%M:%S" 2>/dev/null)

  print_header "Searching for: \"$keyword\" (last $DAYS_BACK days)"
  echo ""

  local total_matches=0
  local session_count=0

  for file in $(ls -t "$history_dir"/*.jsonl 2>/dev/null | grep -v agent); do
    # Check if file is within date range
    local first_timestamp=$(jq -r 'select(.type == "user") | .timestamp' "$file" 2>/dev/null | head -1)

    if [[ -n "$first_timestamp" ]] && [[ "$first_timestamp" < "$cutoff_date" ]]; then
      continue
    fi

    # Search for keyword (case-insensitive)
    local matches=$(rg -i "$keyword" "$file" -c 2>/dev/null || echo "0")

    if [[ $matches -gt 0 ]]; then
      ((session_count++))
      ((total_matches+=matches))

      local session_name=$(basename "$file" .jsonl)
      echo -e "${GREEN}Session:${NC} $session_name"
      echo "  Date: $first_timestamp"
      echo "  Matches: $matches"
      echo ""

      # Show matching lines with context
      rg -i "$keyword" "$file" -A 2 -B 2 --color=always 2>/dev/null | head -$MAX_RESULTS
      echo ""
      echo "---"
      echo ""
    fi
  done

  if [[ $session_count -eq 0 ]]; then
    print_error "No matches found for \"$keyword\""
  else
    print_success "Found $total_matches matches in $session_count sessions"
  fi
}

# Main execution
main() {
  local history_dir=$(find_history_dir)

  if [[ -z "$KEYWORD" ]]; then
    # No keyword provided - list recent sessions
    list_sessions "$history_dir"
  else
    # Keyword provided - search for it
    search_keyword "$history_dir" "$KEYWORD"
  fi
}

# Run main function
main
