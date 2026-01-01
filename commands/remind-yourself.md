---
description: Search and reference past conversations, plans, and insights from previous Claude Code sessions to maintain context continuity
disable-model-invocation: false
---

# Remind Yourself

Search past conversations to maintain context continuity across sessions and avoid re-discovering solutions.

## What It Does

Mines conversation history from `~/.claude/history.jsonl` to:

1. **Temporal Search** - Filter by date ranges using epoch timestamps
2. **Keyword Search** - Find past discussions by topic/pattern
3. **Project Context** - Filter by working directory path
4. **Recent Sessions** - Quick access to last 3-5 sessions
5. **Pattern Discovery** - Identify recurring issues/solutions

## Usage

```bash
/remind-yourself [search_term]
```text

### Examples:
- `/remind-yourself` - Show recent sessions (default)
- `/remind-yourself figma` - Search for Figma-related work
- `/remind-yourself last week` - Filter by time range
- `/remind-yourself PR automation` - Find specific feature work

### Activation:
- User references "past chats", "previous sessions", "history"
- User says "we did this before", "remember when"
- Starting new session on familiar project
- Debugging issues that might have been solved before

## Search Strategies

### 1. Recent Sessions (Default)
```bash
tail -n 500 ~/.claude/history.jsonl | jq -s 'sort_by(.timestamp) | reverse | .[0:10]'
```text

### 2. Keyword Search
```bash
rg -i "keyword" ~/.claude/history.jsonl --json | jq -s '.[].data.lines.text'
```text

### 3. Temporal Filtering (Epoch Timestamps)
```bash
# Last 7 days
WEEK_AGO=$(date -v-7d +%s)000
tail -n 2000 ~/.claude/history.jsonl | jq -s --arg since "$WEEK_AGO" \
  'map(select(.timestamp >= ($since | tonumber)))'
```text

### 4. Project-Specific
```bash
rg "\"project\":.*ProjectName" ~/.claude/history.jsonl | jq -s
```text

## History File Structure

**Location:** `~/.claude/history.jsonl`
**Format:** Newline-delimited JSON (JSONL)

### Schema:
```json
{
  "display": "User's prompt text",
  "timestamp": 1762385562364,
  "project": "/path/to/project"
}
```text

### Critical Notes:
- ⚠️ **Timestamps are epoch milliseconds** (not seconds)
- ⚠️ **HEAD = oldest, TAIL = newest** (always use `tail` for recent)
- ⚠️ **Use `jq -s` for JSONL** (slurp mode handles multiple objects)

## Best Practices

✅ **Temporal precision**: Use epoch filtering, not arbitrary line counts
✅ **Recent first**: Always `tail` then filter (not `head`)
✅ **Keyword flexibility**: Search case-insensitive (`rg -i`)
✅ **Context window**: Start with 500-1000 lines, expand if needed

❌ **Never**: Use `head` for recent entries (gets oldest, not newest)
❌ **Never**: Process JSONL without `jq -s` flag
❌ **Never**: Assume line counts = time windows (varies by activity)

## Output Format

Returns structured summary:
```markdown
## Recent Sessions (Last 7 Days)

### Session 1 (2025-11-09)
- Created PR automation workflow
- Token usage: 22k / 30k target
- Status: ✅ Complete

### Session 2 (2025-11-07)
- Added context-refresh skill
- Fixed cross-platform compatibility
- Status: ✅ Complete
```text

## Integration

Loads the `chat-history-search` skill from:
```bash
~/.claude/skills/chat-history-search/SKILL.md
```text

## Related

- `/refresh-context` - Rebuild project mental model at session start
- `/audit-efficiency` - Analyze patterns in conversation history
- See `CLAUDE.md` for epoch timestamp handling protocols
