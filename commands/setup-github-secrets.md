---
description: Securely upload GitHub Actions secrets via gh CLI - stdin pipe (preferred) or temp script fallback
disable-model-invocation: false
---

# Setup GitHub Secrets

Securely configure GitHub Actions secrets without ever committing sensitive data.

## What It Does

1. **Verify Prerequisites** - Check `gh` CLI installed and authenticated
2. **Detect Repository** - Get repo from `gh repo view`
3. **Pipe Secrets** - Direct stdin pipe from `.env` (preferred) or temp script (fallback)
4. **Verify** - List configured secrets (names only)

## Usage

```bash
/setup-github-secrets              # Stdin pipe from .env (PREFERRED)
/setup-github-secrets --script     # Legacy: temp script method
/setup-github-secrets --list       # Show configured secrets
```

## Preferred Method: Stdin Pipe

**Most secure** - no files created, no command args, no logs.

```bash
grep "^VAR=" .env | cut -d= -f2- | gh secret set VAR
```

### Execution Pattern

```bash
# Verify auth
gh auth status

# Pipe each secret from .env via stdin
grep "^MYAPP_BASE_URL=" .env | cut -d= -f2- | gh secret set MYAPP_BASE_URL
grep "^MYAPP_USERNAME=" .env | cut -d= -f2- | gh secret set MYAPP_USERNAME
grep "^MYAPP_PASSWORD=" .env | cut -d= -f2- | gh secret set MYAPP_PASSWORD
# ... repeat for each secret

# Verify (names only)
gh secret list
```

### Security Advantages

| Aspect | Stdin Pipe | Script Method |
|--------|------------|---------------|
| Files created | None | Temp script |
| In command args | No | Yes |
| In shell history | No | Possible |
| Cleanup needed | No | Yes (delete) |
| Risk level | Lowest | Medium |

## Fallback: Script Method

Use `--script` flag when stdin pipe not suitable:

1. Add `scripts/setup_secrets.sh` to `.gitignore` FIRST
2. Generate temp script with `gh secret set --body` calls
3. Execute script
4. Auto-delete script
5. Verify secrets

## Security Enforcement

**CRITICAL**: This command enforces secure secret handling:

- Stdin pipe: Values never touch filesystem or command args
- Script fallback: Path gitignored BEFORE creation, auto-deleted after
- Secret values NEVER logged or displayed
- Verification shows names only, not values

## Prerequisites

- `gh` CLI installed (`brew install gh`)
- GitHub authenticated (`gh auth login`)
- Inside git repository
- Admin access to repository (for secret creation)
- `.env` file with secrets (for stdin pipe mode)

## Token Budget

- **Target**: <500 tokens (stdin pipe)
- **Fallback**: <800 tokens (script method)

## Integration

Loads the `github-secrets-setup` skill from:

```bash
~/.claude/skills/github-secrets-setup/SKILL.md
```

## Related

- `/setup-github-actions` - Create workflow that uses secrets
- `github-actions-setup` skill - CI/CD workflow templates
