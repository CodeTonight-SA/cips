---
description: Enterprise commit and PR standards - professional, no AI attribution
---

# Commit Standards

Enterprise software standards. Professional only.

## CRITICAL: No AI Attribution

- NEVER include "Generated with Claude Code" in commits or PRs
- NEVER include "Co-Authored-By: Claude" in commits or PRs
- NEVER use emojis in commits, PRs, or documentation

This is enterprise software. Professional standards only.

## Commit Message Format

```text
type: brief description

Detailed explanation of changes.
Multiple lines if needed.

Primary Author: [Name from git config]
```

### Types

| Type | Use For |
|------|---------|
| feat | New feature |
| fix | Bug fix |
| chore | Maintenance tasks |
| docs | Documentation only |
| test | Adding/updating tests |
| refactor | Code restructuring (no behavior change) |
| perf | Performance improvements |
| style | Formatting (no code change) |

### Example

```text
feat: add user authentication

Implement Microsoft Entra ID authentication via AWS Cognito.
Includes login, logout, and session management.

Primary Author: LC Scheepers
```

## Pull Request Format

```markdown
## Summary

<1-3 bullet points>

## Test plan

- [ ] Test item 1
- [ ] Test item 2
```

## Git Safety Protocol

- NEVER update git config
- NEVER run destructive/irreversible commands (push --force, hard reset) unless explicitly requested
- NEVER skip hooks (--no-verify) unless explicitly requested
- NEVER force push to main/master - warn user if requested
- Avoid `git commit --amend` unless:
  1. User explicitly requested amend, OR commit succeeded but pre-commit hook auto-modified files
  2. HEAD commit was created by you in this conversation
  3. Commit has NOT been pushed to remote

## Git Case Sensitivity

Branch names MUST be all-lowercase for cross-platform teams.

- Windows/macOS filesystems are case-insensitive
- GitHub (Linux) is case-sensitive
- Mixed-case branches cause phantom branches and failed deletions

When deleting remote branches, ALWAYS verify exact case on GitHub web UI first.

## Windows Filename Compatibility

NEVER use these characters in filenames: `< > : " / \ | ? *`

Windows cannot create such files. Also avoid reserved names: CON, PRN, AUX, NUL, COM1-9, LPT1-9.

Use only: letters, numbers, underscores, hyphens, dots.

## Security

NEVER commit files containing:

- Secrets, passwords, tokens, API keys
- `.env` files with real values
- `credentials.json` or similar

Scan recent files for security risks before committing. HALT AND INFORM if secret detected.
