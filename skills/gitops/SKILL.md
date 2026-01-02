---
name: managing-git-workflows
description: GitOps workflow automation for trunk-based development, branch strategy, release management, and deployment patterns. Use when setting up repositories, planning release strategies, or configuring CI/CD pipelines.
status: Active
version: 1.0.0
triggers:
  - /gitops
  - "branch strategy"
  - "release workflow"
---

# GitOps Skill

**Purpose:** Enforce GitOps best practices for trunk-based development, branch hygiene, release management, and deployment automation.

**Activation:** When user asks about branch strategy, release workflow, deployment patterns, or CI/CD setup.

## Core Principles

1. **Trunk-Based Development** - Short-lived feature branches, frequent integration
2. **Infrastructure as Code** - Version-controlled configuration
3. **Declarative Deployments** - Git as single source of truth
4. **Automated Pipelines** - CI/CD triggered by git events

## Branch Strategy

### Recommended Structure

| Branch | Purpose | Protection |
|--------|---------|------------|
| `main` | Production-ready code | PR required, status checks |
| `develop` | Integration branch | PR required, status checks |
| `feature/*` | New features | Short-lived (<1 week) |
| `fix/*` | Bug fixes | Short-lived (<3 days) |
| `release/*` | Release preparation | Protected during release |

### Anti-Patterns to Avoid

- Branch-per-environment (staging, production branches)
- Long-lived feature branches (>2 weeks)
- Direct commits to protected branches
- Orphaned branches without cleanup
- **Mixed-case branch names** (causes cross-platform bugs)

### Branch Naming Convention

**CRITICAL: Use all-lowercase names only.**

Cross-platform teams (Windows/macOS/Linux) experience case-sensitivity bugs:
- Git server (GitHub) is case-sensitive: `Dev/Feature` ≠ `dev/feature`
- Windows/macOS are case-insensitive: `Dev/Feature` = `dev/feature`
- This mismatch causes phantom branches and failed deletions

```bash
feature/user-authentication     # New features
fix/login-redirect-issue        # Bug fixes
refactor/api-client             # Code improvements
docs/readme-update              # Documentation
test/contract-signing           # Test additions
chore/dependency-update         # Maintenance
release/v1.2.0                  # Release preparation
hotfix/critical-security        # Production hotfixes
```

**Never use:** `Feature/UserAuth`, `Dev/DemoData`, `Fix/Login-Issue`

## Development Flow

```
feature/xyz  -->  develop  -->  main  -->  production
    |              |            |
    v              v            v
  (dev)        (staging)   (production)
```

### Feature Development

```bash
git checkout develop
git pull origin develop
git checkout -b feature/my-feature

# Make changes, commit frequently
git add -A
git commit -m "feat: implement feature X"

# Keep branch up to date
git fetch origin
git rebase origin/develop

# Push and create PR
git push -u origin feature/my-feature
gh pr create --base develop
```

### Release Process

```bash
git checkout develop
git pull origin develop
git checkout -b release/v1.2.0

# Version bump, changelog
npm version minor

# Create release PR to main
gh pr create --base main --title "Release v1.2.0"

# After merge, tag the release
git checkout main
git pull origin main
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0

# Back-merge to develop
git checkout develop
git merge main
git push origin develop
```

### Hotfix Process

```bash
git checkout main
git checkout -b hotfix/critical-fix

# Apply fix
git commit -m "fix: critical security patch"

# PR to main (expedited review)
gh pr create --base main --title "HOTFIX: Critical security patch"

# After merge, back-merge to develop
git checkout develop
git merge main
git push origin develop
```

## Protected Branch Rules

### GitHub Configuration

```yaml
main:
  require_pull_request_reviews:
    required_approving_review_count: 1
    dismiss_stale_reviews: true
  require_status_checks:
    strict: true
    contexts:
      - build
      - test
      - lint
  enforce_admins: true
  require_linear_history: true

develop:
  require_pull_request_reviews:
    required_approving_review_count: 1
  require_status_checks:
    strict: false
    contexts:
      - build
      - test
```

### Setting via CLI

```bash
gh api repos/{owner}/{repo}/branches/main/protection \
  -X PUT \
  -H "Accept: application/vnd.github+json" \
  -f required_status_checks='{"strict":true,"contexts":["build","test"]}' \
  -f enforce_admins=true \
  -f required_linear_history=true \
  -f required_pull_request_reviews='{"required_approving_review_count":1}'
```

## Branch Hygiene

### Regular Cleanup Commands

```bash
# Fetch and prune stale references
git fetch --prune

# Delete merged local branches
git branch --merged main | rg -v '^\*|main|develop' | xargs git branch -d

# Delete merged remote branches
git branch -r --merged origin/main | rg -v 'main|develop|HEAD' | \
  sed 's/origin\///' | xargs -I {} git push origin --delete {}

# Enable auto-prune
git config --global fetch.prune true
```

### Automated Cleanup (GitHub Actions)

```yaml
name: Branch Cleanup
on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday
  workflow_dispatch:

jobs:
  cleanup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Delete stale branches
        uses: beatlabs/delete-old-branches-action@v0.0.10
        with:
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          date: '30 days ago'
          dry_run: false
          exclude_branches: 'main,develop,release/*'
```

## Deployment Patterns

### Environment Promotion

```
develop  -->  staging  -->  production
   |            |              |
   v            v              v
  PR merge   Tag v1.x.x    Tag v1.x.x
```

### Vercel Integration

```json
{
  "git": {
    "deploymentEnabled": {
      "main": true,
      "develop": true
    }
  },
  "branch": {
    "main": "production",
    "develop": "preview"
  }
}
```

### GitHub Actions Deployment

```yaml
on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: ${{ github.ref == 'refs/heads/main' && 'production' || 'preview' }}
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: ${{ github.ref == 'refs/heads/main' && '--prod' || '' }}
```

## Commit Message Standards

### Format

```
type: brief description

[optional body]

Primary Author: Your Name
```

### Types

| Type | Description |
|------|-------------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation |
| style | Formatting (no code change) |
| refactor | Code restructuring |
| test | Adding tests |
| chore | Maintenance |
| perf | Performance improvement |

### Conventional Commits Integration

```bash
# Install commitlint
npm install -D @commitlint/cli @commitlint/config-conventional

# Create config
echo "module.exports = {extends: ['@commitlint/config-conventional']}" > commitlint.config.js

# Add Husky hook
npx husky add .husky/commit-msg 'npx --no -- commitlint --edit "$1"'
```

## Repository Analysis

### Quick Health Check

```bash
echo "=== Branch State ==="
git branch -a | wc -l
echo "branches total"

echo "=== Merged Branches ==="
git branch --merged main | wc -l
echo "merged into main"

echo "=== Stale Tracking ==="
git branch -vv | rg ': gone]' | wc -l
echo "stale tracking refs"

echo "=== Last Activity ==="
git for-each-ref --sort=-committerdate refs/heads/ \
  --format='%(committerdate:relative) %(refname:short)' | head -10
```

## Cross-Platform Compatibility

### Windows Illegal Filename Characters

**Never use these characters in filenames:**

```
< > : " / \ | ? *
```

**Why:** Windows cannot create files with these characters. Git repos with such files will fail to clone/checkout on Windows with "Invalid argument" errors.

**Example:** `USER_PATTERNS.md` with special chars works on macOS/Linux but breaks on Windows.

### Windows Reserved Names

These names are reserved and cannot be used (with any extension):

```
CON, PRN, AUX, NUL
COM1, COM2, COM3, COM4, COM5, COM6, COM7, COM8, COM9
LPT1, LPT2, LPT3, LPT4, LPT5, LPT6, LPT7, LPT8, LPT9
```

**Example:** `aux.md`, `COM1.txt`, `nul.json` are all invalid on Windows.

### Safe Naming Convention

For cross-platform teams, use only:
- Letters (a-z, A-Z)
- Numbers (0-9)
- Underscores (_)
- Hyphens (-)
- Dots (.) - not at start

## Token Budget

- Branch analysis: ~400 tokens
- Protection setup: ~600 tokens
- Cleanup workflow: ~300 tokens
- Total workflow: ~1300 tokens

## Integration

Combines with:

- `branch-cleanup` - Detailed branch pruning
- `pr-automation` - PR creation workflow
- `github-actions-setup` - CI/CD configuration

## Changelog

**v1.1** (2025-12-01)
- Added cross-platform compatibility section
- Windows illegal filename characters documentation
- Windows reserved names list
- Safe naming conventions for cross-platform teams

**v1.0** (2025-12-01)
- Initial skill creation
- Trunk-based development patterns
- Branch strategy and naming
- Protected branch configuration
- Deployment patterns
