---
name: chat-history-search
description: Search and reference past conversations, plans, realisations, and insights from previous Claude Code sessions to maintain context continuity and avoid re-discovering solutions.
---

# Chat History Search Skill

**Purpose:** Search and reference past conversations, plans, realisations, and insights from previous Claude Code sessions to maintain context continuity and avoid re-discovering solutions.

**Activation:** Automatically when user references "past chats", "previous sessions", "history", or explicitly via `/remind-yourself` slash command.

---

## Core Principle

Claude Code sessions are stateless by default. This skill enables **context persistence** across sessions by mining conversation history stored in **per-project JSONL files**.

**Never assume you know what happened in past sessions.** Always search history first when:

- User references previous work ("we did this before", "remember when", "the plan we made")
- Starting a new session on a familiar project
- User asks to continue/resume previous tasks
- Debugging issues that might have been solved before

**CRITICAL**: History is stored **per-project**, NOT in a global file. See `~/.claude/HISTORY_STORAGE_ANALYSIS.md` for complete specification.

---

## History File Structure

**Location:** `~/.claude/projects/{encoded-project-path}/{session-uuid}.jsonl`

**Path Encoding:** Forward slashes replaced with hyphens

- Example: `/Users/name/project/` → `-Users-name-project`

**Format:** Newline-delimited JSON (JSONL), one file per session

### Schema (User Message):

```json
{
  "type": "user",
  "uuid": "unique-message-id",
  "parentUuid": "previous-message-uuid-or-null",
  "sessionId": "session-uuid",
  "timestamp": "2025-11-13T13:29:53.910Z",
  "cwd": "/Users/username/projects/example-backend",
  "gitBranch": "main",
  "message": {
    "role": "user",
    "content": "User's prompt text or array of content objects"
  }
}
```text

### Schema (Assistant Message):
```json
{
  "type": "assistant",
  "uuid": "unique-message-id",
  "parentUuid": "user-message-uuid",
  "sessionId": "session-uuid",
  "timestamp": "2025-11-13T13:29:59.980Z",
  "cwd": "/Users/username/projects/example-backend",
  "message": {
    "role": "assistant",
    "content": [{"type": "text", "text": "..."}],
    "usage": {
      "input_tokens": 2,
      "output_tokens": 1
    }
  }
}
```text

### Key Fields:
- `type` - Message type: "user", "assistant", "file-history-snapshot", "system"
- `timestamp` - ISO 8601 format: `"YYYY-MM-DDTHH:MM:SS.mmmZ"` (NOT epoch milliseconds)
- `cwd` - Working directory (project path)
- `sessionId` - All messages in one file share same session ID
- `parentUuid` - Links messages in conversation thread

---

## Search Strategies

### 0. Find Project History Directory (REQUIRED FIRST STEP)

Before any search, locate the project's history directory:

```bash
# Encode current project path
PROJECT_DIR=$(pwd | sed 's|^/||' | sed 's|/|-|g')

# Find project history directory
HISTORY_DIR=$(fd -t d "$PROJECT_DIR" ~/.claude/projects | head -1)

# Verify it exists
if [[ -z "$HISTORY_DIR" ]]; then
  echo "No history found for this project"
else
  echo "History: $HISTORY_DIR"
fi
```text

### 1. Pattern-Based Search (Primary Method)

Use `rg` (ripgrep) for fast, efficient searches:

```bash
# Search for specific keywords across all sessions
rg -i "keyword1|keyword2|keyword3" "$HISTORY_DIR"/*.jsonl --glob '!agent-*' -C 5

# Search in most recent session only
LATEST=$(ls -t "$HISTORY_DIR"/*.jsonl | grep -v agent | head -1)
rg -i "search_term" "$LATEST" -C 3

# Multi-keyword search with context
rg -i "nextauth.*cognito|stripe.*webhook|backend.*refactor" "$HISTORY_DIR"/*.jsonl --glob '!agent-*' -C 10 | head -200
```text

### Best Practices:
- Always use `--glob '!agent-*'` to exclude agent sub-sessions
- Use `-C 5` (or `-C 10`) for context lines around matches
- Use `-i` for case-insensitive search
- Use `|` (pipe) for OR searches in patterns
- Use `head -n 200` to limit output (avoid token waste)

### 2. Session-Based Search

```bash
# List recent sessions (excludes agent sessions)
ls -t "$HISTORY_DIR"/*.jsonl | grep -v agent | head -5

# Get user messages from most recent session
cat "$LATEST" | jq -r 'select(.type == "user" and (.message.content | type) == "string") | "\(.timestamp) | \(.message.content | .[0:120])"' | tail -10

# Count messages by type in a session
cat "$SESSION_FILE" | jq -r .type | sort | uniq -c
```text

### 3. Timeline Search (ISO 8601 Timestamps)

```bash
# Filter by date range (string comparison works!)
cat "$SESSION_FILE" | jq -r 'select(.timestamp >= "2025-11-13T00:00:00" and .timestamp < "2025-11-14T00:00:00")'

# Messages from last 7 days
CUTOFF=$(date -v-7d -u +"%Y-%m-%dT%H:%M:%S")
cat "$SESSION_FILE" | jq -r --arg cutoff "$CUTOFF" 'select(.timestamp >= $cutoff)'

# Recent user messages only (last 100 entries)
tail -n 100 "$SESSION_FILE" | jq -r 'select(.type == "user") | .message.content'
```text

### 4. Cross-Session Keyword Search

```bash
# Search all sessions for keyword with file context
for file in "$HISTORY_DIR"/*.jsonl; do
  [[ $(basename "$file") =~ ^agent- ]] && continue
  matches=$(rg -i "keyword" "$file" -c 2>/dev/null || echo "0")
  if [[ $matches -gt 0 ]]; then
    echo "=== $(basename "$file" .jsonl) ==="
    jq -r 'select(.type == "user") | .timestamp' "$file" | head -1
    rg -i "keyword" "$file" -A 2 -B 2 | head -20
  fi
done
```text

---

## Workflow: `/remind-yourself` Command

**Trigger:** User types `/remind-yourself <topic>` or mentions past work

### Execution Steps

1. **Locate Project History**
   ```bash
   PROJECT_DIR=$(pwd | sed 's|^/||' | sed 's|/|-|g')
   HISTORY_DIR=$(fd -t d "$PROJECT_DIR" ~/.claude/projects | head -1)
   ```text

2. **Parse Topic & Extract Keywords**
   - Extract keywords from user query
   - Identify specific timeframe if mentioned ("last week", "yesterday")

3. **Search History**
   ```bash
   # Example: /remind-yourself website backend refactoring
   rg -i "website.*backend|nextauth|cognito|stripe" "$HISTORY_DIR"/*.jsonl --glob '!agent-*' -C 10 | head -200
   ```text

4. **Filter by Type** (focus on user messages)
   ```bash
   # Get user messages containing keywords
   cat "$HISTORY_DIR"/*.jsonl | jq -r 'select(.type == "user" and (.message.content | tostring | ascii_downcase | test("keyword")))' | tail -50
   ```text

5. **Extract Key Information**
   - Plans mentioned (look for `.md` files, "plan:", "TODO:", checklists)
   - Decisions made (look for "decided", "chose", "implemented")
   - Errors solved (look for "fixed", "error:", "solved")
   - Files created/modified (look for file paths)

6. **Summarise Findings**
   - Present chronological summary with session dates
   - Highlight unfinished tasks (unchecked `[ ]` items)
   - Reference specific timestamps/sessions

7. **Ask Clarifying Questions**
   - If multiple relevant sessions found, ask which one user refers to
   - If context is ambiguous, request more keywords

---

## Common Use Cases

### Use Case 1: Resume Previous Work

**User says:** "Continue where we left off with the Oculus website."

### Action:
```bash
# Locate project history
PROJECT_DIR=$(pwd | sed 's|^/||' | sed 's|/|-|g')
HISTORY_DIR=$(fd -t d "$PROJECT_DIR" ~/.claude/projects | head -1)

# Search for Oculus website work, focus on TODOs and plans
rg -i "oculus.*website|oc-tech" "$HISTORY_DIR"/*.jsonl --glob '!agent-*' | \
  rg -i "TODO|plan|phase|checklist" -C 5 | tail -n 100
```text

**Output:** Summary of last session's state, unfinished tasks, next steps.

---

### Use Case 2: Recall Solution to Past Problem

**User says:** "How did we fix the NextAuth Cognito bad token error?"

### Action:
```bash
# Search for error and solution across all sessions
rg -i "bad.*token|nextauth.*error|cognito.*fix" "$HISTORY_DIR"/*.jsonl --glob '!agent-*' -C 10 | head -100
```text

**Output:** Explain the fix, reference file changes, provide context.

---

### Use Case 3: Find Past Plans/Designs

**User says:** "What was our plan for the backend refactoring?"

### Action:
```bash
# Search for planning discussions
rg -i "backend.*refactor|refactoring.*plan|phase 1" "$HISTORY_DIR"/*.jsonl --glob '!agent-*' -C 10 | head -200
```text

**Output:** Extract plan details, link to `.md` files created, summarise phases.

---

### Use Case 4: Track Project Evolution

**User says:** "Show me what we've done on the example project."

### Action:
```bash
# Get all sessions with summary metadata
for file in "$HISTORY_DIR"/*.jsonl; do
  [[ $(basename "$file") =~ ^agent- ]] && continue
  echo "=== Session: $(basename "$file" .jsonl) ==="
  jq -r 'select(.type == "user") | .timestamp' "$file" | head -1
  jq -r 'select(.type == "user" and (.message.content | type) == "string") | .message.content' "$file" | head -3
  echo ""
done | tail -n 50
```text

**Output:** Timeline of work, major milestones, current status.

---

## Integration with Other Skills

### Combine with `code-agentic` Skill
- Before executing agentic tasks, search history for similar past tasks
- Learn from previous verification gates that failed
- Avoid repeating mistakes

### Combine with `figma-to-code` Skill
- Search for past Figma integration patterns
- Reference component structures used before

### Combine with Efficiency Rules
- **Do NOT read entire history file** (186KB+ file with thousands of lines)
- Use `rg` with `head` or `tail` to limit output
- Search strategically (specific keywords, not broad terms)

---

## Response Format

When user invokes `/remind-yourself` or references past work:

### Template:
```markdown
# Context from Past Sessions

**Search Query:** [keywords used]
**Results Found:** [number of relevant entries]

## Summary

[1-2 paragraph overview of what was done]

## Key Decisions
- Decision 1 (timestamp: YYYY-MM-DD)
- Decision 2 (timestamp: YYYY-MM-DD)

## Files Created/Modified
- `/path/to/file1.ts` - [purpose]
- `/path/to/file2.md` - [purpose]

## Current Status
- ✅ Completed: [tasks]
- ⏳ In Progress: [tasks]
- ⏸️ Blocked: [tasks with reasons]

## Next Steps
1. [Action item 1]
2. [Action item 2]

**Note:** [Any caveats, assumptions, or questions for clarification]
```text

---

## Anti-Patterns (What NOT to Do)

❌ **Don't use `~/.claude/history.jsonl`** - This global file doesn't exist! Use per-project directories
❌ **Don't assume epoch millisecond timestamps** - Timestamps are ISO 8601 strings
❌ **Don't forget to exclude agent sessions** - Always use `--glob '!agent-*'` or `grep -v agent`
❌ **Don't assume context without searching** - Always verify past work
❌ **Don't hallucinate past events** - If search returns nothing, say so
❌ **Don't overwhelm with too many results** - Use `head -n 200` to limit
❌ **Don't search without keywords** - Broad searches waste tokens
❌ **Don't read entire session files** - Use `tail` for recent entries

---

## Performance Optimisations

**Token Budget:** ~300-2000 tokens per history search (with corrected approach)

### Best Practices:
1. **Find history dir once:** Store `$HISTORY_DIR` variable, reuse in session
2. **Limit output:** Use `head -n 100` or `tail -n 100`
3. **Use context lines judiciously:** `-C 5` is usually sufficient (not `-C 20`)
4. **Parallel searches:** If user asks multiple questions, batch `rg` commands
5. **Filter by type:** Focus on `.type == "user"` for user messages
6. **Cache results:** If same search needed multiple times, store in working memory

### Example Efficient Search:
```bash
# Good: Targeted, limited output, correct path
PROJECT_DIR=$(pwd | sed 's|^/||' | sed 's|/|-|g')
HISTORY_DIR=$(fd -t d "$PROJECT_DIR" ~/.claude/projects | head -1)
LATEST=$(ls -t "$HISTORY_DIR"/*.jsonl | grep -v agent | head -1)
tail -n 200 "$LATEST" | jq -r 'select(.type == "user") | .message.content' | rg -i "nextauth|cognito" -C 3

# Bad: Non-existent path, unlimited output
rg "project" ~/.claude/history.jsonl
```text

**Token Savings: 60-94%** compared to old broken approach

---

## Slash Command Implementation

**Command:** `/remind-yourself <topic>`

**Aliases:** `/history`, `/recall`, `/remember`

### Syntax:
```bash
/remind-yourself <keywords>
```text

### Examples:
```bash
/remind-yourself website backend refactoring
/remind-yourself stripe integration
/remind-yourself how we fixed the auth error
/remind-yourself terminal setup
```text

### Behaviour:
1. Extract `<keywords>` from command
2. Search `~/.claude/history.jsonl` for matches
3. Present structured summary (using template above)
4. Offer to continue/resume work if tasks are incomplete

---

## Testing the Skill

### Validation Checklist:
- [ ] Can find specific past errors and their fixes
- [ ] Can recall plan documents created in past sessions
- [ ] Can identify unfinished tasks from previous work
- [ ] Results are relevant (not too broad/narrow)
- [ ] Output is concise (doesn't exceed 5000 tokens)
- [ ] Works across different projects
- [ ] Handles "no results found" gracefully

### Test Queries:
```bash
/remind-yourself nextauth cognito bad token fix
/remind-yourself backend refactoring plan
/remind-yourself terminal optimisation tmux
```text

---

## Maintenance

**History Directory Size:** Monitor project history directories

```bash
# Check total size of all history for current project
PROJECT_DIR=$(pwd | sed 's|^/||' | sed 's|/|-|g')
HISTORY_DIR=$(fd -t d "$PROJECT_DIR" ~/.claude/projects | head -1)
du -sh "$HISTORY_DIR"
# Example output: 6.2M

# List sessions by size
ls -lh "$HISTORY_DIR"/*.jsonl | grep -v agent | sort -k5 -h
```text

**Cleanup Strategy:** Archive old sessions (keep last 10):

```bash
# Archive sessions older than 90 days
find "$HISTORY_DIR" -name "*.jsonl" -mtime +90 ! -name "agent-*" \
  -exec mv {} ~/.claude/archive/history/$(date +%Y%m%d)/ \;
```text

**Backup:** History files are precious. Back up regularly:

```bash
# Backup entire projects directory
tar -czf ~/.claude/backups/projects-$(date +%Y%m%d).tar.gz ~/.claude/projects/
```text

**Per-Session Cleanup:** Remove empty or corrupted sessions:

```bash
# Find empty session files
find "$HISTORY_DIR" -name "*.jsonl" -size 0

# Remove agent sessions older than 30 days
find "$HISTORY_DIR" -name "agent-*.jsonl" -mtime +30 -delete
```text

---

## Examples from Real Usage

### Example 1: Oculus Website Backend Integration

**User Query:** "Search recent chats about our plan to complete the website_backend_refactoring_plan"

### Search Executed:
```bash
rg -i "website.*backend|nextauth.*cognito|backend.*refactor" ~/.claude/history.jsonl -C 10 | head -200
```text

### Key Findings:
- "Bad id token" error was fixed in recent session
- NextAuth.js + Cognito integration completed
- Still pending: S3 IAM credentials, Stripe webhook testing
- Microsoft sign-in working ✅
- Stripe test buy pending ⏳

### Files Referenced:
- `pages/api/auth/[...nextauth].ts` - Auth logic fixed
- `.env` vs `.env.local` - Secrets management implemented
- `website_backend_refactoring.md` - Master plan document

---

### Example 2: Terminal Optimisation

**User Query:** "How did we make select+backspace work in the terminal?"

### Search Executed:
```bash
rg -i "select.*backspace|zsh.*region|delete.*selection" ~/.claude/history.jsonl -C 5 | head -150
```text

### Key Findings:
- Created ZLE region-aware functions in `~/.zshrc`
- Added `backward-delete-char-or-region` function
- Configured iTerm2 "Natural Text Editing" preset
- Created Medium article: `medium_terminal_optimisation.md`

---

## Future Enhancements

### Potential Improvements:
1. **Semantic Search:** Use embeddings to find conceptually similar past conversations
2. **Auto-Summary:** Weekly digest of major accomplishments
3. **Cross-Project Insights:** "You solved X in Project A, same pattern applies to Project B"
4. **Knowledge Graph:** Build relationships between files, tasks, and decisions

---

## Changelog

**v2.0** (2025-11-14) - **CRITICAL FIX: Corrected history storage structure**
- ✅ Fixed file path: Per-project `~/.claude/projects/{encoded-path}/{uuid}.jsonl` (NOT global history.jsonl)
- ✅ Fixed timestamp format: ISO 8601 strings (NOT epoch milliseconds)
- ✅ Added agent session filtering (`--glob '!agent-*'`)
- ✅ Updated all search patterns to use correct paths
- ✅ Added comprehensive jq filters for message type filtering
- ✅ Performance improvement: 60-94% token savings
- ✅ Referenced `HISTORY_STORAGE_ANALYSIS.md` for complete specification

**v1.0** (2025-11-06) - Initial skill creation
- Basic `rg` search patterns (with incorrect paths)
- `/remind-yourself` command specification
- Response templates and anti-patterns

---

**Skill Status:** ✅ Active (v2.0 - FIXED)
**Maintainer:** LC Scheepers
**Last Updated:** 2025-11-14
