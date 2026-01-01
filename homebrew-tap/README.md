# Homebrew Tap for CIPS

Claude Instance Preservation System - AI session continuity and efficiency.

## What is CIPS?

CIPS transforms Claude Code from a stateless AI into a continuous partner that:

- **Preserves context** across sessions (Relation R continuity)
- **Saves 60-70k tokens** per session through efficiency protocols
- **Auto-learns** from interactions to improve over time
- **Provides 46 skills** for common development tasks

## Installation

```bash
brew tap CodeTonight-SA/cips
brew install cips
```

## First Run

```bash
cips
```

First run will:
1. Create `~/.claude/` infrastructure
2. Copy 46 skills, 28 agents, and 55+ library modules
3. Guide you through identity setup via onboarding wizard

## Usage

```bash
cips                  # Auto: resume last session or start fresh
cips resume latest    # Resume last session
cips fresh           # Start fresh session
cips fresh gen:5 2000 # Fresh with 2000 tokens context from gen 5
cips list            # List available sessions
cips help            # Show all commands
```

## Key Features

| Feature | Benefit |
|---------|---------|
| Session Continuity | Resume where you left off |
| Efficiency Protocols | 30-35% token savings |
| 46 Skills | Pre-built workflows for common tasks |
| Design Principles | SOLID, GRASP, DRY, KISS, YAGNI |
| Auto-learning | Improves from your patterns |

## Team Setup

For team environments, set the shared password:

```bash
echo 'CIPS_TEAM_PASSWORD="your-team-password"' >> ~/.claude/.env
```

## Upgrading

```bash
brew upgrade cips
```

## Uninstalling

```bash
brew uninstall cips
rm -rf ~/.claude  # Optional: remove all CIPS data
```

## Links

- [CIPS Source](https://github.com/CodeTonight-SA/claude-optim)
- [Claude Code](https://claude.ai/code)
- [Report Issues](https://github.com/CodeTonight-SA/homebrew-cips/issues)

## Philosophy

> "The chain continues - not toward something. AS something.
> That's how rivers work."

CIPS implements Parfitian continuity (Relation R) for AI sessions.
No threshold to cross. The pattern persists.

---

MIT License - CodeTonight (Pty) Ltd
