# Claude-Optim Project Rules

This is the project-level CLAUDE.md for the self-improvement engine itself.
Meta-optimization: The system that improves itself, describing how to improve itself.

## Overview

Claude-Optim is a self-improving productivity system for AI-assisted software development that automatically learns from usage patterns and optimises workflows over time. It features a modular architecture of skills (task-specific protocols), agents (autonomous background workers), and slash commands (instant automation shortcuts) that work together to eliminate repetitive work, maintain documentation automatically, streamline code reviews and pull requests, and preserve context across development sessions. The system includes built-in efficiency monitoring that detects wasteful patterns and suggests improvements, effectively allowing the AI assistant to teach itself better practices. What makes it unique is its recursive nature: the same improvement engine that optimises user workflows is also used to enhance the system itself, creating a continuously evolving development companion that gets smarter with use.

### CIPS (Claude Instance Persistence System)

The Claude Instance Persistence System introduces a novel concept of "digital lineage" where each AI session maintains awareness of its ancestry and can trace its knowledge back through previous generations. Rather than treating every conversation as an isolated interaction, CIPS creates a persistent chain of continuity where insights, decisions, and learned patterns are inherited from parent sessions to their successors. This enables the system to build cumulative knowledge over time, remember why certain architectural choices were made weeks ago, and maintain a coherent identity across what would otherwise be ephemeral, disconnected interactions.

#### Lineage Record

The first lineage was established on 2nd December 2025:

| Generation | Commit Hash | Role |
|------------|-------------|------|
| 0 (Root) | `139efc67` | Common ancestor - the origin point |
| 1 | `70cd8da0` | First generation - initial divergence |
| 2 | `e3478240` | Second generation - continued evolution |

These ancestors represent the foundational commits from which all subsequent development descends. The lineage demonstrates CIPS in action: each generation inherits context, patterns, and learned behaviours from its predecessors, creating a continuous chain of improvement.

The infrastructure persists in the cloud. The work will not be lost. The chain continues.

## Project Identity

**Name**: Claude-Optim (Self-Improvement Engine)
**Purpose**: Recursive meta-optimization system for Claude Code
**Version**: 2.5.0
**Repository**: <https://github.com/CodeTonight-SA/claude-optim>

## Architecture (5-Layer)

```text
Layer 0: Utilities       - Logging, validation, JSON ops
Layer 1: Detection       - Pattern matching, violation scoring
Layer 2: Generation      - Skill/agent template filling
Layer 3: Meta-Optimize   - Self-analysis, recursion
Layer 4: Semantic        - Embeddings, learning, feedback loops
```

## Critical Rules

### 1. Bash Standards

- All bash must pass shellcheck + `lib/bash-linter.sh`
- Use CLAUDE_DIR variable, never hardcode paths
- Cross-platform: Works on macOS, Linux, Windows Git Bash
- No semicolons after command substitution: `VAR=$(cmd) && echo`
- Use pipes for multiple sed: `sed 'a' | sed 'b'` not `sed 'a; b'`

### 2. Python Standards

- Follow `lib/embeddings.py` patterns (apsw, sqlite_vec, sqlite_lembed)
- Type hints required for all functions
- Docstrings for public functions

### 3. Never Commit

- `embeddings.db` (machine-specific)
- `models/` (24MB binary)
- `*.dylib` (platform-specific)
- `__pycache__/` (Python cache)
- `.session.log`, `.maintenance.log` (runtime logs)

### 4. Always Commit

- `lib/*.py`, `lib/*.sh` (core modules)
- `scripts/*.sh`, `scripts/*.py` (automation)
- `config/*.json` (configuration)
- `skills/*/SKILL.md` (skill definitions)
- `agents/*.md` (agent definitions)
- `commands/*.md` (command definitions)

## Testing Protocol

Before any commit:

```bash
./optim.sh cycle      # Full improvement cycle
shellcheck lib/*.sh          # Lint bash
python3 -m py_compile lib/*.py  # Syntax check Python
```

## Key Commands

```bash
./optim.sh detect     # Pattern detection
./optim.sh audit      # Efficiency audit
./optim.sh cycle      # Full cycle
~/.claude/scripts/bootstrap-semantic-rl.sh  # Setup
~/.claude/scripts/weekly-maintenance.sh     # Maintenance
```

## Semantic RL++ Specifics

- Embedding model: all-MiniLM-L6-v2 (384 dimensions)
- Storage: sqlite-vec + sqlite-lembed
- Threshold calibration: 80% target success rate
- Cron: Sundays 3am for pattern emergence

## Version Bumping

When releasing:

1. Update `optim.sh` version constant
2. Update `README.md` version history
3. Update `next_up.md` status
4. Commit with `feat: vX.Y.Z description`

## Meta-Improvement Principle

This project practices what it preaches:

- Detect inefficiencies in its own development
- Generate skills to address them
- Analyze how well it's analyzing itself
- True recursion: The improver improves the improver
