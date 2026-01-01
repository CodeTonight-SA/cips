#!/usr/bin/env bash

# Safety Checks Library for Node Cleanup System
# Validates processes against untouchable/protected lists

# TIER 0: UNTOUCHABLE PROCESSES (CRITICAL SYSTEM - NEVER KILL)
declare -a UNTOUCHABLE_NAMES=(
  "launchd"
  "kernel_task"
  "WindowServer"
  "loginwindow"
  "systemd"
  "mDNSResponder"
  "softwareupdated"
  "bluetoothd"
  "airportd"
  "configd"
  "coreaudiod"
  "distnoted"
  "notifyd"
  "syslogd"
  "UserEventAgent"
  "securityd"
  "SystemUIServer"
  "claude"
  "claude-code"
)

declare -a UNTOUCHABLE_PIDS=(
  0   # kernel_task
  1   # launchd
)

# CRITICAL PORTS (NEVER TOUCH)
declare -a CRITICAL_PORTS=(
  22    # SSH
  88    # Kerberos
  139   # NetBIOS/SMB
  445   # SMB
  548   # AFP
  631   # CUPS printing
  5000  # macOS Control Center (Monterey+)
)

# TIER 1: PROTECTED PATTERNS (Warn before touching)
declare -a PROTECTED_PATTERNS=(
  "Cursor.*Helper"
  "Code.*Helper"
  "Figma.*Helper"
  "Claude.*Code"
  "claude"
  "postgres"
  "redis-server"
  "mongod"
  "mysql"
  "dockerd"
  "Docker"
)

# Check if PID is untouchable (system-critical)
is_untouchable_pid() {
  local pid=$1

  # Check against PID list
  for untouchable_pid in "${UNTOUCHABLE_PIDS[@]}"; do
    if [[ "$pid" -eq "$untouchable_pid" ]]; then
      return 0  # TRUE - untouchable
    fi
  done

  return 1  # FALSE - safe
}

# Check if process name is untouchable (system-critical)
is_untouchable_name() {
  local process_name=$1

  for untouchable in "${UNTOUCHABLE_NAMES[@]}"; do
    if [[ "$process_name" == "$untouchable" ]]; then
      return 0  # TRUE - untouchable
    fi
  done

  return 1  # FALSE - safe
}

# Check if process matches protected pattern (IDE helpers, databases)
is_protected_pattern() {
  local process_cmd=$1

  for pattern in "${PROTECTED_PATTERNS[@]}"; do
    if echo "$process_cmd" | grep -qE "$pattern"; then
      return 0  # TRUE - protected
    fi
  done

  return 1  # FALSE - not protected
}

# Check if port is critical (SSH, SMB, etc.)
is_critical_port() {
  local port=$1

  for critical_port in "${CRITICAL_PORTS[@]}"; do
    if [[ "$port" -eq "$critical_port" ]]; then
      return 0  # TRUE - critical
    fi
  done

  return 1  # FALSE - safe
}

# Validate a process before allowing kill operation
# Returns: 0=safe, 1=untouchable, 2=protected
validate_process() {
  local pid=$1
  local process_name=$2
  local process_cmd=$3
  local port=${4:-""}

  # CRITICAL: Check untouchable PID
  if is_untouchable_pid "$pid"; then
    echo "UNTOUCHABLE_PID"
    return 1
  fi

  # CRITICAL: Check untouchable name
  if is_untouchable_name "$process_name"; then
    echo "UNTOUCHABLE_NAME"
    return 1
  fi

  # CRITICAL: Check critical port
  if [[ -n "$port" ]] && is_critical_port "$port"; then
    echo "CRITICAL_PORT"
    return 1
  fi

  # PROTECTED: Check pattern match
  if is_protected_pattern "$process_cmd"; then
    echo "PROTECTED_PATTERN"
    return 2
  fi

  # SAFE to proceed
  echo "SAFE"
  return 0
}

# Prevent script from running as root (safety measure)
check_not_root() {
  if [[ $EUID -eq 0 ]]; then
    echo "❌ ERROR: This script must NOT be run as root for safety reasons."
    echo "   Running as root could accidentally kill system processes."
    echo "   Run as regular user: ./node-clean.sh"
    exit 1
  fi
}

# Export functions for use in main script
export -f is_untouchable_pid
export -f is_untouchable_name
export -f is_protected_pattern
export -f is_critical_port
export -f validate_process
export -f check_not_root
