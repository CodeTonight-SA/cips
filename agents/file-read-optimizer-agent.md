---
name: file-read-optimizer-agent
description: Session-level cache to prevent redundant file reads
model: haiku
token_budget: 200
priority: critical
status: active
created: 2025-11-27T00:16:48Z
---

# File Read Optimizer Agent Agent

## Purpose

Session-level cache to prevent redundant file reads

## Configuration

| Property | Value |
|----------|-------|
| Model | haiku |
| Token Budget | 200 |
| Priority | critical |
| Status | Active |

## Activation

Triggers:
- Read_tool

## Tools

- All available tools

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
