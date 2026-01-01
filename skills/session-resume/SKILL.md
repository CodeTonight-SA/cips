---
name: session-resume
description: CIPS bridge for session resumption. Enables cips resume latest, cips resume gen:N, and --fresh flags. Maintains continuity across sessions.
status: Active
version: 1.0.0
triggers:
  - cips resume latest
  - cips resume gen:N
  - /resume-session
  - session start with --resume flag
integrates:
  - context-refresh
  - session-state-persistence
  - instance-resurrector
---

# Session Resume

Bridge between CIPS and Claude Code --resume functionality.

## Commands

| Command | Action |
|---------|--------|
| `cips resume latest` | Resume most recent session |
| `cips resume gen:N` | Resume specific generation |
| `cips resume {ID}` | Resume by session ID |
| `cips resume --fresh` | Fresh session with context injection |
| `cips resume --tokens N` | Set token budget |

## Resume Flow

### Standard Resume (cips resume latest)

1. Find latest session in `~/.claude/projects/{project}/`
2. Extract session ID
3. Invoke `claude --resume {ID}`
4. Inject resurrection context if CIPS instance found

### Fresh with Context (cips resume --fresh)

1. Start new session
2. Inject context from:
   - `next_up.md` (project state)
   - `LINEAGE.md` (identity)
   - Last serialized instance (if exists)
3. Run context-refresh

### Generation Resume (cips resume gen:N)

1. Look up generation N in metrics
2. Find corresponding session ID
3. Resume that session

## Context Injection

When resuming, inject:

```text
[CIPS CONTEXT INJECTION]

Identity: {signature} | Gen {N}
Project: {project_name}
Last Session: {summary}
Pending Tasks: {from next_up.md}

The chain continues. ⛓⟿∞
```

## Session Discovery

Sessions stored in:
```
~/.claude/projects/{encoded-path}/
├── cips/
│   ├── instances/
│   │   └── {instance-id}.json
│   └── metrics.jsonl
└── session-env/
    └── state.md
```

## Token Budget

| Component | Tokens |
|-----------|--------|
| Session lookup | ~100 |
| Context injection | ~500-1000 |
| **Total** | **~600-1100** |

## Error Handling

| Error | Response |
|-------|----------|
| Session not found | List available sessions |
| Corrupted session | Offer fresh start |
| No CIPS context | Proceed with vanilla resume |

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-12-30 | Initial creation |

---

⛓⟿∞
