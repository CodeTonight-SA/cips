# Onboarding Quality Checklist v2.1

Validation checklist for the enhanced onboarding-users skill.

## Skill Quality (from skill-creation-best-practices)

### Frontmatter

- [x] Name follows gerund convention: `onboarding-users`
- [x] Description includes WHAT and WHEN
- [x] Description in third person
- [x] Description max 1024 chars
- [x] Status field set: `Active`
- [x] Version specified: `2.1.0`
- [x] Triggers listed
- [x] Integrations defined

### Body Structure

- [x] Body under 500 lines (SKILL.md ~180 lines)
- [x] Min 3 `##` sections
- [x] No unfilled placeholders
- [x] No empty sections
- [x] Code blocks tagged with language
- [x] Progressive disclosure pattern used

---

## Quick Start Flow (5 Questions)

### Core Questions

- [ ] Q1 Name: Uses system username option + skip
- [ ] Q2 Domain: 4 universal domains (Tech, Business, Creative, Research)
- [ ] Q2b Technical clarification: Triggers for Creative or Other
- [ ] Q3 Goal: 4 universal goals (faster, smarter, together, build)
- [ ] Q4 Style: 3 communication styles
- [ ] Q5 Vision: Free-text oriented with fallback options

### Timing

- [ ] Total Quick Start < 3 minutes
- [ ] Each question < 30 seconds
- [ ] Progress shown to user

---

## Skill Synthesis

- [ ] Domain → skill mapping implemented
- [ ] Goal → skill mapping implemented
- [ ] Vision analyzed for custom skill opportunity
- [ ] Q_synth displays personalized recommendations
- [ ] Custom skill creation offered if vision specific
- [ ] "Tell me more" option explains each skill

---

## Quick Win Demonstration

- [ ] Technical users: Directory analysis, git status
- [ ] Non-technical users: Framework template, continuity demo
- [ ] Explorers: Capability tour
- [ ] Value demonstrated within 60 seconds of synthesis

---

## Progressive Profiling (Everboarding)

- [ ] Session 2: Industry question triggers
- [ ] Session 3: Experience level question triggers
- [ ] Session 5: Feedback collection triggers
- [ ] Extended profile stored in people.md
- [ ] Timestamps tracked for last_extended_prompt

---

## Path-Specific Flows

### Team Member Path

- [ ] Password verification works
- [ ] NO skip option on password (PARAMOUNT)
- [ ] Identity selection works
- [ ] Proceeds to Quick Win after identity

### New User Path

- [ ] Quick Start (Q1-Q5) completes
- [ ] Skill Synthesis displays
- [ ] Custom skill creation works if selected
- [ ] Quick Win demonstrates value
- [ ] Profile generated correctly

### Explorer Path

- [ ] Name only collected
- [ ] Quick demo shown
- [ ] Invitation to return displayed
- [ ] `/onboard --full` mentioned

---

## AskUserQuestion Anti-Patterns (PARAMOUNT)

**NEVER create options that redirect to "Other"**

| Anti-Pattern | Fix |
|--------------|-----|
| `"Type in 'Other'"` | Remove - Other is implicit |
| `"Enter X in Other field"` | Make option a concrete action |
| Two options, same destination | Provide distinct choices |
| `"Custom" → implies Other` | Offer concrete alternatives |

- [ ] No option says "Type in Other" or similar
- [ ] No two options lead to same action
- [ ] Each option is a concrete choice
- [ ] "Other" never mentioned in descriptions

---

## Data Schema Validation

### Quick Start Fields

- [ ] name: string
- [ ] domain: enum (Technology, Business, Creative, Research, Other)
- [ ] work_type: enum (technical, strategic, creative, analytical)
- [ ] is_technical: boolean (derived)
- [ ] primary_goal: enum (faster, smarter, together, build_new)
- [ ] communication_style: enum (direct, thorough, supportive)
- [ ] project_vision: string (optional)

### Synthesis Fields

- [ ] suggested_skills: list[string]
- [ ] custom_skill_proposed: object (optional)
- [ ] quick_win_shown: boolean

### Extended Fields (Progressive)

- [ ] industry: string (session 2)
- [ ] experience_level: enum (session 3)
- [ ] feedback: object (session 5)
- [ ] onboarded_at: ISO8601
- [ ] last_extended_prompt: ISO8601

---

## UX Quality

### Tone Adaptation

- [ ] Direct style: "Got it."
- [ ] Thorough style: "Great - that context helps me tailor recommendations."
- [ ] Supportive style: "Excellent choice! You're going to love..."

### Accessibility

- [ ] All options have clear descriptions
- [ ] No jargon without explanation
- [ ] Skip options where appropriate
- [ ] CIPS-LANG explained in welcome message

---

## Security Validation

- [ ] Password flow has NO escape hatch
- [ ] Password validated against ~/.claude/.env
- [ ] Invalid password prompts retry (no skip)
- [ ] No sensitive data logged

---

## Integration Validation

- [ ] /onboard command works
- [ ] /onboard --full works
- [ ] /onboard --refresh works
- [ ] session-start.sh triggers on virgin install
- [ ] creating-wizards skill rules followed

---

## Metrics Tracking

| Metric | Target | Actual |
|--------|--------|--------|
| Completion rate | >85% | |
| Time to complete | <3 min | |
| Custom skill creation rate | >20% | |
| Return rate after onboarding | >70% | |

---

## Test Scenarios

### Scenario 1: Technical User (Full Flow)

1. Start fresh session
2. Select "New user" path
3. Q2: Select "Technology & Engineering"
4. Q3: Select "Work faster"
5. Q5: Type "streamline code reviews"
6. Verify synthesis suggests code-quality, pr-automation
7. Verify custom skill "code-review-automation" proposed
8. Verify technical Quick Win (directory analysis)

### Scenario 2: Business Leader

1. Start fresh session
2. Q2: Select "Business & Leadership"
3. Q3: Select "Build something new"
4. Q5: Type "investor updates automation"
5. Verify synthesis suggests founder, documentation
6. Verify custom skill proposed
7. Verify non-technical Quick Win (framework template)

### Scenario 3: Creative Designer

1. Start fresh session
2. Q2: Select "Creative & Design"
3. Q2b: Should trigger - ask about technical
4. If "Yes, I write code" → technical path
5. If "No" → non-technical path
6. Verify correct Quick Win based on path

### Scenario 4: Explorer

1. Start fresh session
2. Select "I'm exploring"
3. Verify only name asked
4. Verify quick demo shown
5. Verify invitation to `/onboard --full`

### Scenario 5: Team Member

1. Start fresh session
2. Select "Team member"
3. Enter correct password
4. Select identity
5. Verify Quick Win shown
6. Verify no further questions

---

## Quality Score Calculation

| Criteria | Points | Score |
|----------|--------|-------|
| Quick Start < 3 min | 20 | /20 |
| Universal domain coverage | 15 | /15 |
| Skill synthesis works | 20 | /20 |
| Quick Win demonstrated | 15 | /15 |
| No anti-patterns | 15 | /15 |
| Progressive profiling hooks | 15 | /15 |
| **Total** | **100** | **/100** |

**Pass threshold:** 80/100

---

⛓⟿∞
