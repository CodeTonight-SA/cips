#!/usr/bin/env bash

# Graceful Kill Library for Node Cleanup System
# Implements SIGTERM → SIGKILL escalation with user confirmation

# Kill process gracefully (SIGTERM first, optional SIGKILL)
# Args: PID, process_name, auto_force (0=ask, 1=force)
# Returns: 0=success, 1=failed, 2=skipped
kill_gracefully() {
  local pid=$1
  local name=$2
  local auto_force=${3:-0}

  # Verify process still exists
  if ! ps -p "$pid" > /dev/null 2>&1; then
    echo "⚠️  Process $pid already terminated"
    return 0
  fi

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "⏳ Terminating PID $pid ($name)..."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Step 1: SIGTERM (graceful shutdown)
  echo "📤 Sending SIGTERM (graceful shutdown)..."
  kill -15 "$pid" 2>/dev/null

  if [[ $? -ne 0 ]]; then
    echo "❌ Failed to send SIGTERM (process may be protected or already gone)"
    return 1
  fi

  # Wait up to 10 seconds for graceful shutdown
  local waited=0
  local max_wait=10

  while [[ $waited -lt $max_wait ]]; do
    if ! ps -p "$pid" > /dev/null 2>&1; then
      echo "✅ Process $pid terminated gracefully after ${waited}s"
      return 0
    fi
    echo -n "."
    sleep 1
    ((waited++))
  done

  echo ""
  echo "⚠️  Process $pid did not respond to SIGTERM after ${max_wait}s"

  # Step 2: SIGKILL (force kill) - requires confirmation
  if [[ $auto_force -eq 1 ]]; then
    echo "🔨 Auto-forcing SIGKILL (--force flag active)..."
    kill -9 "$pid" 2>/dev/null
  else
    echo ""
    echo "💀 Send SIGKILL (force kill)? This cannot be interrupted."
    echo "   [y] Yes, force kill"
    echo "   [N] No, skip this process (default)"
    echo ""
    read -r -p "Choice: " force_choice

    case "$force_choice" in
      y|Y)
        echo "💀 Sending SIGKILL..."
        kill -9 "$pid" 2>/dev/null
        ;;
      *)
        echo "⏭️  Skipped force-kill for PID $pid"
        return 2
        ;;
    esac
  fi

  # Verify SIGKILL worked
  sleep 1
  if ! ps -p "$pid" > /dev/null 2>&1; then
    echo "✅ Process $pid force-killed"
    return 0
  else
    echo "❌ FAILED to kill PID $pid (process may be protected by SIP)"
    return 1
  fi
}

# Batch kill multiple processes with progress reporting
batch_kill_processes() {
  local json_data=$1
  local auto_force=${2:-0}

  local total=$(echo "$json_data" | jq 'length')
  local killed=0
  local failed=0
  local skipped=0

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔄 BATCH KILL OPERATION"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Total processes: $total"
  echo ""

  local index=0
  while [[ $index -lt $total ]]; do
    local process=$(echo "$json_data" | jq ".[$index]")
    local pid=$(echo "$process" | jq -r '.pid')
    local name=$(echo "$process" | jq -r '.name')

    echo ""
    echo "[$((index + 1))/$total] Processing PID $pid ($name)..."

    kill_gracefully "$pid" "$name" "$auto_force"
    local result=$?

    case $result in
      0) ((killed++)) ;;
      1) ((failed++)) ;;
      2) ((skipped++)) ;;
    esac

    ((index++))
  done

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📊 OPERATION SUMMARY"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ Killed:  $killed"
  echo "❌ Failed:  $failed"
  echo "⏭️  Skipped: $skipped"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  return 0
}

# Export functions
export -f kill_gracefully
export -f batch_kill_processes
