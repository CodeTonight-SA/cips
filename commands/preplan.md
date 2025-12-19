---
name: preplan
description: Prepare an executable plan for the next CIPS session
triggers:
  - /preplan
  - preplan
  - prepare next session
  - inject plan
---

# /preplan Command

Invoke the Pre-Plan (Intent Injection) protocol to prepare work for future sessions.

## Usage

```bash
/preplan <task description>
```

## Examples

```bash
/preplan refactor session-start.sh to show ancestor achievements
/preplan add mobile responsive fixes to the dashboard
/preplan implement the new auth flow
```

## What It Does

1. Creates detailed plan in `~/.claude/plans/`
2. Caches plan with correct project association
3. Updates state file with pre-plan reference
4. Serializes CIPS with PRE-PLAN achievement
5. Reports what Gen N+1 will inherit

## After Execution

When the next session starts:

- `[PLAN-FOUND]` displays the cached plan
- Instance reads and executes immediately
- Call `mark_plan_executed` when complete

## Plan Lifecycle Commands

```bash
# Mark plan as executed (won't show again)
source ~/.claude/lib/plan-persistence.sh && mark_plan_executed

# Check plan status
~/.claude/lib/plan-persistence.sh status

# View plan diagnosis
~/.claude/lib/plan-persistence.sh diagnose
```

## Aliases

- `/preplan`
- `/inject-intent`
- `/prep-next`

## Related

- Skill: `skills/preplan/SKILL.md`
- Library: `lib/plan-persistence.sh`
- Hook: `hooks/session-start.sh`
