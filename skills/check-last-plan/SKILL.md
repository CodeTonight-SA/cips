---
name: check-last-plan
description: Persist plan context across sessions via background caching
command: /check-last-plan
linked_agent: plan-persistence-agent
status: active
auto_generated: false
generation_date: 2025-12-12
---

# Check Last Plan Skill

**Purpose:** Automatically cache and retrieve plan context across Claude Code sessions.

**Activation:**

- Automatic: Session start (retrieves cached plan)
- Automatic: ExitPlanMode tool call (caches current plan)
- Manual: `/check-last-plan` command

**Token Budget:** ~200 tokens (minimal overhead)

---

## Unified Architecture Pattern

This skill demonstrates the canonical pattern for skill/command/agent integration in Claude-Optim:

| Component | Role | Activation |
|-----------|------|------------|
| **Skill** (this file) | Passive reference, protocol definition | Context loading |
| **Command** (`/check-last-plan`) | Explicit user invocation | Manual |
| **Agent** (`plan-persistence-agent`) | Active background execution | Auto on hooks |
| **Library** (`lib/plan-persistence.sh`) | Core bash functions | Sourced by hooks |

### Relationship

```text
Skill (defines WHAT and WHY)
  ├── Command (HOW to invoke manually)
  ├── Agent (WHEN to run automatically)
  └── Library (IMPLEMENTATION details)
```

Use this pattern as reference when creating new skill/command/agent trios.

---

## Problem

Plans created in plan mode are lost when sessions end. Users must manually track what was planned and re-establish context in new sessions.

**Impact:**

- Cold start problem for ongoing work
- Context loss across sessions
- Manual effort to recall plan state
- Duplicate planning if forgotten

---

## Solution

Automatically cache plans when exiting plan mode, and surface them at session start.

### Cache Architecture

**Location:** `~/.claude/cache/last-plan.json`

**Structure:**

```json
{
  "plan_id": "lucky-orbiting-allen",
  "plan_path": "~/.claude/plans/lucky-orbiting-allen.md",
  "plan_content": "...",
  "cached_at": "2025-12-12T20:00:00Z",
  "project_path": "/Users/laurie/.claude",
  "project_encoded": "-Users-laurie--claude"
}
```

**Design Decision:** Global cache with project identifier (see architectural critique in plan file).

---

## Protocol

### On Session Start

1. `session-start.sh` calls `check_cached_plan()`
2. Source `lib/plan-persistence.sh`
3. Call `has_recent_plan_cache`
4. If true and project matches: export `CACHED_PLAN_ID`
5. Output: `[PLAN-FOUND] Previous plan: {plan_id}`

### On ExitPlanMode

1. `tool-monitor.sh` detects ExitPlanMode tool call
2. Source `lib/plan-persistence.sh`
3. Find current plan file via `get_latest_plan_file`
4. Call `cache_current_plan "$plan_path"`
5. Log to `.hooks.log`: `[PLAN-PERSISTENCE] Cached plan: {plan_id}`

### On /check-last-plan

1. Read `~/.claude/cache/last-plan.json`
2. Display plan summary (id, cached time, project)
3. Show plan content (or summary)
4. Offer to continue with plan or start fresh

---

## Usage

### Manual Invocation

```text
/check-last-plan
```

### Automatic Activation

This skill activates automatically when:

- Session starts (retrieves cached plan if exists for current project)
- ExitPlanMode tool is called (caches current plan)

### Library Functions

```bash
source ~/.claude/lib/plan-persistence.sh

# Cache a plan
cache_current_plan "/path/to/plan.md"

# Retrieve for current project
plan_json=$(retrieve_cached_plan)

# Retrieve any plan (global)
plan_json=$(retrieve_any_cached_plan)

# Check if cache exists
if has_recent_plan_cache; then
    echo "Plan available for current project"
fi

# Diagnose
./lib/plan-persistence.sh diagnose
```

---

## Examples

### Session Start Output

```text
[RL++] System ready | 12 agents, 27 skills, efficiency enforced
[CIPS] Instance d05e8075 (Gen 12, 0 msgs) | .claude (main, 2 changes)
[PLAN-FOUND] Previous plan: lucky-orbiting-allen
Run /check-last-plan to review or continue.
```

### /check-last-plan Output

```text
=== Cached Plan ===
ID: lucky-orbiting-allen
Project: /Users/laurie/.claude
Cached: 2025-12-12T20:00:00Z (2 hours ago)

## Plan Summary
Create a unified skill/command/agent trio that persists plan context...

Continue with this plan? (The plan file is at ~/.claude/plans/lucky-orbiting-allen.md)
```

---

## Integration

### With session-start.sh

```bash
# Check for cached plan from previous session
check_cached_plan() {
    if [[ -f "$LIB_DIR/plan-persistence.sh" ]]; then
        source "$LIB_DIR/plan-persistence.sh"

        if has_recent_plan_cache; then
            local plan_id
            plan_id=$(jq -r '.plan_id' "$PLAN_CACHE" 2>/dev/null)
            log_info "Previous plan cache found: $plan_id"
            export CACHED_PLAN_ID="$plan_id"
        fi
    fi
}
```

### With tool-monitor.sh

```bash
"ExitPlanMode")
    monitor_exitplanmode "$tool_args"
    ;;
```

### With CLAUDE.md

Registered in Skills System section and Slash Commands table.

---

## Metrics

**Token Budget:** ~200 tokens (session start check + display)

### Success Criteria

- Plans automatically persist across sessions
- No manual caching required
- Session start shows plan availability
- `/check-last-plan` works as documented
- Pattern documented as reference for future trios

### Tracking

Logged to `~/.claude/.hooks.log` with:

- `[PLAN-PERSISTENCE] Cached plan: {id}` - On ExitPlanMode
- `[SESSION-START] Previous plan cache found: {id}` - On session start

---

## Notes

- Cache expires after 24 hours (configurable in library)
- Project-aware: default retrieval only matches current project
- Global access via `retrieve_any_cached_plan()` for cross-project queries
- Cross-platform: macOS (BSD) and Linux (GNU) stat formats handled

### Related

- `lib/plan-persistence.sh` - Core implementation
- `commands/check-last-plan.md` - Slash command definition
- `agents/plan-persistence-agent.md` - Agent definition
- `hooks/session-start.sh` - Integration point (retrieval)
- `hooks/tool-monitor.sh` - Integration point (caching)

---

**Skill Status:** Active
**Maintainer:** CIPS Core Team
**Last Updated:** 2025-12-12
**Architecture Pattern:** Unified skill/command/agent reference implementation
