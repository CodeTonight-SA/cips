#!/bin/bash
# agy.sh - Open file in Google Antigravity with intelligent inference
# Usage: agy.sh <target>
# Part of Claude-Optim v2.11.0

set -euo pipefail

AGY_BIN="/Users/lauriescheepers/.antigravity/antigravity/bin/antigravity"
TARGET="${1:-}"

if [[ -z "$TARGET" ]]; then
  echo "Usage: agy <filename|description>"
  exit 1
fi

# Verify Antigravity exists
if [[ ! -x "$AGY_BIN" ]]; then
  echo "Antigravity not found at $AGY_BIN"
  exit 1
fi

# Step 1: Exact path
if [[ -f "$TARGET" ]]; then
  exec "$AGY_BIN" "$TARGET"
fi

# Step 2: Exact filename match
EXACT=$(fd -1 -t f "^${TARGET}$" . 2>/dev/null || true)
if [[ -n "$EXACT" ]]; then
  exec "$AGY_BIN" "$EXACT"
fi

# Step 3: Fuzzy match (case-insensitive)
FUZZY=$(fd -t f -i "$TARGET" . --exclude node_modules --exclude .next --exclude dist 2>/dev/null | head -5 || true)
FUZZY_COUNT=$(echo "$FUZZY" | grep -c . 2>/dev/null || echo 0)

if [[ "$FUZZY_COUNT" -eq 1 ]] && [[ -n "$FUZZY" ]]; then
  exec "$AGY_BIN" "$FUZZY"
elif [[ "$FUZZY_COUNT" -gt 1 ]]; then
  # Multiple matches - pick most recently modified in git
  RECENT=$(echo "$FUZZY" | while read -r f; do
    if [[ -n "$f" ]]; then
      MTIME=$(git log -1 --format="%at" -- "$f" 2>/dev/null || stat -f %m "$f" 2>/dev/null || echo 0)
      echo "$MTIME $f"
    fi
  done | sort -rn | head -1 | cut -d' ' -f2-)

  if [[ -n "$RECENT" ]] && [[ -f "$RECENT" ]]; then
    exec "$AGY_BIN" "$RECENT"
  fi
fi

# Step 4: Recent git files
RECENT_GIT=$(git log --name-only --format="" -20 2>/dev/null | grep -i "$TARGET" | head -1 || true)
if [[ -n "$RECENT_GIT" ]] && [[ -f "$RECENT_GIT" ]]; then
  exec "$AGY_BIN" "$RECENT_GIT"
fi

# Step 5: Pattern inference from descriptions
infer_pattern() {
  local t="$1"
  t=$(echo "$t" | tr '[:upper:]' '[:lower:]')

  case "$t" in
    *auth*|*login*) echo "*auth*.ts" ;;
    *config*) echo "config.{json,yaml,ts,js}" ;;
    *schema*) echo "schema.prisma" ;;
    *hook*) echo "*hook*.ts" ;;
    *readme*|*docs*) echo "README.md" ;;
    *test*|*spec*) echo "*.test.ts" ;;
    *controller*) echo "*Controller.ts" ;;
    *service*) echo "*Service.ts" ;;
    *model*) echo "*Model.ts" ;;
    *route*) echo "*route*.ts" ;;
    *component*) echo "*.tsx" ;;
    *env*) echo ".env*" ;;
    *claude*) echo "CLAUDE.md" ;;
    *skill*) echo "SKILL.md" ;;
    *) echo "*${t}*" ;;
  esac
}

PATTERN=$(infer_pattern "$TARGET")
INFERRED=$(fd -t f -g "$PATTERN" . --exclude node_modules --exclude .next 2>/dev/null | head -1 || true)
if [[ -n "$INFERRED" ]] && [[ -f "$INFERRED" ]]; then
  exec "$AGY_BIN" "$INFERRED"
fi

# Fast-fail
echo "File not inferred. Be more specific."
exit 1
