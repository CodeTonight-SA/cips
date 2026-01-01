# GitHub Actions Setup - Reference Material

**Parent:** [SKILL.md](./SKILL.md)

---

## Workflow Execution Steps

### Step 1: Verify Git Repository

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

### Step 2: Detect Project Type

Check for:
- `package.json` → Node.js
  - `"next"` in dependencies → Next.js
  - `"vite"` in devDependencies → Vite
  - `"react"` → React
- `requirements.txt` or `pyproject.toml` → Python
- `Cargo.toml` → Rust
- `go.mod` → Go

### Step 3: Check Existing Workflows

```bash
ls .github/workflows/ 2>/dev/null
```

### Step 4: Create Directory

```bash
mkdir -p .github/workflows
```

### Step 5: Copy Template with Customization

Base: `~/.claude/templates/github-workflows/claude-code.yml`

### Step 6: Write & Commit

```bash
git add .github/workflows/claude-code.yml
git commit -m "Add GitHub Actions CI workflow"
git push origin $(git branch --show-current)
```

---

## Template Customization Logic

### Node Version Detection

Priority:
1. `.nvmrc` file
2. `package.json` → `engines.node`
3. Default: `18` (LTS)

```bash
if [ -f .nvmrc ]; then
  NODE_VERSION=$(cat .nvmrc | tr -d 'v')
elif [ -f package.json ]; then
  NODE_VERSION=$(jq -r '.engines.node // "18"' package.json | grep -oE '[0-9]+' | head -1)
else
  NODE_VERSION=18
fi
```

### Build Command Detection

```bash
jq -r '.scripts.build // "npm run build"' package.json
```

Common patterns:
- `"build": "next build"` → Next.js
- `"build": "vite build"` → Vite
- `"build": "react-scripts build"` → CRA

### Build Output Detection

| Framework | Output Directory |
|-----------|-----------------|
| Next.js | `.next/` |
| Vite | `dist/` |
| CRA | `build/` |
| Gatsby | `public/` |
| Nuxt | `.output/` |

```bash
if jq -e '.dependencies.next' package.json > /dev/null; then
  BUILD_OUTPUT=".next/"
elif jq -e '.devDependencies.vite' package.json > /dev/null; then
  BUILD_OUTPUT="dist/"
fi
```

---

## Common Customizations

### Add Vercel Deployment

```yaml
deploy-preview:
  runs-on: ubuntu-latest
  needs: lint-and-typecheck
  if: github.event_name == 'pull_request'
  steps:
    - name: Deploy to Vercel
      uses: amondnet/vercel-action@v25
      with:
        vercel-token: ${{ secrets.VERCEL_TOKEN }}
        vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
        vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
```

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
```

### Add Slack Notifications

```yaml
- name: Notify Slack on failure
  if: failure()
  uses: slackapi/slack-github-action@v1
  with:
    payload: |
      {"text": "Build failed for ${{ github.repository }}"}
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

---

## Troubleshooting

### Workflow Not Running

Check:
1. File is in `.github/workflows/` (not `.github/workflow/`)
2. File extension is `.yml` or `.yaml`
3. Syntax is valid
4. Branch name matches trigger (`main`, `develop`)

Debug:
```bash
yamllint .github/workflows/claude-code.yml
gh workflow list
gh workflow view "Claude Code CI"
```

### Build Fails in CI but Works Locally

Common causes:
1. Missing environment variables → Add to GitHub Secrets
2. Different Node version → Check `node-version` in workflow
3. Missing dependencies → Ensure `package-lock.json` committed
4. Build script not found → Check `package.json` scripts

Fix:
```yaml
env:
  NODE_ENV: production
  NEXT_PUBLIC_API_URL: ${{ secrets.API_URL }}
```

### Permission Errors

Fix: Enable workflow permissions
1. GitHub repo → Settings → Actions → General
2. Workflow permissions → Read and write permissions
3. Save

---

## Best Practices

### 1. Always Commit package-lock.json
CI uses `npm ci` which requires lockfile.

### 2. Use Secrets for Sensitive Data
```text
Settings → Secrets and variables → Actions → New repository secret
```

Reference:
```yaml
env:
  API_KEY: ${{ secrets.API_KEY }}
```

### 3. Use Caching for Speed
```yaml
- uses: actions/setup-node@v4
  with:
    cache: 'npm'
```

### 4. Continue on Non-Critical Errors
```yaml
- name: Run linter
  run: npm run lint
  continue-on-error: true
```

### 5. Use Matrix for Multi-Version Testing
```yaml
strategy:
  matrix:
    node-version: [18, 20, 22]
steps:
  - uses: actions/setup-node@v4
    with:
      node-version: ${{ matrix.node-version }}
```

---

## Examples

### Next.js Project

Claude detects:
- `package.json` has `"next": "14.0.0"`
- `package.json` scripts: `"build": "next build"`
- `.nvmrc`: `20`

Generated:
```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'
- run: npm run build
- uses: actions/upload-artifact@v4
  with:
    path: .next/
```

### Vite + TypeScript

Claude detects:
- `package.json` has `"vite": "^5.0.0"`
- `tsconfig.json` exists

Generated:
```yaml
- run: npx tsc --noEmit --skipLibCheck
- run: npm run build
- uses: actions/upload-artifact@v4
  with:
    path: dist/
```

---

## Changelog

**v1.0** (2025-11-06) - Initial creation
- Template system for GitHub Actions
- `/setup-github-actions` command
- Auto-detection of project type
- Node version detection
- Build output customization
