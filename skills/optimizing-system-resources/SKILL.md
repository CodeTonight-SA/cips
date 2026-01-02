---
name: optimizing-system-resources
description: Automates system resource cleanup including browser tabs, IDE windows, memory optimisation, and process management. Use when system feels slow, RAM is low, or before intensive work sessions.
status: Active
version: 1.0.0
created: 2025-12-31
triggers:
  - /system-cleanup
  - /cleanup-resources
  - "clean up resources"
  - "free up RAM"
  - "system feels slow"
  - "close unused"
integrates:
  - node-cleanup
platform: macOS-first
---

# Optimizing System Resources

Comprehensive system cleanup automation for developer workstations. macOS-first with cross-platform notes.

## When to Use

- System feels sluggish or unresponsive
- Before starting memory-intensive work (builds, video editing, VMs)
- End of work session cleanup
- When `top` shows high memory pressure or swap usage
- Too many browser tabs accumulated

## Quick Commands

```bash
# Check memory pressure
vm_stat | head -10

# Top memory consumers (macOS)
ps aux -m | head -20 | awk '{printf "%-6s %5s%% %s\n", $2, $4, $11}'

# Count node processes
pgrep -fl "node" | wc -l

# Purge inactive memory (requires sudo)
sudo purge
```

## Workflow

### Phase 1: Assessment

```bash
# 1. Check memory status
top -l 1 -s 0 | head -12

# 2. List visible apps
osascript -e 'tell application "System Events" to get name of every process whose background only is false'

# 3. Count browser tabs
osascript -e 'tell application "Brave Browser" to return (count of tabs of every window)'
osascript -e 'tell application "Google Chrome" to return (count of tabs of every window)'
```

### Phase 2: Browser Cleanup

Close stale tabs (empty tabs, old searches, completed tasks):

```applescript
tell application "Brave Browser"
    set closedCount to 0
    repeat with w in windows
        set tabList to tabs of w
        repeat with t in tabList
            set tabURL to URL of t
            -- Close empty and stale tabs
            if tabURL contains "chrome://newtab" or tabURL contains "google.com/search" then
                close t
                set closedCount to closedCount + 1
            end if
        end repeat
    end repeat
    return "Closed " & closedCount & " tabs"
end tell
```

**Stale tab patterns** (safe to close):

| Pattern | Reason |
|---------|--------|
| `chrome://newtab` | Empty tabs |
| `google.com/search` | Old search results |
| `whatsapp.com/send` | Message links already used |
| `ticketmaster.co.za` | Event pages (time-sensitive) |

**Keep patterns** (do not auto-close):

| Pattern | Reason |
|---------|--------|
| `localhost:*` | Active dev servers |
| `vercel.com` | Deployment monitoring |
| `github.com` | Active work |
| `supabase.com` | Database management |

### Phase 3: Application Cleanup

Close idle applications safely:

```applescript
-- Close app only if no open documents
tell application "Preview"
    if (count of documents) = 0 then quit
end tell

tell application "Microsoft Word"
    if (count of documents) = 0 then quit
end tell
```

**Safe to close** (typically idle):

- ChatGPT (when using Claude)
- Preview (if no documents)
- Adobe Acrobat (if no documents)
- Calculator
- Stickies

**Never auto-close**:

- IDEs with unsaved work
- Terminal sessions
- Database clients
- Current browser

### Phase 4: IDE Window Audit

Check open IDE windows/workspaces:

```bash
# Antigravity/VS Code windows
osascript -e 'tell application "System Events" to get name of every window of process "Antigravity"'

# Count Electron processes (IDEs)
pgrep -fl "Electron" | wc -l
```

Recommend closing workspaces not touched in 24+ hours.

### Phase 5: Process Cleanup

```bash
# Find lingering node processes
pgrep -fl "node" | grep -v "claude-code\|Antigravity"

# Find orphan dev servers
lsof -i -P | grep LISTEN | grep -E "(node|next|vite)"

# Kill specific process (with confirmation)
kill -15 <PID>
```

Integrates with `/node-clean` skill for comprehensive Node.js cleanup.

### Phase 6: Memory Optimization

```bash
# Check current memory state
memory_pressure 2>/dev/null || vm_stat | head -10

# Purge inactive memory (requires sudo password)
sudo purge

# After purge, verify improvement
vm_stat | grep "Pages free"
```

## Platform Notes

### macOS (Primary)

- Uses `osascript` for application control
- `purge` command requires sudo
- `memory_pressure` shows detailed status

### Linux

```bash
# Clear page cache (requires root)
sync && echo 3 > /proc/sys/vm/drop_caches

# Check memory
free -h

# List open files by process
lsof -c chrome | wc -l
```

### Windows (WSL)

```powershell
# Close process
Stop-Process -Name "chrome" -Force

# Check memory
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10
```

## Safety Rules

1. **NEVER close apps with unsaved documents** - always check document count first
2. **NEVER kill claude-code or terminal processes** - breaks current session
3. **NEVER close localhost tabs without asking** - may be active dev work
4. **ALWAYS confirm before closing IDEs** - workspaces may have state
5. **Preserve browser tabs with form data** - user may lose input

## Example Session

```text
User: clean up resources

CIPS:
Assessment:
- Memory: 15G used, 94M free (pressure: HIGH)
- Brave tabs: 52 open
- Apps: 20 visible processes
- Node: 52 processes

Actions taken:
- Closed 10 stale Brave tabs (newtab, searches)
- Closed ChatGPT app
- Closed Preview (no documents)
- Skipped Word (has open documents)

Recommendations:
- Close unused Antigravity windows (4 detected)
- Run `sudo purge` to clear memory cache
- Consider closing Spotify if not listening

Memory freed: ~800MB estimated
```

## Token Budget

| Component | Tokens |
|-----------|--------|
| SKILL.md load | ~1200 |
| Execution | ~500-1000 |
| **Total** | **~1700-2200** |

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-12-31 | Initial creation from live session pattern |

---

⛓⟿∞
