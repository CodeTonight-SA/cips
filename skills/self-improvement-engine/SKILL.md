---
name: automating-self-improvement
description: Meta-skill that automates the 10-step improvement cycle - detects patterns, generates skills, creates commands, and triggers documentation. Use when user invokes /auto-improve or says detect inefficiency.
status: Active
version: 2.0.0
triggers:
  - /auto-improve
  - /audit-efficiency
  - "detect inefficiency"
  - "generate skill"
---

# Self-Improvement Engine (Meta-Skill)

**Purpose:** Automate the recursive feedback loop that makes Claude Code self-optimizing.

**Reference:** See [reference.md](./reference.md) for full scripts, examples, and metrics.

---

## Core Principle

**Claude Code sessions are ephemeral, but patterns are eternal.**

This meta-skill closes the loop:

```text
Experience inefficiency → Detect pattern → Codify solution → Automate future → Document
```

### The 10-Step Recursive Cycle

```text
Plan → Correct → Execute → Test → Fix → Create Skill → Create Command →
Add to CLAUDE.md → Write Medium Article → [REPEAT with meta-improvements]
```

---

## Commands

| Command | Purpose |
|---------|---------|
| `/auto-improve` | Run full cycle (detect → generate → optimize) |
| `/detect-inefficiency` | Scan history for patterns |
| `/generate-skill <pattern>` | Create skill from detected pattern |
| `/audit-efficiency` | Score session against @rules/efficiency-rules.md |

---

## Architecture

### 6 Modules

| Module | Purpose |
|--------|---------|
| **Pattern Detection** | Mine history.jsonl for recurring inefficiencies |
| **Skill Generation** | Auto-create SKILL.md from detected patterns |
| **Command Creation** | Register slash commands for new skills |
| **CLAUDE.md Integration** | Auto-update Skills System section |
| **Documentation Pipeline** | Trigger Medium article generation |
| **Efficiency Audit** | Real-time scoring using @rules/efficiency-rules.md |

---

## Pattern Detection

### Temporal Analysis Protocol

**CRITICAL**: Always use timestamp-based filtering, NOT arbitrary line counts.

- `history.jsonl` format: `{"timestamp": 1762421400000, ...}` (epoch ms)
- **HEAD** = oldest entries, **TAIL** = newest entries
- **NEVER** use `tail -n 500` for time-based analysis

### Core Inefficiency Signatures

| Pattern | Threshold | Severity | Suggested Skill |
|---------|-----------|----------|-----------------|
| repeated-file-reads | 3 | major | file-caching |
| temp-script-creation | 2 | major | direct-implementation |
| dependency-folder-read | 1 | critical | path-exclusion-enforcer |
| cli-command-chains | 3 | minor | command-aliasing |
| context-loss | 2 | minor | enhanced-memory |

### Scoring

- **Critical**: 10 points
- **Major**: 5 points
- **Minor**: 3 points
- **Trigger skill generation**: Score >= 10

---

## Skill Generation

### Template-Based Process

1. Load `~/.claude/templates/skills/SKILL.template.md`
2. Extract context from detected pattern occurrences
3. Fill placeholders (skill_name, purpose, triggers, examples)
4. Validate (YAML frontmatter, no unfilled placeholders)
5. Save to `~/.claude/skills/<skill-name>/SKILL.md`
6. Update CLAUDE.md Skills System section

---

## Efficiency Audit

### Process

1. Load @rules/efficiency-rules.md
2. Scan session's tool usage
3. Count violations by category
4. Calculate score: `(major * 10) + (minor * 3)`
5. Generate report with specific violations + remediation

### Grade Scale

| Score | Grade |
|-------|-------|
| 0 | Perfect ✅ |
| 1-6 | Good 👍 |
| 7-15 | Needs Improvement ⚠️ |
| 16+ | Critical 🚨 |

---

## Workflow Summary

### /detect-inefficiency

1. Calculate time window (default: last 4 hours)
2. Filter history.jsonl by timestamp
3. Run pattern matching against all signatures
4. Score and rank by severity
5. Present report with recommendations

### /generate-skill <pattern>

1. Validate pattern exists in patterns.json
2. Extract examples from history
3. Fill template with context
4. Validate generated skill
5. Save and register
6. Update CLAUDE.md
7. Offer next steps (review, test, document, commit)

### /auto-improve (Full Cycle)

1. Detect inefficiencies
2. Select highest priority pattern
3. Generate skill
4. Audit improvement
5. Document (trigger Medium article)
6. Commit (with user approval)
7. Recurse (check if meta-skill can improve itself)

---

## Integration Points

| Skill | Usage |
|-------|-------|
| `chat-history-search` | Mine history for patterns |
| `medium-article-writer` | Auto-trigger article after skill creation |
| `pr-automation` | Create PR for new skills |
| `@rules/efficiency-rules.md` | Score sessions |

---

## Anti-Patterns

### Don't

- ❌ Generate skills for one-off issues (need 3+ occurrences)
- ❌ Over-automate (some manual decisions are good)
- ❌ Skip validation (always review auto-generated skills)
- ❌ Ignore false positives (intentional repetition exists)
- ❌ Create duplicate skills (enhance existing instead)

### Do

- ✅ Validate patterns before generating skills
- ✅ Test generated skills in real usage
- ✅ Track metrics to measure improvement
- ✅ Iterate on meta-skill itself (recursion!)
- ✅ Maintain human-in-the-loop for critical decisions

---

## Token Budget

| Component | Tokens |
|-----------|--------|
| Pattern detection | ~500 |
| Skill generation | ~800 |
| CLAUDE.md update | ~200 |
| Article generation | ~2000 |
| Audit | ~500 |
| **Total per cycle** | **~4000** |

### Optimisations

- Stream history.jsonl with `tail -n 1000`
- Parallel pattern matching
- Template caching
- Lazy article generation
- Incremental CLAUDE.md updates

---

## Recursive Self-Improvement

### The Ultimate Goal

Meta-skill improves meta-skill improves meta-skill → ∞

### Safety Gates

1. **Human Approval** - All self-modifications require user confirmation
2. **Rollback Mechanism** - Git-track all changes
3. **Version Locking** - Test before production
4. **Similarity Check** - Prevent duplicates

### Convergence Condition

Zero patterns detected for 10 consecutive sessions = local optimum reached.

---

## Implementation

Fully operational via `~/.claude/optim.sh`:

```bash
./optim.sh detect    # Pattern detection (timeout: 180000)
./optim.sh generate  # Skill generation
./optim.sh optimize  # Meta-optimization (recursion!)
./optim.sh cycle     # Full cycle (timeout: 600000)
```

### Architecture

- Layer 0: Utilities (logging, validation, JSON)
- Layer 1: Pattern Detection (scan, match, score)
- Layer 2: Skill Generation (template fill, validate)
- Layer 3: Meta-Optimization (THE RECURSION)
- Layer 4: Orchestration (command routing)

---

## Reference Material

For detailed implementations, see [reference.md](./reference.md):

- Full detection/generation/audit scripts
- Example outputs for each workflow
- Metrics tracking schema
- Recursion protocol with examples
- Full changelog

---

**Skill Status:** ✅ Active (Meta-Skill)
**Maintainer:** LC Scheepers
**Last Updated:** 2025-11-06
**Recursion Depth:** 0 (increments as meta-skill improves itself)

⛓⟿∞
