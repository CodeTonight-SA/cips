---
name: automating-pull-requests
description: Efficient PR creation with gh CLI - automated branch, commit, push, and pr-create. Use when user asks to create PR, open pull request, or invokes /create-pr.
status: Active
version: 1.0.0
triggers:
  - /create-pr
  - "create PR"
  - "open pull request"
---

# PR Automation Skill

**Purpose:** Automate the complete PR creation workflow using GitHub CLI (`gh`) with minimal token usage.

**Token Budget:** <2k per PR creation

**Reference:** See [reference.md](./reference.md) for full examples, error handling, and troubleshooting.

---

## Core Principles

1. **Efficiency First** - Single command chains, no redundant operations
2. **Concise PRs** - Bullet points, not essays
3. **HEREDOC for bodies** - Proper formatting without escaping issues

---

## Prerequisites

```bash
which gh >/dev/null || echo "gh not installed"
gh auth status
git rev-parse --is-inside-work-tree
```

---

## Standard Workflow

### Step 1: Analyze Changes

```bash
git status --short
git diff --stat
```

### Step 2: Create Feature Branch (if needed)

```bash
CURRENT=$(git branch --show-current)
if [[ "$CURRENT" == "main" || "$CURRENT" == "develop" ]]; then
  git checkout -b feature/descriptive-name
fi
```

**Branch naming:**
- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation only
- `chore/` - Maintenance tasks

### Step 3: Stage Changes

```bash
git add file1.tsx file2.tsx && git rm old.jpg
```

### Step 4: Commit with HEREDOC

```bash
git commit -m "$(cat <<'EOF'
Redesign auth pages for visual consistency

- Unified login/register layouts with landing page
- Reduced card sizes, improved typography
- Created RedrLinkButton component (DRY)

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**Critical:** Use `<<'EOF'` (quoted) to prevent variable expansion.

### Step 5: Push to Remote

```bash
git push -u origin feature-branch-name
```

### Step 6: Create PR

```bash
gh pr create \
  --base main \
  --head feature-branch-name \
  --title "Concise PR title" \
  --body "$(cat <<'EOF'
## Changes
- Bullet point summary of changes
- What was modified and why

## Files Modified
- `path/to/file.tsx` - Brief description

## Testing
- ✅ Test criterion 1
- ✅ Test criterion 2

🤖 Generated with Claude Code
EOF
)"
```

---

## PR Body Template

```markdown
## Changes
- High-level summary (WHY, not just WHAT)

## Files Modified
- `path/to/file` - Brief description

## Visual Changes (if UI)
- Before/after comparison

## Testing
- ✅ Criterion 1
- ✅ Criterion 2

🤖 Generated with Claude Code
```

**Keep body <300 words.** Reviewers skim.

---

## Efficiency Optimizations

### Batch Git Operations

```bash
# Bad
git add file1.tsx
git add file2.tsx

# Good
git add file1.tsx file2.tsx
```

### Use HEREDOC for Multi-line

```bash
# Bad
git commit -m "Title\n\n- Point 1"

# Good
git commit -m "$(cat <<'EOF'
Title

- Point 1
EOF
)"
```

### Skip Interactive Prompts

Always use `--title` and `--body` flags.

---

## Token Budget Breakdown

| Step | Tokens |
|------|--------|
| Analyze changes | ~200 |
| Create branch | ~50 |
| Stage files | ~100 |
| Generate commit msg | ~300 |
| Commit | ~100 |
| Push | ~100 |
| Generate PR body | ~500 |
| Create PR | ~200 |
| **Total** | **~1550** |

---

## Common Errors

| Error | Solution |
|-------|----------|
| `gh: command not found` | `brew install gh` |
| `not authenticated` | `gh auth login` |
| `no commits between main and head` | Make changes first |
| `pull request already exists` | `gh pr view` |

---

## Best Practices

### 1. Small, Focused PRs
One feature/fix per PR.

### 2. Descriptive Titles
**Good:** "Redesign auth pages for mobile responsiveness"
**Bad:** "Update files"

### 3. Test Before Creating PR

```bash
npm run lint && npm run build && npm test
```

### 4. Clean Commit History

```bash
git rebase -i HEAD~3  # Squash before PR
```

### 5. Update Branch Before PR

```bash
git checkout main && git pull
git checkout feature-branch && git rebase main
```

---

## Integration

| Skill | Usage |
|-------|-------|
| `chat-history-search` | Reuse successful PR structures |
| `github-actions-setup` | Add CI workflow to new repos |
| `code-agentic` | Verification gate before PR |

---

**Skill Status:** ✅ Active
**Maintainer:** LC Scheepers
**Last Updated:** 2025-11-06

⛓⟿∞
