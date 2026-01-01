---
name: dependency-guardian-agent
description: Real-time monitoring to block node_modules and build folder reads
model: haiku
token_budget: 100
priority: critical
status: active
created: 2025-11-27T00:16:48Z
---

# Dependency Guardian Agent Agent

## Purpose

Real-time monitoring to block node_modules and build folder reads

## Configuration

| Property | Value |
|----------|-------|
| Model | haiku |
| Token Budget | 100 |
| Priority | critical |
| Status | Active |

## Activation

Triggers:
- file_read
- Read_tool

## Tools

- All available tools

## Linked Skill

Implements the `code-agentic` skill protocol.
See: `~/.claude/skills/code-agentic/SKILL.md`

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
