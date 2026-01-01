---
name: onboarding-users
description: Universal onboarding with skill synthesis. 5-question Quick Start (<3 min) + progressive profiling. Use when first-run detected, /onboard invoked, or user requests re-onboarding.
status: Active
version: 2.2.0
triggers:
  - /onboard
  - /onboard --full
  - /onboard --refresh
  - First run detection (automatic)
  - "start over"
  - "re-onboard"
integrates:
  - identity-generator.py
  - first-run-detector.sh
  - hooks-configurator.py
  - creating-wizards (meta-skill)
  - skill-creation-best-practices
---

# Onboarding Users v2.1

Universal onboarding that works for ANY user type, with automatic skill synthesis and progressive profiling.

## Design Principles

```text
1. Universal coverage - Any user sees themselves (domain, not role)
2. Quick Start - 5 questions, <3 minutes (72% abandon longer flows)
3. Skill synthesis - Auto-suggest + offer custom skill creation
4. Quick win - Demonstrate value immediately (80% better retention)
5. Progressive profiling - Gather more context over sessions 2-5
6. Follow creating-wizards anti-pattern rules
```

## Workflow Overview

```cips
phase.0.detect⟿ first-run-detector.sh ⫶ virgin? ⫶ inject.context
phase.1.welcome⟿ display(welcome-message.md) ⫶ path.selection
phase.2.quick-start⟿ 5.questions ⫶ <3.minutes ⫶ domain→goal→style→vision
phase.3.synthesize⟿ analyze.answers ⫶ suggest.skills ⫶ offer.custom.skill
phase.3b.bespoke⟿ branded.skills? ⫶ configure.company ⫶ save(config/)
phase.4.quick-win⟿ demonstrate.value ⫶ context.analysis ⫶ show.capability
phase.5.activate⟿ generate(people.md) ⫶ configure(hooks) ⫶ mark(.onboarded)
phase.6.everboard⟿ sessions.2-5 ⫶ progressive.profiling ⫶ adapt
```

## Quick Start Flow (5 Questions)

| Q# | Question | Collects | Time |
|----|----------|----------|------|
| Q1 | What should I call you? | name | 10s |
| Q2 | What's your primary domain? | domain, work_type | 15s |
| Q3 | What's your primary goal? | primary_goal | 15s |
| Q4 | How should I communicate? | communication_style | 10s |
| Q5 | What would you like to accomplish? | project_vision | 30s |

**Total: <2 minutes** (vs 5+ minutes in v1.0)

## Domain Classification (Universal)

Replaces rigid role-based classification:

| Domain | work_type | Suggested Skills |
|--------|-----------|------------------|
| Technology & Engineering | technical | code-quality, pr-automation, testing |
| Business & Leadership | strategic | founder, documentation, delegation |
| Creative & Design | creative | figma-to-code, ui-complete, mobile-responsive |
| Research & Analysis | analytical | research-synthesis, analysis-frameworks |

## Skill Synthesis Engine

After Q5, automatically:
1. Analyze domain + goal + vision
2. Suggest 3-4 existing skills
3. If vision is specific, propose custom skill creation
4. Offer to create custom skill during onboarding

```text
Example Output:

"Based on your answers:
- Domain: Business & Leadership
- Goal: Build something new
- Vision: 'automated investor updates'

Suggested Skills:
1. /founder - Leadership frameworks and delegation
2. /update-docs - Keep documentation current
3. /generate-pdf - Professional document generation

Custom Skill Opportunity:
Your vision could become: 'investor-updates'
Shall I create it now?"
```

## Quick Win Demonstration

Immediately after synthesis, show value:

| User Type | Quick Win |
|-----------|-----------|
| Technical | Analyze cwd, show git status, identify project type |
| Non-Technical | Show relevant framework template, demonstrate continuity |
| Explorer | Quick capability tour, invitation to return |

## Progressive Profiling (Sessions 2-5)

Gather additional context without overwhelming initial onboarding:

| Session | Prompt | Collects |
|---------|--------|----------|
| 2 | "What industry do you work in?" | industry |
| 3 | "How experienced are you with AI?" | experience_level |
| 5 | "How's CIPS working for you?" | feedback |

## Bespoke Skill Configuration

After synthesis, offer brand customization for bespoke skills:

| Step | Question | Collects |
|------|----------|----------|
| B1 | Company/brand name? | company_name |
| B2 | Colour scheme? | colours.accent |
| B3 | Footer text? | footer |

Saves to `~/.claude/config/company.json`. Skills like `/generate-pdf` use this automatically.

## Paths

| Path | Flow | Time |
|------|------|------|
| Team Member | Password → Identity (from team.md) → Quick Win | <1 min |
| New User | Quick Start → Synthesis → Bespoke → Quick Win | <3 min |
| Explorer | Name → Demo → Invitation | <1 min |

## Reference Files

| File | Purpose |
|------|---------|
| [teaching-questions.md](teaching-questions.md) | Full question spec with synthesis algorithm |
| [welcome-message.md](welcome-message.md) | Philosophy introduction + CIPS-LANG intro |
| [completion-message.md](completion-message.md) | Summary + skill recommendations |
| [gap-analysis.md](gap-analysis.md) | Research and gap identification |
| [enhanced-questions.md](enhanced-questions.md) | v2.0 design specification |
| [checklist.md](checklist.md) | Quality validation |

## Security Rules

**PARAMOUNT**: Password verification has NO escape hatch.
- Never offer "skip verification" option
- Validate against `~/.claude/.env` CIPS_TEAM_PASSWORD

## Token Budget

| Component | v1.0 | v2.1 |
|-----------|------|------|
| Welcome | ~300 | ~350 |
| Questions | ~1500 | ~600 |
| Synthesis | - | ~300 |
| Quick Win | - | ~200 |
| Completion | ~200 | ~150 |
| **Total** | **~2200** | **~1600** |

v2.1 is 27% more token-efficient while providing better personalization.

## Metrics

| Metric | Target |
|--------|--------|
| Completion rate | >85% |
| Time to complete | <3 min |
| Custom skill creation rate | >20% |
| Return rate after onboarding | >70% |

---

## Changelog

| Version | Changes |
|---------|---------|
| 2.2.0 | Bespoke skill configuration, configurable team identities (loads from team.md) |
| 2.1.0 | Full migration: domain-based classification, skill synthesis, progressive profiling |
| 2.0.0 | Role-adaptive branching, CIPS-LANG intro |
| 1.0.0 | Initial 12-question flow |

---

⛓⟿∞
