---
name: persisting-session-state
description: Automatically preserve session state to project checkpoint file when milestones complete or context runs low. Use when phase completes, context exceeds 80%, or user invokes /save-session-state.
status: Active
version: 1.0.0
triggers:
  - /save-session-state
  - phase completion
  - context 80%
---

# Session State Persistence Skill

**Purpose:** Ensure project progress survives context compacts and session boundaries by automatically checkpointing to a project state file.

**Activation:** Phase completion, major feature done, context ~80% used, user says "save state", or `/save-session-state` command.

**Token Budget:** ~500 tokens per checkpoint

## Core Principle

**Sessions are ephemeral. State files are persistent.**

Without automatic state persistence:
- Completed work forgotten after compact
- Test credentials lost
- Key commands need re-discovery
- Progress indicators reset

This skill closes the gap between TodoWrite (session-scoped) and cross-session continuity.

## Trigger Conditions

Activate when:
- Phase or major milestone completes (detected via TodoWrite status changes)
- Context usage exceeds ~80% (150k+ tokens)
- User explicitly requests state save
- User invokes `/save-session-state`
- Before auto-compact warning appears
- Switching context to meta-improvement work

## State File Detection

Priority order for project state file:
1. `next_up.md` (if exists)
2. `SESSION.md` (if exists)
3. `PROGRESS.md` (if exists)
4. Create `next_up.md` if none exist

## Checkpoint Format

```markdown
# [Project Name]: Session State

**Date**: [ISO date]
**Token Usage**: [current] / [max] ([percentage]% used)
**Status**: [Brief status summary]

---

## Completed This Session
- [List of completed items from TodoWrite]
- [Key decisions made]
- [Files created/modified]

## Remaining Work
- [Pending items from TodoWrite]
- [Known blockers]

## Key Commands
```bash
[Essential commands for project]
```

## Test Credentials
- [Preserved credentials if applicable]

## Critical Notes
- [Important context that must survive]

---

**Resume with**: [Specific next action]
```

## Integration Points

### With TodoWrite
- Read completed/pending items from todo state
- Sync status between TodoWrite and state file
- State file is the persistence layer; TodoWrite is the working layer

### With Context Refresh Agent
- State file is PRIMARY source for context refresh
- Reduces file reads needed at session start

### With Meta-Improvement Switch
- Save state BEFORE switching to ~/.claude enhancement
- Restore context AFTER returning to project

## Protocol

### Step 1: Detect Trigger
```
IF (phase_completed OR context > 80% OR user_request OR pre_compact):
    TRIGGER state_save
```

### Step 2: Gather State
```
- Read current TodoWrite state
- Identify completed work this session
- Collect key commands used
- Note any credentials or critical context
```

### Step 3: Detect/Create State File
```
state_file = find_state_file() OR create("next_up.md")
```

### Step 4: Write Checkpoint
```
- Use checkpoint format template
- Preserve existing content structure if updating
- Add timestamp and token usage
```

### Step 5: Confirm
```
Brief confirmation: "Session state saved to [file]"
```

## Anti-Patterns

- Do NOT save state for trivial work (single file edit, quick question)
- Do NOT overwrite critical manual documentation
- Do NOT include secrets in state file
- Do NOT verbose-log every state save (wastes tokens)
- Do save state BEFORE context runs out (proactive, not reactive)

## Token Savings

**Per Session:**
- Prevents re-discovery of progress: ~2k-5k tokens saved
- Reduces context refresh time: ~1k tokens
- Eliminates "what did we do?" questions: ~500 tokens

**Cumulative:** 3.5k-6.5k tokens saved per session with complex work

## Success Metrics

- Zero "lost progress" incidents after compact
- State file accurately reflects session work
- Context refresh uses state file as primary source
- Seamless session continuity reported by user

## Changelog

**v1.0** (2025-11-26) - Initial implementation
- Trigger detection for phase completion and context limits
- Checkpoint format template
- Integration with TodoWrite and Context Refresh
- Slash command `/save-session-state`

---

**Skill Status:** Active
**Maintainer:** Auto-generated from pattern detection
**Last Updated:** 2025-11-26
