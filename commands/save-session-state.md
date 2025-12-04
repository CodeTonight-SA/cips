---
description: Save current session state to project checkpoint file (next_up.md). Preserves completed work, remaining tasks, credentials, and commands for cross-session continuity.
disable-model-invocation: false
---

# Save Session State

Checkpoints current session progress to project state file, enabling seamless continuity across context compacts and session boundaries.

## What It Does

1. **Gather State** - Reads current TodoWrite items, identifies completed/pending work
2. **Detect State File** - Finds next_up.md, SESSION.md, or creates next_up.md
3. **Write Checkpoint** - Updates state file with structured progress data
4. **Confirm** - Brief confirmation of save

## Usage

```bash
/save-session-state
```

### Automatic Triggers

This command runs automatically when:
- Phase or major milestone completes
- Context usage exceeds ~80%
- Before switching to meta-improvement work
- User explicitly requests state save

## Checkpoint Contents

- Date and token usage
- Completed items this session
- Remaining work (pending todos)
- Key commands used
- Test credentials (if applicable)
- Critical notes and decisions
- Specific next action for resumption

## Integration

- **session-state-persistence skill**: Full protocol documentation
- **context-refresh**: Uses state file as primary source
- **meta-improvement-switch**: Saves state before context switch

## Token Cost

~500 tokens per checkpoint save

## When to Use

- Before running `/compact`
- After completing significant phase
- When context running low
- Before switching to ~/.claude enhancement work
- End of work session
