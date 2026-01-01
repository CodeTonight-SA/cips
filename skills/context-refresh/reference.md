# Context Refresh - Reference Material

**Parent:** [SKILL.md](./SKILL.md)

---

## Detailed Step Implementations

### Step 1: Git Reality Snapshot - Full Script

```bash
# Step 1: Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "⚠️ Not a git repository - skipping git analysis"
  echo "Continuing with file analysis and history only..."
  SKIP_GIT=true
  CONFIDENCE_FROM_COMMITS=0
  return 0
fi

# Step 2: Run git commands in parallel with error handling
{
  git status --short 2>/dev/null || echo "ERROR: git status failed"
} &
{
  git log --oneline --format="%h|%s|%cd" --date=iso -10 2>/dev/null || echo "ERROR: git log failed (no commits?)"
} &
{
  git branch -v 2>/dev/null || echo "ERROR: git branch failed"
} &
{
  git diff --stat HEAD 2>/dev/null || echo "WARNING: git diff failed"
} &
wait

# Step 3: Extract key information with fallbacks
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
COMMIT_COUNT=$(git log --oneline 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Step 4: Check for critical states
if [[ "$CURRENT_BRANCH" == "HEAD" ]] || [[ "$CURRENT_BRANCH" == "" ]]; then
  echo "⚠️ DETACHED HEAD detected"
fi

# Check for staged secrets
STAGED_SECRETS=$(git diff --cached --name-only 2>/dev/null | grep -iE '\.(env|secret|credential|key|token)' || echo "")
if [[ -n "$STAGED_SECRETS" ]]; then
  echo "🚨 CRITICAL: Potential secrets staged for commit!"
  echo "Files: $STAGED_SECRETS"
fi

# Check for merge conflicts
CONFLICTS=$(git status --short 2>/dev/null | grep '^UU\|^AA\|^DD' || echo "")
if [[ -n "$CONFLICTS" ]]; then
  echo "⚠️ MERGE CONFLICTS detected:"
  echo "$CONFLICTS"
fi
```

### Step 2: Session History Search - Full Script

```bash
# Step 1: Locate project history directory
PROJECT_DIR=$(pwd | sed 's|^/||' | sed 's|/|-|g')
HISTORY_DIR=$(fd -t d "$PROJECT_DIR" ~/.claude/projects 2>/dev/null | head -1)

# Step 2: Check if history exists and is accessible
if [[ -z "$HISTORY_DIR" ]]; then
  echo "⚠️ No history found for this project - fresh start"
  CONFIDENCE_FROM_HISTORY=0
  return 0
fi

if [[ ! -d "$HISTORY_DIR" ]]; then
  echo "⚠️ History directory not accessible: $HISTORY_DIR"
  CONFIDENCE_FROM_HISTORY=0
  return 0
fi

# Check for session files
if [[ -z "$(ls "$HISTORY_DIR"/*.jsonl 2>/dev/null | grep -v agent)" ]]; then
  echo "⚠️ No session files found in history"
  CONFIDENCE_FROM_HISTORY=0
  return 0
fi

# Step 3: Search with common workflow patterns
echo "=== Session History Search ==="
SEARCH_PATTERN="implement|build|create|add|feature|workflow|api|endpoint|controller|service|route|fix"
SEARCH_PATTERN="$SEARCH_PATTERN|refactor|lease|listing|application|deposit|payment|integration|frontend|backend|model|schema|migration"
SESSION_MATCHES=$(rg -i "$SEARCH_PATTERN" \
  "$HISTORY_DIR"/*.jsonl \
  --glob '!agent-*' \
  -C 5 \
  2>/dev/null | head -200)

# Step 4: Check if search found matches
if [[ -z "$SESSION_MATCHES" ]]; then
  echo "⚠️ No session history matches found"
  CONFIDENCE_FROM_HISTORY=10
else
  echo "$SESSION_MATCHES"
  MATCH_COUNT=$(echo "$SESSION_MATCHES" | grep -c "^--$" 2>/dev/null || echo "0")

  if [[ $MATCH_COUNT -ge 5 ]]; then
    CONFIDENCE_FROM_HISTORY=40
  elif [[ $MATCH_COUNT -ge 2 ]]; then
    CONFIDENCE_FROM_HISTORY=25
  else
    CONFIDENCE_FROM_HISTORY=10
  fi
  echo "History confidence: $CONFIDENCE_FROM_HISTORY% ($MATCH_COUNT match blocks)"
fi

# Step 5: List recent sessions for context
echo ""
echo "=== Recent Sessions ==="
ls -t "$HISTORY_DIR"/*.jsonl 2>/dev/null | grep -v agent | head -3 | while read session; do
  echo "  - $(basename "$session" .jsonl)"
done
```

### Step 4a: CLAUDE.md Detection - Full Script

```bash
# Step 1: Check if CLAUDE.md exists and is readable
if [[ ! -f "CLAUDE.md" ]]; then
  echo "⚠️ No CLAUDE.md found - skipping comparison"
  NEEDS_UPDATE=false
  CONFIDENCE_FROM_CLAUDE=0
  return 0
fi

if [[ ! -r "CLAUDE.md" ]]; then
  echo "⚠️ CLAUDE.md not readable - skipping comparison"
  NEEDS_UPDATE=false
  CONFIDENCE_FROM_CLAUDE=0
  return 0
fi

# Step 2: Extract CURRENT STATE section
echo "=== CLAUDE.md Current State ==="
CURRENT_STATE_CONTENT=$(sed -n '/## CURRENT STATE/,/^## [A-Z]/p' CLAUDE.md | head -n -1)

# Step 3: Check if CURRENT STATE section exists
if [[ -z "$CURRENT_STATE_CONTENT" ]]; then
  echo "⚠️ No CURRENT STATE section found - will add one"
  NEEDS_UPDATE=true
  MISSING_SECTION=true
  CONFIDENCE_FROM_CLAUDE=10
else
  echo "$CURRENT_STATE_CONTENT"
  MISSING_SECTION=false
  CONFIDENCE_FROM_CLAUDE=30
fi

# Step 4: Extract PROJECT IDENTITY
echo ""
echo "=== CLAUDE.md Project Identity ==="
sed -n '/## PROJECT IDENTITY/,/^## [A-Z]/p' CLAUDE.md | head -20

# Step 5: Compare reality vs documented state
echo ""
echo "=== Comparing Reality vs Documentation ==="

DOCUMENTED_BRANCH=$(echo "$CURRENT_STATE_CONTENT" | grep -i "Current Branch" | sed 's/.*: *//')
echo "Documented branch: ${DOCUMENTED_BRANCH:-'Not specified'}"
echo "Actual branch: $CURRENT_BRANCH"

DOCUMENTED_PHASE=$(echo "$CURRENT_STATE_CONTENT" | grep -i "Current Phase" | sed 's/.*: *//')
echo "Documented phase: ${DOCUMENTED_PHASE:-'Not specified'}"

# Infer current phase from session history + branch name
if [[ $CONFIDENCE_FROM_HISTORY -ge 25 ]] && [[ -n "$CURRENT_BRANCH" ]]; then
  case "$CURRENT_BRANCH" in
    *integration*|*ready*) INFERRED_PHASE="Integration Readiness" ;;
    *mvp*|*launch*) INFERRED_PHASE="MVP Development" ;;
    *feat*|*feature*) INFERRED_PHASE="Feature Development" ;;
    *fix*|*bug*) INFERRED_PHASE="Maintenance/Bug Fixes" ;;
    *refactor*|*cleanup*) INFERRED_PHASE="Refactoring" ;;
    main|master|production) INFERRED_PHASE="Production" ;;
    dev|develop|development) INFERRED_PHASE="Active Development" ;;
    *) INFERRED_PHASE="Active Development" ;;
  esac
  echo "Inferred phase: $INFERRED_PHASE"
fi

# Step 6: Determine if update is needed
NEEDS_UPDATE=false

if [[ -n "$DOCUMENTED_BRANCH" ]] && [[ "$DOCUMENTED_BRANCH" != "$CURRENT_BRANCH" ]]; then
  echo "❌ Branch mismatch detected"
  NEEDS_UPDATE=true
fi

if [[ $CONFIDENCE_FROM_HISTORY -ge 25 ]] && [[ -n "$DOCUMENTED_PHASE" ]] && \
   [[ -n "$INFERRED_PHASE" ]] && [[ "$DOCUMENTED_PHASE" != "$INFERRED_PHASE" ]]; then
  echo "❌ Phase mismatch detected"
  NEEDS_UPDATE=true
fi

if [[ $MISSING_SECTION == true ]]; then
  echo "❌ CURRENT STATE section missing"
  NEEDS_UPDATE=true
fi

# Step 7: Calculate total confidence
TOTAL_CONFIDENCE=$(( $CONFIDENCE_FROM_COMMITS + $CONFIDENCE_FROM_HISTORY + $CONFIDENCE_FROM_CLAUDE ))
echo ""
echo "=== Auto-Update Decision ==="
echo "Total confidence: $TOTAL_CONFIDENCE%"
echo "Needs update: $NEEDS_UPDATE"

if [[ $NEEDS_UPDATE == true ]] && [[ $TOTAL_CONFIDENCE -ge 80 ]]; then
  echo "✅ Auto-update approved (confidence: $TOTAL_CONFIDENCE%)"
  SHOULD_AUTO_UPDATE=true
elif [[ $NEEDS_UPDATE == true ]] && [[ $TOTAL_CONFIDENCE -lt 80 ]]; then
  echo "⚠️ Update needed but confidence too low ($TOTAL_CONFIDENCE%) - flagging for manual review"
  SHOULD_AUTO_UPDATE=false
else
  echo "✅ CLAUDE.md is up to date"
  SHOULD_AUTO_UPDATE=false
fi
```

### Step 4b: Execute Auto-Update - Full Script

```bash
# Only execute if Step 4a approved auto-update
if [[ $SHOULD_AUTO_UPDATE != true ]]; then
  echo "Skipping auto-update (not approved)"
  return 0
fi

echo ""
echo "=== Executing CLAUDE.md Auto-Update ==="

# Step 1: Build new CURRENT STATE section
TIMESTAMP=$(date -u +"%Y-%m-%d")
NEW_CURRENT_STATE="## CURRENT STATE

**Current Phase**: ${INFERRED_PHASE:-Active Development}
**Current Branch**: $CURRENT_BRANCH
**Active Work**: $(echo "$SESSION_MATCHES" | head -5 | grep -o '"[^"]*"' | head -1 | tr -d '"' || echo "See recent commits")

### Recent Additions
- Modified files: $(git status --short | grep '^ M' | wc -l | tr -d ' ')
- New files: $(git status --short | grep '^??' | wc -l | tr -d ' ')
- Recent commits: $COMMIT_COUNT

**Last Updated**: $TIMESTAMP (auto-updated by context-refresh v3.2)"

# Step 2: Create backup
cp CLAUDE.md CLAUDE.md.backup
echo "✅ Created backup: CLAUDE.md.backup"

# Step 3: Update CURRENT STATE section with sed
if [[ $MISSING_SECTION == true ]]; then
  sed -i '' '/## PROJECT IDENTITY/,/^## [A-Z]/ {
    /^## [A-Z]/i\
\
'"$NEW_CURRENT_STATE"'\
\
  }' CLAUDE.md
  echo "✅ Added CURRENT STATE section"
else
  sed -i '' '/## CURRENT STATE/,/^## [A-Z]/{
    /## CURRENT STATE/!{
      /^## [A-Z]/!d
    }
  }' CLAUDE.md
  echo "✅ Updated CURRENT STATE section"
fi

# Step 4: Verify update succeeded
if grep -q "Last Updated: $TIMESTAMP" CLAUDE.md; then
  echo "✅ Auto-update completed successfully"
else
  echo "❌ Auto-update verification failed - restoring backup"
  mv CLAUDE.md.backup CLAUDE.md
  return 1
fi
```

### Step 7: Confidence Validation Function

```bash
# Validation 1: Detect merge commits (reduces confidence)
MERGE_COMMIT_COUNT=$(git log --oneline --merges -10 2>/dev/null | wc -l | tr -d ' ')

if [[ $MERGE_COMMIT_COUNT -ge 3 ]]; then
  echo "⚠️ High merge activity detected ($MERGE_COMMIT_COUNT merges in last 10 commits)"
  echo "   Reducing commit confidence by 10%"
  CONFIDENCE_FROM_COMMITS=$(( $CONFIDENCE_FROM_COMMITS - 10 ))
  [[ $CONFIDENCE_FROM_COMMITS -lt 0 ]] && CONFIDENCE_FROM_COMMITS=0
fi

# Validation 2: Sanity check file counts
TOTAL_FILES_CLAIMED=$(git status --short | wc -l | tr -d ' ')
ACTUAL_MODIFIED=$(git status --short | grep '^ M' | wc -l | tr -d ' ')
ACTUAL_UNTRACKED=$(git status --short | grep '^??' | wc -l | tr -d ' ')
ACTUAL_STAGED=$(git status --short | grep '^M' | wc -l | tr -d ' ')
CALCULATED_TOTAL=$(( $ACTUAL_MODIFIED + $ACTUAL_UNTRACKED + $ACTUAL_STAGED ))

if [[ $TOTAL_FILES_CLAIMED -ne $CALCULATED_TOTAL ]]; then
  echo "⚠️ File count mismatch detected"
fi

# Validation 3: Check for detached HEAD
if [[ "$CURRENT_BRANCH" == "HEAD" ]]; then
  echo "⚠️ Detached HEAD state detected"
  CONFIDENCE_FROM_COMMITS=$(( $CONFIDENCE_FROM_COMMITS - 15 ))
  [[ $CONFIDENCE_FROM_COMMITS -lt 0 ]] && CONFIDENCE_FROM_COMMITS=0
fi

# Validation 4: Check for excessive untracked files
if [[ $ACTUAL_UNTRACKED -gt 50 ]]; then
  echo "⚠️ Excessive untracked files detected ($ACTUAL_UNTRACKED files)"
fi

# Recalculate total confidence after validations
TOTAL_CONFIDENCE=$(( $CONFIDENCE_FROM_COMMITS + $CONFIDENCE_FROM_HISTORY + $CONFIDENCE_FROM_CLAUDE ))
```

---

## Adaptive Semantic Analysis Levels

### Level A: Basic Categorization (>80% Confidence)

```bash
echo "=== File Categorization ==="
git status --short | grep '^??' | wc -l  # Untracked count
git status --short | grep '^ M' | wc -l  # Modified count

git status --short | grep '^??' | grep -i 'controller' | wc -l
git status --short | grep '^??' | grep -i 'service' | wc -l
git status --short | grep '^??' | grep -i 'route' | wc -l
git status --short | grep 'schema.prisma\|migration'
```

### Level B: Infer from File Names (<80% Confidence)

```bash
git status --short | grep '^??' | while read status file; do
  case "$file" in
    *Controller.ts) echo "Controller: $(basename "$file" Controller.ts)" ;;
    *Service.ts) echo "Service: $(basename "$file" Service.ts)" ;;
    *routes.ts) echo "Routes: $(basename "$file" .routes.ts)" ;;
    *migration*) echo "Migration: Schema change detected" ;;
  esac
done
fd -t d . src --max-depth 2 | grep -v node_modules
```

### Level C: Preview Key Files (Still Unclear)

```bash
git status --short | grep '^??' | grep 'Controller.ts' | while read status file; do
  if [[ -s "$file" ]]; then
    echo "=== $file (preview) ==="
    bat --line-range 1:10 "$file"
  fi
done

git status --short | grep 'migration' | while read status file; do
  if [[ -s "$file" ]]; then
    bat "$file"
  fi
done
```

---

## Briefing Template

```markdown
# [Project Name] - Context Refresh v3.2

**Project**: [From CLAUDE.md PROJECT IDENTITY]
**Tech Stack**: [Framework + key libraries (top 5)]
**Framework**: [Primary + any conflicts detected]
**Status**: [Production/Dev/Prototype], [file count], [recent work summary]

## CURRENT STATE [auto-updated from multi-source analysis]

- **Phase**: [Current phase name]
- **Branch**: [Branch name with semantic inference]
- **Active Work**: [Synthesized from all sources]
- **Recent Additions**:
  - [Categorized new files]
  - [Schema changes]
  - [Configuration changes]

## SESSION HISTORY CONTEXT (Last 3 Sessions)

- **[ISO Timestamp]**: [What user asked for]
- **[ISO Timestamp]**: [Blockers/decisions made]

## GIT ACTIVITY

- **Staged**: [N] files
- **Unstaged**: [N] files
- **Untracked**: [N] files
- **Recent Commits** (last 3):
  1. [hash] | [commit message] | [timestamp]

## SEMANTIC UNDERSTANDING

**WHY** (from session history): [User intent]
**WHAT INTENDED** (from git commits): [Developer's summary]
**WHAT EXISTS** (from git status): [Actual file changes]
**SYNTHESIS**: [Complete understanding with confidence score]

## RISKS & ALERTS

[🚨 Critical issues or ⚠️ warnings or ✅ None]

## READY TO CODE

- **Dev server**: [npm run dev / cargo run / python main.py]
- **Build**: [npm run build / cargo build --release]
- **Test**: [npm test / cargo test / pytest]

## MENTAL MODEL

**Established**: [Total files], [framework], [current focus], **Confidence: [High/Medium/Low]%**
```

---

## Integration Points

### With self-improvement-engine

```json
{
  "context-loss": {
    "pattern": "Read\\(CLAUDE\\.md\\).*Read\\(CLAUDE\\.md\\)",
    "threshold": 2,
    "severity": "major",
    "skill_suggestion": "context-refresh"
  }
}
```

### With chat-history-search

- History stored per-project: `~/.claude/projects/{encoded-path}/{uuid}.jsonl`
- Timestamps are ISO 8601 strings
- Always filter by `.type == "user"` for user messages

### Multi-Source Synthesis Data Flow

```text
Session History (WHY) ─┐
                       ├─→ Confidence Scoring ─→ Auto-Update Decision
Git Commits (WHAT) ────┤
                       │
Git Status (EXISTS) ───┘
```

---

## Example Workflows

### Workflow 1: Complete Context Refresh

**Scenario:** New session, active development, session history exists

```text
Step 1: Git Snapshot
  Branch: enhancements/api_frontend_integration_readiness
  Recent commits: feat: Add lease endpoints, feat: Add application workflow
  Untracked: 15 files

Step 2: Session History
  "Prepare backend APIs for frontend integration"

Step 3: Semantic Analysis (Level A - High Confidence)
  Session + commits = clear understanding (>90% confidence)

Step 4: CLAUDE.md Check
  Reality vs Documentation → AUTO-UPDATE TRIGGERED

Token Cost: ~2800 tokens
```

### Workflow 2: Fresh Repo (No History)

**Scenario:** First session, no history

```text
Step 2: No history found - fresh start
Step 3: Level C required - read key files
Token Cost: ~3200 tokens
```

### Workflow 3: Low Confidence

**Scenario:** Unclear state, vague commits

```text
Commits: "WIP", "fixes", "update" ← Uninformative
Level A: <60%, Level B: <75%, Level C: 80% achieved
Flag for manual review instead of auto-update
Token Cost: ~3400 tokens
```

---

## Changelog (Full History)

**v3.2** (2025-11-14) - Full Auto-Update + Robustness
- CRITICAL FIX: Step 4 EXECUTES auto-update with sed
- FIXED: Exit code bug (check output, not pipe exit code)
- ADDED: Comprehensive error handling
- SPLIT: Step 4 into 4a/4b for SOLID compliance
- ADDED: Confidence validation function

**v3.1** (2025-11-14) - Simplified Session Search
- Uses proven rg patterns from chat-history-search
- Removed complex jq queries

**v3.0** (2025-11-14) - Multi-Source Semantic Understanding
- Session History Semantic Search
- Adaptive semantic analysis (Level A→B→C)
- Auto-update CLAUDE.md when outdated

**v2.0** (2025-11-14) - Corrected Step 4 history logic
- Fixed per-project history paths
- Fixed ISO 8601 timestamp handling

**v1.0** (2025-11-09) - Initial implementation
- 7-step discovery protocol
- Secrets detection
- Framework conflict detection
