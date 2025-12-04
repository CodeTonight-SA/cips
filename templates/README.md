# Global Templates

Reusable configuration templates for all repositories.

## Structure

```text
~/.claude/templates/
└── github-workflows/          # GitHub Actions CI/CD workflows
    ├── README.md
    ├── claude-code.yml        # Standard Node.js/TS CI
    ├── python-ci.yml          # Python CI (future)
    └── deploy-vercel.yml      # Vercel deployment (future)
```text

## Usage

### Quick Setup (Automated)

```bash
# From any project directory:
/setup-github-actions
```text

Claude will:
1. Detect project type (Next.js, Vite, Python, etc.)
2. Copy appropriate template
3. Customize for your project (Node version, build commands)
4. Commit and push (optional)

### Manual Installation

```bash
# Copy template to project
mkdir -p .github/workflows
cp ~/.claude/templates/github-workflows/claude-code.yml .github/workflows/

# Customize if needed
micro .github/workflows/claude-code.yml

# Commit
git add .github/workflows/
git commit -m "Add GitHub Actions CI"
git push
```text

## Adding New Templates

1. **Create template file:**
   ```bash
   ~/.claude/templates/<category>/<template-name>
   ```text

2. **Document in category README:**
   ```bash
   ~/.claude/templates/<category>/README.md
   ```text

3. **Create corresponding skill** (if complex):
   ```bash
   ~/.claude/skills/<skill-name>/SKILL.md
   ```text

4. **Update this README**

## Available Template Categories

### GitHub Workflows (`github-workflows/`)
CI/CD automation via GitHub Actions

### Templates:
- `claude-code.yml` - Standard CI for Node.js/TypeScript projects

**Skill:** `github-actions-setup`
**Command:** `/setup-github-actions`

### Future Categories

### Planned:
- `docker/` - Dockerfile templates (Node, Python, Go)
- `terraform/` - Infrastructure as Code modules
- `vscode/` - VS Code/Cursor workspace settings
- `eslint/` - ESLint configurations
- `prettier/` - Prettier configurations

## Philosophy

**Why Templates?**

Many project configurations (CI/CD, linting, Docker, etc.) **must live in each repository** but follow the same patterns across projects.

### Benefits:
- ✅ **One source of truth** - Update template once, apply everywhere
- ✅ **Consistency** - All projects follow same standards
- ✅ **Speed** - Setup new projects in seconds
- ✅ **Best practices** - Baked into templates

### How It Works:
1. Store "golden templates" in `~/.claude/templates/`
2. Use skills to auto-install with project-specific customization
3. Commit to each repo (required by tools like GitHub Actions)

## Best Practices

### 1. Keep Templates Generic

Templates should work for **most** projects with minimal customization.

### Good:
```yaml
node-version: '18'    # Works for most projects
```text

### Bad:
```yaml
node-version: '20.5.1'    # Too specific
```text

### 2. Use Variables for Customization

```yaml
# Template uses variables
BUILD_OUTPUT: "${{ env.BUILD_DIR }}"

# Skill customizes based on detection
BUILD_DIR: "dist/"     # For Vite
BUILD_DIR: ".next/"    # For Next.js
```text

### 3. Document Customization Points

In template comments:
```yaml
# Customize: Change Node version based on .nvmrc or package.json engines
- uses: actions/setup-node@v4
  with:
    node-version: '18'
```text

### 4. Version Lock Dependencies

```yaml
# Good: Version locked
uses: actions/checkout@v4

# Bad: Floating version (breaks when v5 releases)
uses: actions/checkout@latest
```text

## Maintenance

**Review templates quarterly** to:
- Update action versions (e.g., `actions/checkout@v4` → `v5`)
- Add new best practices
- Remove deprecated features

### Changelog:
- 2025-11-06: Added `github-workflows/claude-code.yml`

---

**Last Updated:** 2025-11-06
