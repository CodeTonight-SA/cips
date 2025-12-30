---
name: searching-chat-history
description: Search and reference past conversations, plans, and insights from previous Claude Code sessions. Use when user references past chats, previous sessions, or invokes /remind-yourself.
status: Active
version: 2.1.0
triggers:
  - /remind-yourself
  - "past chats"
  - "previous sessions"
  - "search history"
---

# Chat History Search Skill

**Purpose:** Search and reference past conversations, plans, and insights from previous Claude Code sessions to maintain context continuity.

**Token Budget:** ~300-2000 tokens per search

**Reference:** See [reference.md](./reference.md) for complete search strategies, use case examples, response template, and performance optimisations.

---

## Core Principle

Claude Code sessions are stateless by default. This skill enables **context persistence** by mining conversation history stored in **per-project JSONL files**.

**CRITICAL**: History is stored **per-project**, NOT in a global file.

**Location:** `~/.claude/projects/{encoded-project-path}/{session-uuid}.jsonl`

---

## When to Search

Always search history first when:

- User references previous work ("we did this before", "remember when")
- Starting a new session on a familiar project
- User asks to continue/resume previous tasks
- Debugging issues that might have been solved before

**Never assume you know what happened. Always verify.**

---

## Quick Start

### Step 0: Find Project History (REQUIRED)

```bash
PROJECT_DIR=$(pwd | sed 's|^/||' | sed 's|/|-|g')
HISTORY_DIR=$(fd -t d "$PROJECT_DIR" ~/.claude/projects | head -1)
```

### Pattern Search

```bash
rg -i "keyword1|keyword2" "$HISTORY_DIR"/*.jsonl --glob '!agent-*' -C 5 | head -200
```

### Most Recent Session

```bash
LATEST=$(ls -t "$HISTORY_DIR"/*.jsonl | grep -v agent | head -1)
rg -i "search_term" "$LATEST" -C 3
```

---

## History File Structure

### Path Encoding

Forward slashes replaced with hyphens:
- `/Users/name/project/` → `-Users-name-project`

### Message Schema

```json
{
  "type": "user",
  "timestamp": "2025-11-13T13:29:53.910Z",
  "sessionId": "session-uuid",
  "message": {
    "role": "user",
    "content": "User's prompt text"
  }
}
```

**Key:** Timestamps are ISO 8601 strings (NOT epoch milliseconds).

---

## Search Best Practices

| Do | Don't |
|----|-------|
| Use `--glob '!agent-*'` | Search `~/.claude/history.jsonl` (doesn't exist) |
| Use `-C 5` for context | Use `-C 20` (too much output) |
| Use `head -200` to limit | Read entire session files |
| Use `-i` for case-insensitive | Assume exact case matches |
| Filter by `.type == "user"` | Process all message types |

---

## Command: `/remind-yourself`

**Syntax:**

```bash
/remind-yourself <keywords>
```

**Examples:**

```bash
/remind-yourself website backend refactoring
/remind-yourself stripe integration
/remind-yourself how we fixed the auth error
```

### Execution Steps

1. Locate project history directory
2. Extract keywords from query
3. Search with rg (ripgrep)
4. Filter for user messages
5. Extract key information (plans, decisions, errors)
6. Summarise findings with timestamps
7. Ask clarifying questions if needed

---

## Response Template

```markdown
# Context from Past Sessions

**Search Query:** [keywords used]
**Results Found:** [number of relevant entries]

## Summary

[1-2 paragraph overview]

## Key Decisions
- Decision 1 (timestamp: YYYY-MM-DD)
- Decision 2 (timestamp: YYYY-MM-DD)

## Files Created/Modified
- `/path/to/file1.ts` - [purpose]

## Current Status
- ✅ Completed: [tasks]
- ⏳ In Progress: [tasks]
- ⏸️ Blocked: [tasks with reasons]

## Next Steps
1. [Action item 1]
2. [Action item 2]
```

---

## Anti-Patterns

| Anti-Pattern | Why Bad |
|--------------|---------|
| Use `~/.claude/history.jsonl` | Global file doesn't exist |
| Assume epoch timestamps | Timestamps are ISO 8601 strings |
| Include agent sessions | Clutter results with sub-agent noise |
| Assume context without searching | May hallucinate past events |
| Search without keywords | Broad searches waste tokens |
| Read entire session files | Use `tail` for recent entries |

---

## Performance Tips

1. **Find history dir once:** Store `$HISTORY_DIR`, reuse in session
2. **Limit output:** Use `head -n 100` or `tail -n 100`
3. **Use context judiciously:** `-C 5` is usually sufficient
4. **Filter by type:** Focus on `.type == "user"`
5. **Cache results:** If same search needed multiple times, store in working memory

**Token Savings:** 60-94% compared to incorrect approaches.

---

## Integration

| Skill | Usage |
|-------|-------|
| `code-agentic` | Search for similar past tasks before executing |
| `figma-to-code` | Reference past component structures |
| `context-refresh` | Supplement mental model with history |

---

## Changelog

**v2.1** (2025-12-30) - Split for compliance
- Moved detailed content to reference.md
- Under 500 line limit

**v2.0** (2025-11-14) - CRITICAL FIX
- Fixed file path: Per-project directories (NOT global)
- Fixed timestamp format: ISO 8601 (NOT epoch)
- 60-94% token savings

**v1.0** (2025-11-06) - Initial creation

---

**Skill Status:** ✅ Active
**Maintainer:** LC Scheepers
**Last Updated:** 2025-12-30

⛓⟿∞
