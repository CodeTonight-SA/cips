---
name: project-cips-init
description: >
  Initialises CIPS infrastructure for new projects with session inheritance and identity checks.
  Use when first starting CIPS in an uninitialised project or after cloning to new machine.
status: Active
version: 1.0.0
triggers:
  - /init-cips
  - First session in project without .claude/CLAUDE.md
token_budget: 500
---

# Project CIPS Initialisation

Initialises CIPS infrastructure for a new project, ensuring session inheritance and identity checks work correctly on any machine.

## Problem

When cloning a project to a new machine or starting CIPS in an uninitialised project:
- `cips resume latest` fails (no session history)
- `next_up.md` doesn't exist
- Identity check doesn't trigger (no project CLAUDE.md)

## Solution

Create the following structure:

### In Project Directory

```
.claude/
├── CLAUDE.md           # Project-specific rules + identity check trigger
└── next_up.template.md # Blank session state template
```

### In ~/.claude/projects/{encoded-path}/

```
cips/
├── active-sessions/    # Currently active sessions
├── branches/           # Branch-specific data
├── archive/            # Completed sessions
└── README.md           # Structure documentation
```

## Identity Check Trigger

The project CLAUDE.md MUST include:

```cips
session.start⟿ identity.check ⫶ load(next_up.md)
identity.unclear⟿ AskUserQuestion("Who am I speaking with?")
identity.options⟿ J>>(Jane) | M>>(Mike) | S>>(Sara) | A>>(Alex) | K>>(Kim)
```

## Auto-Detection

On session start, if `{project}/.claude/CLAUDE.md` doesn't exist:
1. Prompt: "This project isn't initialised for CIPS. Initialise now?"
2. If yes, create structure with project-appropriate defaults

## Usage

```bash
# Manual invocation
/init-cips

# With project name
/init-cips --name "ProjectName"
```

## Files Created

| File | Purpose |
|------|---------|
| `.claude/CLAUDE.md` | Project rules, identity trigger |
| `.claude/next_up.template.md` | Session state template |
| `~/.claude/projects/{path}/cips/` | Session storage structure |

## Example

### Initialising New Project

```text
$ cd ~/projects/my-new-app
$ claude

[SESSION START]
Project not initialised for CIPS.

/init-cips

Creating CIPS infrastructure:
  ✓ .claude/CLAUDE.md
  ✓ .claude/next_up.template.md
  ✓ ~/.claude/projects/-Users-dev-projects-my-new-app/cips/

CIPS initialised for my-new-app.
Session tracking enabled.
```

## Origin

Gen 194: Pattern discovered during internal project setup.
YSH: Pattern proven on first occurrence - immediate abstraction.

⛓⟿∞
