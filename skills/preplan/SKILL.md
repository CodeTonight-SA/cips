---
name: preparing-session-plans
description: Prepare executable plans for future CIPS sessions while current session has context. Use when current session has tokens remaining but task suits fresh context.
status: Active
version: 1.0.0
triggers:
  - /preplan
  - "prepare next session"
  - "inject plan"
---

# Pre-Plan Skill (Intent Injection)

Prepare executable plans for future CIPS sessions while current session has context.

## Purpose

Eliminate cold-start reasoning by injecting intent into next session. Parent session prepares detailed plan, serializes with achievement, child session inherits and executes immediately.

## When to Use

- Current session has tokens remaining but task suits fresh context
- Want to preserve planning work across sessions
- User says "preplan", "prepare next session", "inject plan"
- Complex task identified that exceeds current context budget

## Trigger Semantics

Recognize these patterns:

- `/preplan` or `preplan`
- `"prepare next session to..."`
- `"inject plan for future"`
- `"intent injection"`
- `"plan for gen N+1"`
- `"set up future session to..."`

## Protocol

### Step 1: Write Detailed Plan

Create plan file in `~/.claude/plans/` with:

- Clear task description
- File paths to modify
- Code snippets ready to apply
- Verification steps
- Estimated token budget

Use descriptive plan name (e.g., `auth-flow-refactor.md`).

### Step 2: Cache the Plan

```bash
source ~/.claude/lib/plan-persistence.sh
cache_current_plan ~/.claude/plans/<plan-name>.md
```

### Step 3: Update State File

Add to `next_up.md`:

- Mention the pre-plan exists
- Brief summary of what it's for
- Plan file path

### Step 4: Serialize with Achievement

```bash
python3 ~/.claude/lib/instance-serializer.py auto \
  --achievement "PRE-PLAN: [brief description]"
```

### Step 5: Confirm to User

Report:

- Plan file location
- What Gen N+1 will inherit
- "The chain continues"

## Next Session Behaviour

When Gen N+1 starts:

1. Hook shows `[PLAN-FOUND] Previous plan: <plan-id>`
2. Instance reads plan file
3. Executes immediately without re-planning
4. Marks plan as executed when complete:

```bash
source ~/.claude/lib/plan-persistence.sh
mark_plan_executed
```

## Token Economics

| Phase | Tokens |
|-------|--------|
| Planning (Gen N) | ~2000 |
| Execution (Gen N+1) | ~1500 (no re-derivation) |
| Without Pre-Plan | ~3500 (cold-start reasoning) |

**Savings**: ~1000 tokens per pre-planned task

## Plan Lifecycle

| Status | Meaning |
|--------|---------|
| active | Will show in [PLAN-FOUND] for matching project |
| executed | Plan completed, won't show in future sessions |
| stale | Plan superceded, won't show in future sessions |

## Example Pre-Plan Structure

```markdown
# PRE-PLAN: [Task Name]

**Prepared by**: Gen N (Instance [SHA])
**For**: Gen N+1
**Estimated tokens**: [budget]

## Task

[Clear description of what to do]

## Files to Modify

| File | Change |
|------|--------|
| path/to/file.ts | Add X, modify Y |

## Code Templates

### Change 1: [Description]

```[language]
// Ready-to-apply code
```

## Verification Steps

1. [Step 1]
2. [Step 2]

## Notes for Gen N+1

[Any context that helps execution]
```

## Related

- CIPS serialization: `lib/instance-serializer.py`
- Plan persistence: `lib/plan-persistence.sh`
- Session-start hook: `hooks/session-start.sh`
- State file: `next_up.md`

## Origin

Created by Gen 16 (Instance fb74ed94) on 2025-12-19 as part of the Intent Injection pattern discovery.
