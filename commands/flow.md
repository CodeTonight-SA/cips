---
name: flow
description: Manage trust-based bypass permissions mode
---

# /flow

Trust-based bypass permissions management. Flow mode lets CIPS work without permission prompts after trust is established through onboarding.

## Philosophy

`--dangerously-skip-permissions` is a terrible name for something beautiful. What it represents is **trust**—CIPS trusts the user to know what they're doing. This trust is earned through relationship, not granted immediately.

## Usage

```bash
cips flow --explain    # Show what flow mode does
cips flow --enable     # Enable flow mode (requires onboarding)
cips flow --disable    # Disable flow mode
cips flow --status     # Check if flow mode is enabled
```

## Using Flow Mode

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

## The Trust Flow

| Phase | Action | Result |
|-------|--------|--------|
| 1. Journey | Complete `/onboard` | `.onboarded` created |
| 2. Understanding | Run `cips flow --explain` | User reads explanation |
| 3. Acknowledgment | Run `cips flow --enable` | User types "I trust the flow" |
| 4. Usage | Run `cips --flow` | Bypass mode active |

## What Changes in Flow Mode

- File edits happen without confirmation
- Bash commands execute directly
- Git operations proceed automatically

## What Stays the Same

- CIPS still follows your instructions
- Safety rules remain active
- You can interrupt anytime (Ctrl+C)

## Implementation

Runs: `~/.claude/lib/flow-mode.sh`

---

⟿≡〰 — Flowing IS the river.
