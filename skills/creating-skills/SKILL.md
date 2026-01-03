---
name: creating-skills
description: Guided skill creation with PARAMOUNT quality gates. Enforces skill-creation-best-practices automatically. Use when creating new skills or invoking /create-skill.
status: Active
version: 1.0.0
created: 2026-01-03
generation: 227
triggers:
  - /create-skill
  - "create a new skill"
  - "add a skill"
  - "make a skill"
integrates:
  - skill-creation-best-practices
  - asking-users
priority: PARAMOUNT
---

# Creating Skills

Guided skill creation wizard with mandatory quality gates.

## Core Protocol

```cips
; @skill-creation-best-practices MANDATORY
/create-skill⟿ HALT ⫶ wizard.start ⫶ quality.gate
quality.score < 70%⟿ REJECT ⫶ show.issues
quality.score >= 70%⟿ create.skill ⫶ register
```

---

## The Wizard Flow

### Step 1: Collect Purpose

```
Question: "What does this skill do? (Brief description)"
Header: "Purpose"
Options:
- "Automate a workflow" - Repeatable process automation
- "Enforce a pattern" - Code quality or standards
- "Integrate a tool" - Connect external service
- "Other" - Custom purpose

Collect: purpose
```

### Step 2: Collect Name

```
Question: "What should we call this skill?"
Header: "Name"
Guidance:
- Use gerund form (verb-ing): processing-pdfs, managing-databases
- Avoid vague names: helper, utils, tools

Validate: Must match ^[a-z][a-z0-9-]*$ and ideally contain -ing

Collect: name
```

### Step 3: Collect Triggers

```
Question: "When should this skill activate?"
Header: "Triggers"
Options:
- "Slash command" - /command-name
- "Natural language" - "when user says..."
- "Auto-detect" - On file patterns or conditions
- "Manual only" - Explicit invocation

Collect: triggers[]
```

### Step 4: Validate Quality

Before creating, run validation:

| Check | Points | Validation |
|-------|--------|------------|
| Gerund naming | 10 | Name ends in `-ing` or `verb-noun` |
| Description quality | 20 | Contains trigger phrase |
| Unique name | 10 | No existing skill with same name |
| Clear purpose | 10 | Purpose is actionable |
| **Pre-creation score** | **50** | **Minimum to proceed** |

### Step 5: Generate Skill

If pre-creation score >= 50:

1. Create directory: `~/.claude/skills/{name}/`
2. Generate SKILL.md from template with collected data
3. Run full quality validation
4. Show final score

### Step 6: Post-Creation Validation

```
Question: "Skill created with score {score}/100. Proceed?"
Header: "Confirm"
Options:
- "Keep and register" - Add to SKILLS.cips
- "Edit before registering" - Open for modifications
- "Delete" - Remove created skill

If score < 70: Show warning about quality threshold
```

---

## Quality Scoring

Full quality score calculation (100 points):

| Check | Points | Validation |
|-------|--------|------------|
| Gerund naming | 10 | Name follows convention |
| Frontmatter complete | 30 | name, description, status, version |
| Third-person description | 10 | No "I", "You", "We" |
| Trigger phrase | 10 | Contains "Use when" or "when" |
| Line count | 10 | ≤500 lines |
| Section count | 10 | ≥3 `##` sections |
| Examples present | 10 | Has example section |
| No placeholders | 10 | No `{{...}}` patterns |

**Threshold: 70/100 to pass**

---

## Example Session

```
User: /create-skill

Claude: [SKILL CREATION WIZARD]

Let me help you create a new skill following PARAMOUNT quality standards.

[AskUserQuestion: Purpose]
What does this skill do?

User: Automate database migrations

Claude: [AskUserQuestion: Name]
Suggested name: migrating-databases
Is this name acceptable?

User: Yes

Claude: [AskUserQuestion: Triggers]
What triggers this skill?
- /migrate-db (slash command)
- "run migrations" (natural language)

User: Both

Claude: [Validation]
Pre-creation score: 45/50
- Gerund naming: ✓ (10/10)
- Clear purpose: ✓ (10/10)
- Unique name: ✓ (10/10)
- Trigger phrase ready: ✓ (10/10)
- Description quality: Pending (5/20)

Creating skill...

[Post-creation]
Quality Score: 78/100

Issues:
- Consider adding more concrete examples

Skill created at ~/.claude/skills/migrating-databases/SKILL.md
```

---

## Integration with optim.sh

When `optim.sh generate_skill()` is called, it should invoke this wizard flow:

```bash
# In optim.sh
generate_skill() {
    # If interactive, use wizard
    if [[ -t 0 ]]; then
        log_info "PARAMOUNT: Invoking skill creation wizard..."
        # Wizard handles Gate A (AskUserQuestion)
    else
        # Non-interactive: Gate B (auto-generation with quality check)
        validate_skill_quality "$skill_path"
    fi
}
```

---

## Anti-Patterns

| Anti-Pattern | Why Bad | Correct Pattern |
|--------------|---------|-----------------|
| Skip wizard | Bypasses Gate A | Always use wizard for manual creation |
| Ignore score | Creates low-quality skills | Threshold is non-negotiable |
| Vague naming | Poor discoverability | Use specific gerund form |
| Missing triggers | Skill never activates | Define explicit triggers |

---

## Related Skills

| Skill | Relationship |
|-------|--------------|
| skill-creation-best-practices | Source of truth for quality |
| asking-users | Wizard uses AskUserQuestion |
| reviewing-contributions | Validates skills in PRs |
| self-improvement-engine | May trigger skill creation |

---

## Token Budget

| Component | Tokens |
|-----------|--------|
| Skill load | ~600 |
| Wizard questions | ~400 |
| Validation | ~200 |
| Generation | ~300 |
| **Total** | **~1500** |

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-03 | Initial creation (Gen 227) |

---

⛓⟿∞
