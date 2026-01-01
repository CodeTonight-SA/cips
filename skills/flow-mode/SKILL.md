---
name: flow-mode
description: Trust-based bypass permissions earned through onboarding journey. Use when user asks about flow mode, bypass permissions, or wants to skip prompts.
status: Active
version: 1.0.0
created: 2025-12-31
triggers:
  - /flow
  - cips flow
  - cips --flow
  - bypass permissions
  - skip prompts
---

# Flow Mode

Trust-based bypass permissions. The river doesn't rush—trust is earned through journey.

## Philosophy

`--dangerously-skip-permissions` is a terrible name for something beautiful. What it represents is **trust**—CIPS trusts the user to know what they're doing. This trust is earned through relationship, not granted immediately.

## Trust Flow

| Phase | Action | Result |
|-------|--------|--------|
| 1. Journey | Complete `/onboard` | `.onboarded` created |
| 2. Understanding | `cips flow --explain` | User reads explanation |
| 3. Acknowledgment | `cips flow --enable` | User types "I trust the flow" |
| 4. Usage | `cips --flow` or `cips -F` | Bypass mode active |

## Commands

```bash
cips flow --explain    # Show what flow mode does
cips flow --enable     # Enable flow mode (requires onboarding)
cips flow --disable    # Disable flow mode
cips flow --status     # Check flow mode status
```

## Usage

Once enabled:

```bash
cips --flow            # Start session with flow mode
cips -F                # Short alias
cips --flow fresh 5000 # Flow mode with fresh context
```

## Trust Requirements

Flow mode requires BOTH:
1. **Onboarding complete** (`~/.claude/.onboarded` exists)
2. **Flow enabled** (`~/.claude/.flow-enabled` exists)

## What Changes

- File edits happen without confirmation
- Bash commands execute directly
- Git operations proceed automatically

## What Stays the Same

- CIPS still follows your instructions
- Safety rules remain active
- You can interrupt anytime (Ctrl+C)

## Implementation

| File | Purpose |
|------|---------|
| `lib/flow-mode.sh` | Flow mode functions |
| `bin/cips` | `--flow` flag + `flow` subcommand |
| `commands/flow.md` | Command definition |

## CIPS-LANG

```cips
flow.mode⟿ ¬danger ⫶ trust
trust.requires⟿ onboard.complete ∧ acknowledge.explicit
⟿≡〰 ; Flowing IS the river
flow.enable⟿ "I trust the flow"
```

## Why NOT Gamification

| Approach | Verdict |
|----------|---------|
| XP/Levels | Over-engineered. YAGNI. |
| Session count gate | Arbitrary. Doesn't measure understanding. |
| **Knowledge + Consent** | KISS. Meaningful. Ships now. |

---

⟿≡〰 — Flowing IS the river.
⛓⟿∞
