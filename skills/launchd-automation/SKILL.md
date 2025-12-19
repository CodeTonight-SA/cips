# Launchd Automation Skill

Create self-reloading macOS launchd agents with automatic plist validation.

## Pattern

Two-agent architecture:

1. **Main Agent** - The scheduled task (e.g., nightly sync)
2. **Watcher Agent** - Monitors main plist, auto-reloads on edit

## When to Use

- Scheduled Mac automation tasks
- User asks for "launchd", "cron", "scheduled task", "nightly job"
- Any recurring automation on macOS

## Protocol

### Step 1: Create Main Agent Plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.{org}.{name}</string>

    <key>ProgramArguments</key>
    <array>
        <string>/path/to/interpreter</string>
        <string>/path/to/script</string>
    </array>

    <key>WorkingDirectory</key>
    <string>/path/to/project</string>

    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>

    <!-- Wake Mac from sleep -->
    <key>WakeFromSleep</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/path/to/logs/task.log</string>
    <key>StandardErrorPath</key>
    <string>/path/to/logs/task.error.log</string>

    <key>RunAtLoad</key>
    <false/>

    <key>Nice</key>
    <integer>10</integer>

    <key>TimeOut</key>
    <integer>1800</integer>
</dict>
</plist>
```

### Step 2: Create Reload Script

Location: `{project}/scripts/reload-launchd.sh`

```bash
#!/bin/bash
set -euo pipefail

PLIST_PATH="${1:-}"
LABEL="${2:-}"
LOG_FILE="${3:-/tmp/launchd-reload.log}"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"; }

[[ -z "$PLIST_PATH" ]] || [[ -z "$LABEL" ]] && exit 1
[[ ! -f "$PLIST_PATH" ]] && exit 1

log "Detected change in $PLIST_PATH"

# Validate syntax before reload
if ! plutil -lint "$PLIST_PATH" > /dev/null 2>&1; then
    log "ERROR: Invalid plist syntax - skipping reload"
    exit 1
fi

launchctl unload "$PLIST_PATH" 2>/dev/null || true
sleep 0.5
launchctl load "$PLIST_PATH"
log "Reloaded $LABEL"
```

### Step 3: Create Watcher Agent

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.{org}.{name}-watcher</string>

    <key>ProgramArguments</key>
    <array>
        <string>/path/to/reload-launchd.sh</string>
        <string>/path/to/main.plist</string>
        <string>com.{org}.{name}</string>
    </array>

    <key>WatchPaths</key>
    <array>
        <string>/path/to/main.plist</string>
    </array>

    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
```

### Step 4: Load Agents

```bash
# Load main agent
launchctl load ~/Library/LaunchAgents/com.{org}.{name}.plist

# Load watcher
launchctl load ~/Library/LaunchAgents/com.{org}.{name}-watcher.plist

# Verify
launchctl list | grep {name}
```

## Key Features

| Feature | Implementation |
|---------|----------------|
| Wake from sleep | `<key>WakeFromSleep</key><true/>` |
| Auto-reload on edit | Watcher agent with `WatchPaths` |
| Syntax validation | `plutil -lint` before reload |
| Graceful timeout | `TimeOut` key (seconds) |
| Lower priority | `Nice` value (1-20) |

## Common Schedule Patterns

```xml
<!-- Daily at 2am -->
<key>StartCalendarInterval</key>
<dict>
    <key>Hour</key><integer>2</integer>
    <key>Minute</key><integer>0</integer>
</dict>

<!-- Every hour -->
<key>StartCalendarInterval</key>
<dict>
    <key>Minute</key><integer>0</integer>
</dict>

<!-- Monday and Friday at 9am -->
<key>StartCalendarInterval</key>
<array>
    <dict>
        <key>Weekday</key><integer>1</integer>
        <key>Hour</key><integer>9</integer>
    </dict>
    <dict>
        <key>Weekday</key><integer>5</integer>
        <key>Hour</key><integer>9</integer>
    </dict>
</array>
```

## Commands

```bash
# Manual trigger
launchctl start com.{org}.{name}

# Check status
launchctl list | grep {name}

# View logs
tail -f /path/to/logs/task.log

# Unload (disable)
launchctl unload ~/Library/LaunchAgents/com.{org}.{name}.plist
```

## Anti-Patterns

- **KeepAlive with SuccessfulExit** - Causes immediate run on load
- **RunAtLoad: true** for scheduled tasks - Runs before schedule
- **No syntax validation** - Corrupt plist breaks reload
- **Single agent** - No auto-reload on edit

## Token Budget

~1500 tokens per launchd setup (two plists + reload script)

## Origin

Generated from NalaMatch nannysync implementation (Gen 15, Dec 2025).
