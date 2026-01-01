---
description: Git branch cleanup automation - prune merged branches locally and remotely with safety gates
disable-model-invocation: false
---

# Prune Branches

Automates git branch cleanup with dry-run previews, protected branch lists, and batch operations.

## What It Does

1. **Fetch and Prune** - Sync with remote, remove stale tracking refs
2. **Analyse** - Identify merged, unmerged, and stale branches
3. **Preview** - Show what will be deleted BEFORE deletion
4. **Delete Local** - Remove merged local branches (safe)
5. **Confirm Unmerged** - Require explicit confirmation for unmerged
6. **Delete Remote** - Remove merged remote branches
7. **Enable Auto-Prune** - Configure repository for future sessions

## Usage

```bash
/prune-branches
```

## Protected Branches

These branches are NEVER deleted:

- `main`, `master`
- `develop`, `dev`
- `production`, `staging`

To protect additional branches, specify them during the workflow.

## Workflow Steps

### Step 1: Analysis

```bash
git fetch --prune
git branch --merged main | rg -v '^\*|main|develop'
git branch --no-merged main
git branch -r --merged origin/main | rg -v 'main|HEAD|develop'
```

### Step 2: Preview Output

```
=== BRANCH CLEANUP PREVIEW ===

LOCAL MERGED (auto-delete):
  feature/old-feature
  fix/resolved-bug

LOCAL UNMERGED (confirm):
  experiment/wip (3 commits ahead)

REMOTE MERGED (confirm delete):
  origin/feature/old-feature

PROTECTED (skip):
  main, develop
```

### Step 3: Execute

```bash
git branch --merged main | rg -v '^\*|main|develop' | xargs -r git branch -d

git push origin --delete branch1 branch2 branch3

git config --local fetch.prune true
```

## Safety Gates

1. **Never auto-delete unmerged** - Always confirm
2. **Preview before delete** - Show full list first
3. **Protected list** - Hard-coded protection
4. **Batch with confirmation** - Group operations

## Token Budget

- Target: <1000 tokens per cleanup
- Analysis: ~300
- Deletion: ~500
- Config: ~100

## Best Practices

- Run after PR merges to clean feature branches
- Review unmerged branches before mass deletion
- Check for valuable uncommitted work in branches

## Integration

Loads the `branch-cleanup` skill from:

```bash
~/.claude/skills/branch-cleanup/SKILL.md
```

## Related

- `/create-pr` - Branch cleanup after PR merge
- `/refresh-context` - Include git state in mental model

## Example Session

```
User: /prune-branches

Claude: Analysing branches...

=== PREVIEW ===
Local merged (12): feature/*, fix/*, chore/*
Local unmerged (2): backup-*, tmp/*
Remote merged (15): origin/feature/*, origin/fix/*

Proceed with deletion? [y/N]

User: y

Claude: Deleted 12 local, 15 remote branches.
Auto-prune enabled.

Final state: main, develop (local + remote)
```
