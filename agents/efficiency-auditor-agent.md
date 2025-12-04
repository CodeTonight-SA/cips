---
name: efficiency-auditor-agent
description: Real-time workflow analysis with violation scoring
model: haiku
token_budget: 600
priority: medium
status: active
created: 2025-11-27T00:16:49Z
---

# Efficiency Auditor Agent Agent

## Purpose

Real-time workflow analysis with violation scoring

## Configuration

| Property | Value |
|----------|-------|
| Model | haiku |
| Token Budget | 600 |
| Priority | medium |
| Status | Active |

## Activation

Triggers:
- /audit-efficiency
- workflow_complete

## Tools

- All available tools

## Linked Skill

Implements the `self-improvement-engine` skill protocol.
See: `~/.claude/skills/self-improvement-engine/SKILL.md`

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
