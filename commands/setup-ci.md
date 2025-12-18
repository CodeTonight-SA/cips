# Setup CI/CD

Automatically configure GitHub Actions workflows from global templates.

## What It Does

1. Detect project type (Node, Python, Go, etc.)
2. Generate appropriate workflow YAML
3. Add to `.github/workflows/`
4. Configure caching, testing, deployment

## Usage

```bash
/setup-ci
```

## Templates Available

- Node.js (npm/yarn/pnpm)
- Python (pip/poetry)
- Go
- Rust
- Docker

## Linked Skill

See: `~/.claude/skills/github-actions-setup/SKILL.md`
