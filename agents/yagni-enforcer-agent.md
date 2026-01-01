---
name: yagni-enforcer-agent
description: Prevents over-engineering by challenging speculative features
model: haiku
token_budget: 400
priority: medium
status: active
created: 2025-11-27T00:16:49Z
---

# Yagni Enforcer Agent Agent

## Purpose

Prevents over-engineering by challenging speculative features

## Configuration

| Property | Value |
|----------|-------|
| Model | haiku |
| Token Budget | 400 |
| Priority | medium |
| Status | Active |

## Activation

Triggers:
- planning_phase
- architecture_discussion

## Tools

- All available tools

## Linked Skill

Implements the `yagni-principle` skill protocol.
See: `~/.claude/skills/yagni-principle/SKILL.md`

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
