---
name: cleaning-git-branches
description: Git branch pruning and cleanup automation. Use when user asks to clean up branches, prune git, or delete old branches.
status: Active
version: 1.0.0
triggers:
  - /prune-branches
  - "clean branches"
  - "prune git"
---

# Branch Cleanup Skill

**Purpose:** Automate git branch cleanup with safety gates, dry-run previews, and protected branch lists.

**Activation:** When user asks to clean branches, prune git tree, or delete stale branches.

## Core Principles

1. **Safety First** - Always preview before delete
2. **Protected Branches** - Never delete main, develop, or user-specified branches
3. **Merged vs Unmerged** - Handle differently with explicit confirmation
4. **Token Efficient** - Batch operations, minimal output

## Prerequisites

```bash
git rev-parse --is-inside-work-tree
git remote -v
```

## Workflow

### Phase 1: Analysis

```bash
git fetch --prune

echo "=== LOCAL BRANCHES ==="
git branch -vv

echo "=== MERGED INTO MAIN ==="
git branch --merged main | rg -v '^\*|main|develop'

echo "=== NOT MERGED ==="
git branch --no-merged main

echo "=== STALE TRACKING (gone) ==="
git branch -vv | rg ': gone]'

echo "=== REMOTE MERGED ==="
git branch -r --merged origin/main | rg -v 'main|HEAD|develop'
```

### Phase 2: Safe Deletions (Merged)

```bash
git branch --merged main | rg -v '^\*|main|develop' | xargs -r git branch -d
```

### Phase 3: Unmerged Review

For each unmerged branch, show:

```bash
git log main..$BRANCH --oneline | head -5
```

Require explicit user confirmation before `-D` (force delete).

### Phase 4: Remote Cleanup

```bash
git branch -r --merged origin/main | rg -v 'main|HEAD|develop' | \
  sed 's|origin/||' | xargs -I {} git push origin --delete {}
```

### Phase 5: Enable Auto-Prune

```bash
git config --local fetch.prune true
```

## Protected Branches

Default protected list:

- `main`
- `master`
- `develop`
- `dev`
- `production`
- `staging`

User can specify additional protected branches.

## Safety Gates

1. **Dry-run first** - Show what WILL be deleted before deleting
2. **Merged confirmation** - Auto-delete merged, confirm unmerged
3. **Remote confirmation** - Always confirm before remote deletion
4. **No force on protected** - Never force-delete protected branches

## Output Format

```
=== BRANCH CLEANUP PREVIEW ===

LOCAL (safe to delete - merged):
  feature/old-feature
  fix/resolved-bug

LOCAL (requires confirmation - unmerged):
  experiment/wip (3 commits ahead)

REMOTE (safe to delete - merged):
  origin/feature/old-feature
  origin/fix/resolved-bug

PROTECTED (will NOT delete):
  main, develop

Proceed? [y/N]
```

## Token Budget

- Analysis: ~300 tokens
- Local deletion: ~200 tokens
- Remote deletion: ~400 tokens
- Total: ~900 tokens per cleanup

## Error Handling

### "Branch not fully merged"

Use `-D` only with explicit user confirmation.

### "Remote ref does not exist"

Run `git fetch --prune` first.

### "Permission denied"

Check GitHub/GitLab permissions for branch deletion.

### Remote branch still exists after deletion

**Case-sensitivity bug.** This occurs in cross-platform teams (Windows/macOS + Linux).

**Root cause:**
- Git server (GitHub/Linux) is **case-sensitive**: `Dev/Feature` ≠ `dev/feature`
- Windows/macOS filesystems are **case-insensitive**: `Dev/Feature` = `dev/feature`
- Local tracking ref may have different case than actual remote branch
- `git push origin --delete Dev/Feature` deletes local ref but misses remote `dev/feature`

**Diagnosis:**

```bash
# Check GitHub web UI for EXACT branch name (case matters)
# Compare with local tracking ref:
ls -la .git/refs/remotes/origin/
```

**Fix:**

```bash
# Use EXACT case as shown on GitHub:
git push origin --delete dev/feature  # lowercase if that's what GitHub shows
```

**Prevention:**
- **Always use all-lowercase branch names** (mandatory for cross-platform teams)
- Verify deletion by checking GitHub web UI, not just Git CLI output

## Best Practices

1. Run `git fetch --prune` before analysis
2. Review unmerged branches for valuable work
3. Create backup branch before mass deletion if uncertain
4. Enable `fetch.prune` globally for future sessions
5. **Use all-lowercase branch names** to prevent case-sensitivity bugs
6. Verify remote deletions via GitHub web UI (Git CLI can report false success)

## Integration

Combine with:

- `/create-pr` - Clean up after PR merge
- `/refresh-context` - Include branch state in context
- `gitops` skill - Cross-platform naming rules (filenames + branches)

## Changelog

**v1.1** (2025-12-01)
- Added case-sensitivity warning for cross-platform teams
- Added all-lowercase branch naming rule
- Added GitHub UI verification step

**v1.0** (2025-12-01)
- Initial skill creation
- Protected branch list
- Dry-run previews
- Batch deletion commands
