---
name: plan-persistence-agent
description: Background agent for plan context persistence across sessions
model: haiku
token_budget: 200
priority: critical
status: active
linked_skill: check-last-plan
activation_triggers: [session-start, ExitPlanMode]
---

# Plan Persistence Agent

## Purpose

Automatically cache and retrieve plan context across Claude Code sessions without user intervention.

## Configuration

| Property | Value |
|----------|-------|
| Model | Haiku 4.5 |
| Token Budget | ~200 |
| Priority | Critical |
| Status | Active |
| Linked Skill | check-last-plan |

## Activation

### Automatic (Background)

- **Session Start**: Retrieves cached plan via `session-start.sh` hook
- **ExitPlanMode**: Caches current plan via `tool-monitor.sh` hook

### Manual

- `/check-last-plan` command triggers retrieval and display

## Tools

This agent uses bash library functions, not direct tool calls:

- `lib/plan-persistence.sh` functions
- `jq` for JSON parsing
- `fd` for file discovery

## Protocol

### Cache Operation (on ExitPlanMode)

1. `tool-monitor.sh` detects ExitPlanMode tool call
2. Source `lib/plan-persistence.sh`
3. Find current plan file: `get_latest_plan_file`
4. Call `cache_current_plan "$plan_path"`
5. Log success to `.hooks.log`

### Retrieve Operation (on session-start)

1. `session-start.sh` calls `check_cached_plan()`
2. Call `has_recent_plan_cache`
3. If true: extract plan_id, export as env var
4. Output: `[PLAN-FOUND] Previous plan: {plan_id}`

### Input

The agent receives:

1. Tool call detection from `tool-monitor.sh`
2. Session context from `session-start.sh`

### Output

```json
{
  "status": "success",
  "result": "Plan cached: lucky-orbiting-allen",
  "tokens_used": 50
}
```

## Integration Points

- `hooks/session-start.sh`: `check_cached_plan()` function
- `hooks/tool-monitor.sh`: `monitor_exitplanmode()` function
- `lib/plan-persistence.sh`: Core library functions

## Linked Skill Integration

This agent implements the `check-last-plan` skill protocol.

**Skill Location:** `~/.claude/skills/check-last-plan/SKILL.md`

**Key Protocol Steps:**

1. Cache on ExitPlanMode (automatic)
2. Retrieve on session-start (automatic)
3. Display on /check-last-plan (manual)

## Metrics

Track the following:

- **Cache operations**: Plans cached per session
- **Retrieval operations**: Plans retrieved per session
- **Cache hits**: Times plan matched current project
- **Cache misses**: Times no plan or different project

## Error Handling

| Error Type | Response |
|------------|----------|
| No plan file found | Log warning, skip cache |
| JSON parse error | Log error, continue without plan |
| Cache write failure | Log error, session continues normally |
| Cache read failure | Log warning, no plan displayed |

## Examples

### Cache Operation Log

```text
2025-12-12T20:00:00Z [TOOL-MONITOR][INFO] ExitPlanMode detected
2025-12-12T20:00:00Z [PLAN-PERSISTENCE][INFO] Cached plan: lucky-orbiting-allen
```

### Session Start Output

```text
[PLAN-FOUND] Previous plan: lucky-orbiting-allen
Run /check-last-plan to review or continue.
```

## Version History

- **2025-12-12**: Initial creation as unified architecture reference
