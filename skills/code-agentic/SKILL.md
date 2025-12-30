---
name: enforcing-agentic-protocols
description: Agentic execution protocols for Claude Code with verification gates, rollback mechanisms, and confidence thresholds. Triggers on any destructive or high-risk operations.
status: Active
version: 1.0.0
triggers:
  - destructive operations
  - high-risk changes
  - file deletions
---

# Claude Code Agentic Execution Protocol

This skill defines mandatory verification protocols for Claude Code operations to ensure safe, reversible, and confident execution.

## PARAMOUNT RULE: Dependency/Build Folder Exclusion

**NEVER read from dependency or build directories. These waste 50,000+ tokens per operation and provide zero value.**

### ⚠️ CRITICAL: permissions.deny IS BROKEN (as of v1.0.128)

**The `permissions.deny` configuration below DOES NOT WORK in current Claude Code versions.**

- **GitHub Issues:** [#6631](https://github.com/anthropics/claude-code/issues/6631), [#6699](https://github.com/anthropics/claude-code/issues/6699), [#4467](https://github.com/anthropics/claude-code/issues/4467)
- **Tested:** v1.0.128 (2025-11-05) - All deny rules ignored
- **Workaround:** Manual vigilance only - see enforcement protocol below

### Universal Exclusion List (Aspirational - For When Fixed)

### Configuration for project-level `.claude/settings.json`

```json
// .claude/settings.json (IN PROJECT ROOT, NOT ~/.claude/)
{
  "permissions": {
    "deny": [
      "Read(node_modules/**)",
      "Read(.next/**)",
      "Read(dist/**)",
      "Read(build/**)",
      "Read(out/**)",
      "Read(.turbo/**)",
      "Read(coverage/**)",
      "Read(__pycache__/**)",
      "Read(venv/**)",
      "Read(.venv/**)",
      "Read(env/**)",
      "Read(target/**)",
      "Read(vendor/**)",
      "Read(Pods/**)",
      "Read(DerivedData/**)",
      "Read(.gradle/**)",
      "Read(gradle/**)",
      "Read(.cargo/**)",
      "Read(pkg/**)",
      "Read(deps/**)",
      "Read(.pytest_cache/**)",
      "Read(.tox/**)",
      "Read(.egg-info/**)",
      "Read(site-packages/**)",
      "Read(.bundle/**)",
      "Read(tmp/**)",
      "Read(temp/**)",
      "Read(.cache/**)",
      "Read(.parcel-cache/**)",
      "Read(.nuxt/**)",
      "Read(.output/**)",
      "Read(.svelte-kit/**)",
      "Read(.astro/**)",
      "Read(.docusaurus/**)",
      "Read(.jekyll-cache/**)",
      "Read(.sass-cache/**)",
      "Read(.serverless/**)",
      "Read(.terraform/**)",
      "Read(.idea/**)",
      "Read(.vscode/**)",
      "Read(.DS_Store)",
      "Read(Thumbs.db)"
    ]
  }
}
```text

### Why This Is PARAMOUNT

| Action | Token Cost | Value | Result |
|--------|------------|-------|--------|
| Read `src/` | ~2,000 | High | ✅ Productive |
| Read `node_modules/` | ~50,000+ | Zero | ❌ Catastrophic waste |
| Read `__pycache__/` | ~10,000+ | Zero | ❌ Catastrophic waste |
| Read `target/` (Rust) | ~30,000+ | Zero | ❌ Catastrophic waste |

**One accidental read of node_modules/ can consume your entire daily API limit.**

### Enforcement Protocol (MANUAL VIGILANCE REQUIRED)

### Since `permissions.deny` is broken, you MUST manually enforce exclusions

### Before EVERY search/read operation

1. **Be Specific:** Never use broad commands like "search the project"
   - ❌ Bad: "search for all TODO comments"
   - ✅ Good: "search for TODO comments in src/ directory"

2. **Use Exclusion Flags:** Always use `rg` and `fd` with glob exclusions
   ```bash
   rg "pattern" --glob '!node_modules/*' --glob '!venv/*'
   fd "file" --exclude node_modules --exclude venv
   ```text

3. **Monitor Tokens:** Watch your token usage. If you see massive spikes (10k+), you likely hit a dependency folder

4. **Create .gitignore:** While not enforced, helps as visual reference
   ```bash
   test -f .gitignore || echo "node_modules/\nvenv/\ndist/\nbuild/" > .gitignore
   ```text

5. **Halt Immediately:** If Claude starts reading node_modules/, STOP the session (/clear)

## Pre-Execution Verification (MANDATORY)

Before **ANY** high-risk operation, document:

```yaml
assumption_ledger:
  file_exists:
    - path: ./src/index.js
      verified: false
      last_check: null
      fallback: create_if_missing
      confidence: 0.0

  permissions:
    - operation: write
      target: ./dist/
      verified: false
      user: unknown
      group: unknown
      mode: unknown

  dependencies:
    - package: express
      version: "^4.0.0"
      installed: unverified
      location: node_modules/  # NEVER READ THIS
      integrity: unchecked

  environment:
    - variable: NODE_ENV
      expected: production
      actual: unknown
      critical: true

  git_state:
    - branch: unknown
    - clean: unverified
    - remote: unchecked
    - conflicts: unknown
```text

## Claude Code Flags To Use For DEBUGGING

These are the REAL flags that exist:

```bash
# Debugging
claude --verbose              # Detailed output for debugging
claude --mcp-debug           # Debug MCP server issues

# Model selection - **ALWAYS USE 4.5 SONNET LATEST VERSION like
claude --model claude-sonnet-4-5-20250929

# Multi-directory access **ONLY IF WE ARE DOING SIMULTANEOUS MULTIPLE PROJECT CODING!!**
claude --add-dir ../apps ../lib

# Headless/scripting mode
claude -p "query" --output-format json

# Session management
claude -c                    # Continue last session
claude -r "session-id"       # Resume specific session

# Dangerous (use with extreme caution)
claude --dangerously-skip-permissions
```text

**DO NOT INVENT FLAGS.** If a flag doesn't exist, describe the concept in plain English.

## Manual Verification Steps

### Before any destructive operation

1. **State verification**
   - Run `git status` to check clean working directory
   - Run `git diff` to review uncommitted changes
   - Verify current branch with `git branch --show-current`

2. **Dependency check**
   - For Node.js: `npm ls` or `cat package-lock.json`
   - For Python: `pip freeze` or `cat requirements.txt`
   - For Rust: `cargo tree`
   - For Go: `go list -m all`

3. **Test existence**
   - Check if tests exist: `test -d tests/ || test -f *test*`
   - Run tests before changes: `npm test` or `pytest` or `cargo test`

4. **Rollback capability**
   - Verify git history: `git log --oneline -5`
   - Create safety branch: `git checkout -b backup-$(date +%Y%m%d-%H%M%S)`
   - Stash changes: `git stash push -m "pre-operation-backup"`

5. **Resource checks**
   - Disk space: `df -h .`
   - Memory available: `free -h` (Linux) or `vm_stat` (macOS)
   - Port availability: `lsof -i :3000-9999`

## Error Recovery Planning

### Before ANY Operation

```bash
# Create restoration point
git checkout -b safety-$(date +%Y%m%d-%H%M%S)
git stash push -m "pre-change-backup"

# Document current state
echo "Branch: $(git branch --show-current)" > .recovery-info
echo "Last commit: $(git log -1 --oneline)" >> .recovery-info
echo "Timestamp: $(date)" >> .recovery-info
```text

### Rollback Documentation Template

```markdown
## Rollback Plan
1. **Trigger Conditions:**
   - [ ] Build failure
   - [ ] Test regression
   - [ ] Runtime error
   - [ ] Data corruption

2. **Recovery Steps:**
   - Return to safety branch: `git checkout safety-YYYYMMDD-HHMMSS`
   - Restore stash: `git stash pop`
   - Reinstall deps: `npm ci` or `pip install -r requirements.txt`
   - Verify tests: `npm test` or `pytest`

3. **Verification:**
   - [ ] All tests passing
   - [ ] No data loss confirmed
   - [ ] Dependencies restored
```text

## Operation Classifications

```yaml
safe_operations:  # Can proceed with 99% confidence
  - read (excluding dependency folders)
  - list
  - git status
  - git log

risky_operations:  # Require 99.99999% confidence
  - write
  - modify
  - delete
  - install
  - npm install / pip install / cargo add

critical_operations:  # Require 99.9999999% + manual confirmation
  - database migrations
  - production deployments
  - rm -rf operations
  - credential modifications
  - git push to main/master
```text

## Execution Confidence Formula

```python
def compute_operation_confidence(op_type, assumptions):
    base_confidence = {
        "safe": 0.99,
        "risky": 0.9,
        "critical": 0.8
    }[op_type]

    for assumption in assumptions:
        if not assumption.verified:
            base_confidence *= 0.5  # Halve for each unverified
        if assumption.fallback == "none":
            base_confidence *= 0.7  # Reduce for no fallback

    return base_confidence
```text

## Critical Halt Conditions

### IMMEDIATELY STOP if

```python
HALT_CONDITIONS = [
    "Ambiguous file paths",
    "Unverified destructive operations",
    "Missing dependency specification",
    "Unclear rollback path",
    "Production environment detected without confirmation",
    "Credentials in plaintext",
    "Recursive deletion without bounds",
    "Port conflicts detected",
    "Insufficient disk space (<100MB)",
    "Git merge conflicts present",
    "Attempting to read node_modules/ or other excluded dirs",
]
```text

## Core Bash Tools (NO EXCEPTIONS)

### Pattern Search - USE 'rg' ONLY
```bash
rg -n "pattern" --glob '!node_modules/*'
rg -l "pattern"              # List matching files
rg -t py "pattern"           # Search Python files only
```text

### File Finding - USE 'fd' ONLY
```bash
fd filename                  # Find by name
fd -e py                     # Find Python files
fd -H .env                   # Include hidden
```text

### Bulk Operations - ONE command > many edits
```bash
rg -l "old" | xargs sed -i '' 's/old/new/g'
```text

### Preview - USE 'bat'
```bash
bat -n filepath              # With line numbers
bat -r 10:50 file            # Lines 10-50
```text

### JSON - USE 'jq'
```bash
jq '.dependencies | keys[]' package.json
```text

### Performance Rule
**If you can solve it in 1 CLI command, NEVER use multiple tool calls.**

## Examples

### Example 1: Safe File Read
```bash
# Operation: Read configuration
# Classification: safe
# Confidence: 99%
# Verification: File exists check only
bat package.json
```text

### Example 2: Package Installation
```bash
# Operation: npm install express
# Classification: risky
# Confidence required: 99.99999%

# Pre-checks:
git status                    # Verify clean
test -f package.json          # Verify file exists
df -h .                       # Check disk space (2GB free confirmed)
git checkout -b backup-$(date +%s)  # Safety branch

# Execute
npm install express

# Verify
npm ls express                # Confirm installed
git diff package.json         # Review changes
```text

### Example 3: Database Migration
```bash
# Operation: Apply schema changes
# Classification: critical
# Confidence required: 99.9999999% + manual confirmation

# Pre-checks:
pg_dump mydb > backup-$(date +%Y%m%d).sql  # Database backup verified
test -f migrations/001-add-users.sql        # Migration script exists
psql mydb -c "SELECT version()"            # Connection verified

# HALT: Request manual confirmation from user
echo "Ready to migrate. Confirm: yes/no"
```text

## Slash Commands Reference

Available during Claude Code sessions:

```bash
/help              # Show all available commands
/clear             # Reset conversation context
/compact           # Compress conversation history
/memory            # View CLAUDE.md files loaded
/permissions       # Manage tool permissions
/add-dir           # Add additional directories
/init              # Initialize CLAUDE.md for project
/model             # Switch AI model
/rewind            # Undo last changes (double escape)
```text

## Settings.json Quick Reference

```json
{
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Bash(git diff)",
      "Bash(npm test)"
    ],
    "ask": [
      "Bash(git push:*)",
      "Bash(npm install *)"
    ],
    "deny": [
      "Read(./node_modules/**)",
      "Read(./.env*)",
      "Read(./secrets/**)",
      "Bash(rm -rf:*)"
    ]
  }
}
```text

## Enforcement

NO operation without complete assumption documentation.  
NO guessing.  
NO reading dependency/build folders EVER.  
HALT and ASK when confidence < 99.9999999%.
