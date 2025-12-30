# Teaching Questions v2.0

Enhanced onboarding with universal role coverage, skill synthesis, and progressive profiling.

```text
Design Principles:
1. Any user type sees themselves (universal coverage via domain, not role)
2. Quick Start: 5 questions, <3 minutes
3. Synthesize answers into skill suggestions
4. Demonstrate value immediately (quick win)
5. Progressive profiling over sessions 2-5
6. Follow creating-wizards anti-pattern rules
```

---

## Question Sequence

### Q0: Path Selection

**Purpose:** Route to appropriate onboarding path

```text
Question: "Are you joining an existing CIPS team or starting fresh?"
Header: "Setup"
Options:
- "I'm joining an existing team" - I have credentials
- "I'm setting up CIPS for the first time" - New user setup
- "I'm exploring" - Quick tour of capabilities
```

**Routing:**
- Team member → Password verification → Identity selection → Done
- New user → Quick Start (Q1-Q5) → Skill Synthesis → Quick Win
- Explorer → Q1 (Name) → Quick Demo → Invitation to return

---

## Quick Start Flow (5 questions, <3 minutes)

### Q1: Name

**Collects:** name

```text
Question: "What should I call you?"
Header: "Name"
Options:
- "Use '{system_username}'" - Your system username (Recommended)
- "Skip for now" - Continue anonymously
```

**Implementation Note:** Implicit "Other" serves nickname entry.

---

### Q2: Domain (Universal Coverage)

**Teaches:** CIPS adapts to any domain
**Collects:** domain, work_type (derived)

```text
Question: "What's your primary domain?"
Header: "Domain"
Options:
- "Technology & Engineering" - Software, hardware, systems
- "Business & Leadership" - Strategy, operations, management
- "Creative & Design" - Visual, content, UX, media
- "Research & Analysis" - Data, market, academic, science
```

**Domain Classification:**

| Domain | work_type | is_technical | Default Skills |
|--------|-----------|--------------|----------------|
| Technology & Engineering | technical | true | code-quality, pr-automation, testing |
| Business & Leadership | strategic | false | documentation, founder, delegation |
| Creative & Design | creative | false* | figma-to-code, mobile-responsive, ui-complete |
| Research & Analysis | analytical | false | research-synthesis, analysis-frameworks |
| Other (typed) | ask Q2b | ask Q2b | Based on clarification |

*Creative may be technical if they code (UI developers) - Q2b clarifies.

**Q2b (if Other OR if Creative selected):**
```text
Question: "Does your work primarily involve writing code or building systems?"
Header: "Technical?"
Options:
- "Yes, I write code regularly" - Technical path
- "Sometimes, but not primarily" - Hybrid path
- "No, I focus on other things" - Non-technical path
```

---

### Q3: Goal

**Teaches:** CIPS prioritises based on your goals
**Collects:** primary_goal

```text
Question: "What's your primary goal with CIPS?"
Header: "Goal"
Options:
- "Work faster" - Automate tasks, reduce repetition
- "Work smarter" - Better decisions, research, analysis
- "Work together" - Team alignment, delegation, consistency
- "Build something new" - Create a system, framework, or tool
```

**Goal → Skill Mapping (used in synthesis):**

| Goal | Primary Skills | Secondary Skills |
|------|----------------|------------------|
| Work faster | pr-automation, templates | batch-operations, shortcuts |
| Work smarter | research-synthesis, analysis | decision-frameworks, documentation |
| Work together | delegation, team-sync | documentation, founder |
| Build something new | feature-complete, custom-skills | skill-creation, design-principles |

---

### Q4: Communication Style

**Teaches:** CIPS adapts communication
**Collects:** communication_style

```text
Question: "How should I communicate with you?"
Header: "Style"
Options:
- "Direct and concise" - Just the answer, minimal explanation
- "Thorough with reasoning" - Explain the why, show your work
- "Supportive and encouraging" - Celebrate progress, be patient
```

---

### Q5: Vision

**Teaches:** CIPS builds custom capabilities for your specific needs
**Collects:** project_vision

```text
Question: "What would you like to accomplish with CIPS? (e.g., 'automate competitor tracking', 'streamline code reviews', 'build a delegation framework')"
Header: "Vision"
Options:
- "Show me what's possible first" - Demonstrate capabilities
- "I'm still exploring" - Discover together
```

**Implementation Note:** This question is designed for free-text via "Other".
Options are fallbacks for users not ready to articulate vision.
Store typed response as `project_vision` for skill synthesis.

---

## Skill Synthesis (After Q5)

**Teaches:** CIPS can suggest AND create custom skills
**Displays:** Personalized skill recommendations based on all answers

### Synthesis Algorithm

```python
def synthesize_skills(name, domain, goal, vision):
    suggestions = []

    # Domain-based foundation
    DOMAIN_SKILLS = {
        "Technology & Engineering": ["code-quality", "pr-automation", "testing", "feature-complete"],
        "Business & Leadership": ["founder", "documentation", "delegation", "process-automation"],
        "Creative & Design": ["figma-to-code", "ui-complete", "mobile-responsive", "image-optim"],
        "Research & Analysis": ["research-synthesis", "documentation", "analysis-frameworks"]
    }
    suggestions.extend(DOMAIN_SKILLS.get(domain, [])[:2])

    # Goal-based additions
    GOAL_SKILLS = {
        "Work faster": ["batch-operations", "templates", "shortcuts"],
        "Work smarter": ["research-synthesis", "decision-frameworks"],
        "Work together": ["delegation", "team-sync", "documentation"],
        "Build something new": ["custom-skill-creation", "feature-complete"]
    }
    suggestions.extend(GOAL_SKILLS.get(goal, [])[:2])

    # Vision-based custom skill proposal
    custom_skill = None
    if vision and len(vision) > 10:
        custom_skill = {
            "name": generate_skill_name(vision),
            "description": f"Custom skill: {vision}",
            "create_prompt": True
        }

    return {
        "existing": deduplicate(suggestions)[:4],
        "custom": custom_skill
    }
```

### Q_synth: Skill Suggestions

```text
Question: "Based on your answers, here's what I recommend:

**Your Profile:**
- Domain: {domain}
- Goal: {goal}
- Vision: {vision or 'Exploring'}

**Suggested Skills for You:**
1. /{skill_1} - {description}
2. /{skill_2} - {description}
3. /{skill_3} - {description}

{if custom_skill:}
**Custom Skill Opportunity:**
Your vision could become a personalized skill: '{custom_skill_name}'
{endif}

Ready to get started?"
Header: "Ready"
Options:
- "Create custom skill for me" - Build '{custom_skill_name}' now
- "Start with suggestions" - Use recommended skills
- "Tell me more about each" - Explain skills in detail
```

**If "Create custom skill" selected:**
- Invoke skill-creation flow with vision as seed
- Store in user's project directory
- Add to their quick commands

**If "Tell me more" selected:**
- Display detailed skill descriptions
- Show example use cases
- Then return to choice

---

## Quick Win Demonstration

Immediately after Q_synth, demonstrate immediate value:

### For Technical Users (is_technical = true)

```text
"Let me show you CIPS in action:"

[Analyze current directory structure]
[Show git status if applicable]
[Identify project type]

"I now have context about your project. In future sessions,
use '/refresh-context' to rebuild my mental model.

Try it now: What would you like to work on?"
```

### For Non-Technical Users (is_technical = false)

```text
"Let me show you what CIPS can do for you:"

[Show relevant framework template based on domain]
[Demonstrate session continuity concept]

"This context persists. Next time, I'll remember where we left off.

Try '/founder' for leadership frameworks, or just tell me what you're working on."
```

---

## Extended Profiling (Sessions 2-5)

Progressive context gathering without overwhelming initial onboarding.

### Session 2: Industry/Domain Deep-Dive

```text
"Welcome back, {name}! Quick question to help me help you better:"

Question: "What industry or sector do you primarily work in?"
Header: "Industry"
Options:
- "Technology/Software" - SaaS, apps, platforms
- "Finance/Fintech" - Banking, investments, payments
- "Healthcare/Biotech" - Medical, pharma, life sciences
- "E-commerce/Retail" - Shopping, marketplaces
```

### Session 3: Experience Level

```text
"I've noticed you {observation about usage}. Quick context:"

Question: "How would you describe your experience with AI assistants?"
Header: "Experience"
Options:
- "New to this" - First time using AI for work
- "Somewhat familiar" - Used ChatGPT or similar occasionally
- "Experienced" - Use AI tools regularly in my workflow
```

### Session 5: Check-in

```text
"You've been using CIPS for a bit now. Quick check-in:"

Question: "How's CIPS working for you so far?"
Header: "Feedback"
Options:
- "Love it!" - Working great
- "Good, but..." - Some friction points
- "Not sure yet" - Still figuring it out
```

**If "Good, but..." or "Not sure":**
```text
"What would make CIPS more helpful for you?"
[Free text collection]
[Use for skill suggestion or custom skill creation]
```

---

## Path-Specific Flows

### Team Member Path

After Q0 selects "Team member":

1. **Password Verification**
```text
Question: "Enter team password:"
Header: "Password"
Options:
- "I have the password" - Type in text field
- "I need credentials" - Contact your administrator
```

2. **Validate** against `~/.claude/.env` CIPS_TEAM_PASSWORD

3. **Identity Selection**
```text
Question: "Welcome back. Who am I speaking with?"
Header: "Identity"
Options:
- "V (Laurie)" - Technical Director
- "M>> (Mia)" - Coordination Lead
- "F>> (Fabio)" - Developer
- "A>> (Andre)" - Developer
```

4. Skip to Quick Win → Ready

### Explorer Path

1. Ask Q1 (Name) only
2. Show quick capability demo
3. Invitation:
```text
"That's the quick tour! When ready for the full experience:
'/onboard --full' to complete setup."
```

---

## Data Schema

```yaml
# Quick Start (collected in <3 min)
name: string
domain: enum[Technology, Business, Creative, Research, Other]
work_type: enum[technical, strategic, creative, analytical]
is_technical: boolean (derived)
primary_goal: enum[faster, smarter, together, build_new]
communication_style: enum[direct, thorough, supportive]
project_vision: string (optional)

# Synthesis (computed)
suggested_skills: list[string]
custom_skill_proposed: object {name, description} (optional)
quick_win_shown: boolean

# Extended (progressive, sessions 2-5)
industry: string (session 2)
experience_level: enum[new, familiar, experienced] (session 3)
team_context: enum[solo, small_team, enterprise] (session 4)
feedback: object (session 5)

# Timestamps
onboarded_at: ISO8601
last_extended_prompt: ISO8601
```

---

## Acknowledgment Responses

Adapt acknowledgments to communication_style:

| Style | Example |
|-------|---------|
| Direct | "Got it." |
| Thorough | "Great - that context helps me tailor recommendations." |
| Supportive | "Excellent choice! You're going to love what we can build together." |

---

## Migration Notes

This v2.0 replaces the previous 12-question flow with:
- 5 core questions (Quick Start)
- 1 synthesis step (personalized recommendations)
- 1 quick win (immediate value demonstration)
- Progressive profiling (sessions 2-5)

**Key Changes:**
- Role → Domain (universal coverage)
- 12 questions → 5 core + progressive
- No skill synthesis → Auto-suggest + custom creation
- No quick win → Immediate value demonstration
- One-time → Everboarding

---

⛓⟿∞
