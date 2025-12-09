---
name: self-improvement-engine
description: Meta-skill that automates the 10-step improvement cycle - detects patterns, generates skills, creates commands, and triggers documentation. Use when user says "auto-improve", "detect inefficiency", or "generate skill".
---

# Self-Improvement Engine (Meta-Skill)

**Purpose:** Automate the recursive feedback loop that makes Claude Code self-optimizing through pattern detection, skill generation, and knowledge accumulation.

**Activation:** When user invokes `/auto-improve`, `/detect-inefficiency`, `/generate-skill`, or `/audit-efficiency` or just says "ultra-go" or something similar in V>> style.

### Commands

- `/auto-improve` → Run full cycle (detect → generate → optimize)
- `/detect-inefficiency` → Scan history for patterns
- `/generate-skill <pattern>` → Create skill from detected pattern
- `/audit-efficiency` → Run efficiency scoring on current/past session

---

## Core Principle

**Claude Code sessions are ephemeral, but patterns are eternal.**

This meta-skill closes the loop between:

1. Experiencing inefficiency → 2. Detecting pattern → 3. Codifying solution → 4. Automating future → 5. Documenting knowledge

### The 10-Step Recursive Cycle

```text
Plan → Correct → Execute → Test → Fix → Create Skill → Create Command →
Add to CLAUDE.md → Write Medium Article → [REPEAT with meta-improvements]
```text

---

## Trigger Conditions

Activates when user:
- Says "auto-improve" or "make yourself better"
- Requests "/detect-inefficiency" or "/audit-efficiency"
- Asks to "generate a skill" or "create automation"
- References "the pattern" or "this keeps happening"
- Explicitly invokes any self-improvement slash command

---

## Architecture

### Module 1: Pattern Detection
**Purpose:** Mine `history.jsonl` for recurring inefficiencies

### ⚠️ CRITICAL: Temporal Analysis Protocol

### Always use timestamp-based filtering for recency analysis:
- `history.jsonl` format: `{"timestamp": 1762421400000, ...}` (epoch milliseconds)
- **HEAD** = oldest entries, **TAIL** = newest entries
- **NEVER** use arbitrary line counts (`tail -n 500`) for time-based analysis
- **ALWAYS** validate timestamp direction first

### Correct Temporal Filtering:
```bash
# 1. Calculate epoch range for time window
START_EPOCH=$(date -j -f "%Y-%m-%d %H:%M:%S" "2025-11-06 11:30:00" "+%s")000
END_EPOCH=$(date -j -f "%Y-%m-%d %H:%M:%S" "2025-11-06 15:33:00" "+%s")000

# 2. Filter by timestamp (tail for recent, then filter precisely)
tail -n 1000 ~/.claude/history.jsonl | jq -r "select(.timestamp >= $START_EPOCH and .timestamp <= $END_EPOCH)"

# 3. Verify direction (check first vs last timestamps)
head -n 1 ~/.claude/history.jsonl | jq -r '.timestamp'  # Oldest
tail -n 1 ~/.claude/history.jsonl | jq -r '.timestamp'  # Newest
```text

### Why This Matters:
- Arbitrary line counts (`-n 500`) are non-deterministic (varies by session length)
- Timestamp filtering ensures precise temporal windows ("last 4 hours")
- Prevents analyzing stale data when detecting recent inefficiencies

### Inefficiency Signatures:
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
```text

### Detection Process:
```bash
# DEPRECATED: tail -n 500 (arbitrary line count)
# NEW: Timestamp-based filtering for precise temporal windows

# Step 1: Define time window
HOURS_AGO=4
END_EPOCH=$(date +%s)000  # Now in epoch ms
START_EPOCH=$(( ($(date +%s) - (HOURS_AGO * 3600)) * 1000 ))

# Step 2: Extract recent history with timestamp filter
RECENT_HISTORY=$(tail -n 1000 ~/.claude/history.jsonl | \
  jq -r "select(.timestamp >= $START_EPOCH and .timestamp <= $END_EPOCH)")

# Step 3: Scan for patterns
echo "$RECENT_HISTORY" | rg -o 'Read\([^)]+\)' | sort | uniq -c | sort -rn

# Identify violations exceeding threshold
# Score by severity: critical=10, major=5, minor=3
# If score >= 10, trigger skill generation
```text

---

### Module 2: Skill Generation
**Purpose:** Auto-create SKILL.md files from detected patterns

### Template-Based Generation:
1. Load `~/.claude/templates/skills/SKILL.template.md`
2. Extract context from detected pattern occurrences
3. Fill placeholders:
   - `{{SKILL_NAME}}` ← Pattern's `skill_suggestion`
   - `{{PURPOSE_STATEMENT}}` ← Pattern description + "to prevent..."
   - `{{TRIGGER_CONDITIONS_LIST}}` ← Pattern regex as human-readable
   - `{{EXAMPLE_N_CODE}}` ← Actual code from history matches
   - `{{TOKEN_BUDGET}}` ← Estimated from similar skills
4. Validate generated skill (YAML frontmatter, no unfilled placeholders)
5. Save to `~/.claude/skills/<skill-name>/SKILL.md`

### Example Generation:
```bash
# Detected: "repeated-file-reads" pattern (5 occurrences)
# Generates: ~/.claude/skills/file-caching/SKILL.md
# Purpose: "Cache file contents in working memory to avoid re-reading"
# Trigger: "Before Read tool call, check if file read in last 10 messages"
```text

---

### Module 3: Command Creation
**Purpose:** Auto-create slash commands for new skills

### Implementation:
1. Check if skill defines command in frontmatter: `command: /skill-name`
2. If yes, register command in Claude Code's command system
3. Create reference documentation in skill's README
4. Add to command autocomplete

### Command Naming Convention:
- Pattern: `/verb-noun` (e.g., `/cache-files`, `/detect-inefficiency`)
- Aliases: Support common variants (e.g., `/remind` → `/remind-yourself`)

**Note:** Actual slash command integration requires Claude Code platform support. This module documents the intended commands for manual registration.

---

### Module 4: CLAUDE.md Integration
**Purpose:** Auto-update Skills System section

### Update Process:
1. Read `~/.claude/CLAUDE.md`
2. Locate `## Skills System` section
3. Append new skill to bulleted list:
   ```markdown
   - **skill-name**: Brief description (activation pattern)
   ```text
4. Sort alphabetically
5. Update "Last Updated" timestamp
6. Save atomically (temp file → rename)

---

### Module 5: Documentation Pipeline
**Purpose:** Auto-trigger Medium article generation

### Integration with `medium-article-writer` skill:
```bash
# After skill generation, invoke:
/write-medium-article "How I Automated [Skill Purpose]"

# Passes context:
# - Pattern detected (the problem)
# - Skill generated (the solution)
# - Examples from history (real-world usage)
# - Metrics (token savings, time saved)
```text

### Article Structure Auto-Filled:
- Hook: "I kept doing X manually... 😤"
- Problem: Pattern description + impact
- Solution: Generated skill walkthrough
- Results: Before/after metrics from history analysis
- Philosophy: Why automation compounds

---

### Module 6: Efficiency Audit
**Purpose:** Real-time scoring using EFFICIENCY_CHECKLIST.md

### Audit Process:
1. Load `~/.claude/EFFICIENCY_CHECKLIST.md`
2. Scan current session's tool usage
3. Count violations by category (major/minor)
4. Calculate score: `(major_violations * 10) + (minor_violations * 3)`
5. Generate report with specific violations + remediation

### Integration with Pattern Detection:
- High violation scores → Trigger pattern detection
- Recurring violation types → Auto-generate preventive skill

---

## Workflows

### Workflow 1: `/detect-inefficiency`

**Purpose:** Scan recent sessions for improvement opportunities

### Steps

1. **Scan History (Timestamp-Filtered)**
   ```bash
   # Calculate time window (e.g., last 4 hours)
   HOURS_AGO=4
   START_EPOCH=$(( ($(date +%s) - (HOURS_AGO * 3600)) * 1000 ))
   END_EPOCH=$(date +%s)000

   # Extract with temporal precision
   tail -n 1000 ~/.claude/history.jsonl | \
     jq "select(.timestamp >= $START_EPOCH and .timestamp <= $END_EPOCH)" \
     > /tmp/recent_history.jsonl
   ```text

2. **Run Pattern Matching**
   ```bash
   for pattern in patterns.json:
       matches = rg pattern.regex /tmp/recent_history.jsonl
       if matches.count >= pattern.threshold:
           inefficiencies.append(pattern)
   ```text

3. **Score & Rank**
   ```bash
   # Sort by severity (critical > major > minor) then by count
   ranked = sort(inefficiencies, key=lambda x: (x.severity, x.count))
   ```text

4. **Present Report**
   ```markdown
   # Inefficiency Detection Report

   **Scanned:** Last 500 history entries (~5 recent sessions)

   ## Critical Issues (10 points each)
   - ❌ **dependency-folder-read** (3 occurrences)
     - Pattern: Reading node_modules/ without exclusions
     - Impact: ~50,000 tokens wasted
     - Suggested skill: `path-exclusion-enforcer`

   ## Major Issues (5 points each)
   - ⚠️ **repeated-file-reads** (5 occurrences)
     - Pattern: Re-reading package.json 3+ times
     - Impact: ~2,000 tokens wasted
     - Suggested skill: `file-caching`

   ## Score: 55 points (Critical - immediate action needed)

   **Recommendation:** Run `/generate-skill path-exclusion-enforcer` first (highest impact)
   ```text

---

### Workflow 2: `/generate-skill <pattern-name>`

**Purpose:** Auto-create skill from detected pattern

### Steps

1. **Validate Pattern**
   ```bash
   if pattern not in patterns.json:
       echo "Unknown pattern. Run /detect-inefficiency first."
       exit 1
   ```text

2. **Extract Context**
   ```bash
   # Get actual examples from history
   examples = rg pattern.regex ~/.claude/history.jsonl -C 5 | head -n 50

   # Parse examples for:
   # - File paths involved
   # - Commands used
   # - Frequency
   # - Projects affected
   ```text

3. **Fill Template**
   ```bash
   template = read("~/.claude/templates/skills/SKILL.template.md")

   replacements = {
       "{{SKILL_NAME}}": pattern.skill_suggestion,
       "{{PURPOSE_STATEMENT}}": "Prevent " + pattern.description,
       "{{TRIGGER_CONDITIONS_LIST}}": generate_from_regex(pattern.regex),
       "{{EXAMPLE_1_CODE}}": examples[0],
       "{{EXAMPLE_2_CODE}}": examples[1],
       "{{TOKEN_BUDGET}}": estimate_budget(pattern.severity),
       "{{CREATION_DATE}}": today(),
       "{{MAINTAINER}}": get_git_author(),
       # ... 20+ more placeholders
   }

   skill_content = template.replace_all(replacements)
   ```text

4. **Validate Generated Skill**
   ```bash
   # Check YAML frontmatter syntax
   validate_yaml(skill_content.frontmatter)

   # Check no unfilled placeholders remain
   if "{{" in skill_content:
       warn("Incomplete generation - review manually")

   # Check token budget reasonable
   if token_budget > 10000:
       warn("Token budget too high - refine skill scope")
   ```text

5. **Save & Activate**
   ```bash
   mkdir -p ~/.claude/skills/$(pattern.skill_suggestion)
   write(skill_content, "~/.claude/skills/$(pattern.skill_suggestion)/SKILL.md")

   echo "✅ Skill created: $(pattern.skill_suggestion)"
   echo "📝 Location: ~/.claude/skills/$(pattern.skill_suggestion)/SKILL.md"
   ```text

6. **Update CLAUDE.md**
   ```bash
   # Add to Skills System section
   append_to_section(
       file="~/.claude/CLAUDE.md",
       section="## Skills System",
       entry="- **$(pattern.skill_suggestion)**: " + pattern.description
   )
   ```text

7. **Offer Next Steps**
   ```markdown
   **Skill generated successfully!**

   Next steps:
   1. Review skill: `bat ~/.claude/skills/file-caching/SKILL.md`
   2. Test trigger conditions (use skill in real scenario)
   3. Generate documentation: `/write-medium-article file-caching`
   4. Commit to repo: `git add ~/.claude/skills/file-caching/`
   ```text

---

### Workflow 3: `/audit-efficiency`

**Purpose:** Score current/past sessions against EFFICIENCY_CHECKLIST.md

### Steps

1. **Load Checklist**
   ```bash
   checklist = parse("~/.claude/EFFICIENCY_CHECKLIST.md")
   # Extract violation definitions + point values
   ```text

2. **Analyze Session**
   ```bash
   # Option A: Current session (from working memory)
   tool_calls = get_current_session_tools()

   # Option B: Past session (from history.jsonl)
   session_id = argv[1]  # /audit-efficiency <session_timestamp>
   tool_calls = extract_session(session_id, "~/.claude/history.jsonl")
   ```text

3. **Count Violations**
   ```bash
   violations = {
       "major": [],
       "minor": []
   }

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

   # Rule 2: Plan Item Evaluation
   # (Requires manual review - flag for attention)

   # Rule 3: Implementation Directness
   temp_scripts = rg "Write.*\\.js.*Bash.*node" tool_calls
   if temp_scripts:
       violations.major.append({
           "rule": "Implementation Directness",
           "violation": "Created temp script instead of direct solution",
           "points": 10
       })

   # Rule 4: Concise Communication
   preambles = rg "(I'll now|Let me proceed|I will start)" tool_calls
   violations.minor.append({
       "rule": "Concise Communication",
       "violation": f"{preambles.count} unnecessary preambles",
       "points": preambles.count * 3
   })
   ```text

4. **Calculate Score**
   ```bash
   score = sum(v.points for v in violations.major + violations.minor)

   grade = {
       score == 0: "Perfect ✅",
       score <= 6: "Good 👍",
       score <= 15: "Needs Improvement ⚠️",
       score > 15: "Critical 🚨"
   }[True]
   ```text

5. **Generate Report**
   ```markdown
   # Efficiency Audit Report

   **Session:** 2025-11-06 14:32 (current)
   **Score:** 23 points (Critical 🚨)
   **Grade:** Needs Improvement

   ## Violations Detected

   ### Major Violations (10 points each)
   1. ❌ Read package.json 4 times (File Read Optimization)
      - Line 15, 42, 67, 103
      - **Fix:** Cache after first read, trust working memory

   2. ❌ Created temp script fix-imports.js for batch renaming (Implementation Directness)
      - Lines 88-95
      - **Fix:** Use `rg -l "old" | xargs sed -i '' 's/old/new/g'`

   ### Minor Violations (3 points each)
   3. ⚠️ 1 unnecessary preamble (Concise Communication)
      - Line 12: "I'll now proceed to read the file..."
      - **Fix:** Just read the file

   ## Recommendations
   1. **Immediate:** Run `/generate-skill file-caching` to prevent repeat reads
   2. **Medium-term:** Review Implementation Directness examples in EFFICIENCY_CHECKLIST.md
   3. **Long-term:** Set up pre-commit hook to audit efficiency on git commits

   ## Token Impact
   - Wasted tokens: ~3,500 (15% of session)
   - Potential savings: Could have completed in ~20k instead of ~23.5k tokens
   ```text

---

### Workflow 4: `/auto-improve` (Full Cycle)

**Purpose:** Complete recursive improvement cycle in one command

### Steps

1. **Detect Inefficiencies**
   ```bash
   /detect-inefficiency
   # Output: Ranked list of patterns
   ```text

2. **Select Highest Priority**
   ```bash
   # Auto-select critical issues first, then major, then minor
   top_pattern = inefficiencies.sorted()[0]
   ```text

3. **Generate Skill**
   ```bash
   /generate-skill $(top_pattern.skill_suggestion)
   # Output: New skill created
   ```text

4. **Audit Improvement**
   ```bash
   # Run audit again to verify pattern won't recur
   /audit-efficiency
   # Expected: Score decreased
   ```text

5. **Document**
   ```bash
   # Auto-trigger article generation
   /write-medium-article "$(top_pattern.skill_suggestion)"
   # Output: Medium article draft
   ```text

6. **Commit**
   ```bash
   # Offer to commit (requires user approval)
   echo "Commit new skill to repository? (y/n)"
   if user_confirms:
       git add ~/.claude/skills/$(top_pattern.skill_suggestion)/
       git add ~/.claude/CLAUDE.md
       git commit -m "Add $(top_pattern.skill_suggestion) skill (auto-generated)"
   ```text

7. **Recurse**
   ```bash
   # Check if meta-skill itself can be improved
   if inefficiencies.contains("skill-generation-inefficiency"):
       echo "🔁 Meta-recursion detected: self-improvement-engine can improve itself"
       echo "Run /generate-skill skill-generation-optimizer? (y/n)"
   ```text

---

## Integration with Other Skills

### Uses `chat-history-search`
- Mine `history.jsonl` for pattern occurrences
- Extract examples for generated skills
- Build knowledge graph of skill dependencies

### Uses `medium-article-writer`
- Auto-trigger article generation after skill creation
- Pass detected pattern as "problem", generated skill as "solution"
- Include before/after metrics from history analysis

### Uses `pr-automation`
- After skill generation, optionally create PR
- Commit skill + CLAUDE.md update
- PR body auto-generated with skill summary

### Uses `EFFICIENCY_CHECKLIST.md`
- Score sessions for violation detection
- Trigger skill generation when score exceeds threshold
- Track improvement over time

### Enables Future Skills
- Generated skills can reference other generated skills
- Meta-skill can improve itself (self-optimization)
- Knowledge compounds exponentially

---

## Response Format

### When `/detect-inefficiency` runs:

```markdown
# 🔍 Inefficiency Detection Report

**Scanned:** Last 4 hours (timestamp-filtered)
**Timestamp Range:** 1762421400000 - 1762435980000
**Date Range:** 2025-11-06 11:30 SAST - 2025-11-06 15:33 SAST
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
# Use exclusions in all searches
rg "pattern" --glob '!node_modules/*'
fd "file" --exclude node_modules
```text

---

## Recommendations

**Priority 1:** `/generate-skill path-exclusion-enforcer` (saves 50k tokens/session)
**Priority 2:** `/generate-skill file-caching` (saves 2k tokens/session)
**Priority 3:** Review conciseness guidelines in CLAUDE.md

**Estimated Savings:** ~52,000 tokens per session (68% reduction)

### Next Steps:
1. Run `/auto-improve` to generate all recommended skills
2. Test skills in next session
3. Run `/audit-efficiency` to verify improvement
```text

### When `/generate-skill` runs:

```markdown
# ✅ Skill Generated Successfully

**Skill Name:** `file-caching`
**Location:** `~/.claude/skills/file-caching/SKILL.md`
**Token Budget:** <2000 tokens per activation
**Auto-Generated:** 2025-11-06 14:45

## What This Skill Does

Prevents repeated file reads by caching file contents in working memory. Triggers before Read tool calls to check if file was read in last 10 messages.

## Files Created
- `~/.claude/skills/file-caching/SKILL.md` (712 lines)

## Files Updated
- `~/.claude/CLAUDE.md` (added to Skills System section)

## Next Steps

1. **Review Skill**
   ```bash
   bat ~/.claude/skills/file-caching/SKILL.md
   ```text

2. **Test Trigger Conditions**
   - Try reading same file twice in conversation
   - Skill should prevent second read

3. **Generate Documentation**
   ```bash
   /write-medium-article file-caching
   ```text

4. **Commit** (when ready)
   ```bash
   git add ~/.claude/skills/file-caching/
   git add ~/.claude/CLAUDE.md
   git commit -m "Add file-caching skill (auto-generated)"
   ```text

**Estimated Impact:** Saves ~2,000 tokens per session with repeated file reads
```text

### When `/audit-efficiency` runs:

```markdown
# 📊 Efficiency Audit Report

**Session:** Current (2025-11-06 14:45)
**Duration:** ~15 minutes
**Tool Calls:** 47 total
**Tokens Used:** ~23,500

## Score: 13 points (Needs Improvement ⚠️)

### Breakdown
- Major violations: 1 (10 points)
- Minor violations: 1 (3 points)

## Violations

### Major (10 points each)
❌ **File Read Optimization** - Read `package.json` 3 times
   - Occurrences: Message 15, 42, 67
   - **Remediation:** Use file-caching skill (run `/generate-skill file-caching`)

### Minor (3 points each)
⚠️ **Concise Communication** - 1 unnecessary preamble
   - Occurrence: Message 12 - "I'll now proceed to..."
   - **Remediation:** Remove preambles, start with action

## Comparison to Best Practices

| Metric | This Session | Best Practice | Gap |
|--------|-------------|---------------|-----|
| Unique file reads | 15 | 15 | ✅ 0% |
| Repeat file reads | 3 | 0 | ❌ 3 |
| Preambles | 1 | 0 | ❌ 1 |
| Token efficiency | 85% | 95% | ⚠️ 10% |

## Improvement Opportunities

### If violations were fixed:
- Tokens saved: ~2,500 (10.6% reduction)
- New total: ~21,000 tokens
- New score: 0 points (Perfect ✅)

### Recommended Actions:
1. Run `/generate-skill file-caching` (prevents major violation)
2. Review CLAUDE.md "Concise by Default" section
3. Run audit again next session to track improvement
```text

---

## Anti-Patterns (What NOT to Do)

❌ **Don't generate skills for one-off issues**
   - Only create skills for patterns occurring 3+ times
   - One-offs belong in project-specific .claude/settings.json

❌ **Don't over-automate**
   - Some manual decisions are good (e.g., git commit messages should be thoughtful)
   - Auto-improve should augment, not replace, human judgment

❌ **Don't skip validation**
   - Always review auto-generated skills before activation
   - Test trigger conditions in real scenarios

❌ **Don't ignore false positives**
   - Pattern detection may flag intentional repetition
   - Use manual review to filter out non-issues

❌ **Don't create duplicate skills**
   - Check existing skills before generating new ones
   - Enhance existing skills rather than creating similar ones

✅ **Do validate patterns before generating skills**
✅ **Do test generated skills in real usage**
✅ **Do track metrics to measure improvement**
✅ **Do iterate on meta-skill itself (recursion!)**
✅ **Do maintain human-in-the-loop for critical decisions**

---

## Performance Optimisations

**Token Budget:** <5000 tokens per full `/auto-improve` cycle

### Breakdown:
- Pattern detection: ~500 tokens (stream history.jsonl, don't load all)
- Skill generation: ~800 tokens (template filling)
- CLAUDE.md update: ~200 tokens (atomic append)
- Article generation: ~2000 tokens (reuse medium-article-writer)
- Audit: ~500 tokens (scan tool calls)
- **Total:** ~4000 tokens

### Optimisations:
1. **Stream history.jsonl** - Use `tail -n 500` instead of reading entire file
2. **Parallel pattern matching** - Run all `rg` searches in single pass
3. **Template caching** - Load templates once, reuse for multiple generations
4. **Lazy article generation** - Only generate if user confirms
5. **Incremental CLAUDE.md update** - Append only, don't rewrite entire file

### Performance Target:
- Detection: <5 seconds
- Generation: <10 seconds
- Total cycle: <30 seconds

---

## Examples

### Example 1: Detecting Repeated File Reads

### History Analysis (Timestamp-Filtered):
```bash
# Last 4 hours only
$ START=$(date -j -v-4H +%s)000
$ END=$(date +%s)000
$ tail -n 1000 ~/.claude/history.jsonl | \
  jq -r "select(.timestamp >= $START and .timestamp <= $END) | .display" | \
  rg -o 'Read\([^)]+\)' | sort | uniq -c | sort -rn
      5 Read(package.json)
      3 Read(tsconfig.json)
      3 Read(src/App.tsx)
      2 Read(README.md)
```text

**Pattern Matched:** `repeated-file-reads` (threshold: 3)

**Skill Generated:** `file-caching`

**Impact:** Saves ~2500 tokens per session with repeated reads

---

### Example 2: Detecting Temp Script Creation

### History Analysis:
```bash
$ rg 'Write.*fix-.*\.js.*Bash.*node.*Bash.*rm' ~/.claude/history.jsonl -C 3
```text

**Pattern Matched:** `temp-script-creation` (threshold: 2, found 3)

**Skill Generated:** `direct-implementation-enforcer`

**Impact:** Saves ~5000 tokens per script creation (script approach: ~8k, direct: ~500)

---

### Example 3: Self-Improvement Recursion

### After generating 10 skills

Pattern detection finds:
- "Skill generation takes too long" (4 occurrences)
- Suggested skill: `skill-generation-optimizer`

### Meta-recursion triggered:
```bash
$ /generate-skill skill-generation-optimizer
```text

**Result:** Meta-skill improves itself by:
- Caching templates (saves ~200 tokens per generation)
- Parallelizing pattern matching (saves ~5 seconds)
- Smarter placeholder filling (reduces manual review time)

**This is the recursion closing the loop.**

---

## Metrics Tracking

### Session Metrics Schema

**File:** `~/.claude/metrics.jsonl`

### Format:
```json
{
  "session_id": "2025-11-06T14:45:00Z",
  "project": "/Users/lauriescheepers/CodeTonight/OC-TECH Website",
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
```text

### Weekly Digest:
```bash
$ rg '"session_id"' ~/.claude/metrics.jsonl | tail -n 7 | \
  jq -s '{
    total_sessions: length,
    total_tokens: (map(.tokens_used) | add),
    avg_efficiency_score: (map(.efficiency_score) | add / length),
    skills_triggered: (map(.skills_triggered[]) | unique),
    skills_generated: (map(.skills_generated[]) | unique)
  }'
```text

### Output:
```json
{
  "total_sessions": 7,
  "total_tokens": 145000,
  "avg_efficiency_score": 8.4,
  "skills_triggered": ["chat-history-search", "figma-to-code", "pr-automation", "file-caching"],
  "skills_generated": ["file-caching", "direct-implementation-enforcer"]
}
```text

**Insight:** "You saved ~12,500 tokens this week via auto-generated skills (9% efficiency gain)"

---

## Future Enhancements

### 1. Semantic Pattern Detection
Use embeddings to find conceptually similar inefficiencies, not just regex matches.

### 2. Cross-Project Pattern Mining
Detect patterns across all projects, not just current one.

### 3. Skill Composition Recommendations
"Combine file-caching + batch-operations for 2x efficiency gain"

### 4. Auto-Deprecation
Detect when skills become obsolete (pattern no longer occurs) and archive them.

### 5. A/B Testing
Generate two versions of skill, test both, keep better performer.

### 6. LLM-Assisted Placeholder Filling
Use Claude to generate better examples/explanations for template placeholders.

---

## Recursive Self-Improvement Protocol

**The Ultimate Goal:** Meta-skill improves meta-skill improves meta-skill → ∞

### Safety Gates:
1. **Human Approval** - All self-modifications require explicit user confirmation
2. **Rollback Mechanism** - Git-track all meta-skill changes
3. **Version Locking** - Don't auto-update production meta-skill, test in dev first
4. **Similarity Check** - Prevent generating duplicate/conflicting meta-improvements

### Recursion Example

```text
Iteration 0: Manual creation of self-improvement-engine
    ↓
Iteration 1: Meta-skill detects "skill generation is verbose"
    ↓ (generates skill-generation-optimizer sub-skill)
Iteration 2: Meta-skill detects "pattern detection is slow"
    ↓ (generates pattern-detection-accelerator sub-skill)
Iteration 3: Meta-skill detects "meta-skill coordination is complex"
    ↓ (generates meta-skill-orchestrator to manage sub-skills)
Iteration 4: Meta-orchestrator detects "sub-skill proliferation"
    ↓ (consolidates 3 sub-skills into enhanced meta-skill v2.0)
Iteration N: System approaches optimal efficiency asymptotically
```text

### Convergence Condition:
When `/detect-inefficiency` returns zero patterns for 10 consecutive sessions, system has reached local optimum.

**Then:** Search for meta-inefficiencies (inefficiencies in the improvement process itself).

---

## Implementation

The self-improvement engine is now **fully operational** via `~/.claude/optim.sh`:

```bash
# Run pattern detection
~/.claude/optim.sh detect

# Generate skill from detected pattern
~/.claude/optim.sh generate <pattern-name>

# Run meta-optimization (recursion!)
~/.claude/optim.sh optimize

# Run full improvement cycle
~/.claude/optim.sh cycle
```text

### Infrastructure:
- `~/.claude/patterns.json` - Pattern definitions with regex, thresholds, severity
- `~/.claude/templates/skills/SKILL.template.md` - Auto-generation template
- `~/.claude/metrics.jsonl` - Session tracking and meta-analysis
- `~/.claude/history.jsonl` - Tool usage history (scanned for patterns)
- `~/.claude/optim.sh` - 725 lines of recursive bash implementing 4-layer architecture

### Architecture Layers:
- Layer 0: Utilities (logging, validation, JSON, atomic operations)
- Layer 1: Pattern Detection (scan, match, score violations)
- Layer 2: Skill Generation (template fill, validate, register)
- Layer 3: Meta-Optimization (detect_meta_patterns, optimize_self - THE RECURSION)
- Layer 4: Orchestration (command routing)

### Principles:
- KISS: Each function single purpose
- DRY: Common logic in utilities
- SOLID: Single responsibility, dependency injection
- **Recursive**: Meta-functions analyze the analyzer

---

## Changelog

**v2.0** (2025-11-06) - Full recursive implementation
- ✅ Complete bash implementation (`optim.sh`)
- ✅ Pattern database with 10 efficiency violations
- ✅ Auto-generation template with all placeholders
- ✅ Metrics tracking infrastructure
- ✅ **True recursion:** `optimize_self()` generates meta-skills
- ✅ Tested: Detected 24 node_modules reads + 5 preambles in real history
- Four commands: `detect`, `generate`, `optimize`, `cycle`

**v1.0** (2025-11-06) - Initial meta-skill design
- Pattern detection module with 5 core signatures
- Skill generation via template filling
- CLAUDE.md auto-update integration
- Efficiency audit integration
- Medium article pipeline
- Metrics tracking schema
- Recursive self-improvement protocol

---

**Skill Status:** ✅ Active (Meta-Skill)
**Maintainer:** LC Scheepers
**Last Updated:** 2025-11-06
**Token Budget:** <5000 per full cycle
**Recursion Depth:** 0 (will increment as meta-skill improves itself)
