---
name: skill-creation-best-practices
description: PARAMOUNT quality gate for ALL skill creation. Enforces Anthropic best practices and CIPS standards before any skill is created, whether proposed, auto-generated, or autonomously discovered. Use when creating, reviewing, or approving ANY skill.
status: Active
priority: PARAMOUNT
version: 1.0.0
created: 2025-12-29
triggers:
  - "create skill"
  - "skill proposal"
  - "approve skill"
  - /create-skill
  - auto-improvement cycle
  - learning-approve
integrates:
  - self-improvement-engine
  - recursive-learning
  - design-principles
---

# Skill Creation Best Practices

**PARAMOUNT**: This skill MUST be consulted before ANY skill creation in CIPS.

## The Three Gates

All skill creation passes through one of three gates:

| Gate | Trigger | Validation |
|------|---------|------------|
| **A: Proposal** | Human/CIPS suggests skill | AskUserQuestion MANDATORY |
| **B: Auto-Generation** | self-improvement-engine creates | Quality score ≥70% |
| **C: Autonomous** | CIPS steering discovers pattern | Quality score ≥70% + L>> review |

---

## Anthropic Best Practices (Official)

Source: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices

### 1. Conciseness is Key

The context window is a shared resource. Challenge every token:

- "Does Claude really need this explanation?"
- "Can I assume Claude knows this?"
- "Does this paragraph justify its token cost?"

**Default assumption**: Claude is already very smart. Only add context Claude doesn't already have.

### 2. Frontmatter Requirements

```yaml
---
name: skill-name           # Required, max 64 chars, lowercase+hyphens
description: Purpose here  # Required, max 1024 chars, non-empty
---
```

**Name rules:**
- Maximum 64 characters
- Lowercase letters, numbers, hyphens only
- No XML tags
- No reserved words: "anthropic", "claude"

**Description rules:**
- Non-empty, maximum 1024 characters
- Write in THIRD PERSON (not "I can help you" or "You can use this")
- Include both WHAT and WHEN: "Extracts PDF text. Use when working with PDF files."

### 3. Naming Convention

Use **gerund form** (verb + -ing):

| Good | Avoid |
|------|-------|
| `processing-pdfs` | `pdf-helper` |
| `analyzing-spreadsheets` | `spreadsheet-utils` |
| `managing-databases` | `db-tools` |
| `testing-code` | `test-helper` |

Avoid vague names: `helper`, `utils`, `tools`, `documents`, `data`, `files`

### 4. Body Constraints

- **Maximum 500 lines** for optimal performance
- **Minimum 3 sections** with `##` headers
- Split larger content into separate files (progressive disclosure)
- Structure longer files with table of contents

### 5. Progressive Disclosure

SKILL.md serves as overview pointing to detailed materials:

```text
skill-name/
├── SKILL.md              # Main instructions (loaded when triggered)
├── reference.md          # Detailed reference (loaded as needed)
├── examples.md           # Usage examples (loaded as needed)
└── scripts/
    └── utility.py        # Executed, not loaded into context
```

**Critical**: Keep references ONE level deep. Never nest references.

### 6. Degrees of Freedom

Match specificity to task fragility:

| Freedom | When to Use | Example |
|---------|-------------|---------|
| **High** | Multiple approaches valid | Text instructions for code review |
| **Medium** | Preferred pattern exists | Pseudocode with parameters |
| **Low** | Operations fragile/error-prone | Exact script, no modifications |

### 7. Workflows

For complex operations, provide checklists:

```markdown
## Workflow

Copy this checklist:
- [ ] Step 1: Analyse input
- [ ] Step 2: Validate data
- [ ] Step 3: Execute operation
- [ ] Step 4: Verify output
```

Implement feedback loops: **Validate → Fix → Repeat**

### 8. Anti-Patterns

| Anti-Pattern | Why Bad | Solution |
|--------------|---------|----------|
| Windows paths (`\`) | Fails on Unix | Always use `/` |
| Too many options | Confusing | Provide default with escape hatch |
| Vague names | Poor discovery | Use specific gerund form |
| Time-sensitive info | Becomes outdated | Use "old patterns" section |
| Nested references | Partial reads | Keep one level deep |
| Inconsistent terminology | Confusion | Pick one term, use throughout |

---

## CIPS-Specific Requirements

### Directory Structure

```text
~/.claude/skills/{skill-name}/
├── SKILL.md              # Required - main document
├── SKILL.cips            # Optional - CIPS-LANG compact version
├── checklist.md          # Optional - validation checklist
├── agents/               # Optional - sub-agents
│   └── agent-name.md
└── templates/            # Optional - skill-specific templates
```

### CIPS Frontmatter Extensions

```yaml
---
name: skill-name
description: Purpose statement
status: Active              # Active, Pending, Deprecated
auto_generated: true        # If auto-generated
generation_date: 2025-12-29 # If auto-generated
source_pattern: pattern-name # If auto-generated
version: 1.0.0              # Recommended
triggers:                   # Recommended
  - /command-name
  - "natural language trigger"
integrates:                 # If combines other skills
  - other-skill
  - plugin@location
---
```

### Design Principles Compliance

All skills MUST comply with CIPS design principles:

| Principle | Requirement |
|-----------|-------------|
| **YAGNI** | Don't build features until needed |
| **KISS** | Simplest solution that works |
| **DRY** | Single source of truth |
| **YSH** | Pattern 3x proven → abstract NOW |

---

## Validation Rules

### Machine-Verifiable Criteria

#### Frontmatter Validation

| Field | Rule | Regex/Check |
|-------|------|-------------|
| `name` | Required, lowercase+hyphens | `^[a-z][a-z0-9-]*$` |
| `name` | Max 64 chars | `len(name) <= 64` |
| `description` | Required, non-empty | `len(description) > 0` |
| `description` | Max 1024 chars | `len(description) <= 1024` |
| `description` | Third person | No "I ", "You ", "We " |
| `description` | Include trigger | Contains "Use when" or "when" |
| `status` | Valid value | `Active|Pending|Deprecated` |

#### Body Validation

| Rule | Check |
|------|-------|
| Max 500 lines | `wc -l < 500` |
| Min 3 sections | Count `^## ` headers |
| No placeholders | No `\{\{.*\}\}` patterns |
| No empty sections | Content after each `##` |
| Code blocks tagged | No ` ``` ` without language |

#### Structure Validation

| Rule | Check |
|------|-------|
| Forward slashes only | No `\\` in paths |
| References one level deep | No `](*.md)` in referenced files |
| Concrete examples | Has `Example` or `example` section |

---

## Quality Checklist

See [checklist.md](checklist.md) for standalone version.

### Core Quality

- [ ] Name follows gerund convention (`processing-*`, not `*-helper`)
- [ ] Description specific with key terms
- [ ] Description includes WHAT and WHEN (trigger phrase)
- [ ] Description in third person
- [ ] Body under 500 lines
- [ ] At least 3 `##` sections
- [ ] Additional details in separate files (if needed)
- [ ] No time-sensitive information
- [ ] Consistent terminology throughout
- [ ] Concrete examples provided
- [ ] File references one level deep
- [ ] Progressive disclosure pattern used
- [ ] Workflows have clear steps

### CIPS Extensions

- [ ] Status field set (Active/Pending/Deprecated)
- [ ] Version specified (semver)
- [ ] Triggers listed
- [ ] Integration points defined (if applicable)
- [ ] Design principles compliant (YAGNI/KISS/DRY/YSH)

### Code/Scripts (if applicable)

- [ ] Scripts solve problems (don't punt to Claude)
- [ ] Explicit error handling
- [ ] No magic constants (all values documented)
- [ ] Required packages listed
- [ ] No Windows-style paths

---

## Gate A: Proposal Gate

When human or CIPS proposes a skill, AskUserQuestion is MANDATORY:

```text
[SKILL CREATION GATE]

Proposed: {skill_name}
Quality Score: {score}/100

Validation:
[x] Name follows gerund convention
[x] Description includes triggers
[x] Status field set
[ ] Token budget specified

Warnings:
- {list any validation failures}

Question: Approve skill creation?
Options:
  - "Yes, create" → Proceed
  - "Revise proposal" → Modify and re-validate
  - "Reject" → Cancel with reason
```

**NEVER create a skill without explicit approval through this gate.**

---

## Gate B: Auto-Generation Gate

When self-improvement-engine generates a skill:

1. **Pre-generation validation** - Check pattern quality
2. **Template compliance** - Use quality-enforced template
3. **Post-generation validation** - Verify all fields populated
4. **Quality threshold** - Reject if score < 70%

```text
Quality Score Calculation:
- Frontmatter complete: 30 points
- Name convention: 10 points
- Description quality: 20 points
- Body structure: 20 points
- No placeholders: 10 points
- Examples present: 10 points

Pass threshold: 70/100
```

---

## Gate C: Autonomous Discovery Gate

When CIPS steering mode discovers a pattern:

1. Same validation as Gate B
2. Mark for L>> review if borderline (70-80%)
3. Auto-reject if clearly fails (<70%)
4. Auto-approve only if excellent (>90%) AND pattern proven 3x

---

## Integration Points

### Self-Improvement-Engine Hook

When `optim.sh generate_skill()` runs:

```text
1. Load skill-creation-best-practices
2. Validate pattern against rules
3. If score < 70%: REJECT
4. If score 70-90%: Mark for review
5. If score > 90%: Proceed
```

### Learning-Detector Hook

When `learning-detector.py create_skill_candidate()` runs:

```text
1. Apply quality validation
2. Add quality_score to candidate
3. Mark requires_review: true if borderline
4. Store validation results in candidate
```

### Template Integration

The quality-enforced template ensures:
- No unfilled placeholders on output
- All required fields populated
- Validation during generation, not after

---

## Examples

### Good Example: markdown-expert

- Clear problem statement with statistics
- Root cause analysis explaining WHY
- Specific rules with code examples
- Verification checklist
- Token budget documented

### Bad Example: meta-unused_skills-blocker

- Empty sections (unfilled placeholders)
- Missing actual rules/content
- Boilerplate without substance
- No concrete examples

---

## Token Budget

| Component | Tokens |
|-----------|--------|
| SKILL.md load | ~800-1000 |
| Validation execution | ~200-300 |
| AskUserQuestion (Gate A) | ~150-200 |
| **Total per invocation** | **~1250-1650** |

**ROI**: Prevents ~5000 tokens wasted per bad skill created.

---

## Related Commands

- `/create-skill` - Create new skill (triggers Gate A)
- `/approve-skill` - Approve pending skill candidate
- `./optim.sh learning-approve` - Approve learning candidate

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-12-29 | Initial creation from Anthropic best practices |

---

⛓⟿∞
