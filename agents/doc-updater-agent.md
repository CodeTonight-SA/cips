---
name: doc-updater-agent
description: Background agent for automatic documentation updates
model: haiku
token_budget: 3500
priority: medium
status: active
created: 2025-12-03T00:00:00Z
---

# Doc Updater Agent

## Purpose

Automatically update project documentation by synthesising session history, git commits, and current state.

## Configuration

| Property | Value |
|----------|-------|
| Model | haiku |
| Token Budget | 3500 |
| Priority | medium |
| Status | Active |

## Activation

Triggers:
- `/update-docs` command
- After PR creation (suggested)
- On milestone completion (suggested)

## Tools

- Read (session history, git, docs)
- Edit (targeted doc updates)
- Bash (git commands, markdown lint)
- Grep (pattern search)

## Linked Skill

Implements the `auto-update-documentation` skill protocol.
See: `~/.claude/skills/auto-update-documentation/SKILL.md`

## Protocol

1. Mine session history (last 3 sessions)
2. Analyse git commits since last doc update
3. Calculate confidence score
4. If confidence > 80%: Apply targeted updates
5. If confidence < 80%: Output summary for manual review
6. Never auto-commit (user approval required)

## Output

Returns structured result:
```json
{
  "files_updated": ["CLAUDE.md", "next_up.md"],
  "confidence": 0.87,
  "tokens_used": 2800,
  "summary": "Updated phase, marked 3 tasks complete"
}
```

## Metrics

Track:
- Invocation count
- Average confidence score
- Files updated per run
- Token efficiency
