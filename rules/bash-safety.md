---
description: Cross-platform bash safety rules - SINGLE SOURCE OF TRUTH
---

# Bash Safety Rules

All bash rules in ONE place. No repetition elsewhere.

## Tool Selection (NO EXCEPTIONS)

| Task | Use | Never Use |
|------|-----|-----------|
| Pattern search | `rg` | grep |
| File finding | `fd` | find, ls |
| JSON processing | `jq` | sed/awk on JSON |
| File preview | `bat` | cat (for display) |

### Always Exclude Dependencies

```bash
rg -n "pattern" --glob '!node_modules/*' --glob '!venv/*'
fd filename --exclude node_modules --exclude venv
```

## Syntax Safety

### No Semicolons After Command Substitution

```bash
# BAD - causes parse error in eval contexts
VAR=$(cmd); echo "$VAR"

# GOOD - use && instead
VAR=$(cmd) && echo "$VAR"
```

### Use Pipes for Multiple Sed

```bash
# BAD - causes zsh parse error in eval contexts
sed 's|a||; s|b||'

# GOOD - use pipes
sed 's|a||' | sed 's|b||'
```

Why: Claude Code hooks run through zsh eval. Semicolons inside patterns cause `(eval):1: parse error near ')'`.

## Path Handling

### Always Use Double-Dash Before Variable Paths

```bash
# BAD - paths like -Users-foo interpreted as flags
fd -t d "$path"

# GOOD - -- ends flag parsing
fd -t d -- "$path"
```

### Project Directory Encoding Formula

Claude Code encodes paths as: `path.replace('/', '-').replace('.', '-')`

```bash
# CORRECT formula
PROJECT_DIR=$(pwd | sed 's|/|-|g' | sed 's|\.|-|g')

# Example: /Users/foo/.claude → -Users-foo--claude
```

The directory KEEPS the leading dash and replaces dots with dashes.

### Finding Project Directories

```bash
fd -t d -- "$PROJECT_DIR" ~/.claude/projects
```

Filter sessions (exclude agents): `grep -v agent`

## JSONL Processing

When processing JSONL files (like `metrics.jsonl`), always use `-s` flag:

```bash
# BAD - treats each line separately, causes "Cannot index string" errors
cat metrics.jsonl | jq '[.[] | select(.event == "skill_generated")]'

# GOOD - slurp mode handles multiple JSON objects
cat metrics.jsonl | jq -s '[.[] | select(.event == "skill_generated")]'
```

## Validation Requirements

All bash must pass:

1. `shellcheck lib/*.sh`
2. `~/.claude/lib/bash-linter.sh`

## Cross-Platform Compatibility

Scripts must work on:

- macOS (zsh default)
- Linux (bash default)
- Windows Git Bash

### Platform-Specific stat

```bash
# macOS
stat -f %m "$file"

# Linux/Git Bash
stat -c %Y "$file"
```

Use `lib/file-mtime-cache.sh` for cross-platform mtime handling.

## Timeout Configuration

Long-running operations require explicit timeouts:

| Command | Timeout | Reason |
|---------|---------|--------|
| `optim.sh audit` | 300000 (5 min) | Scans all session history |
| `optim.sh cycle` | 600000 (10 min) | Full improvement cycle |
| `optim.sh detect` | 180000 (3 min) | Pattern detection |
| All other optim.sh | 120000 (default) | Quick operations |

ALWAYS specify `timeout` parameter for audit/cycle/detect commands.
