# GitHub Workflows Templates

Global templates for GitHub Actions workflows. Use the `/setup-github-actions` command or install manually.

## Available Templates

### `claude-code.yml`

Standard CI workflow for Node.js/TypeScript projects built with Claude Code.

### Features:

- Linting and type checking
- Build verification
- Test execution
- Artifact uploading

### Triggers:

- Push to `main` or `develop`
- Pull requests to `main` or `develop`
- Manual workflow dispatch

---

## Manual Installation

```bash
# From any project directory:
mkdir -p .github/workflows
cp ~/.claude/templates/github-workflows/claude-code.yml .github/workflows/
git add .github/workflows/claude-code.yml
git commit -m "Add GitHub Actions CI workflow"
git push
```text

---

## Automated Installation (Claude Code)

Use the `/setup-github-actions` slash command:

```bash
/setup-github-actions
```text

This will:
1. Create `.github/workflows/` directory
2. Copy template files
3. Customize for current project (detect framework, build commands)
4. Commit and push (if requested)

---

## Customization

After installation, edit `.github/workflows/claude-code.yml` to:

- Add environment-specific steps
- Configure deployment
- Add additional jobs (e.g., Docker build, deploy to Vercel)
- Customize test commands

---

## Framework-Specific Notes

### Next.js
- Build output: `.next/`
- Build command: `npm run build`
- No additional config needed

### Vite
- Build output: `dist/`
- Build command: `npm run build`
- No additional config needed

### Python
Create `python-ci.yml` template with:
- `actions/setup-python@v4`
- `pip install -r requirements.txt`
- `pytest` for testing

---

## Future Templates

### Planned:
- `deploy-vercel.yml` - Auto-deploy to Vercel on merge
- `security-scan.yml` - Dependency vulnerability scanning
- `python-ci.yml` - Python projects (pytest, ruff, mypy)
- `terraform-plan.yml` - Terraform validation and plan

---

**Last Updated:** 2025-11-06
