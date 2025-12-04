---
name: pr-automation
description: Efficient PR creation with gh CLI - automated branch, commit, push, and pr-create. Use when user asks to "create PR", "open pull request", or "make PR".
---

# PR Automation Skill

**Purpose:** Automate the complete PR creation workflow using GitHub CLI (`gh`) with minimal token usage.

**Activation:** When user asks to create a PR, open a pull request, or similar phrasing.

---

## Core Principles

1. **Efficiency First** - Single command chains, no redundant operations
2. **Concise PRs** - Bullet points, not essays
3. **HEREDOC for bodies** - Proper formatting without escaping issues
4. **Token Budget** - Target: <2k per PR creation

---

## Prerequisites

### Check before executing:

```bash
# 1. Verify gh CLI installed
which gh >/dev/null || echo "gh not installed"

# 2. Verify authenticated
gh auth status

# 3. Verify in git repo
git rev-parse --is-inside-work-tree
```text

If any check fails, guide user to install/setup.

---

## Standard Workflow

### Step 1: Analyze Changes

```bash
# Get modified files
git status --short

# Get diff summary
git diff --stat
```text

### Parse output to identify:
- Files modified
- Files added
- Files deleted
- Rough change scope

### Step 2: Create Feature Branch (if needed)

```bash
# Check current branch
CURRENT=$(git branch --show-current)

# If on main/develop, create feature branch
if [[ "$CURRENT" == "main" || "$CURRENT" == "develop" ]]; then
  BRANCH="feature/descriptive-name"
  git checkout -b "$BRANCH"
fi
```text

### Branch naming convention:
- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation only
- `chore/` - Maintenance tasks

### Step 3: Stage Changes

```bash
# Stage relevant files
git add file1.tsx file2.tsx

# Remove deleted files
git rm deleted-file.jpg

# Or stage all if appropriate
git add -A
```text

### Step 4: Generate Commit Message

### Format:
```text
<imperative-verb> <concise-summary>

- Bullet point detail 1
- Bullet point detail 2
- Bullet point detail 3

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>
```text

**Imperative verbs:** Add, Update, Fix, Refactor, Remove, Redesign, Implement, Create

### Step 5: Commit with HEREDOC

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
```text

**Critical:** Use `<<'EOF'` (quoted) to prevent variable expansion.

### Step 6: Push to Remote

```bash
# First push (set upstream)
git push -u origin feature-branch-name

# Subsequent pushes
git push
```text

### Step 7: Create PR with gh CLI

```bash
gh pr create \
  --base main \
  --head feature-branch-name \
  --title "Concise PR title (imperative, <60 chars)" \
  --body "$(cat <<'EOF'
## Changes
- Bullet point summary of changes
- What was modified and why
- Any new components/features

## Files Modified
- `path/to/file1.tsx` - Brief description
- `path/to/file2.tsx` - Brief description

## Testing
- ✅ Test criterion 1
- ✅ Test criterion 2
- ✅ Test criterion 3

🤖 Generated with Claude Code
EOF
)"
```text

**Returns:** PR URL (e.g., `https://github.com/owner/repo/pull/35`)

---

## Efficiency Optimizations

### Batch Git Operations

### Bad (multiple calls):
```bash
git add file1.tsx
git add file2.tsx
git rm old.jpg
```text

### Good (single call):
```bash
git add file1.tsx file2.tsx && git rm old.jpg
```text

### Use HEREDOC for Multi-line

### Bad (escaping hell):
```bash
git commit -m "Title\n\n- Point 1\n- Point 2"
```text

### Good (HEREDOC):
```bash
git commit -m "$(cat <<'EOF'
Title

- Point 1
- Point 2
EOF
)"
```text

### Skip Interactive Prompts

**Always use `--title` and `--body` flags** - Don't rely on `gh pr create` interactive mode (wastes tokens waiting for input).

---

## PR Body Template

```markdown
## Changes
- High-level summary of what changed
- Focus on WHY, not just WHAT

## Files Modified
- `path/to/file` - Brief description
- Keep this section factual and concise

## Visual Changes (if UI)
- Before/after comparison
- Key measurements (e.g., "Card width: 600px → 520px")

## Testing
- ✅ Criterion 1
- ✅ Criterion 2
- ✅ Criterion 3

🤖 Generated with Claude Code
```text

**Keep body <300 words.** Reviewers skim, don't read essays.

---

## Common Scenarios

### Scenario 1: Feature Branch from Main

```bash
git checkout -b feature/new-component
# ... make changes ...
git add src/components/NewComponent.tsx
git commit -m "Add NewComponent with props interface"
git push -u origin feature/new-component
gh pr create --base main --head feature/new-component \
  --title "Add NewComponent" \
  --body "Implements NewComponent with TypeScript props"
```text

### Scenario 2: Already on Feature Branch

```bash
# Already on feature/auth-redesign
git add app/auth/login.tsx
git commit -m "Redesign login page"
git push
gh pr create --base main --head feature/auth-redesign \
  --title "Redesign auth pages" \
  --body "Visual consistency improvements"
```text

### Scenario 3: Draft PR (WIP)

```bash
gh pr create \
  --base main \
  --head feature/wip \
  --title "WIP: New feature" \
  --body "Work in progress" \
  --draft  # Marks as draft
```text

### Scenario 4: Multiple Commits → Single PR

```bash
# User made 3 commits locally
git push -u origin feature-branch

# Create PR for all commits in branch
gh pr create --base main --head feature-branch \
  --title "Feature implementation" \
  --body "$(git log main..HEAD --pretty=format:'- %s')"  # Auto-list commits
```text

---

## Error Handling

### Error: "gh: command not found"

### Solution:
```bash
# macOS
brew install gh

# Linux
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```text

### Error: "not authenticated"

### Solution:
```bash
gh auth login
# Follow prompts
```text

### Error: "no commits between main and head"

**Cause:** Branch is up-to-date with base.

**Solution:** Make changes first, then create PR.

### Error: "pull request already exists"

### Solution:
```bash
# List PRs for current branch
gh pr list --head $(git branch --show-current)

# Or view existing PR
gh pr view
```text

---

## Advanced Options

### Add Reviewers

```bash
gh pr create --title "..." --body "..." \
  --reviewer username1,username2
```text

### Add Labels

```bash
gh pr create --title "..." --body "..." \
  --label "enhancement,frontend"
```text

### Add Assignees

```bash
gh pr create --title "..." --body "..." \
  --assignee @me
```text

### Link to Issue

### In PR body, mention:
```markdown
Fixes #123
Closes #456
```text

GitHub auto-links and closes issues when PR merges.

### Auto-merge on CI Pass

```bash
# Create PR
gh pr create --title "..." --body "..."

# Enable auto-merge
gh pr merge --auto --squash
```text

---

## Token Budget Breakdown

**Target:** <2k tokens per PR

| Step | Tokens |
|------|--------|
| Analyze changes (git status/diff) | ~200 |
| Create branch | ~50 |
| Stage files | ~100 |
| Generate commit msg | ~300 |
| Commit | ~100 |
| Push | ~100 |
| Generate PR body | ~500 |
| Create PR | ~200 |
| **Total** | **~1550** |

### Efficiency wins:
- Batch git operations (save ~100 tokens)
- Concise PR bodies (save ~300 tokens vs verbose)
- No interactive prompts (save ~200 tokens)

---

## Integration with Other Skills

### Combine with `chat-history-search`

Before creating PR:
```bash
/remind-yourself similar PR format
```text

Reuse successful PR structures from past.

### Combine with `claude-code-agentic`

### Verification gate:
1. Create PR
2. Run CI locally first
3. Fix any failures
4. Push fixes
5. PR is green

### Combine with `github-actions-setup`

After creating repo:
```bash
/setup-github-actions    # First
/create-pr               # Then (to add workflow)
```text

---

## Best Practices

### 1. Small, Focused PRs

**Good:** One feature/fix per PR

**Bad:** Multiple unrelated changes in one PR

### 2. Descriptive Titles

**Good:** "Redesign auth pages for mobile responsiveness"

**Bad:** "Update files"

### 3. Test Before Creating PR

```bash
npm run lint
npm run build
npm test
# All pass → create PR
```text

### 4. Clean Commit History

**Option 1:** Squash before PR
```bash
git rebase -i HEAD~3  # Squash last 3 commits
git push --force-with-lease
```text

**Option 2:** Use `--squash` when merging
```bash
gh pr merge --squash
```text

### 5. Update Branch Before PR

```bash
git checkout main
git pull
git checkout feature-branch
git rebase main  # Or: git merge main
git push --force-with-lease
```text

---

## Troubleshooting

### PR Shows Unintended Commits

**Cause:** Feature branch includes commits from other branches.

### Fix:
```bash
# Create clean branch from main
git checkout main
git pull
git checkout -b feature-clean
git cherry-pick <commit-hash>  # Only relevant commits
git push -u origin feature-clean
```text

### PR Diff Shows Too Many Files

**Cause:** Base branch is outdated.

### Fix:
```bash
git checkout feature-branch
git rebase main  # Update with latest main
git push --force-with-lease
```text

### Can't Push - "Updates were rejected"

**Cause:** Remote has changes not in local.

### Fix:
```bash
git pull --rebase origin feature-branch
git push
```text

---

## Examples from This Session

### REDR Auth Redesign PR

```bash
git checkout -b feature/auth-page-redesign
git add app/auth/login/page.tsx app/auth/register/page.tsx \
  components/redr-link-button.tsx components/confetti-animation.tsx \
  app/page.tsx components/redr-button.tsx \
  public/images/*.jpg
git rm public/images/cta2.jpg public/images/iStock-2032308693_edit.jpg \
  public/images/img3.jpg public/images/register-marina.jpg

git commit -m "$(cat <<'EOF'
Redesign auth pages for visual consistency

- Unified login/register layouts with landing page
- Reduced card sizes (600px → 520-560px), improved typography
- Created RedrLinkButton component (DRY principle)
- Added right-aligned layout on desktop, centered on mobile
- Updated background images for visual cohesion

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

git push -u origin feature/auth-page-redesign

gh pr create --base main --head feature/auth-page-redesign \
  --title "Redesign auth pages for visual consistency" \
  --body "$(cat <<'EOF'
## Changes
- Unified login/register page layouts with landing page aesthetic
- Reduced card sizes, improved typography hierarchy
- Created RedrLinkButton component (DRY principle)

## Files Modified
- app/auth/login/page.tsx - Complete layout redesign
- app/auth/register/page.tsx - Consistent styling + CTA
- components/redr-link-button.tsx - New reusable link component

## Visual Changes
- Login card: 600px → 520-560px max-width
- Input heights: uniform h-11
- Typography: Scaled down headings

## Testing
- ✅ Mobile responsive (320px+)
- ✅ Tablet layout (640px+)
- ✅ Desktop layout (1024px+)

🤖 Generated with Claude Code
EOF
)"
```text

**Result:** PR #35 created in ~1500 tokens.

---

## Changelog

**v1.0** (2025-11-06) - Initial skill creation
- Standard PR workflow with gh CLI
- HEREDOC templates for commit messages and PR bodies
- Token budget optimization strategies
- Error handling and troubleshooting

---

**Skill Status:** ✅ Active
**Maintainer:** LC Scheepers
**Last Updated:** 2025-11-06
**Token Budget:** <2k per execution
