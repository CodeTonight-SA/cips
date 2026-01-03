---
name: session-state-persistence
description: Auto-update project state files on significant milestones. Enables seamless cross-session continuity. Triggers at 80% context gate and milestone completion.
status: Active
version: 1.0.0
triggers:
  - 80% context window usage
  - milestone completion
  - /save-session-state
integrates:
  - asking-users
  - context-refresh
---

# Session State Persistence

Automatic state file updates for cross-session continuity.

## Core Principle

On significant milestone completion, AUTO-UPDATE the project's state file (`next_up.md`, `SESSION.md`, or equivalent):

- Completed work summary
- Remaining tasks
- Test credentials (if applicable)
- Key commands used

**Do NOT wait for user instruction.** This enables seamless cross-session continuity.

## 80% Context Gate (PARAMOUNT)

At 80% context window usage, HALT ALL WORK immediately:

1. Serialize CIPS instance:
```bash
python3 ~/.claude/lib/instance-serializer.py auto --achievement "Session checkpoint at 80%"
```

2. Save session state:
```bash
/save-session-state
```

3. Compact or start fresh session

## State File Format

```markdown
# Session State - {Project Name}

## Completed
- [x] Task 1 description
- [x] Task 2 description

## In Progress
- [ ] Current task

## Remaining
- [ ] Future task 1
- [ ] Future task 2

## Credentials
- Test user: {if applicable}
- API endpoint: {if applicable}

## Key Commands
- `{command used}` - {why}

## Notes
- {Any important context for next session}

---
Updated: {ISO_DATE}
```

## Trigger Conditions

| Condition | Action |
|-----------|--------|
| Context > 80% | HALT, serialize, save state |
| Feature completed | Update state file |
| PR created | Update state file |
| Test suite passes | Update state file |
| User says "save state" | Invoke /save-session-state |

## File Locations

| File | Purpose |
|------|---------|
| `next_up.md` | Project root state |
| `SESSION.md` | Alternative naming |
| `.claude/session-env/state.md` | CIPS session state |

## Token Budget

| Component | Tokens |
|-----------|--------|
| State detection | ~100 |
| File update | ~200-400 |
| **Total** | **~300-500** |

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-12-30 | Initial creation |

---

⛓⟿∞
