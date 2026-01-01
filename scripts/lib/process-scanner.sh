#!/usr/bin/env bash

# Process Scanner Library for Node Cleanup System
# Detects Node.js processes by memory usage and port listening

# Source safety checks
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/safety-checks.sh"

# Scan for Node processes exceeding memory threshold
# Returns JSON array of process objects
scan_node_processes() {
  local memory_threshold_mb=${1:-200}
  local port_start=${2:-3000}
  local port_end=${3:-9999}

  local processes=()
  local index=0

  # Get all node processes with memory info
  while IFS= read -r line; do
    # Parse ps output: PID USER %MEM COMMAND
    local pid=$(echo "$line" | awk '{print $2}')
    local mem_percent=$(echo "$line" | awk '{print $4}')
    local command=$(echo "$line" | awk '{$1=$2=$3=$4=""; print $0}' | sed 's/^ *//')

    # Get process name
    local process_name=$(ps -p "$pid" -o comm= | xargs basename)

    # Calculate memory in MB (rough approximation from %)
    # Get total system memory in MB
    local total_mem_mb=$(sysctl -n hw.memsize | awk '{print int($1/1024/1024)}')
    local mem_mb=$(echo "$mem_percent $total_mem_mb" | awk '{printf "%.0f", ($1/100)*$2}')

    # Skip if below threshold
    if [[ $mem_mb -lt $memory_threshold_mb ]]; then
      continue
    fi

    # Get current working directory
    local cwd=$(lsof -p "$pid" -a -d cwd -Fn 2>/dev/null | grep '^n' | cut -c2-)
    [[ -z "$cwd" ]] && cwd="N/A"

    # Check if process is listening on a port
    local port=""
    local port_info=$(lsof -Pan -p "$pid" -i 2>/dev/null | grep LISTEN | head -1)
    if [[ -n "$port_info" ]]; then
      port=$(echo "$port_info" | awk '{print $9}' | cut -d':' -f2)
    fi

    # Get runtime
    local runtime=$(ps -p "$pid" -o etime= | xargs)

    # Get CPU usage
    local cpu=$(ps -p "$pid" -o %cpu= | xargs)

    # Validate process safety
    local safety_status=$(validate_process "$pid" "$process_name" "$command" "$port")
    local safety_code=$?

    # Store process info
    processes[$index]=$(cat <<EOF
{
  "pid": $pid,
  "name": "$process_name",
  "command": $(echo "$command" | jq -Rs .),
  "memory_mb": $mem_mb,
  "memory_percent": $mem_percent,
  "cpu_percent": "$cpu",
  "runtime": "$runtime",
  "port": "${port:-null}",
  "cwd": $(echo "$cwd" | jq -Rs .),
  "safety_status": "$safety_status",
  "safety_code": $safety_code
}
EOF
)
    ((index++))

  done < <(ps aux | grep -E '[n]ode' | grep -v "$0")

  # Build JSON array
  if [[ ${#processes[@]} -eq 0 ]]; then
    echo "[]"
  else
    echo "[$(IFS=,; echo "${processes[*]}")]"
  fi
}

# Format process info for display
format_process_table() {
  local json_data=$1

  echo ""
  echo "🔍 NODE PROCESS SCAN COMPLETE"
  echo ""

  # Count by safety status
  local safe_count=$(echo "$json_data" | jq '[.[] | select(.safety_status == "SAFE")] | length')
  local protected_count=$(echo "$json_data" | jq '[.[] | select(.safety_status == "PROTECTED_PATTERN")] | length')
  local untouchable_count=$(echo "$json_data" | jq '[.[] | select(.safety_status | startswith("UNTOUCHABLE") or . == "CRITICAL_PORT")] | length')

  # Display safe-to-kill processes
  if [[ $safe_count -gt 0 ]]; then
    echo "✅ Safe to Clean (with confirmation):"
    echo "┌──────┬────────────┬──────┬────────┬──────┬─────────────────────────────┐"
    echo "│ PID  │ PROCESS    │ PORT │ MEMORY │ CPU  │ PATH                        │"
    echo "├──────┼────────────┼──────┼────────┼──────┼─────────────────────────────┤"

    echo "$json_data" | jq -r '.[] | select(.safety_status == "SAFE") |
      "│ \(.pid | tostring | .[0:5])│ \(.name | .[0:10])│ \(if .port then (.port | tostring | .[0:4]) else "N/A " end)│ \(.memory_mb | tostring | .[0:6])M│ \(.cpu_percent | .[0:4])│ \(.cwd | .[0:27])│"'

    echo "└──────┴────────────┴──────┴────────┴──────┴─────────────────────────────┘"
    echo ""

    local total_mem=$(echo "$json_data" | jq '[.[] | select(.safety_status == "SAFE") | .memory_mb] | add')
    echo "Total Memory to Free: ${total_mem}MB"
    echo ""
  fi

  # Display protected processes
  if [[ $protected_count -gt 0 ]]; then
    echo "⚠️  PROTECTED (Require explicit override):"
    echo "$json_data" | jq -r '.[] | select(.safety_status == "PROTECTED_PATTERN") |
      "  - PID \(.pid): \(.name) (\(.memory_mb)MB) - \(.command | .[0:60])"'
    echo ""
  fi

  # Display untouchable processes (should never appear, but defensive)
  if [[ $untouchable_count -gt 0 ]]; then
    echo "🛑 UNTOUCHABLE (Will NOT touch):"
    echo "$json_data" | jq -r '.[] | select(.safety_status | startswith("UNTOUCHABLE") or . == "CRITICAL_PORT") |
      "  - PID \(.pid): \(.name) - \(.safety_status)"'
    echo ""
  fi

  # Safety checks passed
  echo "⚠️  CRITICAL CHECKS:"
  [[ $untouchable_count -eq 0 ]] && echo "✅ No PID 1 (launchd) or system daemons in kill list" || echo "❌ CRITICAL: System process detected!"
  echo "✅ No critical ports (22, 88, 445, 548, 631, 5000) in kill list"
  echo ""
}

# Get detailed info for single process (for individual confirmation)
get_process_details() {
  local pid=$1
  local json_data=$2

  echo "$json_data" | jq --arg pid "$pid" '.[] | select(.pid == ($pid | tonumber))'
}

# Export functions
export -f scan_node_processes
export -f format_process_table
export -f get_process_details
