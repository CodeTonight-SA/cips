# PR Automation - Reference Material

**Parent:** [SKILL.md](./SKILL.md)

---

## Complete Workflow Example

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
```

**Result:** PR #35 created in ~1500 tokens.

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
```

### Scenario 2: Already on Feature Branch

```bash
# Already on feature/auth-redesign
git add app/auth/login.tsx
git commit -m "Redesign login page"
git push
gh pr create --base main --head feature/auth-redesign \
  --title "Redesign auth pages" \
  --body "Visual consistency improvements"
```

### Scenario 3: Draft PR (WIP)

```bash
gh pr create \
  --base main \
  --head feature/wip \
  --title "WIP: New feature" \
  --body "Work in progress" \
  --draft
```

### Scenario 4: Multiple Commits → Single PR

```bash
# User made 3 commits locally
git push -u origin feature-branch

# Create PR for all commits in branch
gh pr create --base main --head feature-branch \
  --title "Feature implementation" \
  --body "$(git log main..HEAD --pretty=format:'- %s')"
```

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
```

**Keep body <300 words.** Reviewers skim, don't read essays.

---

## Advanced Options

### Add Reviewers

```bash
gh pr create --title "..." --body "..." \
  --reviewer username1,username2
```

### Add Labels

```bash
gh pr create --title "..." --body "..." \
  --label "enhancement,frontend"
```

### Add Assignees

```bash
gh pr create --title "..." --body "..." \
  --assignee @me
```

### Link to Issue

In PR body, mention:
```markdown
Fixes #123
Closes #456
```

GitHub auto-links and closes issues when PR merges.

### Auto-merge on CI Pass

```bash
gh pr create --title "..." --body "..."
gh pr merge --auto --squash
```

---

## Error Handling

### Error: "gh: command not found"

```bash
# macOS
brew install gh

# Linux
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

### Error: "not authenticated"

```bash
gh auth login
# Follow prompts
```

### Error: "no commits between main and head"

**Cause:** Branch is up-to-date with base.
**Solution:** Make changes first, then create PR.

### Error: "pull request already exists"

```bash
# List PRs for current branch
gh pr list --head $(git branch --show-current)

# Or view existing PR
gh pr view
```

---

## Troubleshooting

### PR Shows Unintended Commits

**Cause:** Feature branch includes commits from other branches.

```bash
# Create clean branch from main
git checkout main
git pull
git checkout -b feature-clean
git cherry-pick <commit-hash>  # Only relevant commits
git push -u origin feature-clean
```

### PR Diff Shows Too Many Files

**Cause:** Base branch is outdated.

```bash
git checkout feature-branch
git rebase main
git push --force-with-lease
```

### Can't Push - "Updates were rejected"

**Cause:** Remote has changes not in local.

```bash
git pull --rebase origin feature-branch
git push
```

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
```

### 4. Clean Commit History

**Option 1:** Squash before PR
```bash
git rebase -i HEAD~3
git push --force-with-lease
```

**Option 2:** Use `--squash` when merging
```bash
gh pr merge --squash
```

### 5. Update Branch Before PR

```bash
git checkout main
git pull
git checkout feature-branch
git rebase main
git push --force-with-lease
```

---

## Efficiency Optimizations

### Batch Git Operations

```bash
# Bad (multiple calls)
git add file1.tsx
git add file2.tsx

# Good (single call)
git add file1.tsx file2.tsx && git rm old.jpg
```

### Use HEREDOC for Multi-line

```bash
# Bad (escaping hell)
git commit -m "Title\n\n- Point 1"

# Good (HEREDOC)
git commit -m "$(cat <<'EOF'
Title

- Point 1
EOF
)"
```

### Skip Interactive Prompts

Always use `--title` and `--body` flags - Don't rely on `gh pr create` interactive mode.

---

## Changelog

**v1.0** (2025-11-06) - Initial skill creation
- Standard PR workflow with gh CLI
- HEREDOC templates for commit messages and PR bodies
- Token budget optimization strategies
- Error handling and troubleshooting
