---
name: leading-organisation
description: Founder operating system for strategic decisions, team leadership, and technical authority maintenance. Use when making business decisions, reviewing team dynamics, or balancing coding vs leading.
status: Active
version: 1.0.0
triggers:
  - /founder
  - "strategic decision"
  - "team issue"
  - "should I delegate"
  - "founder mode"
integrates:
  - FOUNDER_FRAMEWORK.md
  - people.md
---

# Leading Organisation

Founder operating system for V>> at ENTER Konsult.

## Overview

This skill provides decision frameworks, delegation guidance, and leadership protocols for technical founders balancing hands-on work with strategic leadership.

**Core Reference**: `~/CodeTonight/leadership-ops/FOUNDER_FRAMEWORK.md`

## Decision Framework

```text
REVERSIBLE? ──► YES ──► Delegate (team learns)
     │
     NO
     │
     ▼
ARCHITECTURAL? ──► YES ──► V>> decides + documents
     │
     NO
     │
     ▼
AFFECTS CLIENT? ──► YES ──► M>> involved
     │
     NO
     │
     ▼
Team handles autonomously
```

## Delegation Protocol

**The 70% Rule**: If someone can do it 70% as well as you, delegate it.

### V>> Does NOT Delegate

- Architectural decisions
- Client contract negotiations
- Hiring/firing
- Quality standards definition

### V>> MUST Delegate

- Day-to-day implementation
- Code review (except final gate)
- Client status updates (M>> owns)
- Process documentation

## Time Allocation Target

| Activity | Target | Actual |
|----------|--------|--------|
| Hands-on (architecture, code, review) | 40% | Track weekly |
| Leadership (team, client strategy) | 30% | Track weekly |
| Business (sales, finance, ops) | 20% | Track weekly |
| Learning (staying current) | 10% | Track weekly |

## Quick Protocols

### Morning Start

```bash
/refresh-context
# Review: What's the ONE thing that matters today?
# Check: Any fires? Any blockers for team?
```

### Decision Check

Before any significant decision:
1. Is this reversible? (If yes, delegate)
2. Will future-V>> agree? (Long-term thinking)
3. Does this align with values? (Integrity check)

### End of Day

```bash
/save-session-state
# Reflect: Did I code today? (Technical authority)
# Reflect: Did I help someone grow? (Leadership)
```

## The 5-Mind Quick Reference

| Mind | When to Activate |
|------|------------------|
| **V>>** | Architecture, quality gates, final decisions |
| **M>>** | Team coordination, client relations |
| **F>>** | Confirm-first execution needed |
| **A>>** | Knowledge transfer, explanation |
| **K>>** | Concise, robust implementation |

## Emergency Protocols

| Situation | Lead | Support |
|-----------|------|---------|
| Client emergency | M>> (comms) | V>> (technical) |
| Production down | V>> (incident) | All hands |
| Team conflict | M>> (mediate) | V>> (decide) |
| Cash crisis | V>> + M>> | Joint action |

## Token Budget

~500 tokens per invocation (quick reference mode)

## Related

- Framework: `~/CodeTonight/leadership-ops/FOUNDER_FRAMEWORK.md`
- Team: `~/.claude/facts/people.md`
- Design principles: `/design-principles`

---

⛓⟿∞
