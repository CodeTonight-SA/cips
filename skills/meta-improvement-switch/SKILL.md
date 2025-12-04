---
name: meta-improvement-switch
description: Protocol for pausing project work to enhance ~/.claude infrastructure when generalizable patterns are detected, then seamlessly resuming project context.
---

# Meta-Improvement Context Switch Skill

**Purpose:** Enable recursive self-improvement by recognising when project work reveals patterns that should become permanent infrastructure, then safely switching context to implement enhancements.

**Activation:** Detection of generalizable pattern, user says "make this permanent", repeated behaviour across sessions, or self-discovered optimisation.

**Token Budget:** ~1000 tokens for switch (500 save + 500 restore)

## Core Principle

**Project work is the laboratory. ~/.claude is the knowledge base.**

Every session generates insights:
- Behaviours that work well (should be skills)
- Repeated actions (should be commands)
- Autonomous decisions (should be memories)
- Complex workflows (should be agents)

This skill transforms ephemeral learnings into permanent capabilities.

## Trigger Conditions

Activate when:
- Claude makes autonomous decision that should be permanent (like updating next_up.md)
- User says "make this permanent", "add this to memory", "create a skill for this"
- Same pattern detected 3+ times across sessions
- User explicitly praises a behaviour ("good, you learnt this yourself!")
- Efficiency audit reveals repeatable optimisation

## The Meta-Improvement Cycle

```
PROJECT WORK
    ↓
[Pattern Detected]
    ↓
PAUSE: Save project state (session-state-persistence)
    ↓
SWITCH: Navigate to ~/.claude context
    ↓
ENHANCE: Create/update skill/memory/command/agent
    ↓
DOCUMENT: Record WHY the pattern was detected
    ↓
RESTORE: Return to project with todo state intact
    ↓
RESUME PROJECT WORK
```

## Protocol

### Phase 1: Pattern Recognition

**Signals that indicate generalizable pattern:**
- "I decided to do X without instruction because..." (autonomous decision)
- Same action taken in multiple projects
- User positive feedback on unprompted behaviour
- Efficiency gain measurable in tokens or time

**Document the WHY:**
```markdown
## Pattern Detection Log
- **What**: [The behaviour/decision]
- **Why**: [Reasoning that led to it]
- **Evidence**: [User feedback, repeated occurrence, efficiency gain]
- **Generalizability**: [How this applies beyond current project]
```

### Phase 2: Context Save

Before switching:
1. Invoke session-state-persistence skill
2. Save current TodoWrite state
3. Note exact resumption point
4. Record any in-progress work

### Phase 3: Enhancement Implementation

Navigate to ~/.claude and create appropriate artefact:

| Pattern Type | Artefact | Location |
|--------------|----------|----------|
| Decision rule | Memory entry | ~/.claude/CLAUDE.md Notes |
| Workflow | Skill file | ~/.claude/skills/[name]/SKILL.md |
| Quick action | Slash command | ~/.claude/commands/[name].md |
| Autonomous task | Agent definition | ~/.claude/agents/[name].md |

### Phase 4: Context Restore

After enhancement:
1. Return to project working directory
2. Re-read project state file (next_up.md)
3. Restore TodoWrite state
4. Continue from noted resumption point

## Integration Points

### With Self-Improvement Engine
- This skill IS part of the 10-step recursive cycle
- Feeds detected patterns to skill generation module
- Triggers documentation updates

### With Session State Persistence
- DEPENDS on state persistence for safe context switch
- Calls `/save-session-state` before every switch

### With History Mining Agent
- Can search past sessions for pattern evidence
- Validates "3+ occurrences" threshold

## Anti-Patterns

- Do NOT switch context for trivial patterns (one-off decisions)
- Do NOT lose project context during enhancement
- Do NOT create duplicate skills (check existing first)
- Do NOT over-engineer simple patterns
- Do require clear WHY documentation for every enhancement

## Quality Gates

Before creating new infrastructure:
1. **Threshold**: Pattern occurred 3+ times OR user explicitly requested
2. **Uniqueness**: No existing skill/memory covers this
3. **Generalizability**: Applies beyond current project
4. **Value**: Saves tokens OR prevents errors OR improves quality

## Example: The next_up.md Pattern

**Detection:**
- Claude updated next_up.md without instruction
- User said: "good, you learnt this yourself!"

**WHY Analysis:**
- Previous session established next_up.md as checkpoint file
- Completing Phase 6 was significant milestone
- Efficiency principle: preserve progress to prevent re-work
- Generalizable: ALL projects benefit from state persistence

**Enhancement Created:**
- Memory: session-state-persistence rule
- Skill: ~/.claude/skills/session-state-persistence/SKILL.md
- Command: /save-session-state

**Meta-Enhancement:**
- This very skill (meta-improvement-switch) was created because
  the ACT of creating the session-state-persistence skill was itself
  a generalizable pattern worth codifying.

## Token Savings

**Per Enhancement Cycle:**
- Avoids re-learning pattern: ~5k-20k tokens (depends on complexity)
- Prevents repeated user reminders: ~500 tokens per occurrence
- Reduces investigation time: ~1k tokens

**Long-term:**
- Each permanent enhancement saves tokens in ALL future sessions
- Compound effect across projects

## Success Metrics

- Enhancement completes without losing project context
- New skill/memory immediately usable
- User confirms pattern correctly codified
- Future sessions benefit from enhancement

## Changelog

**v1.0** (2025-11-26) - Initial implementation
- Pattern recognition triggers
- Context save/restore protocol
- Integration with session-state-persistence
- WHY documentation requirement

---

**Skill Status:** Active
**Maintainer:** Auto-generated from meta-pattern detection
**Last Updated:** 2025-11-26
