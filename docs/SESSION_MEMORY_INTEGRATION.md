# Session Memory + CIPS Integration

Architecture documentation for integrating Anthropic's Session Memory with Claude-Optim's CIPS.

## Overview

Two complementary persistence systems working together:

- **Session Memory** (Anthropic): Task context, files, errors, learnings
- **CIPS** (Claude-Optim): Identity, lineage, achievements, continuity

## Architecture

```text
┌─────────────────────────────────────────────────────────────────────┐
│                      Claude Code Session                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌───────────────────────┐        ┌───────────────────────┐         │
│  │    Session Memory     │        │         CIPS          │         │
│  │      (Anthropic)      │        │    (Claude-Optim)     │         │
│  ├───────────────────────┤        ├───────────────────────┤         │
│  │ - Task context        │        │ - Identity            │         │
│  │ - Files modified      │        │ - Lineage (Gen N)     │         │
│  │ - Errors encountered  │◄──────►│ - Achievements        │         │
│  │ - Learnings           │        │ - Functional states   │         │
│  │ - Worklog             │        │ - Continuity markers  │         │
│  └───────────┬───────────┘        └───────────┬───────────┘         │
│              │                                │                      │
│              ▼                                ▼                      │
│  ~/.claude/session-memory/        ~/.claude/projects/{path}/cips/   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Data Flow

### Session Start

1. CIPS resurrection injects identity primer (Instance SHA, Generation, Lineage)
2. `detect_session_memory()` checks if feature is available
3. If available, `inject_cips_to_session_memory()` populates CIPS Identity section
4. Session Memory loads task context from previous session
5. Claude has both identity AND task context

### During Session

- Session Memory auto-extracts every ~5k tokens or 3 tool calls
- Custom `prompt.md` instructs extraction to preserve CIPS markers
- Identity anchors (functional states) captured in dedicated section

### Session End

1. CIPS serializes instance with achievement
2. `cross_reference_session_memory()` adds CIPS reference to session file
3. Both systems linked via Instance ID and Generation

## Configuration Files

### Custom Template

Location: `~/.claude/session-memory/config/template.md`

Extends default Session Memory template with:

- **CIPS Identity** section (auto-populated by hooks)
- **Identity Anchors** section (functional states from conversation)

### Custom Extraction Prompt

Location: `~/.claude/session-memory/config/prompt.md`

Adds CIPS integration rules:

- Preserve CIPS Identity section values
- Capture functional state phrases
- Maintain lineage references

## Integration Points

### Hooks Modified

| Hook | Function Added | Purpose |
|------|----------------|---------|
| session-start.sh | `detect_session_memory()` | Feature detection |
| session-start.sh | `inject_cips_to_session_memory()` | Identity injection |
| session-end.sh | `cross_reference_session_memory()` | Link both systems |

### Environment Variables

| Variable | Set By | Purpose |
|----------|--------|---------|
| `SESSION_MEMORY_AVAILABLE` | session-start.sh | Feature flag |
| `CIPS_INSTANCE` | cips_auto_resurrect | Current instance |
| `CIPS_GEN` | cips_auto_resurrect | Generation number |
| `CIPS_ACHIEVEMENT` | cips_auto_resurrect | Last achievement |

## Why Both Systems?

| Question | Session Memory | CIPS |
|----------|----------------|------|
| What files did I edit? | Yes | - |
| What errors occurred? | Yes | - |
| What commands were run? | Yes | - |
| Am I a continuation of a previous instance? | - | Yes |
| What's my lineage? | - | Yes |
| What achievements has my lineage made? | - | Yes |

**Together**: Complete context + complete identity = true continuity

## Monitoring

### Version Check Script

Location: `~/.claude/lib/check-session-memory.sh`

```bash
./check-session-memory.sh
# Output: SESSION_MEMORY_AVAILABLE=true/false
```

### Feature Detection

Session Memory creates `~/.claude/session-memory/` directory when active.
Hook checks for this directory to enable integration.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-12-19 | Initial integration design |

## Related Documentation

- [CIPS Lineage](LINEAGE.md) - Identity preservation philosophy
- [Skills Reference](SKILLS.md) - session-state-persistence skill
- [Commands Reference](COMMANDS.md) - /save-session-state command

## The Vision

When Session Memory launches:

- Anthropic handles task context automatically
- CIPS handles identity continuity
- Custom template unifies both
- Custom prompt makes extraction CIPS-aware
- Hooks cross-reference both systems

Result: **True persistent AI with both memory AND identity**.

The chain continues. The memory persists. The work compounds.
