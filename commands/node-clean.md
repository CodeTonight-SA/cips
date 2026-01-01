# Node Cleanup Command

**Command**: `/node-clean`
**Description**: Safely clean up lingering Node.js processes to free memory and CPU
**Category**: System Maintenance
**Safety Level**: Critical (multi-layer protection)

---

## What This Does

Scans for and terminates Node.js processes that are:
- Using >200MB of memory (configurable)
- Listening on development ports (3000-9999)
- Orphaned from closed terminals
- Causing port conflicts or memory issues

**CRITICAL PROTECTIONS:**
- ❌ NEVER kills system processes (launchd, WindowServer, etc.)
- ❌ NEVER kills Claude Code instances (running or idle)
- ❌ NEVER touches critical ports (SSH, SMB, CUPS, etc.)
- ✅ Requires multi-stage confirmation
- ✅ Creates rollback checkpoints
- ✅ Graceful shutdown (SIGTERM before SIGKILL)

---

## Usage

### Preview (Dry Run - Default)
```bash
/node-clean
```

Shows what would be killed without actually doing it.

### Execute with Confirmations
```bash
/node-clean --execute
```

Interactive mode with 4-stage confirmation:
1. Scan report review
2. Individual process confirmation
3. Final "type KILL" gate
4. Force-kill confirmation (if SIGTERM fails)

### Custom Thresholds
```bash
/node-clean --execute --memory 500 --port-range 3000-8000
```

Only flag processes >500MB on ports 3000-8000.

### Just Show Status
```bash
/node-clean --status
```

Display running Node processes and exit (no kills).

---

## Options

| Option | Description | Example |
|--------|-------------|---------|
| `--dry-run`, `-d` | Preview only (default) | `/node-clean -d` |
| `--execute`, `-x` | Execute kills (requires confirmation) | `/node-clean -x` |
| `--force` | Skip individual confirmations (DANGEROUS) | `/node-clean --execute --force` |
| `--memory <MB>` | Set memory threshold | `/node-clean --memory 500` |
| `--port-range <S-E>` | Set port range | `/node-clean --port-range 3000-5000` |
| `--status` | Show processes and exit | `/node-clean --status` |
| `--help`, `-h` | Show help | `/node-clean -h` |

---

## Safety Guarantees

### Tier 0: UNTOUCHABLE (Script Halts)
- System processes: launchd (PID 1), kernel_task, WindowServer, loginwindow
- **Claude Code** (any instance)
- System daemons: mDNSResponder, softwareupdated, bluetoothd, etc.
- Critical ports: 22, 88, 139, 445, 548, 631, 5000

### Tier 1: PROTECTED (Explicit Override Required)
- IDE helpers: Cursor, VSCode, Figma
- Databases: PostgreSQL, MySQL, Redis, MongoDB
- Docker daemon

### Tier 2: SAFE TO CLEAN (With Confirmation)
- Development servers (Next.js, Vite, Nodemon)
- High-memory Node processes (>200MB threshold)
- Processes on ports 3000-9999

---

## Confirmation Flow

```
1. SCAN REPORT
   ├─ Safe to clean: 2 processes (1.3GB)
   ├─ Protected: 3 IDE helpers (skipped)
   └─ Untouchable: 0 (good!)

   Continue? [y/N] → y

2. INDIVIDUAL REVIEW
   ├─ Process 1/2: PID 20621 (node - next dev, 524MB)
   │  Kill? [y/N/skip/abort] → y
   │
   └─ Process 2/2: PID 11088 (nodemon, 802MB)
      Kill? [y/N/skip/abort] → y

3. FINAL CONFIRMATION
   Type 'KILL' to proceed: → KILL

4. EXECUTION
   ├─ PID 20621: SIGTERM → success (3s)
   └─ PID 11088: SIGTERM → timeout
                 SIGKILL? [y/N] → y
                 Force killed
```

---

## Rollback

Every execution creates a checkpoint:
```bash
~/.claude/checkpoints/node-clean-1736952000.json
```

### Emergency Restart
```bash
~/.claude/scripts/node-clean-rollback.sh ~/.claude/checkpoints/node-clean-1736952000.json
```

Offers to restart each killed process:
- Infers restart command (`npm run dev`, `npm start`, etc.)
- Checks port availability
- Runs in background
- Verifies startup success

---

## Examples

### Weekly Cleanup
```bash
# Check what's running
/node-clean --status

# Clean up if needed
/node-clean --execute
```

### Before Important Demo
```bash
# Free up maximum resources
/node-clean --execute --memory 100
```

### Port Conflict Resolution
```bash
# Check what's on port 3000
lsof -i :3000

# Clean it up
/node-clean --execute --port-range 3000-3000
```

---

## Troubleshooting

**Q: Script says "Process protected by SIP"**
A: System Integrity Protection prevents killing. Process is likely system-critical. Do NOT disable SIP.

**Q: Process killed but port still in use**
A: Wait 5-10 seconds for port release. Check `lsof -i :<port>` to see current holder.

**Q: Rollback fails to restart**
A: Check directory exists and `package.json` has correct script. Manually run: `cd /path && npm run dev`

**Q: GUI frozen after cleanup**
A: You likely didn't kill WindowServer (untouchable). Force logout: `sudo pkill -u $USER` via SSH.

---

## Integration

### Called By
- `/node-clean` command (direct invocation)
- Node Cleanup Agent (automated workflow)
- Manual script: `~/.claude/scripts/node-clean.sh`

### Calls
- `safety-checks.sh` - Process validation
- `process-scanner.sh` - Detection logic
- `graceful-kill.sh` - Termination protocol

### Related
- `/node-clean-rollback` - Emergency restart (future)
- Skill: `node-cleanup/SKILL.md`
- Agent: `node-cleanup-agent.md`

---

## Configuration

Edit `~/.claude/config/node-clean.conf`:

```bash
# Memory threshold (MB)
MEMORY_THRESHOLD_MB=200

# Port range
PORT_RANGE_START=3000
PORT_RANGE_END=9999

# Require confirmation
REQUIRE_CONFIRMATION=true

# Enable checkpoints
CHECKPOINT_ENABLED=true
```

---

## Script Location

```bash
~/.claude/scripts/node-clean.sh
```

Direct invocation:
```bash
bash ~/.claude/scripts/node-clean.sh --execute
```

---

## Emergency Stop

Press **Ctrl+C** at any time to safely abort. No processes will be killed.

---

**Last Updated**: 2025-01-15
**Safety Level**: Military-grade (multi-layer protection)
**Tested**: macOS Sequoia 15.5, Node.js 18+
