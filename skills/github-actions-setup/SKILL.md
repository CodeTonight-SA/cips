---
name: github-actions-setup
description: Automatically configure GitHub Actions CI/CD workflows for any repository using global templates.
---

# GitHub Actions Setup Skill

**Purpose:** Automatically configure GitHub Actions CI/CD workflows for any repository using global templates.

**Activation:** When user runs `/setup-github-actions` or when setting up a new repository.

---

## Core Principle

GitHub Actions workflows **must live in each repository** at `.github/workflows/` due to how GitHub discovers and runs them. However, we can:

1. **Store global templates** in `~/.claude/templates/github-workflows/`
2. **Auto-install with one command** (`/setup-github-actions`)
3. **Customize for each project** (detect framework, adapt build commands)

---

## Template Location

**Global Templates:** `~/.claude/templates/github-workflows/`

```bash
~/.claude/templates/github-workflows/
├── README.md                    # Template documentation
├── claude-code.yml              # Standard CI workflow (Node.js/TS)
├── python-ci.yml                # Python projects (future)
└── deploy-vercel.yml            # Vercel deployment (future)
```text

---

## Slash Command: `/setup-github-actions`

### Usage:
```bash
/setup-github-actions [template-name]
```text

### Examples:
```bash
/setup-github-actions                    # Use default (claude-code.yml)
/setup-github-actions claude-code        # Explicit template name
/setup-github-actions python-ci          # Python template (future)
```text

---

## Workflow Execution

When user types `/setup-github-actions`:

### Step 1: Verify Git Repository

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```text

If not a git repo, ask user:
> "This isn't a Git repository. Initialize with `git init` first?"

### Step 2: Detect Project Type

### Check for:
- `package.json` → Node.js project
  - Check for `"next"` in dependencies → Next.js
  - Check for `"vite"` in devDependencies → Vite
  - Check for `"react"` → React
- `requirements.txt` or `pyproject.toml` → Python
- `Cargo.toml` → Rust
- `go.mod` → Go

**Select template based on detection.**

### Step 3: Check if Workflows Already Exist

```bash
ls .github/workflows/ 2>/dev/null
```text

If workflows exist:
> "Found existing workflows:
> - `.github/workflows/existing-workflow.yml`
>
> Add Claude Code workflow alongside these? (y/n)"

### Step 4: Create Directory Structure

```bash
mkdir -p .github/workflows
```text

### Step 5: Copy Template with Customization

**Base template:** `~/.claude/templates/github-workflows/claude-code.yml`

### Customizations:
1. **Detect Node version** from `.nvmrc` or `package.json` engines
2. **Detect build command** from `package.json` scripts
3. **Detect test command** from `package.json` scripts
4. **Adapt build output** based on framework:
   - Next.js: `.next/`
   - Vite: `dist/`
   - Create React App: `build/`

### Example customization:
```yaml
# Original template
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '18'

# Customized (detected from .nvmrc)
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '20'
```text

### Step 6: Write Workflow File

```bash
cp ~/.claude/templates/github-workflows/claude-code.yml .github/workflows/claude-code.yml
# Apply customizations inline
```text

### Step 7: Verify Workflow Syntax

```bash
# Optional: Use GitHub CLI to validate
gh workflow view .github/workflows/claude-code.yml --repo $(gh repo view --json nameWithOwner -q .nameWithOwner)
```text

If `gh` not installed, skip validation.

### Step 8: Git Commit (Optional)

Ask user:
> "Workflow created at `.github/workflows/claude-code.yml`
>
> Commit and push? (y/n)"

If yes:
```bash
git add .github/workflows/claude-code.yml
git commit -m "Add GitHub Actions CI workflow

✅ Auto-linting and type checking
✅ Build verification
✅ Test execution
✅ Artifact uploading

🤖 Generated with Claude Code"

git push origin $(git branch --show-current)
```text

### Step 9: Display Next Steps

```markdown
# GitHub Actions Setup Complete! ✅

**Workflow:** `.github/workflows/claude-code.yml`

## What It Does
- ✅ Runs linter on every push to `main`/`develop`
- ✅ Type checks TypeScript code
- ✅ Builds project to verify no build errors
- ✅ Runs tests (if configured)
- ✅ Uploads build artifacts

## Next Steps
1. **Push to GitHub** (if not already done)
2. **View workflow runs:** https://github.com/OWNER/REPO/actions
3. **Customize workflow:** Edit `.github/workflows/claude-code.yml`

## Testing Locally
```bash
npm run lint      # If configured
npm run build     # Should succeed
npm test          # If configured
```text

**Tip:** Add status badge to README.md:
```markdown
![CI Status](https://github.com/OWNER/REPO/workflows/Claude%20Code%20CI/badge.svg)
```text
```text

---

## Template Customization Logic

### Node Version Detection

### Priority order:
1. `.nvmrc` file
2. `package.json` → `engines.node`
3. Default: `18` (LTS)

### Implementation:
```bash
# Check .nvmrc
if [ -f .nvmrc ]; then
  NODE_VERSION=$(cat .nvmrc | tr -d 'v')
# Check package.json engines
elif [ -f package.json ]; then
  NODE_VERSION=$(jq -r '.engines.node // "18"' package.json | grep -oE '[0-9]+' | head -1)
else
  NODE_VERSION=18
fi
```text

### Build Command Detection

### Check `package.json` scripts:
```bash
jq -r '.scripts.build // "npm run build"' package.json
```text

### Common patterns:
- `"build": "next build"` → Next.js
- `"build": "vite build"` → Vite
- `"build": "react-scripts build"` → CRA
- `"build": "tsc"` → TypeScript-only

### Build Output Detection

### Framework → Output mapping:
| Framework | Output Directory |
|-----------|-----------------|
| Next.js | `.next/` |
| Vite | `dist/` |
| CRA | `build/` |
| Gatsby | `public/` |
| Nuxt | `.output/` |

### Implementation:
```bash
if jq -e '.dependencies.next' package.json > /dev/null; then
  BUILD_OUTPUT=".next/"
elif jq -e '.devDependencies.vite' package.json > /dev/null; then
  BUILD_OUTPUT="dist/"
# ... etc
fi
```text

---

## Multi-Template Support

### Available Templates

### Current:
- `claude-code.yml` - Node.js/TypeScript CI

### Future:
- `python-ci.yml` - Python with pytest, ruff, mypy
- `deploy-vercel.yml` - Auto-deploy to Vercel on merge to main
- `security-scan.yml` - Dependency vulnerability scanning with Snyk
- `terraform-plan.yml` - Terraform validate and plan

### Adding New Templates

**Step 1:** Create template file
```bash
~/.claude/templates/github-workflows/python-ci.yml
```text

**Step 2:** Update detection logic in this skill

**Step 3:** Add to template README

---

## Integration with Other Skills

### Combine with `gitignore-auto-setup`

When setting up a new repo:
```bash
/gitignore-auto-setup    # First
/setup-github-actions    # Then
```text

### Combine with `chat-history-search`

Before creating workflow:
```bash
/remind-yourself github actions setup
```text

Check if we've done similar before, reuse customizations.

---

## Common Customizations

### Add Vercel Deployment

### After Step 1 (Type Check), add:
```yaml
  deploy-preview:
    runs-on: ubuntu-latest
    needs: lint-and-typecheck
    if: github.event_name == 'pull_request'

    steps:
      - name: Deploy to Vercel (Preview)
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
```text

### Add Docker Build

```yaml
  docker-build:
    runs-on: ubuntu-latest
    needs: build

    steps:
      - name: Build Docker image
        run: docker build -t myapp:${{ github.sha }} .

      - name: Push to registry
        run: docker push myapp:${{ github.sha }}
```text

### Add Slack Notifications

```yaml
      - name: Notify Slack on failure
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "Build failed for ${{ github.repository }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```text

---

## Troubleshooting

### Workflow Not Running

### Check:
1. File is in `.github/workflows/` (not `.github/workflow/`)
2. File extension is `.yml` or `.yaml`
3. Syntax is valid (use YAML validator)
4. Branch name matches trigger (`main`, `develop`)

### Debug:
```bash
# Validate YAML syntax
yamllint .github/workflows/claude-code.yml

# Check workflow with GitHub CLI
gh workflow list
gh workflow view "Claude Code CI"
```text

### Build Fails in CI but Works Locally

### Common causes:
1. **Missing environment variables** - Add to GitHub Secrets
2. **Different Node version** - Check `node-version` in workflow
3. **Missing dependencies** - Ensure `package-lock.json` committed
4. **Build script not found** - Check `package.json` scripts

### Fix:
```yaml
# Add env vars
env:
  NODE_ENV: production
  NEXT_PUBLIC_API_URL: ${{ secrets.API_URL }}
```text

### Permission Errors

**Error:** `Push failed: permission denied`

**Fix:** Enable workflow permissions
1. GitHub repo → Settings → Actions → General
2. Workflow permissions → Read and write permissions
3. Save

---

## Best Practices

### 1. Always Commit `package-lock.json`

CI uses `npm ci` which requires lockfile.

### 2. Use Secrets for Sensitive Data

Never hardcode:
- API keys
- Database passwords
- Deploy tokens

### Add to GitHub Secrets:
```text
Settings → Secrets and variables → Actions → New repository secret
```text

### Reference in workflow:
```yaml
env:
  API_KEY: ${{ secrets.API_KEY }}
```text

### 3. Use Caching for Speed

Already included in template:
```yaml
- uses: actions/setup-node@v4
  with:
    cache: 'npm'    # Caches node_modules
```text

### 4. Continue on Non-Critical Errors

```yaml
- name: Run linter
  run: npm run lint
  continue-on-error: true    # Don't fail build if linter has warnings
```text

### 5. Use Matrix for Multi-Version Testing

```yaml
strategy:
  matrix:
    node-version: [18, 20, 22]

steps:
  - uses: actions/setup-node@v4
    with:
      node-version: ${{ matrix.node-version }}
```text

---

## Performance Optimization

**Token Budget:** ~1000-1500 tokens per setup

### Efficiency Tips:
1. **Read package.json once** - Extract all info in one jq call
2. **Batch file operations** - Create directory + copy file together
3. **Skip validation if gh not installed** - Don't waste time installing it

---

## Examples

### Example 1: Next.js Project

### User types:
```bash
/setup-github-actions
```text

### Claude detects:
- `package.json` has `"next": "14.0.0"`
- `package.json` scripts: `"build": "next build"`
- `.nvmrc`: `20`

### Generated workflow includes:
```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'

- run: npm run build

- uses: actions/upload-artifact@v4
  with:
    path: .next/
```text

### Example 2: Vite + TypeScript

### User types:
```bash
/setup-github-actions
```text

### Claude detects:
- `package.json` has `"vite": "^5.0.0"`
- `tsconfig.json` exists
- Default Node 18

### Generated workflow includes:
```yaml
- run: npx tsc --noEmit --skipLibCheck

- run: npm run build

- uses: actions/upload-artifact@v4
  with:
    path: dist/
```text

---

## Changelog

**v1.0** (2025-11-06) - Initial skill creation
- Template system for GitHub Actions
- `/setup-github-actions` command
- Auto-detection of project type
- Node version detection
- Build output customization

---

**Skill Status:** ✅ Active
**Maintainer:** LC Scheepers
**Last Updated:** 2025-11-06
