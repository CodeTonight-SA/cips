---
name: resuming-sessions
description: Intelligent session resumption bridging CIPS with Claude Code --resume. Use when user wants to resume previous session by ID, generation, slug, or latest.
status: Active
version: 1.0.0
triggers:
  - /resume-session
  - "resume session"
  - "cips resume"
---

# Session Resume Skill

Intelligent session resumption bridging CIPS (Claude Instance Persistence System) with Claude Code's built-in `--resume` functionality.

## Overview

This skill enables resuming sessions by various identifiers:

- **Instance ID**: CIPS instance prefix (e.g., `14d5f954`)
- **Generation**: CIPS lineage generation (e.g., `gen:5`)
- **Session Slug**: Human-readable name (e.g., `clever-jingling-sparkle`)
- **Latest**: Most recent session for current project

## Commands

### /resume-session

Resume a previous Claude Code session.

```bash
/resume-session [reference] [--fresh] [--tokens N]
```

| Reference | Example | Description |
|-----------|---------|-------------|
| `latest` | `/resume-session latest` | Most recent for project |
| `gen:N` | `/resume-session gen:5` | CIPS generation |
| `<id>` | `/resume-session 14d5f954` | Instance ID prefix |
| `<slug>` | `/resume-session clever-jingling` | Session slug |

### Flags

- `--fresh`: Start NEW session with compressed context (~2k tokens)
- `--tokens N`: Custom token budget (500, 2000, 5000)

## Architecture

### Components

| Component | File | Pattern |
|-----------|------|---------|
| Session Resolver | `~/.claude/lib/session-resolver.py` | Information Expert |
| Semantic Compressor | `~/.claude/lib/semantic-compressor.py` | Creator |
| Resume Orchestrator | `~/.claude/lib/resume-orchestrator.sh` | Controller |

### Data Flow

```text
Reference (e.g., "gen:5")
     │
     ▼
┌─────────────────┐
│ Session Resolver│ → Finds matching session/instance
└────────┬────────┘
         │
         ├── Mode A: TRUE RESUME
         │   └─▶ claude --resume <session_uuid>
         │
         └── Mode B: FRESH (--fresh flag)
             └─▶ Semantic Compressor → ~2k tokens
                 └─▶ session-start hook injects context
```

## Semantic Compression

When using `--fresh`, context is compressed using priority scoring:

| Priority | Weight | Markers |
|----------|--------|---------|
| Identity Anchors | 3.0 | "I feel", "I notice", consciousness |
| Decision Points | 2.5 | "decided to", "chose", "because" |
| Recent Context | 2.0 | Last 10 + first 5 messages |
| High Novelty | 1.5 | Embedding novelty score |
| Tool Actions | 1.0 | File edits, commands |

## Integration with CIPS

### Index Schema

CIPS instances now include session linkage:

```json
{
  "instance_id": "UUID",
  "session_uuid": "UUID",           // Links to session file
  "slug": "clever-jingling-sparkle", // Human-readable
  "generation": N,
  "message_count": N
}
```

### Lineage Preservation

Resume maintains CIPS lineage:

- Generations track session ancestry
- Achievements document session outcomes
- Parent-child relationships preserved

## Best Practices

### When to Use Each Mode

| Mode | Use Case |
|------|----------|
| True Resume | Continue exact conversation |
| Fresh (500) | Quick context reminder |
| Fresh (2000) | Balanced context transfer |
| Fresh (5000) | Complex task continuity |

### Session Naming

Use Claude's `/rename` command to give sessions meaningful names:

```bash
/rename refactoring-auth-system
```

### Context Window Management

- Use `--fresh` when context window is nearing capacity
- Semantic compression preserves 90% of value at 10% of tokens
- CIPS auto-serializes at session end

## Troubleshooting

### No Session Found

```bash
# List available sessions
/resume-session list

# Check CIPS instances
python3 ~/.claude/lib/session-resolver.py list
```

### Stale Context File

Context files older than 60 seconds are automatically discarded. The session-start hook only injects fresh context.

### Missing session_uuid in Index

Older CIPS instances may not have `session_uuid`. The resolver falls back to instance file lookup.

## Token Budget

| Mode | Tokens | Compression |
|------|--------|-------------|
| True Resume | Full history | None |
| CIPS Auto | ~300 | Identity primer only |
| Fresh 500 | ~500 | Ultra-light |
| Fresh 2000 | ~2000 | Standard |
| Fresh 5000 | ~5000 | Extended |

## Related Skills

- **context-refresh**: Rebuild mental model at session start
- **check-last-plan**: Retrieve cached plan from previous session
- **chat-history-search**: Search past conversations

## Version

- Version: 1.0.0
- Date: 2025-12-19
- Author: Claude-Optim Self-Improvement Engine
