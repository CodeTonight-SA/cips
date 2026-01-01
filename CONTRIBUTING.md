# Contributing to CIPS

## Development Setup

1. Clone the repository
2. Run `./optim.sh cycle` to verify setup
3. All bash must pass `shellcheck lib/*.sh`
4. All Python must pass `py_compile lib/*.py`

## Creating Skills

Follow [skill-creation-best-practices](skills/skill-creation-best-practices/SKILL.md):

- Gerund naming convention (verb-ing)
- Frontmatter with name, description, status, version
- Max 500 lines per SKILL.md
- Third-person descriptions

## Commit Standards

See [commit-standards.md](rules/commit-standards.md):

- Types: feat, fix, chore, docs, test, refactor, perf, style
- No AI attribution in commits
- No emojis
- Professional language

## Pull Requests

1. Create feature branch from `main`
2. Make changes following code standards
3. Run `./optim.sh cycle` to validate
4. Submit PR with:
   - Summary (1-3 bullet points)
   - Test plan (checklist)

## Code Style

- British English in documentation
- CIPS-LANG (`.cips` files) for compact protocols
- Markdown for human-readable docs
- Bash scripts must be POSIX-compatible where possible

## Testing

Before submitting:

```bash
# Validate all scripts
shellcheck lib/*.sh

# Validate Python
python3 -m py_compile lib/*.py

# Run full cycle
./optim.sh cycle
```

## Questions

Open an issue for questions about contributing.
