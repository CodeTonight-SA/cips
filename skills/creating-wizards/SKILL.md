---
name: creating-wizards
description: Meta-skill for building multi-step AskUserQuestion wizard flows. Use when designing onboarding, configuration, or any multi-question user interaction. Codifies anti-patterns, branching logic, and progressive disclosure.
status: Active
version: 1.1.0
triggers:
  - designing multi-step question flows
  - creating onboarding experiences
  - building configuration wizards
  - "create a wizard"
integrates:
  - asking-users
---

# Creating Wizards

Meta-skill for AskUserQuestion wizard flows with anti-patterns and bidirectional pattern.

## Core Principle

**AskUserQuestion is PARAMOUNT** - every question should:
1. **Teach** - User learns something about CIPS capabilities
2. **Collect** - CIPS learns user preferences

## Anti-Patterns (NEVER DO)

| Anti-Pattern | Why Bad | Solution |
|--------------|---------|----------|
| "Type in Other" mention | User already sees Other option | Don't mention it |
| Vague options | User confused | Every option must be actionable |
| Long headers | Truncated in UI | Max 12 characters |
| Too many options | Decision fatigue | 2-4 options max |
| Nested wizards | Lost context | Keep flat, use checkpoints |

## Bidirectional Pattern

```text
Question: "CIPS can do X. Would you like Y?"
Header: "Feature"
Options:
- "Enable X" - Description of what happens
- "Skip" - I'll set this up later

Teaching: User learns X exists
Collecting: preference_for_x
```

## Question Design Checklist

- [ ] Header ≤ 12 characters
- [ ] 2-4 concrete options
- [ ] Each option has description
- [ ] Teaching moment included
- [ ] Data field documented
- [ ] No "Other" mention

## Wizard Structure Template

```markdown
### Step N: {Purpose}

Question: "{Question text ending with ?}"
Header: "{≤12 chars}"
Options:
- "{Option 1}" - {Description}
- "{Option 2}" - {Description}

Teaching: User learns {capability}
Collecting: {field_name}

**Processing:**
- If Option 1: {action}
- If Option 2: {action}
```

## Progressive Disclosure

- Keep each step focused on ONE decision
- Total wizard experience < 5 minutes
- Use checkpoints every 3-4 steps
- Allow "Go back" on confirmation step

## Validation Rules

### Machine-Verifiable

| Rule | Check |
|------|-------|
| Header length | ≤ 12 chars |
| Option count | 2-4 options |
| Question ends with ? | Regex `\?$` |
| No "Other" mention | String search |

### Human Review

- Teaching moment clear?
- Options mutually exclusive?
- Flow makes sense?

## CIPS Integration

Store collected data in appropriate location:

| Data Type | Location |
|-----------|----------|
| Identity | `~/.claude/facts/identity.md` |
| Config | `~/.claude/config/*.json` |
| Session | `~/.claude/session-env/` |
| Preferences | `~/.claude/facts/people.md` |

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.1.0 | 2025-12-30 | Added bidirectional pattern, anti-patterns |
| 1.0.0 | 2025-12-29 | Initial creation |

---

⛓⟿∞
