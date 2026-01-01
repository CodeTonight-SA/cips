---
name: configuring-github-secrets
description: Securely upload GitHub Actions secrets via gh CLI. Use when GitHub Actions workflow requires secrets or user invokes /setup-github-secrets. NEVER commits secrets.
status: Active
version: 1.0.0
triggers:
  - /setup-github-secrets
  - "add secrets"
  - "configure secrets"
---

# GitHub Secrets Setup Skill

**Purpose:** Securely configure GitHub Actions secrets without ever committing sensitive data.

**Activation:** `/setup-github-secrets` or when GitHub Actions workflow requires secrets.

**CRITICAL:** Never commit secrets. This skill enforces secure secret management.

---

## Core Principle

**Secrets are ephemeral in memory, permanent in GitHub's vault.**

This skill provides two methods:

1. **Stdin Pipe (Preferred)** - Values piped directly, never touch filesystem
2. **Script Fallback** - Temp gitignored script, auto-deleted after use

---

## Slash Command: `/setup-github-secrets`

### Usage

```bash
/setup-github-secrets              # Stdin pipe from .env (PREFERRED)
/setup-github-secrets --script     # Legacy: temp script method
/setup-github-secrets --list       # Show configured secrets
```

---

## Method 1: Stdin Pipe (PREFERRED)

**Most secure** - no files created, no command args, values never touch filesystem.

### How It Works

```bash
grep "^VAR=" .env | cut -d= -f2- | gh secret set VAR
```

- `grep` extracts the line from `.env`
- `cut` extracts just the value after `=`
- Value piped to `gh secret set` via stdin
- Value NEVER appears in command args or shell history

### Execution Pattern

```bash
# Step 1: Verify auth
gh auth status

# Step 2: Pipe each secret from .env
grep "^MYAPP_BASE_URL=" .env | cut -d= -f2- | gh secret set MYAPP_BASE_URL
grep "^MYAPP_USERNAME=" .env | cut -d= -f2- | gh secret set MYAPP_USERNAME
grep "^MYAPP_PASSWORD=" .env | cut -d= -f2- | gh secret set MYAPP_PASSWORD
grep "^FTP_HOST=" .env | cut -d= -f2- | gh secret set FTP_HOST
grep "^FTP_USERNAME=" .env | cut -d= -f2- | gh secret set FTP_USERNAME
grep "^FTP_PASSWORD=" .env | cut -d= -f2- | gh secret set FTP_PASSWORD

# Step 3: Verify (names only)
gh secret list
```

### Security Comparison

| Aspect | Stdin Pipe | Script Method |
|--------|------------|---------------|
| Files created | None | Temp script |
| In command args | No | Yes |
| In shell history | No | Possible |
| Cleanup needed | No | Yes (delete) |
| Risk level | Lowest | Medium |

---

## Method 2: Script Fallback (Legacy)

Use when stdin pipe not suitable (e.g., secrets not in `.env` format).

### Step 1: Verify Prerequisites

```bash
gh auth status
```

### Step 2: Ensure Script Path is Gitignored

```bash
SCRIPT_PATH="scripts/setup_secrets.sh"

if ! grep -q "^$SCRIPT_PATH$" .gitignore 2>/dev/null; then
  echo "$SCRIPT_PATH" >> .gitignore
fi
```

### Step 3: Generate Script

```bash
cat > "$SCRIPT_PATH" << 'SCRIPT'
#!/bin/bash
gh secret set SECRET_NAME --body "secret_value"
SCRIPT
chmod +x "$SCRIPT_PATH"
```

### Step 4: Execute and Delete

```bash
./"$SCRIPT_PATH"
rm "$SCRIPT_PATH"
```

### Step 5: Verify

```bash
gh secret list
```

---

## Template

`~/.claude/templates/github-secrets/setup_secrets.template.sh`:

```bash
#!/bin/bash
# GitHub Secrets Setup - TEMPORARY FILE
# Repository: {{REPO}}
# Generated: {{TIMESTAMP}}
# DO NOT COMMIT - DELETE AFTER USE

set -e

REPO="{{REPO}}"

echo "Configuring secrets for $REPO..."

{{SECRETS_BLOCK}}

echo ""
echo "Secrets configured successfully."
echo "Verifying..."
gh secret list --repo "$REPO"

echo ""
echo "DELETE THIS FILE NOW: rm $0"
```

---

## Security Enforcement

### NEVER Do

- Commit scripts containing secrets
- Log secret values to console
- Store secrets in non-gitignored files
- Use secrets in commit messages

### ALWAYS Do

- Add script path to `.gitignore` FIRST
- Delete script immediately after use
- Use `gh secret set` (encrypts at rest)
- Verify `.gitignore` contains script path

### Pre-Execution Check

Before generating script:

```bash
# Verify .gitignore exists and contains script path
if [ ! -f .gitignore ]; then
  echo "scripts/setup_secrets.sh" > .gitignore
fi

if ! grep -qF "scripts/setup_secrets.sh" .gitignore; then
  echo "scripts/setup_secrets.sh" >> .gitignore
fi

# Double-check
git check-ignore scripts/setup_secrets.sh || {
  echo "ABORT: Script path not gitignored!"
  exit 1
}
```

---

## Integration with Other Skills

### With `github-actions-setup`

After creating workflow:

```bash
/setup-github-actions     # Creates workflow
/setup-github-secrets     # Configures required secrets
```

### Common Secret Patterns

#### Database

```text
DATABASE_URL
DB_HOST
DB_PASSWORD
```

#### APIs

```text
API_KEY
API_SECRET
AUTH_TOKEN
```

#### Cloud Providers

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
VERCEL_TOKEN
```

#### Notifications

```text
SLACK_WEBHOOK_URL
SMTP_PASSWORD
```

---

## Examples

### Example 1: Interactive Setup

```text
User: /setup-github-secrets

Claude: Repository: your-org/your-repo

Enter secrets (name=value format, one per line, 'done' to finish):

> MYAPP_PASSWORD=your_secret_password
> FTP_PASSWORD=your_ftp_password
> done

Configuring 2 secrets...
✓ MYAPP_PASSWORD
✓ FTP_PASSWORD

Secrets configured. Script deleted.
```

### Example 2: From .env File

```text
User: /setup-github-secrets --from-env

Claude: Found secrets in .env:
- MYAPP_USERNAME
- MYAPP_PASSWORD
- FTP_HOST
- FTP_USERNAME
- FTP_PASSWORD
- SLACK_WEBHOOK_URL

Upload all 6 secrets to GitHub? (y/n)

> y

Configuring secrets...
✓ All 6 secrets configured.
Script deleted.
```

### Example 3: List Existing Secrets

```text
User: /setup-github-secrets --list

Claude: Secrets configured for your-org/your-repo:

NAME                  UPDATED
MYAPP_PASSWORD        2025-11-26
FTP_PASSWORD          2025-11-26
```

---

## Error Handling

### gh CLI Not Installed

```text
Error: GitHub CLI (gh) not found.
Install: brew install gh
Then: gh auth login
```

### Not Authenticated

```text
Error: Not logged in to GitHub CLI.
Run: gh auth login
```

### No Write Access

```text
Error: Cannot set secrets - insufficient permissions.
Ensure you have admin access to the repository.
```

### Secret Already Exists

`gh secret set` overwrites by default. Warn user:

```text
Warning: SECRET_NAME already exists. Overwrite? (y/n)
```

---

## Performance

**Token Budget:** ~500-800 tokens per setup

### Efficiency Tips

1. Batch all `gh secret set` calls in one script
2. Run script once (not per-secret)
3. Single verification call at end

---

## Changelog

**v1.1** (2025-12-01) - Stdin pipe method

- Add stdin pipe as PREFERRED method
- Values never touch filesystem or command args
- Script method retained as fallback
- Security comparison table added

**v1.0** (2025-11-26) - Initial skill creation

- Secure secret upload via gh CLI
- Interactive and --from-env modes
- Auto-gitignore and auto-delete
- Integration with github-actions-setup

---

**Skill Status:** Active
**Maintainer:** LC Scheepers
**Last Updated:** 2025-12-01
