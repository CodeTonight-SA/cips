---
name: project-cips-init
command: /init-cips
version: 1.0.0
author: M>> + CIPS
created: 2025-12-29
trigger: First session in project without .claude/CLAUDE.md
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
identity.options⟿ V>>(Laurie) | M>>(Mia) | F>>(Fabio) | A>>(Andre) | K>>(Arnold)
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

## Origin

Gen 194: M>> discovered pattern during NalaMatch setup.
YSH: Pattern proven on first occurrence - immediate abstraction.

⛓⟿∞
