# Self-Improvement Engine - Slash Commands Reference

Quick reference for the meta-skill's automation commands.

## Available Commands

### `/auto-improve`

**Full recursive improvement cycle**

Runs complete workflow: detect → generate → audit → document → commit

```bash
/auto-improve
```text

### What it does:
1. Scans recent history for inefficiency patterns
2. Selects highest-priority pattern (critical > major > minor)
3. Auto-generates skill to prevent pattern
4. Updates CLAUDE.md Skills System section
5. Runs efficiency audit to verify improvement
6. Triggers Medium article generation (optional)
7. Offers to commit changes to git

**Output:** Skill created, CLAUDE.md updated, article drafted (if confirmed)

**Token Budget:** ~4000 tokens per full cycle

---

### `/detect-inefficiency`
**Scan for improvement opportunities**

Mines `history.jsonl` for recurring patterns matching inefficiency signatures.

```bash
/detect-inefficiency
```text

### What it does:
1. Scans last 500 history entries (~5 recent sessions)
2. Runs pattern matching against 10 signature types
3. Scores by severity: critical=10, major=5, minor=3
4. Ranks by impact (token waste)
5. Presents report with recommended skills

**Output:** Inefficiency Detection Report with ranked patterns + fix suggestions

**Token Budget:** ~500 tokens

### Example Output:
```text
# 🔍 Inefficiency Detection Report

## Critical Issues
- ❌ dependency-folder-read (3 occurrences) - saves 50k tokens
  Suggested skill: path-exclusion-enforcer

## Major Issues
- ⚠️ repeated-file-reads (5 occurrences) - saves 2k tokens
  Suggested skill: file-caching

Score: 55 points (Critical)
```text

---

### `/generate-skill <pattern-name>`
**Auto-create skill from detected pattern**

Generates complete SKILL.md file from template + history examples.

```bash
/generate-skill file-caching
/generate-skill path-exclusion-enforcer
/generate-skill direct-implementation-enforcer
```text

### What it does:
1. Validates pattern exists in `patterns.json`
2. Extracts real examples from `history.jsonl`
3. Fills `SKILL.template.md` with context:
   - Purpose from pattern description
   - Triggers from pattern regex
   - Examples from actual occurrences
   - Token budget estimated from severity
4. Saves to `~/.claude/skills/<skill-name>/SKILL.md`
5. Updates `CLAUDE.md` Skills System section
6. Offers next steps (review, test, document)

**Output:** Skill file created + CLAUDE.md updated

**Token Budget:** ~800 tokens

### Example Output:
```text
✅ Skill Generated Successfully

Skill Name: file-caching
Location: ~/.claude/skills/file-caching/SKILL.md
Token Budget: <2000 tokens per activation

Next steps:
1. Review skill: bat ~/.claude/skills/file-caching/SKILL.md
2. Test trigger conditions
3. Generate documentation: /write-medium-article file-caching
4. Commit: git add ~/.claude/skills/file-caching/
```text

---

### `/audit-efficiency`
**Score session against EFFICIENCY_CHECKLIST.md**

Analyzes current or past session for violations, calculates score.

```bash
/audit-efficiency                    # Current session
/audit-efficiency 2025-11-06T14:45   # Past session
```text

### What it does:
1. Loads `EFFICIENCY_CHECKLIST.md` violation rules
2. Scans tool calls for violations:
   - Repeated file reads (major: 10 pts)
   - Temp script creation (major: 10 pts)
   - Unnecessary preambles (minor: 3 pts each)
   - etc.
3. Calculates score: (major × 10) + (minor × 3)
4. Grades: Perfect (0) | Good (1-6) | Needs Improvement (7-15) | Critical (16+)
5. Generates report with specific fixes

**Output:** Efficiency Audit Report with violations + remediation

**Token Budget:** ~500 tokens

### Example Output:
```text
# 📊 Efficiency Audit Report

Session: Current (2025-11-06 14:45)
Score: 13 points (Needs Improvement ⚠️)

## Violations
❌ Read package.json 3 times (File Read Optimization)
   Fix: Use file-caching skill

⚠️ 1 unnecessary preamble (Concise Communication)
   Fix: Remove "I'll now proceed to..."

Token Impact: Wasted ~2,500 tokens (10.6%)
Potential savings: 21,000 instead of 23,500
```text

---

## Pattern Names (for `/generate-skill`)

From `patterns.json`:

| Pattern Name | Severity | Impact | Description |
|--------------|----------|--------|-------------|
| `path-exclusion-enforcer` | Critical | 50k tokens | Reading node_modules/, venv/, etc. |
| `file-caching` | Major | 2k tokens | Re-reading same file 3+ times |
| `direct-implementation-enforcer` | Major | 5k tokens | Creating temp scripts |
| `batch-operations` | Major | 3k tokens | Individual edits vs MultiEdit |
| `plan-evaluation-enforcer` | Major | 10k tokens | Executing unnecessary plan items |
| `command-aliasing` | Minor | 1k tokens | Repeated CLI command chains |
| `enhanced-memory` | Minor | 500 tokens | Context loss / asking about past work |
| `concise-communication` | Minor | 500 tokens | Unnecessary preambles |
| `fast-search-enforcer` | Minor | 1k tokens | Using grep/find instead of rg/fd |
| `auto-efficiency-auditor` | Minor | 5k tokens | Long sessions without audits |

---

## Workflow Examples

### Example 1: First-Time Auto-Improvement

```bash
# User: I notice I keep re-reading files
$ /detect-inefficiency

# Output: "repeated-file-reads pattern detected (5 occurrences), suggested skill: file-caching"

$ /generate-skill file-caching

# Output: "Skill created at ~/.claude/skills/file-caching/SKILL.md"

$ /audit-efficiency

# Output: "Score improved from 13 → 3 points (Good 👍)"
```text

---

### Example 2: Full Auto-Improvement Cycle

```bash
# User: Make yourself better
$ /auto-improve

# System:
# 1. Detecting inefficiencies... (found 3 critical issues)
# 2. Generating skill 'path-exclusion-enforcer'... (created)
# 3. Updating CLAUDE.md... (added to Skills System)
# 4. Auditing efficiency... (score improved 55 → 5 points)
# 5. Generate Medium article? (y/n)
y
# 6. Article drafted: ~/CodeTonight/medium_articles/2025-11-06_path-exclusion.md
# 7. Commit changes? (y/n)
y
# 8. Committed: "Add path-exclusion-enforcer skill (auto-generated)"

✅ Improvement cycle complete
Estimated savings: 50,000 tokens per session (68% reduction)
```text

---

### Example 3: Meta-Recursion

```bash
# After generating 10 skills...
$ /detect-inefficiency

# Output: "skill-generation-inefficiency detected (4 occurrences)"
# Suggested skill: skill-generation-optimizer

$ /generate-skill skill-generation-optimizer

# 🔁 Meta-recursion: self-improvement-engine improving itself
# Skill created: optimizes template caching, parallel pattern matching
# Next iteration will be 20% faster
```text

---

## Integration with Other Skills

### Works with `chat-history-search`
```bash
/remind-yourself similar patterns    # Find past inefficiencies
/detect-inefficiency                 # Uses history search under the hood
```text

### Works with `medium-article-writer`
```bash
/generate-skill file-caching
/write-medium-article file-caching   # Auto-triggered by /auto-improve
```text

### Works with `pr-automation`
```bash
/auto-improve                        # Generates skill
# Offers: Create PR for new skill? (y/n)
y
# Creates PR with skill + CLAUDE.md update
```text

---

## Metrics Tracking

Session metrics auto-saved to `~/.claude/metrics.jsonl`:

```bash
# View weekly summary
$ tail -n 7 ~/.claude/metrics.jsonl | jq -s '{
    total_sessions: length,
    avg_efficiency_score: (map(.efficiency_score) | add / length),
    skills_generated: (map(.skills_generated[]) | unique)
  }'
```text

### Output:
```json
{
  "total_sessions": 7,
  "avg_efficiency_score": 8.4,
  "skills_generated": ["file-caching", "direct-implementation-enforcer"]
}
```text

---

## Troubleshooting

### Issue: `/detect-inefficiency` finds no patterns

### Causes:
- Recent history too short (< 500 entries)
- No patterns exceed threshold
- Already operating at high efficiency

### Solution:
- Wait until more sessions accumulate
- Lower thresholds in `patterns.json` (advanced)
- Run `/audit-efficiency` to check current score

---

### Issue: `/generate-skill` creates incomplete skill

### Causes:
- Not enough examples in history for pattern
- Template placeholders couldn't be filled

### Solution:
- Review generated skill: `bat ~/.claude/skills/<skill-name>/SKILL.md`
- Manually fill remaining `{{PLACEHOLDERS}}`
- Report issue for pattern refinement

---

### Issue: `/auto-improve` gets stuck

### Causes:
- Waiting for user confirmation (article generation, commit)
- Pattern detection found 0 issues

### Solution:
- Check for prompts requiring input (y/n)
- If no issues found, system is already optimal
- Try `/detect-inefficiency` manually to see report

---

## Advanced Usage

### Custom Pattern Detection

Edit `~/.claude/skills/self-improvement-engine/patterns.json`:

```json
{
  "name": "custom-pattern",
  "regex": "your-regex-here",
  "threshold": 3,
  "severity": "major",
  "skill_suggestion": "your-skill-name"
}
```text

Then run:
```bash
/detect-inefficiency    # Will now detect custom pattern
```text

---

### Manual Skill Generation

1. Create directory: `mkdir ~/.claude/skills/my-skill`
2. Copy template: `cp ~/.claude/templates/skills/SKILL.template.md ~/.claude/skills/my-skill/SKILL.md`
3. Fill placeholders: Edit `{{SKILL_NAME}}`, `{{PURPOSE_STATEMENT}}`, etc.
4. Update CLAUDE.md: Add to Skills System section
5. Test: Use skill in real scenario

---

## Safety & Best Practices

### Human-in-the-Loop

All `/auto-improve` steps requiring destructive actions ask for confirmation:
- Article generation: `Generate Medium article? (y/n)`
- Git commit: `Commit new skill? (y/n)`
- Meta-recursion: `Improve self-improvement-engine? (y/n)`

### Validation Gates

1. **Pattern threshold** - Only generate skills for recurring issues (3+ occurrences)
2. **Duplicate check** - Don't create skills that already exist
3. **Manual review** - Always review auto-generated skills before activation
4. **Git tracking** - All changes versioned, can rollback if needed

### Recursion Limits

- Max 1 skill generation per `/auto-improve` invocation
- Meta-skill self-improvements require explicit user approval
- Convergence condition: 10 consecutive sessions with 0 detected patterns

---

## Changelog

**v1.0** (2025-11-06) - Initial command implementation
- Four slash commands: `/auto-improve`, `/detect-inefficiency`, `/generate-skill`, `/audit-efficiency`
- 10 inefficiency pattern signatures
- Template-based skill generation
- Metrics tracking to `metrics.jsonl`
- Human-in-the-loop safety gates

---

**Commands Status:** ✅ Active
**Maintainer:** LC Scheepers
**Last Updated:** 2025-11-06
**Skill:** `self-improvement-engine`
