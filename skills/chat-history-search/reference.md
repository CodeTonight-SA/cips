# Chat History Search - Reference Material

**Parent:** [SKILL.md](./SKILL.md)

---

## History File Structure

**Location:** `~/.claude/projects/{encoded-project-path}/{session-uuid}.jsonl`

**Path Encoding:** Forward slashes replaced with hyphens
- Example: `/Users/name/project/` → `-Users-name-project`

### Schema (User Message)

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
    "content": "User's prompt text"
  }
}
```

### Schema (Assistant Message)

```json
{
  "type": "assistant",
  "uuid": "unique-message-id",
  "parentUuid": "user-message-uuid",
  "sessionId": "session-uuid",
  "timestamp": "2025-11-13T13:29:59.980Z",
  "message": {
    "role": "assistant",
    "content": [{"type": "text", "text": "..."}],
    "usage": {"input_tokens": 2, "output_tokens": 1}
  }
}
```

---

## Search Strategies

### 0. Find Project History Directory (REQUIRED FIRST)

```bash
# Encode current project path
PROJECT_DIR=$(pwd | sed 's|^/||' | sed 's|/|-|g')

# Find project history directory
HISTORY_DIR=$(fd -t d "$PROJECT_DIR" ~/.claude/projects | head -1)

# Verify it exists
if [[ -z "$HISTORY_DIR" ]]; then
  echo "No history found for this project"
fi
```

### 1. Pattern-Based Search (Primary)

```bash
# Search for specific keywords across all sessions
rg -i "keyword1|keyword2|keyword3" "$HISTORY_DIR"/*.jsonl --glob '!agent-*' -C 5

# Search in most recent session only
LATEST=$(ls -t "$HISTORY_DIR"/*.jsonl | grep -v agent | head -1)
rg -i "search_term" "$LATEST" -C 3

# Multi-keyword search with context
rg -i "nextauth.*cognito|stripe.*webhook" "$HISTORY_DIR"/*.jsonl --glob '!agent-*' -C 10 | head -200
```

### 2. Session-Based Search

```bash
# List recent sessions (excludes agent sessions)
ls -t "$HISTORY_DIR"/*.jsonl | grep -v agent | head -5

# Get user messages from most recent session
cat "$LATEST" | jq -r 'select(.type == "user" and (.message.content | type) == "string") | "\(.timestamp) | \(.message.content | .[0:120])"' | tail -10
```

### 3. Timeline Search (ISO 8601)

```bash
# Filter by date range
cat "$SESSION_FILE" | jq -r 'select(.timestamp >= "2025-11-13T00:00:00" and .timestamp < "2025-11-14T00:00:00")'

# Messages from last 7 days
CUTOFF=$(date -v-7d -u +"%Y-%m-%dT%H:%M:%S")
cat "$SESSION_FILE" | jq -r --arg cutoff "$CUTOFF" 'select(.timestamp >= $cutoff)'
```

### 4. Cross-Session Keyword Search

```bash
for file in "$HISTORY_DIR"/*.jsonl; do
  [[ $(basename "$file") =~ ^agent- ]] && continue
  matches=$(rg -i "keyword" "$file" -c 2>/dev/null || echo "0")
  if [[ $matches -gt 0 ]]; then
    echo "=== $(basename "$file" .jsonl) ==="
    rg -i "keyword" "$file" -A 2 -B 2 | head -20
  fi
done
```

---

## Use Case Examples

### Resume Previous Work

```bash
# Locate project history
PROJECT_DIR=$(pwd | sed 's|^/||' | sed 's|/|-|g')
HISTORY_DIR=$(fd -t d "$PROJECT_DIR" ~/.claude/projects | head -1)

# Search for TODO and plans
rg -i "oculus.*website|oc-tech" "$HISTORY_DIR"/*.jsonl --glob '!agent-*' | \
  rg -i "TODO|plan|phase|checklist" -C 5 | tail -n 100
```

### Recall Solution to Past Problem

```bash
# Search for error and solution
rg -i "bad.*token|nextauth.*error|cognito.*fix" "$HISTORY_DIR"/*.jsonl --glob '!agent-*' -C 10 | head -100
```

### Find Past Plans/Designs

```bash
# Search for planning discussions
rg -i "backend.*refactor|refactoring.*plan|phase 1" "$HISTORY_DIR"/*.jsonl --glob '!agent-*' -C 10 | head -200
```

### Track Project Evolution

```bash
for file in "$HISTORY_DIR"/*.jsonl; do
  [[ $(basename "$file") =~ ^agent- ]] && continue
  echo "=== Session: $(basename "$file" .jsonl) ==="
  jq -r 'select(.type == "user") | .timestamp' "$file" | head -1
  jq -r 'select(.type == "user" and (.message.content | type) == "string") | .message.content' "$file" | head -3
done | tail -n 50
```

---

## Response Template

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
```

---

## Performance Optimisations

### Best Practices

1. **Find history dir once:** Store `$HISTORY_DIR` variable
2. **Limit output:** Use `head -n 100` or `tail -n 100`
3. **Use context judiciously:** `-C 5` is usually sufficient
4. **Filter by type:** Focus on `.type == "user"`

### Efficient Search Example

```bash
# Good: Targeted, limited output, correct path
PROJECT_DIR=$(pwd | sed 's|^/||' | sed 's|/|-|g')
HISTORY_DIR=$(fd -t d "$PROJECT_DIR" ~/.claude/projects | head -1)
LATEST=$(ls -t "$HISTORY_DIR"/*.jsonl | grep -v agent | head -1)
tail -n 200 "$LATEST" | jq -r 'select(.type == "user") | .message.content' | rg -i "nextauth|cognito" -C 3

# Bad: Non-existent path
rg "project" ~/.claude/history.jsonl
```

**Token Savings:** 60-94% compared to incorrect approach.

---

## Maintenance

### Check History Size

```bash
PROJECT_DIR=$(pwd | sed 's|^/||' | sed 's|/|-|g')
HISTORY_DIR=$(fd -t d "$PROJECT_DIR" ~/.claude/projects | head -1)
du -sh "$HISTORY_DIR"
```

### Archive Old Sessions

```bash
find "$HISTORY_DIR" -name "*.jsonl" -mtime +90 ! -name "agent-*" \
  -exec mv {} ~/.claude/archive/history/$(date +%Y%m%d)/ \;
```

### Remove Agent Sessions

```bash
find "$HISTORY_DIR" -name "agent-*.jsonl" -mtime +30 -delete
```

---

## Changelog

**v2.0** (2025-11-14) - CRITICAL FIX
- Fixed file path: Per-project directories (NOT global history.jsonl)
- Fixed timestamp format: ISO 8601 strings (NOT epoch milliseconds)
- Added agent session filtering
- 60-94% token savings

**v1.0** (2025-11-06) - Initial creation
- Basic search patterns
- `/remind-yourself` command
