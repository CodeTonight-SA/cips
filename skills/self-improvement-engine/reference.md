# Self-Improvement Engine - Reference Material

**Parent:** [SKILL.md](./SKILL.md)

---

## Pattern Detection Scripts

### Temporal Analysis Protocol

```bash
# CRITICAL: Always use timestamp-based filtering
# history.jsonl format: {"timestamp": 1762421400000, ...} (epoch ms)
# HEAD = oldest, TAIL = newest

# Calculate epoch range for time window
START_EPOCH=$(date -j -f "%Y-%m-%d %H:%M:%S" "2025-11-06 11:30:00" "+%s")000
END_EPOCH=$(date -j -f "%Y-%m-%d %H:%M:%S" "2025-11-06 15:33:00" "+%s")000

# Filter by timestamp
tail -n 1000 ~/.claude/history.jsonl | jq -r "select(.timestamp >= $START_EPOCH and .timestamp <= $END_EPOCH)"

# Verify direction (first vs last timestamps)
head -n 1 ~/.claude/history.jsonl | jq -r '.timestamp'  # Oldest
tail -n 1 ~/.claude/history.jsonl | jq -r '.timestamp'  # Newest
```

### Inefficiency Signatures

```json
{
  "repeated-file-reads": {
    "pattern": "Read\\(([^)]+)\\).*Read\\(\\1\\)",
    "threshold": 3,
    "severity": "major",
    "skill_suggestion": "file-caching"
  },
  "temp-script-creation": {
    "pattern": "Write.*\\.js\\).*Bash.*node.*\\.js.*Bash.*rm.*\\.js",
    "threshold": 2,
    "severity": "major",
    "skill_suggestion": "direct-implementation"
  },
  "dependency-folder-read": {
    "pattern": "Read\\(.*node_modules|venv|__pycache__",
    "threshold": 1,
    "severity": "critical",
    "skill_suggestion": "path-exclusion-enforcer"
  },
  "cli-command-chains": {
    "pattern": "(Bash.*){5,}",
    "threshold": 3,
    "severity": "minor",
    "skill_suggestion": "command-aliasing"
  },
  "context-loss": {
    "pattern": "remind.*previous|what did we|can't remember|forgot",
    "threshold": 2,
    "severity": "minor",
    "skill_suggestion": "enhanced-memory"
  }
}
```

### Detection Process

```bash
# Step 1: Define time window
HOURS_AGO=4
END_EPOCH=$(date +%s)000
START_EPOCH=$(( ($(date +%s) - (HOURS_AGO * 3600)) * 1000 ))

# Step 2: Extract recent history with timestamp filter
RECENT_HISTORY=$(tail -n 1000 ~/.claude/history.jsonl | \
  jq -r "select(.timestamp >= $START_EPOCH and .timestamp <= $END_EPOCH)")

# Step 3: Scan for patterns
echo "$RECENT_HISTORY" | rg -o 'Read\([^)]+\)' | sort | uniq -c | sort -rn

# Score by severity: critical=10, major=5, minor=3
# If score >= 10, trigger skill generation
```

---

## Workflow 1: /detect-inefficiency

### Full Script

```bash
# Calculate time window (last 4 hours)
HOURS_AGO=4
START_EPOCH=$(( ($(date +%s) - (HOURS_AGO * 3600)) * 1000 ))
END_EPOCH=$(date +%s)000

# Extract with temporal precision
tail -n 1000 ~/.claude/history.jsonl | \
  jq "select(.timestamp >= $START_EPOCH and .timestamp <= $END_EPOCH)" \
  > /tmp/recent_history.jsonl

# Run pattern matching
for pattern in patterns.json:
    matches = rg pattern.regex /tmp/recent_history.jsonl
    if matches.count >= pattern.threshold:
        inefficiencies.append(pattern)

# Score & Rank
ranked = sort(inefficiencies, key=lambda x: (x.severity, x.count))
```

### Example Output

```markdown
# Inefficiency Detection Report

**Scanned:** Last 4 hours (timestamp-filtered)
**Timestamp Range:** 1762421400000 - 1762435980000
**Entries Analyzed:** 6 conversations

## Summary
- 🚨 **2 critical issues** (20 points)
- ⚠️ **3 major issues** (15 points)
- 💡 **1 minor issue** (3 points)
- **Total Score:** 38 points (Critical)

## Critical Issues

### 1. dependency-folder-read (3 occurrences)
**Impact:** ~50,000 tokens wasted
**Pattern:** Reading `node_modules/` without exclusions
**Suggested Skill:** `path-exclusion-enforcer`

### Examples:
- Session 2025-11-06 10:15: Read node_modules/react/package.json
- Session 2025-11-06 11:32: Read node_modules/@types/node/README.md

### Fix:
```bash
rg "pattern" --glob '!node_modules/*'
fd "file" --exclude node_modules
```

## Recommendations

**Priority 1:** `/generate-skill path-exclusion-enforcer` (saves 50k tokens)
**Priority 2:** `/generate-skill file-caching` (saves 2k tokens)
**Estimated Savings:** ~52,000 tokens per session
```

---

## Workflow 2: /generate-skill

### Full Script

```bash
# 1. Validate Pattern
if pattern not in patterns.json:
    echo "Unknown pattern. Run /detect-inefficiency first."
    exit 1

# 2. Extract Context
examples = rg pattern.regex ~/.claude/history.jsonl -C 5 | head -n 50

# 3. Fill Template
template = read("~/.claude/templates/skills/SKILL.template.md")
replacements = {
    "{{SKILL_NAME}}": pattern.skill_suggestion,
    "{{PURPOSE_STATEMENT}}": "Prevent " + pattern.description,
    "{{TRIGGER_CONDITIONS_LIST}}": generate_from_regex(pattern.regex),
    "{{EXAMPLE_1_CODE}}": examples[0],
    "{{TOKEN_BUDGET}}": estimate_budget(pattern.severity),
    "{{CREATION_DATE}}": today(),
    "{{MAINTAINER}}": get_git_author(),
}
skill_content = template.replace_all(replacements)

# 4. Validate
validate_yaml(skill_content.frontmatter)
if "{{" in skill_content:
    warn("Incomplete generation - review manually")

# 5. Save & Activate
mkdir -p ~/.claude/skills/$(pattern.skill_suggestion)
write(skill_content, "~/.claude/skills/$(pattern.skill_suggestion)/SKILL.md")

# 6. Update CLAUDE.md
append_to_section(
    file="~/.claude/CLAUDE.md",
    section="## Skills System",
    entry="- **$(pattern.skill_suggestion)**: " + pattern.description
)
```

### Example Output

```markdown
# ✅ Skill Generated Successfully

**Skill Name:** `file-caching`
**Location:** `~/.claude/skills/file-caching/SKILL.md`
**Token Budget:** <2000 tokens per activation
**Auto-Generated:** 2025-11-06 14:45

## What This Skill Does

Prevents repeated file reads by caching file contents in working memory.

## Files Created
- `~/.claude/skills/file-caching/SKILL.md` (712 lines)

## Files Updated
- `~/.claude/CLAUDE.md` (added to Skills System section)

## Next Steps

1. Review Skill: `bat ~/.claude/skills/file-caching/SKILL.md`
2. Test Trigger Conditions
3. Generate Documentation: `/write-medium-article file-caching`
4. Commit when ready
```

---

## Workflow 3: /audit-efficiency

### Full Script

```bash
# 1. Load Checklist
checklist = parse("~/.claude/EFFICIENCY_CHECKLIST.md")

# 2. Analyze Session
tool_calls = get_current_session_tools()

# 3. Count Violations
violations = {"major": [], "minor": []}

# Rule 1: File Read Optimization
file_reads = filter(tool_calls, type="Read")
for file in unique(file_reads.paths):
    count = file_reads.count(file)
    if count >= 3:
        violations.major.append({
            "rule": "File Read Optimization",
            "violation": f"Read {file} {count} times",
            "points": 10
        })

# Rule 3: Implementation Directness
temp_scripts = rg "Write.*\\.js.*Bash.*node" tool_calls
if temp_scripts:
    violations.major.append({
        "rule": "Implementation Directness",
        "violation": "Created temp script",
        "points": 10
    })

# Rule 4: Concise Communication
preambles = rg "(I'll now|Let me proceed)" tool_calls
violations.minor.append({
    "rule": "Concise Communication",
    "violation": f"{preambles.count} preambles",
    "points": preambles.count * 3
})

# 4. Calculate Score
score = sum(v.points for v in violations.major + violations.minor)
grade = {
    score == 0: "Perfect ✅",
    score <= 6: "Good 👍",
    score <= 15: "Needs Improvement ⚠️",
    score > 15: "Critical 🚨"
}[True]
```

### Example Output

```markdown
# 📊 Efficiency Audit Report

**Session:** Current (2025-11-06 14:45)
**Duration:** ~15 minutes
**Tool Calls:** 47 total
**Tokens Used:** ~23,500

## Score: 13 points (Needs Improvement ⚠️)

### Major Violations (10 points each)
❌ **File Read Optimization** - Read `package.json` 3 times
   - Occurrences: Message 15, 42, 67

### Minor Violations (3 points each)
⚠️ **Concise Communication** - 1 unnecessary preamble
   - Occurrence: Message 12

## Comparison to Best Practices

| Metric | This Session | Best Practice | Gap |
|--------|-------------|---------------|-----|
| Repeat file reads | 3 | 0 | ❌ 3 |
| Preambles | 1 | 0 | ❌ 1 |
| Token efficiency | 85% | 95% | ⚠️ 10% |

## If violations were fixed:
- Tokens saved: ~2,500 (10.6% reduction)
- New score: 0 points (Perfect ✅)
```

---

## Workflow 4: /auto-improve (Full Cycle)

```bash
# 1. Detect Inefficiencies
/detect-inefficiency
# Output: Ranked list of patterns

# 2. Select Highest Priority
top_pattern = inefficiencies.sorted()[0]

# 3. Generate Skill
/generate-skill $(top_pattern.skill_suggestion)

# 4. Audit Improvement
/audit-efficiency
# Expected: Score decreased

# 5. Document
/write-medium-article "$(top_pattern.skill_suggestion)"

# 6. Commit (requires user approval)
git add ~/.claude/skills/$(top_pattern.skill_suggestion)/
git add ~/.claude/CLAUDE.md
git commit -m "Add $(top_pattern.skill_suggestion) skill (auto-generated)"

# 7. Recurse (check if meta-skill can improve itself)
if inefficiencies.contains("skill-generation-inefficiency"):
    echo "🔁 Meta-recursion detected"
```

---

## Metrics Tracking

### Session Metrics Schema

**File:** `~/.claude/metrics.jsonl`

```json
{
  "session_id": "2025-11-06T14:45:00Z",
  "project": "/path/to/your/project",
  "duration_minutes": 15,
  "tokens_used": 23500,
  "tool_calls": 47,
  "skills_triggered": ["chat-history-search", "figma-to-code"],
  "efficiency_score": 13,
  "violations": {
    "major": 1,
    "minor": 1
  },
  "patterns_detected": ["repeated-file-reads"],
  "skills_generated": [],
  "improvement_recommendations": ["file-caching"]
}
```

### Weekly Digest

```bash
$ rg '"session_id"' ~/.claude/metrics.jsonl | tail -n 7 | \
  jq -s '{
    total_sessions: length,
    total_tokens: (map(.tokens_used) | add),
    avg_efficiency_score: (map(.efficiency_score) | add / length),
    skills_triggered: (map(.skills_triggered[]) | unique),
    skills_generated: (map(.skills_generated[]) | unique)
  }'
```

---

## Recursive Self-Improvement Protocol

### Safety Gates

1. **Human Approval** - All self-modifications require explicit user confirmation
2. **Rollback Mechanism** - Git-track all meta-skill changes
3. **Version Locking** - Test in dev before production
4. **Similarity Check** - Prevent duplicate meta-improvements

### Recursion Example

```text
Iteration 0: Manual creation of self-improvement-engine
    ↓
Iteration 1: Meta-skill detects "skill generation is verbose"
    ↓ (generates skill-generation-optimizer)
Iteration 2: Meta-skill detects "pattern detection is slow"
    ↓ (generates pattern-detection-accelerator)
Iteration 3: Meta-skill detects "meta-skill coordination is complex"
    ↓ (generates meta-skill-orchestrator)
Iteration 4: Meta-orchestrator consolidates into enhanced v2.0
    ↓
Iteration N: System approaches optimal efficiency
```

### Convergence Condition

When `/detect-inefficiency` returns zero patterns for 10 consecutive sessions.

---

## Implementation

The self-improvement engine is operational via `~/.claude/optim.sh`:

```bash
# Run pattern detection
~/.claude/optim.sh detect

# Generate skill from detected pattern
~/.claude/optim.sh generate <pattern-name>

# Run meta-optimization (recursion!)
~/.claude/optim.sh optimize

# Run full improvement cycle
~/.claude/optim.sh cycle
```

### Infrastructure

- `~/.claude/patterns.json` - Pattern definitions
- `~/.claude/templates/skills/SKILL.template.md` - Auto-generation template
- `~/.claude/metrics.jsonl` - Session tracking
- `~/.claude/history.jsonl` - Tool usage history
- `~/.claude/optim.sh` - 725 lines implementing 4-layer architecture

### Architecture Layers

- Layer 0: Utilities (logging, validation, JSON)
- Layer 1: Pattern Detection (scan, match, score)
- Layer 2: Skill Generation (template fill, validate)
- Layer 3: Meta-Optimization (detect_meta_patterns, optimize_self)
- Layer 4: Orchestration (command routing)

---

## Changelog

**v2.0** (2025-11-06) - Full recursive implementation
- Complete bash implementation (`optim.sh`)
- Pattern database with 10 efficiency violations
- Auto-generation template with all placeholders
- Metrics tracking infrastructure
- True recursion: `optimize_self()` generates meta-skills
- Tested: Detected 24 node_modules reads + 5 preambles

**v1.0** (2025-11-06) - Initial meta-skill design
- Pattern detection module with 5 core signatures
- Skill generation via template filling
- CLAUDE.md auto-update integration
- Efficiency audit integration
- Medium article pipeline
- Metrics tracking schema
