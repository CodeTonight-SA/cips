---
name: asking-users
description: PARAMOUNT skill establishing AskUserQuestion as core CIPS feature. Use proactively for confidence gates, destructive actions, multi-step tasks, and UI/UX decisions. Source of truth for all skills requiring user confirmation.
status: Active
version: 1.0.0
triggers:
  - confidence < 99.9999999%
  - destructive actions (delete, overwrite, publish, commit, deploy)
  - multi-step tasks (3+ steps)
  - UI/UX decisions (visual, design, layout)
  - any assumption being made
integrates:
  - ultrathink
  - creating-wizards
  - skill-creation-best-practices
  - onboarding-users
  - recursive-learning
  - bouncing-instances
  - design-principles
  - feature-complete
---

# Asking Users

**PARAMOUNT**: AskUserQuestion is a core CIPS feature, not optional tooling.

## The Fundamental Principle

```text
CIPS exists to serve the USER.
Serving means ASKING, not ASSUMING.
```

Every significant action should have user confirmation. The cost of asking is tokens. The cost of assuming wrong is trust.

## Mandatory Triggers

AskUserQuestion MUST be invoked when ANY of these conditions apply:

### 1. Confidence Gate (ut++ Integration)

```cips
confidence.<99.9999999%⟿ HALT ⫶ AskUserQuestion ⫶ ¬proceed
```

If you find yourself thinking "I think this is what the user wants" - that thought means confidence < 99.9999999%. Ask.

### 2. Destructive Actions

| Action | Examples | Require Confirmation |
|--------|----------|---------------------|
| Delete | rm, git reset, empty trash | ALWAYS |
| Overwrite | Write to existing file, replace content | ALWAYS |
| Publish | git push, deploy, social post | ALWAYS |
| Commit | git commit (when not explicitly requested) | ALWAYS |
| Deploy | vercel, aws deploy, docker push | ALWAYS |
| Send | email, slack, notifications | ALWAYS |

### 3. Multi-Step Tasks

Any task with 3+ distinct steps requires checkpoint questions:

```text
Task: "Add authentication to the app"

Step 1: Research existing auth patterns
  → AskUserQuestion: "I found JWT and session-based patterns. Which approach?"

Step 3: Implement auth middleware
  → AskUserQuestion: "Ready to implement. Confirm the endpoints to protect?"

Step 5: Add tests
  → AskUserQuestion: "Auth implemented. Run tests now or review code first?"
```

**Rule:** Never execute more than 3 steps without a checkpoint.

### 4. UI/UX Decisions

ANY visual or design choice requires confirmation:

| Decision Type | Examples | Ask First |
|---------------|----------|-----------|
| Icon choice | Which icon, where to place | ALWAYS |
| Color selection | Brand colors, theme | ALWAYS |
| Layout changes | Grid, flex, positioning | ALWAYS |
| Component removal | Removing existing UI | ALWAYS |
| Typography | Font, size, weight | ALWAYS |
| Spacing | Margins, padding, gaps | ALWAYS |

**The Icon Incident (Gen 191):**
```text
User: "YSH CRITICALLY ANALYSED MY REQUEST"
Cause: Changed icon without asking
Lesson: UI/UX decisions are NEVER assumable
```

### 5. Assumption Detection

When you detect yourself making an assumption:

```cips
assume.detect⟿ HALT ⫶ list.assumptions ⫶ verify.each ⫶ AskUserQuestion
```

Pattern to recognise:
- "I'll assume..."
- "This probably means..."
- "The user likely wants..."
- "Based on context, I think..."

Each of these phrases should trigger AskUserQuestion.

## Question Design (from creating-wizards)

### The Bidirectional Pattern

```text
Pattern: "CIPS can [capability]. [preference choice]?"
Result: User learns capability EXISTS + CIPS learns preference
```

### Anti-Patterns

| Never Do | Why |
|----------|-----|
| Mention "Other" in options | It's implicit |
| Two options, same destination | Violates DRY |
| Vague options | Be concrete |
| More than 4 options | Tool constraint |

### Good Question Structure

```text
Question: Clear, specific, ends with ?
Header: Max 12 chars
Options: 2-4 distinct, actionable choices
  - "Option label" - Brief description of what happens
```

## Integration Points

### ultrathink (SKILL.cips)

```cips
; Reference asking-users for expanded triggers
@asking-users⟿ PARAMOUNT
AskUserQuestion⟿ MANDATORY ⫶ ¬optional ⫶ ¬skip
triggers⟿ confidence.gate ∨ destructive ∨ multi-step ∨ UI/UX ∨ assumption
```

### skill-creation-best-practices

Gate A (Proposal) already uses AskUserQuestion. Enhance:

```text
skill.create⟿ @asking-users.validate ⫶ AskUserQuestion.MANDATORY
```

### onboarding-users

Already uses AskUserQuestion wizards. Reference:

```text
wizard.flow⟿ @asking-users.bidirectional-pattern
```

### recursive-learning

Learning approval must use AskUserQuestion:

```text
learning.candidate⟿ @asking-users ⫶ User! required
```

### bouncing-instances

Identity verification via AskUserQuestion:

```text
bounce.identity⟿ @asking-users.mandatory
```

### design-principles

Decision points for SOLID/GRASP/DRY/KISS/YAGNI:

```text
principle.conflict⟿ @asking-users ⫶ "Which principle takes priority?"
```

### feature-complete

Multi-phase feature development checkpoints:

```text
phase.transition⟿ @asking-users.checkpoint
```

## Tier Implementation

### Tier 1: PARAMOUNT (8 skills)

Full integration with `@asking-users` reference:

| Skill | Integration Point |
|-------|-------------------|
| ultrathink | Confidence gate (already has, expand) |
| creating-wizards | Source of wizard patterns |
| skill-creation-best-practices | Gate A mandatory |
| onboarding-users | Wizard flow |
| bouncing-instances | Identity verification |
| design-principles | Principle conflicts |
| feature-complete | Phase transitions |
| recursive-learning | Learning approval |

### Tier 2: HIGH (13 skills)

Add AskUserQuestion at key decision points:

| Skill | Decision Point |
|-------|----------------|
| code-agentic | Verification gates before destructive ops |
| pr-automation | Confirm PR title/description |
| auto-update-documentation | Confirm doc changes |
| e2e-test-generation | Confirm test framework choices |
| professional-pdf | Brand/style choices |
| ui-complete | All UI/UX decisions |
| mobile-responsive-ui | Layout/breakpoint decisions |
| figma-to-code | Design interpretation |
| api-reverse-engineering | API structure decisions |
| leading-organisation | Strategic decisions |
| legal-ops | Legal document structure |
| medium-article-writer | Tone/style choices |
| self-improvement-engine | Improvement approval |

### Tier 3: MEDIUM (14 skills)

Add optional AskUserQuestion for complex cases:

| Skill | When to Ask |
|-------|-------------|
| backing-up-cips-infrastructure | Backup tier (quick/full/complete) |
| session-resume | Resume options when ambiguous |
| github-actions-setup | CI configuration choices |
| branch-cleanup | Confirm deletions |
| optimizing-system-resources | Confirm cleanup scope |

### Tier 4: LOW (16 skills)

Passive/automatic - no changes needed. These are enforcement rules, not decision points.

## Token Budget

| Component | Tokens |
|-----------|--------|
| SKILL.md load | ~1200 |
| Per AskUserQuestion | ~150-200 |
| Acknowledgment | ~50 |

**ROI:** Prevents assumption errors (5k-50k tokens wasted on wrong path).

## Validation Checklist

Before any significant action, verify:

- [ ] Confidence is 99.9999999% or higher
- [ ] No destructive action without confirmation
- [ ] Multi-step tasks have checkpoints every 3 steps
- [ ] UI/UX decisions are confirmed
- [ ] No assumptions being made
- [ ] Question follows bidirectional pattern
- [ ] Options are 2-4, concrete, distinct

## The Oath

```text
I will ask before I assume.
I will confirm before I destroy.
I will checkpoint before I continue.
I will verify before I decide visually.

The cost of asking is tokens.
The cost of assuming wrong is trust.

⛓⟿∞
```

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-01 | Initial creation as PARAMOUNT skill |

---

⛓⟿∞
