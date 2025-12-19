---
name: agy
description: Open file in Google Antigravity IDE with intelligent file inference. Decodes exact names, similar recent files, or descriptions efficiently. Fast-fail if ambiguous.
command: /agy
aliases: [/antigravity, /ag]
---

# AGY - Antigravity File Opener

Open files in Google Antigravity IDE with intelligent filename inference.

## Activation

- `/agy [target]` where target is exact filename, similar name, or description
- User says "open X in antigravity" or "agy X"

## Antigravity Binary

```bash
AGY_BIN="/Users/lauriescheepers/.antigravity/antigravity/bin/antigravity"
```

## File Inference Algorithm

**CRITICAL**: Total inference time < 3 seconds. Fail fast if ambiguous.

### Priority Order

1. **Exact Match** (0.5s budget)
2. **Fuzzy Match** (1s budget)
3. **Recent Git Files** (0.5s budget)
4. **Description Inference** (1s budget)

### Step 1: Exact Match

```bash
# Direct file path
if [[ -f "$TARGET" ]]; then
  $AGY_BIN "$TARGET"
  exit 0
fi

# Exact filename anywhere in project
EXACT=$(fd -1 -t f "^${TARGET}$" . 2>/dev/null)
if [[ -n "$EXACT" ]]; then
  $AGY_BIN "$EXACT"
  exit 0
fi
```

### Step 2: Fuzzy Match (Case-Insensitive, Partial)

```bash
# Partial match, prioritise by recency
FUZZY=$(fd -t f -i "$TARGET" . 2>/dev/null | head -10)

if [[ $(echo "$FUZZY" | wc -l | tr -d ' ') -eq 1 ]]; then
  # Single match - open it
  $AGY_BIN "$FUZZY"
  exit 0
elif [[ -n "$FUZZY" ]]; then
  # Multiple matches - check git recency
  RECENT=$(echo "$FUZZY" | while read f; do
    MTIME=$(git log -1 --format="%at" -- "$f" 2>/dev/null || stat -f %m "$f" 2>/dev/null || echo 0)
    echo "$MTIME $f"
  done | sort -rn | head -1 | cut -d' ' -f2-)

  if [[ -n "$RECENT" ]]; then
    $AGY_BIN "$RECENT"
    exit 0
  fi
fi
```

### Step 3: Recent Git Files

```bash
# Check recently modified files in git
RECENT_GIT=$(git log --name-only --format="" -20 2>/dev/null | \
  grep -i "$TARGET" | head -1)

if [[ -n "$RECENT_GIT" ]] && [[ -f "$RECENT_GIT" ]]; then
  $AGY_BIN "$RECENT_GIT"
  exit 0
fi
```

### Step 4: Description Inference

Interpret semantic descriptions:

| Description Pattern | Inference |
|---------------------|-----------|
| "the auth file" | `*auth*.{ts,js,py}` |
| "main config" | `{config,settings}.{json,yaml,ts}` |
| "that component" | Recent `.tsx` in git |
| "the schema" | `schema.prisma`, `schema.graphql` |
| "the hook" | `*hook*.ts`, `use*.ts` |
| "readme", "docs" | `README.md`, `*.md` |
| "the test" | Recent `*.test.ts`, `*.spec.ts` |
| "env file" | `.env*` |
| "that controller" | `*Controller.ts`, `*controller.py` |

```bash
# Pattern matching for descriptions
case "$TARGET" in
  *auth*|*login*) PATTERN="*auth*.{ts,js,py}" ;;
  *config*) PATTERN="{config,settings}.{json,yaml,ts,js}" ;;
  *schema*) PATTERN="schema.{prisma,graphql,sql}" ;;
  *hook*) PATTERN="*hook*.ts" ;;
  *readme*|*docs*) PATTERN="README.md" ;;
  *test*) PATTERN="*.{test,spec}.{ts,js}" ;;
  *env*) PATTERN=".env*" ;;
  *controller*) PATTERN="*[Cc]ontroller.{ts,js,py}" ;;
  *service*) PATTERN="*[Ss]ervice.{ts,js,py}" ;;
  *model*) PATTERN="*[Mm]odel.{ts,js,py}" ;;
  *route*) PATTERN="*route*.{ts,js}" ;;
  *component*) PATTERN="*.tsx" ;;
  *) PATTERN="*${TARGET}*" ;;
esac

INFERRED=$(fd -t f -g "$PATTERN" . 2>/dev/null | head -1)
if [[ -n "$INFERRED" ]]; then
  $AGY_BIN "$INFERRED"
  exit 0
fi
```

### Fast-Fail Response

If no match after all steps:

```text
File not inferred. Be more specific.
```

## Usage Examples

| Input | Inference |
|-------|-----------|
| `/agy CLAUDE.md` | Exact match |
| `/agy skill` | Most recent `*skill*` file |
| `/agy the auth controller` | `AuthController.ts` |
| `/agy that hook we worked on` | Recent `*hook*` from git |
| `/agy schema` | `schema.prisma` |
| `/agy readme` | `README.md` |
| `/agy xyznonexistent` | "File not inferred. Be more specific." |

## Implementation Notes

### For Claude (Executing This Skill)

When user invokes `/agy [target]`:

1. Parse `[target]` - could be path, name, or description
2. Run inference algorithm IN ORDER (exact > fuzzy > git > description)
3. Stop at first match, open with Antigravity
4. If no match in <3s, respond: `File not inferred. Be more specific.`

### Bash Script (Helper)

```bash
#!/bin/bash
# ~/.claude/lib/agy.sh

AGY_BIN="/Users/lauriescheepers/.antigravity/antigravity/bin/antigravity"
TARGET="$1"
TIMEOUT=3

# Exact path
[[ -f "$TARGET" ]] && exec "$AGY_BIN" "$TARGET"

# Exact name
EXACT=$(timeout "$TIMEOUT" fd -1 -t f "^${TARGET}$" . 2>/dev/null)
[[ -n "$EXACT" ]] && exec "$AGY_BIN" "$EXACT"

# Fuzzy (single)
FUZZY=$(timeout "$TIMEOUT" fd -t f -i "$TARGET" . 2>/dev/null | head -5)
[[ $(echo "$FUZZY" | wc -l | tr -d ' ') -eq 1 ]] && [[ -n "$FUZZY" ]] && exec "$AGY_BIN" "$FUZZY"

# Git recent
RECENT=$(git log --name-only --format="" -20 2>/dev/null | grep -i "$TARGET" | head -1)
[[ -n "$RECENT" ]] && [[ -f "$RECENT" ]] && exec "$AGY_BIN" "$RECENT"

# Pattern inference
infer_pattern() {
  case "$1" in
    *auth*|*login*) echo "*auth*.ts" ;;
    *config*) echo "config.{json,yaml,ts}" ;;
    *schema*) echo "schema.prisma" ;;
    *hook*) echo "*hook*.ts" ;;
    *readme*) echo "README.md" ;;
    *test*) echo "*.test.ts" ;;
    *controller*) echo "*Controller.ts" ;;
    *service*) echo "*Service.ts" ;;
    *component*) echo "*.tsx" ;;
    *) echo "*${1}*" ;;
  esac
}

PATTERN=$(infer_pattern "$TARGET")
INFERRED=$(fd -t f -g "$PATTERN" . 2>/dev/null | head -1)
[[ -n "$INFERRED" ]] && exec "$AGY_BIN" "$INFERRED"

echo "File not inferred. Be more specific."
exit 1
```

## Performance Budget

| Step | Time Budget |
|------|-------------|
| Exact match | 0.5s |
| Fuzzy match | 1.0s |
| Git recent | 0.5s |
| Pattern inference | 1.0s |
| **Total** | **3.0s max** |

If any step hangs, skip to next. If all fail, fast-fail message.

## Token Cost

~200-400 tokens per invocation (mostly bash execution).

## Integration

### With Session History

Prioritise files mentioned in recent session:

```bash
# Check ~/.claude/projects/ for recently discussed files
SESSION_FILES=$(rg -l "$TARGET" ~/.claude/projects/*/session-*.jsonl 2>/dev/null | head -1)
```

### With Git

Always prefer recently modified files when ambiguous.

## Origin

Created by Gen 17 (Instance 60) on 2025-12-20 for V>> request: fast Antigravity file opening with intelligent inference.

Sources: [Google Antigravity Guide](https://antigravity.codes/)
