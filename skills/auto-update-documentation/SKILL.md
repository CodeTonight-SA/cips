---
name: auto-update-documentation
description: Automatically update project documentation by synthesising session history, git commits, and current state.
  Eliminates documentation drift. Token budget 3500.
command: /update-docs
aliases: [/sync-docs, /doc-refresh]
---

# Auto Update Documentation Skill

**Purpose:** Keep project documentation current by synthesising session history + git commits + current state.

**Activation:** Manual `/update-docs`, after PR creation, or on milestone completion.

**Token Budget:** <3500 tokens per execution (typical: ~2800)

---

## Core Principle

**Documentation drift is inevitable. This skill eliminates it automatically.**

Without automatic updates:
- CLAUDE.md falls behind actual state
- README.md lists outdated features
- ROADMAP.md shows completed tasks as pending
- New team members get stale context

---

## Target Files

Detect and update per-project:

| File | Update Type | Priority |
|------|-------------|----------|
| `CLAUDE.md` | Current state, phase, recent work | HIGH |
| `next_up.md` / `SESSION.md` | Session progress, remaining tasks | HIGH |
| `README.md` | Features, stats, quick start | MEDIUM |
| `docs/ROADMAP*.md` | Task completion status | MEDIUM |
| `CHANGELOG.md` | Recent changes summary | LOW |

---

## 5-Phase Protocol

### Phase 1: History Mining (~600 tokens)

```bash
PROJECT_DIR=$(pwd | sed 's|/|-|g' | sed 's|\.|-|g')
HISTORY_DIR=$(fd -t d -- "$PROJECT_DIR" ~/.claude/projects 2>/dev/null | head -1)

if [[ -n "$HISTORY_DIR" ]]; then
  rg -i "implement|create|add|fix|update|complete|feature|endpoint" \
    "$HISTORY_DIR"/*.jsonl \
    --glob '!agent-*' \
    -C 2 \
    2>/dev/null | head -150
fi
```

**Extract:** User decisions, completed work, blockers resolved.

### Phase 2: Git Analysis (~500 tokens)

```bash
LAST_UPDATE=$(git log -1 --format="%ci" -- "*.md" 2>/dev/null | cut -d' ' -f1)
[[ -z "$LAST_UPDATE" ]] && LAST_UPDATE="7 days ago"

git log --oneline --since="$LAST_UPDATE" --format="%h|%s" 2>/dev/null | head -20

git diff --stat HEAD~10..HEAD 2>/dev/null | tail -20
```

**Extract:** Commits since last doc update, changed files, commit types (feat/fix/docs).

### Phase 3: State Synthesis (~400 tokens)

```bash
TOTAL_FILES=$(git ls-files 2>/dev/null | wc -l | tr -d ' ')
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
RECENT_COMMITS=$(git log --oneline -7 2>/dev/null | wc -l | tr -d ' ')

case "$CURRENT_BRANCH" in
  *feat*|*feature*) INFERRED_PHASE="Feature Development" ;;
  *fix*|*bug*) INFERRED_PHASE="Bug Fixes" ;;
  *release*|*prod*) INFERRED_PHASE="Release Preparation" ;;
  main|master) INFERRED_PHASE="Production" ;;
  *) INFERRED_PHASE="Active Development" ;;
esac
```

**Combine:** History + git = understanding of what changed and why.

### Phase 4: Targeted Updates (~1200 tokens)

For each target file that exists:

**CLAUDE.md:**
```markdown
## CURRENT STATE

**Phase**: {INFERRED_PHASE}
**Branch**: {CURRENT_BRANCH}
**Last Updated**: {TODAY}

### Recent Work
- {from session history - top 5}

### Key Stats
- Files: {TOTAL_FILES}
- Recent commits: {RECENT_COMMITS}
```

**next_up.md:**
```markdown
## Session Progress

**Completed This Session:**
- {from git commits}

**Remaining:**
- {inferred from session context}
```

**ROADMAP.md:**
- Scan for `[ ]` items matching completed commit messages
- Update to `[x]` with date

### Phase 5: Verification (~300 tokens)

```bash
rg -i "(password|secret|token|key|credential)" updated_files.md
npx markdownlint updated_files.md 2>/dev/null || true
```

**Check:** No secrets exposed, markdown valid.

---

## Confidence Gate

Only update if confidence > 80%:

| Source | Max Contribution |
|--------|------------------|
| Session history (clear topics) | 40% |
| Git commits (descriptive) | 35% |
| File changes (meaningful) | 25% |

**If < 80%:** Output summary for manual review, no auto-update.

---

## Update Strategy

1. **Preserve structure** - Only update specific sections, never rewrite whole file
2. **Add timestamps** - Every update gets `Last Updated: YYYY-MM-DD`
3. **Idempotent** - Running twice produces same result
4. **Minimal edits** - Use Edit tool, not Write (preserves unchanged content)

---

## Anti-Patterns

- Never rewrite entire documentation files
- Never add speculative content ("might need", "could be")
- Never update without recent session/git data (7+ days stale)
- Never commit secrets or credentials
- Never auto-commit (output for user review)

---

## Output Format

```text
=== Auto Documentation Update ===

Session History: {count} sessions analysed
Git Analysis: {count} commits since last update

Confidence: {percentage}%

Updates Applied:
{checkmark} CLAUDE.md - Updated current state
{checkmark} next_up.md - Updated session progress
{skip} README.md - No changes needed (up to date)
{skip} CHANGELOG.md - Not found

Summary:
- Phase updated: MVP Development -> Feature Development
- {count} tasks marked complete in ROADMAP
- Stats refreshed: {old_count} -> {new_count} files

Review changes with: git diff *.md
```

---

## Integration

### Dependencies
- `chat-history-search` skill (session mining patterns)
- `context-refresh` skill (state detection)
- `markdown-expert` skill (linting)

### Metrics
```json
{
  "event": "docs_updated",
  "files_updated": 0,
  "confidence_score": 0.0,
  "execution_tokens": 0,
  "timestamp": "ISO8601"
}
```

---

## Success Criteria

1. Documentation within 24h of actual state
2. Zero manual doc updates for routine work
3. < 3500 tokens per execution
4. No false updates (confidence gate)

---

**Skill Status:** Active (v1.0)
**Created:** 2025-12-03
**Maintainer:** LC Scheepers
