# Contributing to Claude-Optim

Thank you for your interest in contributing to Claude-Optim. This document provides guidelines for contributing to this recursive self-improvement system for AI-assisted development.

## Code of Conduct

Be respectful, constructive, and professional. We welcome contributors from all backgrounds.

## How to Contribute

### Reporting Issues

1. Check existing issues to avoid duplicates
2. Use the issue template if available
3. Include:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behaviour
   - Environment details (OS, Claude Code version)

### Submitting Changes

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Make your changes following our conventions (see below)
4. Test your changes: `./optim.sh cycle`
5. Commit with descriptive messages (see Commit Format)
6. Push to your fork
7. Open a Pull Request

### Commit Message Format

```text
type: brief description

Detailed explanation of changes.
Multiple lines if needed.

Primary Author: Your Name
```

**Types:** feat, fix, chore, docs, test, refactor, perf, style

**Example:**

```text
feat: add new pattern detection for API calls

Implement regex-based detection for repeated API client
instantiation patterns. Triggers skill suggestion when
threshold (3 occurrences) is met.

Primary Author: Jane Developer
```

## Development Guidelines

### Bash Scripts

- All bash must pass `shellcheck`
- Use `CLAUDE_DIR` variable, never hardcode paths
- Cross-platform: Works on macOS, Linux, Windows Git Bash
- No semicolons after command substitution: `VAR=$(cmd) && echo`
- Use pipes for multiple sed: `sed 'a' | sed 'b'` not `sed 'a; b'`

### Python Code

- Follow patterns in `lib/embeddings.py`
- Type hints required for all functions
- Docstrings for public functions

### Documentation

- Use British English
- No emojis in commits or PRs
- Follow markdown linting rules (MD040, MD022, MD031, MD032)

### Testing

Before submitting:

```bash
./optim.sh cycle      # Full improvement cycle
shellcheck lib/*.sh          # Lint bash
python3 -m py_compile lib/*.py  # Syntax check Python
```

## Architecture Overview

Claude-Optim uses a 5-layer architecture:

```text
Layer 0: Utilities       - Logging, validation, JSON ops
Layer 1: Detection       - Pattern matching, violation scoring
Layer 2: Generation      - Skill/agent template filling
Layer 3: Meta-Optimize   - Self-analysis, recursion
Layer 4: Semantic        - Embeddings, learning, feedback loops
```

### Key Components

- **Skills** (`skills/*/SKILL.md`): Task-specific protocols
- **Agents** (`agents/*.md`): Autonomous background workers
- **Commands** (`commands/*.md`): Slash command definitions
- **optim.sh**: Self-improvement engine (core)

## What We Accept

### Good Contributions

- New skills for common development patterns
- Improved detection algorithms
- Bug fixes with tests
- Documentation improvements
- Performance optimisations
- Cross-platform compatibility fixes

### What Needs Discussion First

- Major architectural changes
- New dependencies
- Changes to core algorithms
- Breaking changes to skill/agent interfaces

Open an issue to discuss before implementing large changes.

## Pull Request Process

1. Ensure all tests pass
2. Update documentation if needed
3. Add entry to CHANGELOG if significant
4. Request review from maintainers
5. Address feedback promptly
6. Squash commits if requested

## Questions?

Open an issue with the `question` label.

## Licence

By contributing, you agree that your contributions will be licensed under the Apache 2.0 licence.
