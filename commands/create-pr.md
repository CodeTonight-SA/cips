---
description: Efficient PR creation with gh CLI - automated branch, commit, push, and pr-create workflow in <2k tokens
disable-model-invocation: false
---

# Create PR

Automates the complete pull request creation workflow using GitHub CLI (`gh`) with minimal token usage.

## What It Does

Executes efficient PR workflow:

1. **Analyze Changes** - Run `git status`, `git diff --stat`, check commit history
2. **Create/Switch Branch** - Create feature branch if needed
3. **Stage Files** - Batch `git add` operations (not individual adds)
4. **Commit** - Use HEREDOC for proper multi-line commit messages
5. **Push** - Push with `-u` flag to set upstream
6. **Create PR** - Use `gh pr create` with HEREDOC body
7. **Return URL** - Provide PR link to user

## Usage

```bash
/create-pr
```text

### Activation:
- User says "create PR", "open pull request", "make PR"
- User says "submit changes for review"
- Auto-suggested after completing multi-file feature

## Prerequisites

Command validates:
- ✅ `gh` CLI installed (`which gh`)
- ✅ GitHub authenticated (`gh auth status`)
- ✅ Inside git repository (`git rev-parse --is-inside-work-tree`)

If any check fails, guides user to install/setup.

## Workflow Example

```bash
# 1. Analyze changes
git status --short && git diff --stat

# 2. Create branch (if needed)
git checkout -b feature/new-feature

# 3. Batch staging
git add file1.tsx file2.tsx components/

# 4. Commit with HEREDOC
git commit -m "$(cat <<'EOF'
Add new feature with tests

- Implement core functionality
- Add unit tests
- Update documentation
EOF
)"

# 5. Push with upstream
git push -u origin feature/new-feature

# 6. Create PR with HEREDOC
gh pr create --title "Add new feature" --body "$(cat <<'EOF'
## Summary
- Bullet point 1
- Bullet point 2

## Test plan
- [ ] Test item 1
- [ ] Test item 2
EOF
)"
```text

## Token Budget

- **Target**: <2k tokens per PR
- **Actual average**: ~1500 tokens
- **Efficiency gains**:
  - Batch operations > individual commands
  - HEREDOC > string escaping
  - Parallel git commands when possible

## Best Practices

✅ **Batch git operations**: `git add X Y Z` not `git add X && git add Y`
✅ **HEREDOC for multi-line**: Always use `$(cat <<'EOF' ... EOF)` format
✅ **Concise PR bodies**: Bullet points, not paragraphs
✅ **Analyze before commit**: Review `git diff` to understand scope
✅ **Check commit history**: `git log` to match repo's commit style

❌ **Never**: Run additional code exploration unless needed
❌ **Never**: Create empty commits
❌ **Never**: Push without checking branch is correct

## Integration

Loads the `pr-automation` skill from:
```bash
~/.claude/skills/pr-automation/SKILL.md
```text

## Related

- `/audit-efficiency` - Validate batch operations usage
- `/refresh-context` - Understand recent git history
- See `EFFICIENCY_CHECKLIST.md` for batch operation protocols
