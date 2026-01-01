---
name: configuring-github-actions
description: Automatically configure GitHub Actions CI/CD workflows for any repository using global templates. Use when setting up a new repository or user invokes /setup-ci.
status: Active
version: 1.1.0
triggers:
  - /setup-ci
  - "setup github actions"
  - "add CI/CD"
---

# GitHub Actions Setup Skill

**Purpose:** Automatically configure GitHub Actions CI/CD workflows for any repository using global templates.

**Token Budget:** ~1000-1500 tokens per setup

**Reference:** See [reference.md](./reference.md) for workflow execution steps, template customization logic, common customizations, and troubleshooting.

---

## Core Principle

GitHub Actions workflows **must live in each repository** at `.github/workflows/`. This skill:

1. Stores global templates in `~/.claude/templates/github-workflows/`
2. Auto-installs with one command (`/setup-ci`)
3. Customizes for each project (detects framework, adapts build commands)

---

## Template Location

```text
~/.claude/templates/github-workflows/
├── README.md              # Template documentation
├── claude-code.yml        # Standard CI workflow (Node.js/TS)
├── python-ci.yml          # Python projects (future)
└── deploy-vercel.yml      # Vercel deployment (future)
```

---

## Command: `/setup-ci`

**Syntax:**

```bash
/setup-ci [template-name]
```

**Examples:**

```bash
/setup-ci                    # Use default (claude-code.yml)
/setup-ci claude-code        # Explicit template
/setup-ci python-ci          # Python template (future)
```

---

## Workflow Summary

### Step 1: Verify Git Repository

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

### Step 2: Detect Project Type

| File | Project Type |
|------|--------------|
| `package.json` with `"next"` | Next.js |
| `package.json` with `"vite"` | Vite |
| `package.json` with `"react"` | React |
| `requirements.txt` or `pyproject.toml` | Python |
| `Cargo.toml` | Rust |
| `go.mod` | Go |

### Step 3: Check Existing Workflows

```bash
ls .github/workflows/ 2>/dev/null
```

### Step 4: Create Directory & Copy Template

```bash
mkdir -p .github/workflows
cp ~/.claude/templates/github-workflows/claude-code.yml .github/workflows/
```

### Step 5: Apply Customizations

Detect and apply:
- Node version from `.nvmrc` or `package.json` engines
- Build command from `package.json` scripts
- Build output directory based on framework

### Step 6: Commit (Optional)

Ask user, then:

```bash
git add .github/workflows/claude-code.yml
git commit -m "Add GitHub Actions CI workflow"
git push origin $(git branch --show-current)
```

---

## Auto-Detection

### Node Version

| Priority | Source |
|----------|--------|
| 1 | `.nvmrc` file |
| 2 | `package.json` → `engines.node` |
| 3 | Default: `18` (LTS) |

### Build Output

| Framework | Output Directory |
|-----------|-----------------|
| Next.js | `.next/` |
| Vite | `dist/` |
| CRA | `build/` |
| Gatsby | `public/` |
| Nuxt | `.output/` |

---

## What the Workflow Does

- ✅ Runs linter on every push to `main`/`develop`
- ✅ Type checks TypeScript code
- ✅ Builds project to verify no build errors
- ✅ Runs tests (if configured)
- ✅ Uploads build artifacts

---

## Best Practices

| Practice | Why |
|----------|-----|
| Commit `package-lock.json` | CI uses `npm ci` which requires lockfile |
| Use GitHub Secrets | Never hardcode API keys or tokens |
| Use caching | `cache: 'npm'` speeds up installs |
| Use matrix for multi-version | Test on Node 18, 20, 22 |

---

## Troubleshooting

### Workflow Not Running

Check:
1. File is in `.github/workflows/` (not `.github/workflow/`)
2. File extension is `.yml` or `.yaml`
3. Branch name matches trigger (`main`, `develop`)

### Build Fails in CI but Works Locally

Common causes:
1. Missing environment variables → Add to GitHub Secrets
2. Different Node version → Check `node-version` in workflow
3. Missing dependencies → Ensure `package-lock.json` committed

### Permission Errors

Fix: GitHub repo → Settings → Actions → General → Workflow permissions → Read and write

---

## Integration

| Skill | Usage |
|-------|-------|
| `gitignore-auto-setup` | Run first when setting up new repo |
| `chat-history-search` | Check if similar setup done before |
| `github-secrets-setup` | Add secrets after workflow created |

---

## Changelog

**v1.1** (2025-12-30) - Split for compliance
- Moved detailed content to reference.md
- Under 500 line limit

**v1.0** (2025-11-06) - Initial creation
- Template system for GitHub Actions
- `/setup-ci` command
- Auto-detection of project type

---

**Skill Status:** ✅ Active
**Maintainer:** LC Scheepers
**Last Updated:** 2025-12-30

⛓⟿∞
