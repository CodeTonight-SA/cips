---
name: gitignore-auto-setup
description: Automatically create and maintain .gitignore files to prevent token waste on ignored directories. Triggers on first project interaction or when .gitignore is missing/incomplete.
---

# .gitignore Enforcement Protocol

This skill prevents token waste by ensuring proper .gitignore configuration before any file operations.

## Auto-Detection and Creation

### Trigger Conditions

- First interaction in new project directory
- `.gitignore` file missing
- `.gitignore` file empty or incomplete
- Before any `Read/Grep/Glob` operations

### Detection Phase

```bash
# Check if .gitignore exists in project root
test -f .gitignore || echo "MISSING: .gitignore required"
```text

## Framework Detection Logic

Detect framework from project files and apply appropriate patterns:

```python
if exists("package.json"): apply_nodejs_gitignore()
if exists("requirements.txt") or exists("pyproject.toml"): apply_python_gitignore()
if exists("Cargo.toml"): apply_rust_gitignore()
if exists("go.mod"): apply_go_gitignore()
if exists("pom.xml") or exists("build.gradle"): apply_java_gitignore()
```text

## Framework-Specific Templates

### Node.js/Next.js/React
```gitignore
# Dependencies
node_modules/
.pnp/
.pnp.js

# Build outputs
.next/
out/
dist/
build/
.turbo/

# Deployment
.vercel/
.netlify/

# Environment
.env*.local
.env.production

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnpm-debug.log*

# Testing
coverage/
.nyc_output/

# OS
.DS_Store
Thumbs.db
```text

### Python
```gitignore
# Byte-compiled / optimized
__pycache__/
*.py[cod]
*$py.class
.Python

# Virtual environments
venv/
env/
ENV/
.venv/

# Testing
.pytest_cache/
.coverage
htmlcov/
.tox/

# Build
dist/
build/
*.egg-info/
*.egg

# Jupyter
.ipynb_checkpoints/

# OS
.DS_Store
```text

### Rust
```gitignore
# Build
target/
Cargo.lock

# IDE
.idea/
.vscode/

# OS
.DS_Store
```text

### Go
```gitignore
# Build
bin/
*.exe
*.dll
*.so
*.dylib

# Test coverage
*.out
coverage.txt

# Dependency directories
vendor/

# OS
.DS_Store
```text

### General (Always Include)
```gitignore
# IDEs
.idea/
.vscode/
*.swp
*.swo
*~

# Environment files
.env
.env.local
.env.*.local

# OS files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
```text

## Token Waste Prevention Rules

**NEVER** use Read/Grep/Glob on:
- `node_modules/`
- `__pycache__/`
- `venv/`, `.venv/`, `env/`
- `dist/`, `build/`, `.next/`, `out/`
- `target/` (Rust)
- `vendor/` (Go)

**ALWAYS** use exclusion flags:
```bash
# With rg
rg "pattern" --glob '!node_modules/*' --glob '!venv/*'

# With fd
fd "file" --exclude node_modules --exclude venv
```text

## Assumption Ledger Template

```yaml
gitignore_status:
  exists: true
  framework: nodejs  # or python, rust, go, etc.
  critical_patterns_present: true
  verified: true
  token_waste_risk: eliminated
```text

## Auto-Creation Workflow

1. **Detect**: Check if `.gitignore` exists
2. **Analyze**: Identify framework(s) from project files
3. **Generate**: Create `.gitignore` with appropriate patterns
4. **Verify**: Confirm critical patterns present
5. **Document**: Update assumption ledger
6. **Proceed**: Continue with original task

## Integration with Search Tools

Before **EVERY** `rg`, `fd`, `Read`, or `Glob` operation:
1. Verify `.gitignore` exists
2. Confirm exclusion patterns active
3. Use explicit `--glob '!pattern'` or `--exclude pattern` flags

## Examples

### Example 1: New Next.js Project
```bash
# User starts work in new project
# Skill detects package.json, no .gitignore
# Auto-creates .gitignore with Node.js patterns
# Proceeds with task
```text

### Example 2: Python Project Missing .gitignore
```bash
# User asks to search for imports
# Skill detects requirements.txt, no .gitignore
# Creates .gitignore with Python patterns
# Executes search with proper exclusions
```text

## Anti-Patterns

❌ Reading from `node_modules/` without .gitignore check  
❌ Grepping through `__pycache__/` directories  
❌ Empty .gitignore files  
❌ Generic .gitignore without framework-specific patterns  
❌ Using search tools without exclusion flags  
❌ Assuming .gitignore exists without verification

## Rationale

Reading from ignored directories (especially `node_modules/`) can waste thousands of tokens per operation. Proactive `.gitignore` creation and enforcement prevents this systematically.

**Token Impact**: Reading `node_modules/` in a typical Next.js project can consume 50,000+ tokens. This skill prevents that waste entirely.
