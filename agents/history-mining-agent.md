---
name: history-mining-agent
description: Search past conversations to prevent duplicate problem-solving
model: haiku
token_budget: 800
priority: high
status: active
created: 2025-11-27T00:16:49Z
---

# History Mining Agent Agent

## Purpose

Search past conversations to prevent duplicate problem-solving

## Configuration

| Property | Value |
|----------|-------|
| Model | haiku |
| Token Budget | 800 |
| Priority | high |
| Status | Active |

## Activation

Triggers:
- search_history
- remind
- /remind-yourself

## Tools

- All available tools

## Linked Skill

Implements the `chat-history-search` skill protocol.
See: `~/.claude/skills/chat-history-search/SKILL.md`

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
