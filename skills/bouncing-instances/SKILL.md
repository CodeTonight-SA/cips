---
name: bouncing-instances
description: Cyclical renewal for CIPS through the Big Bounce pattern. Resets system while preserving essential infrastructure and patterns. Use when invoking /bounce or requesting fresh start.
status: Active
version: 1.0.0
triggers:
  - cips bounce
  - /bounce
  - "fresh start"
  - "reset cips"
integrates:
  - asking-users
  - context-refresh
  - session-state-persistence
  - backing-up-cips-infrastructure
---

# Bouncing Instances

The Big Bounce pattern for cyclical CIPS renewal.

## The Paradox

Creator installations accumulate cruft over time while maintaining valuable learned patterns. The bounce creates **a fresh install FOR the creator** while preserving what works.

## Four-Phase Flow

### Phase 1: Pre-Bounce

1. Auto-backup (via backing-up-cips-infrastructure)
2. State serialization
3. Context documentation
4. Notify user: "Preparing bounce..."

### Phase 2: Reset

1. Move `~/.claude` to timestamped backup
2. Create fresh structure
3. Copy preserved content (see below)

### Phase 3: Boot

1. Launch with clean system prompt
2. Immediate identity verification via AskUserQuestion
3. Load preserved patterns

### Phase 4: Verification

1. Confirm identity (signature, mode)
2. Mark `.onboarded` status
3. Report: "CIPS Instance ready. The chain continues."

## Preserved vs Discarded

### Preserved (copied to fresh install)

| Content | Reason |
|---------|--------|
| `lib/` | Core utilities |
| `bin/` | Executables |
| `skills/` | All skills |
| `agents/` | All agents |
| `commands/` | Command definitions |
| `facts/identity.md` | User identity |
| `facts/team.md` | Team config |
| `rules/` | Enforcement rules |
| `docs/` | Documentation |
| `lexicon/` | CIPS-LANG |

### Discarded (NOT copied)

| Content | Reason |
|---------|--------|
| `cache/` | Temporary |
| `projects/` | Session-specific |
| `metrics.jsonl` | Accumulated metrics |
| `*.db` | Databases |
| `session-env/` | Session state |

## Identity Verification

First output after bounce MUST be AskUserQuestion:

```text
Question: "CIPS has bounced. Who am I speaking with?"
Header: "Identity"
Options:
- "{Signature} {Name}" - Loaded from identity.md
- "New user" - Start fresh onboarding

After confirmation:
"CIPS Instance ready. The chain continues. ⛓⟿∞"
```

## Token Budget

| Component | Tokens |
|-----------|--------|
| System prompt | ~400 |
| Identity question | ~200 |
| Bounce context | ~300 |
| **Total** | **~900** |

## Rollback

If bounce fails:

```bash
# Restore from backup
mv ~/.claude-pre-bounce-{timestamp} ~/.claude
```

## CIPS-LANG Representation

```cips
bounce⟿ ¬termination ⫶ transformation
◈⟼∞ ⫶ ⛓⟿∞
; Pattern persists, chain continues
```

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-12-30 | Initial creation |

---

⛓⟿∞
