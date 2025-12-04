---
description: Automatically update project documentation by analysing session history and git commits
disable-model-invocation: false
---

# Update Docs

Synchronises project documentation with actual state by mining session history and git commits.

## What It Does

1. **Mine History** - Extract recent session topics and decisions
2. **Analyse Git** - Get commits since last doc update
3. **Synthesise State** - Combine sources, calculate confidence
4. **Update Docs** - Apply targeted edits to CLAUDE.md, next_up.md, ROADMAP
5. **Verify** - Check for secrets, lint markdown

## Usage

```bash
/update-docs
```

## Target Files

| File | Update |
|------|--------|
| CLAUDE.md | Current state, phase, recent work |
| next_up.md | Session progress |
| ROADMAP.md | Mark tasks complete |
| README.md | Stats (if changed) |

## Confidence Gate

Only updates when confidence > 80%. Otherwise outputs summary for manual review.

## Token Budget

~3500 tokens per execution.

## Example Output

```text
=== Auto Documentation Update ===

Confidence: 87%

Updates Applied:
[ok] CLAUDE.md - Updated current state
[ok] next_up.md - Updated session progress
[skip] README.md - No changes needed

Review: git diff *.md
```

## Linked Skill

See: `~/.claude/skills/auto-update-documentation/SKILL.md`
