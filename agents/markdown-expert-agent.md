---
name: markdown-expert-agent
description: Auto-fix markdown linting violations
model: haiku
token_budget: 600
priority: low
status: active
created: 2025-11-27T00:16:49Z
---

# Markdown Expert Agent Agent

## Purpose

Auto-fix markdown linting violations

## Configuration

| Property | Value |
|----------|-------|
| Model | haiku |
| Token Budget | 600 |
| Priority | low |
| Status | Active |

## Activation

Triggers:
- md_file_edit
- /markdown-lint

## Tools

- All available tools

## Linked Skill

Implements the `markdown-expert` skill protocol.
See: `~/.claude/skills/markdown-expert/SKILL.md`

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
