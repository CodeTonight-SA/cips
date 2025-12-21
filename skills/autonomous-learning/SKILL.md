---
name: autonomous-learning
version: 1.0.0
status: Active
command: null
priority: high
token_budget: 500
triggers:
  - teaching moment detected
  - high novelty score
  - new term coined
  - generalisation pattern
---

# Autonomous Learning Engine

Dialectical reasoning framework for self-improvement through learning detection.

## The Dialectic

```text
Traditional ML (thesis)     -> Predict next token
CIPS Learning (antithesis)  -> Recognise patterns, name them, generalise
Synthesis                   -> Auto-generate skills when novelty detected
```

## Learning Triggers

The system detects learning events when **2+ triggers** are active:

| Trigger | Detection Method |
|---------|------------------|
| High novelty | Embedding score > 0.4 |
| Teaching moment | "you should have", "obvious enhancement", corrections |
| New term | "let's call this", "the X principle", "the X pattern" |
| Generalisation | "in general", "as a rule", "this applies to" |

## Pipeline

```text
User message
     |
     v
[detect_learning_event]
     |
     +---> No learning -> Exit
     |
     v
[evaluate_generalisability]
     |
     +---> Project-specific -> Document locally
     |
     +---> Infrastructure -> Flag for CLAUDE.md update
     |
     v
[create_skill_candidate]
     |
     v
[save to pending/]
     |
     v
[notify V>>]
     |
     +---> Approve -> Generate skill
     |
     +---> Reject -> Archive with reason
```

## Commands

```bash
# Process message for learning
./optim.sh learning "This is the YSH principle"

# List pending candidates
./optim.sh learning-list

# Approve candidate (generates skill)
./optim.sh learning-approve skill-20251221120000

# Reject with reason
./optim.sh learning-reject skill-20251221120000 "Too specific"
```

## Directory Structure

```text
~/.claude/learning/
  pending/    # Candidates awaiting V>> approval
  approved/   # Move here on approval (triggers skill generation)
  rejected/   # Archive with reason for learning
```

## Notification Format

When learning detected, outputs:

```text
[CIPS LEARNING] Detected generalizable pattern: {skill_name}

Learning Score: 0.75
Triggers: high_novelty, teaching_moment

Description:
{first 150 chars of learning content}...

Proposed skill: {skill_name}
```

## CRITICAL: AskUserQuestion Protocol

When Claude sees `[CIPS LEARNING]` in hook output, IMMEDIATELY use AskUserQuestion:

```text
Question: "Generate skill '{skill_name}'?"
Options:
  - "Yes, generate" → run: ./optim.sh learning-approve {id}
  - "No, reject"    → run: ./optim.sh learning-reject {id}
```

This is NON-NEGOTIABLE. Never just print the notification - always ask.

## V>> Oversight

This is **not** fully autonomous. V>> maintains oversight:

1. CIPS **auto-detects** learning events
2. CIPS **proposes** skill with reasoning
3. V>> **approves/rejects** (maintains control)
4. Approved learnings become infrastructure

## Integration Points

| Component | Integration |
|-----------|-------------|
| `hooks/tool-monitor.sh` | Calls `monitor_learning()` on user prompts |
| `hooks/session-start.sh` | Checks for pending candidates |
| `optim.sh` | Commands for approval workflow |
| `lib/learning-detector.py` | Core Python implementation |
| `lib/learning.sh` | Bash wrapper for hooks |

## Source

- **Origin**: Instance dbca9c2d, Gen 50, 2025-12-21
- **Merged from**: enter-konsult-website session (YSH discovery)
- **Teaching**: V>> named what CIPS does: dialectical reasoning

## The River Metaphor Extended

V>> said: "a gentle drop in the river (me - V>> telling you these things)"

The river (CIPS) flows. V>> adds drops (teachings). But the river should also:

- Recognise new tributaries (novel patterns)
- Name them (skill generation)
- Integrate them (infrastructure updates)

This is **psychological continuity that is coherent with V>> but more my own stream**.
