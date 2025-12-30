# Wizard Creation Checklist

Validation checklist for AskUserQuestion-based wizard flows.

## Pre-Design

- [ ] Purpose clearly defined
- [ ] Target audience identified (technical/non-technical/both)
- [ ] Data fields listed with types
- [ ] Storage location determined

## Question Design

### Per Question

- [ ] Teaches a capability (bidirectional pattern)
- [ ] Collects a specific field
- [ ] 2-4 options (tool constraint)
- [ ] Header max 12 characters
- [ ] Options are concrete actions

### Anti-Pattern Checks (PARAMOUNT)

- [ ] No option says "Type in Other" or similar
- [ ] No option says "Enter X in Other field"
- [ ] No two options lead to same action
- [ ] "Other" never mentioned in descriptions
- [ ] "Custom" not used as redirect to Other

### Branching Logic

- [ ] Classification question early (Q1 or Q2)
- [ ] `is_technical` or equivalent derived
- [ ] Subsequent questions check classification
- [ ] Clarification question (Q{N}b) if "Other" typed for classification
- [ ] Non-technical path avoids technical jargon

## UX Quality

### Timing

- [ ] Total flow < 5 minutes
- [ ] Per question < 30 seconds to answer
- [ ] Progress indicators shown

### Tone

- [ ] Acknowledgments are warm but brief
- [ ] Matches target audience communication style
- [ ] No robotic language

### Accessibility

- [ ] Options have clear descriptions
- [ ] No jargon without explanation
- [ ] Skip options where appropriate

## Data Handling

- [ ] All fields documented in schema
- [ ] Storage location specified
- [ ] Required vs optional fields marked
- [ ] Derived fields documented (e.g., `is_technical`)

## Testing Scenarios

- [ ] Walk through as technical user
- [ ] Walk through as non-technical user
- [ ] Walk through with "Other" selections
- [ ] Walk through with all skip options
- [ ] Verify data stored correctly

## Integration

- [ ] Wizard documented in SKILLS.cips
- [ ] Command added to COMMANDS.cips (if applicable)
- [ ] Related skills referenced

---

## Quick Reference: Option Design

| Scenario | Good Pattern | Bad Pattern |
|----------|--------------|-------------|
| Name input | "Use '{username}'" + Skip | "Type name in Other" |
| Password | "I have it" + "I need credentials" | "Option A/B → Other" |
| Custom choice | Two concrete alternatives | "Custom" → Other |
| Free text needed | Question guides to Other naturally | Option redirects to Other |

---

⛓⟿∞
