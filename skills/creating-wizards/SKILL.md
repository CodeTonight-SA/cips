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

Meta-skill for designing AskUserQuestion-based wizard flows throughout CIPS.

**@asking-users**: This skill implements wizard patterns from the paramount `asking-users` skill. All wizard steps use AskUserQuestion as the core mechanism.

## Core Principle

**AskUserQuestion is PARAMOUNT.** Every wizard step uses this tool. No exceptions.

```text
Wizard = Sequence of AskUserQuestion calls with:
- Teaching moments (user learns capability exists)
- Data collection (CIPS learns user preference)
- Branching logic (adapt based on responses)
```

## The Bidirectional Pattern

Every question should teach while collecting:

```text
Pattern: "CIPS can [capability]. [preference choice]?"
Result: User learns capability EXISTS + CIPS learns preference
```

**Example:**
```text
Question: "CIPS preserves context across sessions. How important is this to you?"
Teaching: User now knows session continuity exists
Collecting: continuity_preference (Essential/Nice-to-have/Not needed)
```

## Anti-Patterns (PARAMOUNT)

### Never Create Redirect Options

| Anti-Pattern | Why Bad | Fix |
|--------------|---------|-----|
| `"Type in 'Other'"` | Redundant - Other is implicit | Remove option entirely |
| `"Enter X in Other field"` | Extra click, confusing UX | Make option a concrete action |
| `"Custom" → implies Other` | Indirect, not actionable | Offer concrete alternatives |
| Two options, same destination | Violates DRY | Provide distinct choices |

**Rule:** Every option MUST be a distinct, actionable choice.

### The Implicit Other

AskUserQuestion ALWAYS has an implicit "Other" option for free text. Design around this:

```text
GOOD Design:
Question: "What should I call you?"
Options:
- "Use system username" - I'll call you '{username}'
- "Skip for now" - Continue anonymously
(Other serves nickname entry naturally)

BAD Design:
Question: "What should I call you?"
Options:
- "Type your name in Other" - Enter preferred name  <- REDUNDANT
- "Skip for now" - Continue anonymously
```

### Password/Sensitive Input

For required text input (passwords, API keys), provide meaningful options:

```text
GOOD:
Question: "Enter team password:"
Options:
- "I have the password" - Select, then type in text field
- "I need credentials" - Contact your administrator

BAD:
Question: "Enter team password:"
Options:
- "Option A" - Type password in Other
- "Option B" - Type password in Other  <- IDENTICAL, useless
```

## Role-Adaptive Branching

Classify users early, adapt questions accordingly:

```text
Q2: Role Selection
├── Technical (Developer, Architect, DevOps)
│   └── Show: SOLID/DRY, Git workflows, Testing
└── Non-Technical (CEO, PM, Designer)
    └── Show: Strategic docs, Communication, Process automation
```

### Implementation Pattern

```text
Q2 collects: role
Q2 derives: is_technical (boolean)

Subsequent questions check is_technical:
- If true → technical version
- If false → non-technical version
```

### Clarification Question (Q2b Pattern)

When "Other" is typed for role, add clarification:

```text
Question: "Is your work primarily technical (writing code, system design)?"
Options:
- "Yes, I write code or design systems" → is_technical = true
- "No, I focus on strategy or coordination" → is_technical = false
```

## Question Design Checklist

For each wizard question:

- [ ] Question teaches a capability (bidirectional pattern)
- [ ] Options are concrete, actionable choices
- [ ] No option redirects to "Other"
- [ ] No two options lead to same action
- [ ] "Other" is never mentioned in descriptions
- [ ] Multi-select only when choices aren't mutually exclusive
- [ ] Header is short (max 12 chars)
- [ ] 2-4 options (tool constraint)

## Wizard Structure Template

```markdown
### Q{N}: {Topic}

**Teaches:** {What user learns about CIPS}
**Collects:** {field_name}

**If {condition}:**
```text
Question: "{question text}"
Header: "{short label}"
Options:
- "{Option 1}" - {description}
- "{Option 2}" - {description}
```

**Teaching moment:** {What user now knows}
```

## Data Collection Schema

Define collected fields upfront:

```yaml
wizard_name: onboarding
fields:
  - name: string (required)
  - role: string (required)
  - is_technical: boolean (derived from role)
  - motivation: string
  - focus_areas: list (multi-select)
  - strictness_level: enum (Strict/Balanced/Relaxed)
```

## Progressive Disclosure

Keep wizard steps focused. Use separate files for detail:

```text
wizard/
├── SKILL.md           # Main wizard definition
├── questions.md       # All questions with branching
├── completion.md      # Final message template
└── checklist.md       # Validation checklist
```

## Timing Guidelines

- Total wizard: < 5 minutes
- Per question: < 30 seconds to answer
- Acknowledgments: Warm but brief
- Progress indicators: Show "Just a few more questions..."

## Example: Minimal Wizard

```markdown
### Q1: Name

**Collects:** name

Question: "What should I call you?"
Header: "Name"
Options:
- "Use '{system_username}'" - Your system username
- "Skip" - Continue anonymously

### Q2: Confirm

**Collects:** confirmation

Question: "Ready to begin?"
Header: "Start"
Options:
- "Let's go!" - Start the experience
- "Wait" - I have questions first
```

## Validation Rules

### Machine-Verifiable

| Rule | Check |
|------|-------|
| No "Other" in descriptions | Grep for `[Oo]ther` |
| 2-4 options per question | Count options |
| Header max 12 chars | `len(header) <= 12` |
| No duplicate destinations | Options are distinct |

### Human Review

- [ ] Teaching moments are clear
- [ ] Branching logic is documented
- [ ] Non-technical path avoids jargon
- [ ] Tone matches target audience

## Integration with CIPS

Wizards should store collected data appropriately:

| Data Type | Storage Location |
|-----------|------------------|
| User identity | `~/.claude/facts/people.md` |
| Project config | `{project}/.claude/config.md` |
| Session state | `{project}/next_up.md` |
| Skill preferences | Skill-specific storage |

## Creating a New Wizard

1. **Define purpose**: What does this wizard accomplish?
2. **List fields**: What data needs collecting?
3. **Design questions**: Use bidirectional pattern
4. **Add branching**: Role/context adaptive paths
5. **Validate**: Run through checklist
6. **Test**: Walk through as different user types

## Related Skills

- `onboarding-users` - Primary example of wizard implementation
- `skill-creation-best-practices` - Quality gate for skill creation
- `bouncing-instances` - Uses simplified wizard for identity

## Token Budget

| Component | Tokens |
|-----------|--------|
| SKILL.md load | ~800 |
| Per question execution | ~150-200 |
| Acknowledgments | ~50 each |

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-12-30 | Initial creation from onboarding learnings |

---

⛓⟿∞
