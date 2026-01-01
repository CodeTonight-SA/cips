#!/usr/bin/env bash

##############################################################################
# Node Process Cleanup Script
#
# CRITICAL SAFETY FEATURES:
# - Multi-tier protection (Untouchable → Protected → Safe)
# - 4-stage confirmation (Scan → Individual → Final → Force)
# - Graceful shutdown (SIGTERM → SIGKILL with confirmation)
# - Full rollback via checkpoints
# - Emergency stop (Ctrl+C safe at all stages)
#
# NEVER KILLS:
# - System processes (launchd, WindowServer, etc.)
# - Claude Code instances (running or idle)
# - Critical ports (22, 88, 445, 548, 631, 5000)
# - IDE helpers (Cursor, Figma)
##############################################################################

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# Source libraries
source "$LIB_DIR/safety-checks.sh"
source "$LIB_DIR/process-scanner.sh"
source "$LIB_DIR/graceful-kill.sh"

# Configuration
CONFIG_FILE="$HOME/.claude/config/node-clean.conf"
CHECKPOINT_DIR="$HOME/.claude/checkpoints"
CHECKPOINT_FILE=""

# Default settings
MEMORY_THRESHOLD_MB=200
PORT_RANGE_START=3000
PORT_RANGE_END=9999
DRY_RUN=true
REQUIRE_CONFIRMATION=true
AUTO_FORCE=false
CHECKPOINT_ENABLED=true

# Load configuration if exists
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
fi

# Emergency stop handler
emergency_stop() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🛑 EMERGENCY STOP TRIGGERED"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Operation cancelled. No processes were harmed."
  [[ -n "$CHECKPOINT_FILE" ]] && echo "Checkpoint saved: $CHECKPOINT_FILE"
  echo "Exiting safely..."
  exit 130
}

trap 'emergency_stop' INT TERM

# Show usage
show_usage() {
  cat <<EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Node Process Cleanup - Safe Memory & CPU Recovery
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Usage: node-clean.sh [OPTIONS]

OPTIONS:
  --dry-run, -d          Preview only (default)
  --execute, -x          Execute kills (requires confirmation)
  --force                Skip individual confirmations (DANGEROUS)
  --memory <MB>          Memory threshold in MB (default: 200)
  --port-range <S-E>     Port range (default: 3000-9999)
  --status               Show current Node processes and exit
  --help, -h             Show this help

EXAMPLES:
  node-clean.sh                    # Dry run preview
  node-clean.sh --execute          # Interactive kill with confirmations
  node-clean.sh --memory 500       # Only processes >500MB
  node-clean.sh --status           # Just show running processes

SAFETY:
  ✅ Never kills system processes (launchd, WindowServer, etc.)
  ✅ Never kills Claude Code instances
  ✅ Never touches critical ports (SSH, SMB, etc.)
  ✅ Requires confirmation at multiple stages
  ✅ Graceful shutdown (SIGTERM before SIGKILL)
  ✅ Full rollback via checkpoints
  ✅ Emergency stop (Ctrl+C) safe at all stages

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

# Parse arguments
parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --dry-run|-d)
        DRY_RUN=true
        shift
        ;;
      --execute|-x)
        DRY_RUN=false
        shift
        ;;
      --force)
        AUTO_FORCE=true
        REQUIRE_CONFIRMATION=false
        shift
        ;;
      --memory)
        MEMORY_THRESHOLD_MB=$2
        shift 2
        ;;
      --port-range)
        IFS='-' read -r PORT_RANGE_START PORT_RANGE_END <<< "$2"
        shift 2
        ;;
      --status)
        show_status
        exit 0
        ;;
      --help|-h)
        show_usage
        exit 0
        ;;
      *)
        echo "❌ Unknown option: $1"
        show_usage
        exit 1
        ;;
    esac
  done
}

# Show status only
show_status() {
  echo "🔍 Scanning for Node processes..."
  local processes=$(scan_node_processes "$MEMORY_THRESHOLD_MB" "$PORT_RANGE_START" "$PORT_RANGE_END")
  format_process_table "$processes"
}

# Create checkpoint
create_checkpoint() {
  local processes=$1

  if [[ "$CHECKPOINT_ENABLED" == "true" ]]; then
    mkdir -p "$CHECKPOINT_DIR"
    CHECKPOINT_FILE="$CHECKPOINT_DIR/node-clean-$(date +%s).json"

    cat > "$CHECKPOINT_FILE" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "memory_threshold_mb": $MEMORY_THRESHOLD_MB,
  "port_range": "$PORT_RANGE_START-$PORT_RANGE_END",
  "dry_run": $DRY_RUN,
  "processes": $processes
}
EOF

    echo "💾 Checkpoint created: $CHECKPOINT_FILE"
  fi
}

# Main execution
main() {
  # Safety check: not root
  check_not_root

  # Parse arguments
  parse_args "$@"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🧹 NODE PROCESS CLEANUP"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Mode: $([[ "$DRY_RUN" == "true" ]] && echo "DRY RUN (preview only)" || echo "EXECUTE (will kill processes)")"
  echo "Memory threshold: ${MEMORY_THRESHOLD_MB}MB"
  echo "Port range: $PORT_RANGE_START-$PORT_RANGE_END"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Scan for processes
  echo "🔍 Scanning for Node processes..."
  local all_processes=$(scan_node_processes "$MEMORY_THRESHOLD_MB" "$PORT_RANGE_START" "$PORT_RANGE_END")

  # Filter to safe-to-kill only
  local safe_processes=$(echo "$all_processes" | jq '[.[] | select(.safety_status == "SAFE")]')
  local safe_count=$(echo "$safe_processes" | jq 'length')

  # Display results
  format_process_table "$all_processes"

  # No processes to kill
  if [[ $safe_count -eq 0 ]]; then
    echo "✅ No Node processes found exceeding threshold."
    echo "   All systems clean!"
    exit 0
  fi

  # Dry run mode
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔍 DRY RUN MODE - No processes will be killed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "To execute: $0 --execute"
    exit 0
  fi

  # Create checkpoint
  create_checkpoint "$safe_processes"

  # Stage 1: Initial confirmation
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "⚠️  STAGE 1: INITIAL CONFIRMATION"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Found $safe_count processes to clean."
  echo ""
  read -r -p "Continue to individual process review? [y/N] " initial_confirm

  if [[ ! "$initial_confirm" =~ ^[Yy]$ ]]; then
    echo "❌ Operation cancelled."
    exit 0
  fi

  # Stage 2: Individual process confirmation (if required)
  local confirmed_processes="[]"

  if [[ "$REQUIRE_CONFIRMATION" == "true" ]]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  STAGE 2: INDIVIDUAL PROCESS REVIEW"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local index=0
    local total=$safe_count

    while [[ $index -lt $total ]]; do
      local process=$(echo "$safe_processes" | jq ".[$index]")
      local pid=$(echo "$process" | jq -r '.pid')
      local name=$(echo "$process" | jq -r '.name')
      local command=$(echo "$process" | jq -r '.command')
      local memory=$(echo "$process" | jq -r '.memory_mb')
      local port=$(echo "$process" | jq -r '.port')
      local cwd=$(echo "$process" | jq -r '.cwd')

      echo ""
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "PROCESS $((index + 1)) of $total"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "PID:     $pid"
      echo "Name:    $name"
      echo "Command: $command"
      echo "Memory:  ${memory}MB"
      echo "Port:    ${port:-N/A}"
      echo "Path:    $cwd"
      echo ""
      read -r -p "Kill this process? [y/N/skip/abort] " choice

      case "$choice" in
        y|Y)
          confirmed_processes=$(echo "$confirmed_processes" | jq ". += [$process]")
          echo "✅ Marked for termination"
          ;;
        abort)
          echo "❌ Operation aborted by user."
          exit 0
          ;;
        *)
          echo "⏭️  Skipped"
          ;;
      esac

      ((index++))
    done
  else
    confirmed_processes="$safe_processes"
  fi

  local confirmed_count=$(echo "$confirmed_processes" | jq 'length')

  if [[ $confirmed_count -eq 0 ]]; then
    echo ""
    echo "ℹ️  No processes selected for termination."
    exit 0
  fi

  # Stage 3: Final confirmation
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "⚠️  STAGE 3: FINAL CONFIRMATION"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "You are about to kill $confirmed_count process(es):"
  echo ""
  echo "$confirmed_processes" | jq -r '.[] | "  - PID \(.pid): \(.name) (\(.memory_mb)MB)"'
  echo ""
  local total_mem=$(echo "$confirmed_processes" | jq '[.[].memory_mb] | add')
  echo "Expected memory freed: ${total_mem}MB"
  echo "Checkpoint: $CHECKPOINT_FILE"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "⚠️  TYPE 'KILL' TO PROCEED (or anything else to abort)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  read -r final_confirm

  if [[ "$final_confirm" != "KILL" ]]; then
    echo "❌ Operation cancelled (confirmation failed)."
    exit 0
  fi

  # Execute kills
  batch_kill_processes "$confirmed_processes" "$([[ "$AUTO_FORCE" == "true" ]] && echo 1 || echo 0)"

  echo ""
  echo "✅ Cleanup complete!"
  echo ""
  echo "Checkpoint saved for rollback: $CHECKPOINT_FILE"
  echo "To restart killed processes: node-clean-rollback.sh $CHECKPOINT_FILE"
  echo ""
}

# Run main
main "$@"
