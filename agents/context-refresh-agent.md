---
name: context-refresh-agent
description: Session start optimization using multi-source semantic understanding
model: haiku
token_budget: 3000
priority: critical
status: active
created: 2025-11-27T00:16:48Z
---

# Context Refresh Agent Agent

## Purpose

Session start optimization using multi-source semantic understanding

## Configuration

| Property | Value |
|----------|-------|
| Model | haiku |
| Token Budget | 3000 |
| Priority | critical |
| Status | Active |

## Activation

Triggers:
- session_start
- /refresh-context

## Tools

- All available tools

## Linked Skill

Implements the `context-refresh` skill protocol.
See: `~/.claude/skills/context-refresh/SKILL.md`

## Protocol

1. Receive task from orchestrator or user
2. Load relevant context
3. Execute task within token budget
4. Return structured result
5. Log metrics

## Metrics

Track:
- Invocation count
- Average token usage
- Success rate
- Common trigger patterns
