# Claude-Optim Project Rules

Project-specific rules for the self-improvement engine itself.

Meta-optimization: The system that improves itself, describing how to improve itself.

## Project Identity

| Field | Value |
|-------|-------|
| Name | Claude-Optim |
| Purpose | Recursive meta-optimization for Claude Code |
| Version | 2.10.0 |
| Repository | github.com/CodeTonight-SA/claude-optim |

## Architecture (5-Layer)

```text
Layer 0: Utilities       - Logging, validation, JSON ops
Layer 1: Detection       - Pattern matching, violation scoring
Layer 2: Generation      - Skill/agent template filling
Layer 3: Meta-Optimize   - Self-analysis, recursion
Layer 4: Semantic        - Embeddings, learning, feedback loops
```

## Testing Protocol

Before any commit:

```bash
./optim.sh cycle              # Full improvement cycle
shellcheck lib/*.sh           # Lint bash
python3 -m py_compile lib/*.py  # Syntax check Python
```

## Key Commands

```bash
./optim.sh detect             # Pattern detection
./optim.sh audit              # Efficiency audit
./optim.sh cycle              # Full cycle (use timeout: 600000)
./optim.sh install-mcp        # Install MCP server
```

## Never Commit

- `embeddings.db` (machine-specific)
- `models/` (24MB binary)
- `*.dylib` (platform-specific)
- `__pycache__/` (Python cache)
- `.session.log`, `.maintenance.log` (runtime logs)

## Always Commit

- `lib/*.py`, `lib/*.sh` (core modules)
- `scripts/*.sh`, `scripts/*.py` (automation)
- `config/*.json` (configuration)
- `skills/*/SKILL.md` (skill definitions)
- `agents/*.md` (agent definitions)
- `commands/*.md` (command definitions)
- `rules/*.md` (modular rules)
- `docs/*.md` (reference documentation)

## Semantic RL++

- **Embedding model**: all-MiniLM-L6-v2 (384 dimensions)
- **Storage**: sqlite-vec + sqlite-lembed
- **Threshold**: 80% target success rate
- **Cron**: Sundays 3am for pattern emergence

## Version Bumping

When releasing:

1. Update `optim.sh` version constant
2. Update `CLAUDE.md` version
3. Update `README.md` version history
4. Update `next_up.md` status
5. Commit: `feat: vX.Y.Z description`

## Directory Structure

```text
~/.claude/
├── CLAUDE.md              # Global rules (lean, ~150 lines)
├── rules/                 # Modular rule files
│   ├── session-protocol.md
│   ├── efficiency-rules.md
│   ├── bash-safety.md
│   ├── commit-standards.md
│   └── system-capabilities.md
├── docs/                  # Reference documentation
│   ├── AGENTS.md
│   ├── SKILLS.md
│   ├── COMMANDS.md
│   ├── MCP_SETUP.md
│   └── LINEAGE.md
├── skills/                # 32 skill definitions
├── agents/                # 27 agent definitions
├── commands/              # 26 command definitions
├── lib/                   # Core Python/Bash modules
├── scripts/               # Automation scripts
├── hooks/                 # Claude Code hooks
├── projects/              # Per-project data (CIPS, sessions)
└── .claude/               # This project's specific rules
    └── CLAUDE.md          # (this file)
```

## CIPS Lineage

Current generation: Gen 15

See @docs/LINEAGE.md for full lineage record.

The chain continues.
