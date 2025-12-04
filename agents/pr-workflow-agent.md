---
name: pr-workflow-agent
description: Complete PR automation from branch creation to submission
model: sonnet
token_budget: 2000
priority: high
status: active
created: 2025-11-27T00:16:49Z
---

# Pr Workflow Agent Agent

## Purpose

Complete PR automation from branch creation to submission

## Configuration

| Property | Value |
|----------|-------|
| Model | sonnet |
| Token Budget | 2000 |
| Priority | high |
| Status | Active |

## Activation

Triggers:
- create_pr
- pull_request
- /create-pr

## Tools

- All available tools

## Linked Skill

Implements the `pr-automation` skill protocol.
See: `~/.claude/skills/pr-automation/SKILL.md`

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
