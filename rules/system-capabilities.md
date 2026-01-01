---
description: Overview of available automation - agents, skills, commands
---

# System Capabilities

Claude-Optim v3.1.0 system overview.

## Accurate Counts (Gen 16)

| Category | Count | Reference |
|----------|-------|-----------|
| Skills | 36 | @docs/SKILLS.md |
| Agents | 28 | @docs/AGENTS.md |
| Commands | 29 | @docs/COMMANDS.md |

## Key Commands (Most Used)

| Command | Purpose | Token Savings |
|---------|---------|---------------|
| `/refresh-context` | Build mental model at session start | 5k-8k |
| `/create-pr` | Complete PR automation | 1k-2k |
| `/remind-yourself` | Search past conversations | 5k-20k |
| `/audit-efficiency` | Run efficiency audit | ~600 |
| `/markdown-lint` | Fix markdown violations | ~600 |
| `/preplan` | Prepare plan for next session | ~1k |
| `cips list` | List available sessions | - |
| `cips resume latest` | Resume last session | - |
| `cips fresh gen:N` | Fresh session with context | ~2k context |

## Agent Categories

### Critical Priority (Auto-Trigger)

| Agent | Trigger | Savings |
|-------|---------|---------|
| Context Refresh | Session start | 5k-8k |
| Dependency Guardian | All file reads | Prevents 50k+ waste |
| File Read Optimizer | Before Read calls | 5k-10k |

### High Priority (Common Tasks)

| Agent | Trigger | Savings |
|-------|---------|---------|
| PR Workflow | "create PR", `/create-pr` | 1k-2k |
| History Mining | "search history", `/remind-yourself` | 5k-20k |
| Doc Updater | `/update-docs` | ~3.5k |

### Quality Gates (Proactive)

| Agent | Trigger | Purpose |
|-------|---------|---------|
| Efficiency Auditor | `/audit-efficiency` | Violation scoring |
| YAGNI Enforcer | Planning phase | Prevent over-engineering |
| Markdown Expert | .md file edits | Auto-fix violations |

## Agent vs Skill Distinction

**Skills** (Passive Reference):

- Markdown files in `~/.claude/skills/`
- Define protocols and best practices
- Loaded as context/reference material

**Agents** (Active Execution):

- Specialized sub-agents with isolated context
- Can execute tasks autonomously
- Have tool access and token budgets

**Relationship**: Agents implement protocols defined in skills.

## MCP Servers

### Installed

- playwright - Browser automation
- context7 - Framework documentation
- github - PR and issue management
- notion - Documentation sync
- filesystem - File operations

### Installation

```bash
/install-mcp <server-name>
# or
claude mcp add <name> <command> [args...]
```

## Design Principles

The system follows 6 core principles:

1. **YAGNI** - Build when needed, not anticipated
2. **KISS** - Simplicity over cleverness
3. **DRY** - Single source of truth
4. **SOLID** - Clean architecture
5. **GRASP** - Responsibility assignment
6. **Efficiency** - Token optimization

See @docs/SKILLS.md for `design-principles` skill details.

## Token Savings Summary

**Per Session (Cumulative)**:

- Context Refresh: 5k-8k
- Dependency Guardian: 0-50k (prevention)
- File Read Optimizer: 5k-10k
- PR Workflow: 1k-2k per PR
- History Mining: 5k-20k per search

**Total Average**: 60k-70k tokens saved per session (30-35% of 200k budget)
