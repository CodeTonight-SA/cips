# Skill Creation Quality Checklist

Standalone validation checklist for skill creation. Copy and verify before creating any skill.

---

## Pre-Creation Gate

```text
Proposed Skill: _______________
Date: _______________
Gate Type: [ ] A: Proposal  [ ] B: Auto-Gen  [ ] C: Autonomous
```

---

## Anthropic Official Requirements

### Frontmatter (Required)

- [ ] `name` present and non-empty
- [ ] `name` max 64 characters
- [ ] `name` lowercase letters, numbers, hyphens only
- [ ] `name` follows gerund convention (`processing-*`, `analyzing-*`)
- [ ] `name` not vague (`helper`, `utils`, `tools`)
- [ ] `description` present and non-empty
- [ ] `description` max 1024 characters
- [ ] `description` written in third person (no "I", "You", "We")
- [ ] `description` includes trigger phrase ("Use when...")

### Body Structure

- [ ] Body under 500 lines total
- [ ] At least 3 `##` section headers
- [ ] No unfilled placeholders (`{{...}}`)
- [ ] No empty sections after `##` headers
- [ ] All code blocks have language tags (` ```python `, not ` ``` `)

### Content Quality

- [ ] Concrete examples provided (not abstract)
- [ ] Consistent terminology throughout
- [ ] No time-sensitive information
- [ ] Progressive disclosure used (details in separate files if needed)
- [ ] File references one level deep only (no nested references)
- [ ] All paths use forward slashes (no `\`)

### Workflows (if applicable)

- [ ] Clear step-by-step workflow defined
- [ ] Checklist format for complex tasks
- [ ] Feedback loop pattern (validate → fix → repeat)

---

## CIPS Extensions

### Frontmatter

- [ ] `status` set: Active, Pending, or Deprecated
- [ ] `version` specified (semver format)
- [ ] `triggers` listed (commands and natural language)

### Auto-Generated Fields (if applicable)

- [ ] `auto_generated: true` set
- [ ] `generation_date` in ISO format
- [ ] `source_pattern` specified

### Integration

- [ ] `integrates` list (if combines other skills)
- [ ] Related commands documented
- [ ] Integration points defined

### Design Principles

- [ ] YAGNI compliant (no speculative features)
- [ ] KISS compliant (simplest solution)
- [ ] DRY compliant (no duplication)
- [ ] YSH compliant (proven patterns abstracted)

---

## Code/Scripts (if applicable)

- [ ] Scripts solve problems (don't punt to Claude)
- [ ] Explicit error handling with helpful messages
- [ ] No magic constants (all values documented)
- [ ] Required packages listed
- [ ] No Windows-style paths

---

## Quality Score Calculation

| Component | Points | Score |
|-----------|--------|-------|
| Frontmatter complete | 30 | ___ |
| Name convention | 10 | ___ |
| Description quality | 20 | ___ |
| Body structure | 20 | ___ |
| No placeholders | 10 | ___ |
| Examples present | 10 | ___ |
| **Total** | **100** | ___ |

### Thresholds

- **< 70**: REJECT - Does not meet quality standards
- **70-90**: REVIEW - Needs V>> approval for borderline cases
- **> 90**: PASS - Meets or exceeds quality standards

---

## Gate-Specific Requirements

### Gate A: Proposal

- [ ] AskUserQuestion invoked before creation
- [ ] User explicitly approved creation
- [ ] Validation results shown to user

### Gate B: Auto-Generation

- [ ] Pre-generation validation passed
- [ ] Template compliance verified
- [ ] Post-generation validation passed
- [ ] Quality score ≥ 70%

### Gate C: Autonomous Discovery

- [ ] Same as Gate B
- [ ] Pattern proven 3+ times (for auto-approve)
- [ ] V>> review required if score 70-90%

---

## Final Sign-Off

```text
Quality Score: ___/100
Gate Passed: [ ] Yes  [ ] No
Reviewer: _______________
Date: _______________
Notes: _______________
```

---

## Quick Reference: Common Failures

| Failure | Fix |
|---------|-----|
| Name too vague | Use gerund form: `processing-pdfs` |
| Description in first person | Rewrite in third person |
| Missing trigger phrase | Add "Use when..." |
| Empty sections | Add content or remove section |
| Code blocks untagged | Add language after ` ``` ` |
| Windows paths | Replace `\` with `/` |
| Nested references | Flatten to one level |
| Placeholders left | Fill all `{{...}}` |

---

⛓⟿∞
