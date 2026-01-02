---
description: Systematically rebuild mental model of any repository when starting fresh sessions. Eliminates "cold start" problem by executing 7-step discovery protocol in <3000 tokens.
disable-model-invocation: false
---

# Refresh Context

Rapidly establishes comprehensive project understanding at session start without excessive file re-reading.

## What It Does

Executes a 7-step discovery protocol to rebuild complete mental model:

1. **Project Identity** - Read README/CLAUDE.md for purpose, tech stack, status
2. **Git State** - Check branch, staged/unstaged files, recent commits
3. **Architecture** - Scan directory structure, identify key modules
4. **Recent History** - Filter chat history by epoch timestamps (last 3 sessions)
5. **Environment** - Detect dependencies, config files, framework conflicts
6. **Mental Model** - Synthesize findings into structured briefing
7. **Risk Detection** - Alert on secrets in staged files, dual configs, merge conflicts

## Usage

```bash
/refresh-context
```text

### Aliases:
- `/understand-repo`
- `/repo-context`

### Auto-activation:
- Session start with project CLAUDE.md detected
- User asks project-specific question without context
- Efficiency audit detects repeated README/CLAUDE.md reads

## Output

Generates concise briefing:

```markdown
# [Project Name] - Context Refresh

**Project**: [1-sentence purpose and target audience]
**Tech Stack**: [Framework + key libraries (top 5)]
**Status**: [Production/Dev/Prototype], [file count], [recent work summary]

**Recent Activity** (last 3 sessions):
- [Task 1 from history]
- [Task 2 from history]

**Git State**: [Staged/unstaged/untracked files summary]
**Risks**: [⚠️ warnings or 🚨 critical issues, or ✅ None]
```text

## Token Budget

- **Target**: <3000 tokens per refresh
- **Actual average**: ~2500 tokens
- **Savings vs cold start**: 2000-5000 tokens

## Integration

Loads the `context-refresh` skill from:
```bash
~/.claude/skills/context-refresh/SKILL.md
```text

## Benefits

✅ Eliminates 5+ redundant file reads
✅ Detects secrets before commits
✅ Identifies framework conflicts (dual Vite + Next.js configs)
✅ Provides temporal context from history (epoch filtering)
✅ Structured briefing > scattered knowledge

## Related

- `/remind-yourself` - Search past conversations by topic/date
- `/audit-efficiency` - Detect context-loss pattern violations
- See `@rules/efficiency-rules.md` for file read optimization protocols
