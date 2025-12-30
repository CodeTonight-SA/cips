# Enhanced Teaching Questions v2.0

Based on gap analysis. Reduces questions, expands coverage, adds skill synthesis.

```text
Design Principles:
1. Any user type should see themselves (universal coverage)
2. Collect rich context without overwhelming (progressive profiling)
3. Synthesize answers into actionable skill suggestions
4. Demonstrate value immediately (quick win)
5. Follow creating-wizards anti-pattern rules
```

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

---

### Q2: Domain (Universal Coverage)

**Teaches:** CIPS adapts to any domain
**Collects:** domain, work_type (derived)

```text
Question: "What's your primary domain?"
Header: "Domain"
Options:
- "Technology & Engineering" - Software, hardware, systems
- "Business & Operations" - Strategy, finance, management
- "Creative & Design" - Visual, content, UX
- "Research & Analysis" - Data, market, academic
```

**Domain Classification:**

| Domain | work_type | Default Skills |
|--------|-----------|----------------|
| Technology & Engineering | technical | code-quality, pr-automation, testing |
| Business & Operations | strategic | documentation, process-automation, delegation |
| Creative & Design | creative | figma-to-code, mobile-responsive, documentation |
| Research & Analysis | analytical | research-synthesis, documentation, analysis |
| Other (typed) | ask Q2b | Clarify |

**Q2b (if Other):**
```text
Question: "What does your work primarily involve?"
Header: "Work Type"
Options:
- "Building/creating things" - Technical or creative production
- "Analyzing/researching" - Investigation and synthesis
- "Coordinating/leading" - Team and project management
- "Communicating/selling" - Outreach and persuasion
```

---

### Q3: Goal (Universal)

**Teaches:** CIPS prioritises based on goals
**Collects:** primary_goal

```text
Question: "What's your primary goal with CIPS?"
Header: "Goal"
Options:
- "Work faster" - Automate repetitive tasks, reduce friction
- "Work smarter" - Better decisions, research, analysis
- "Work together" - Team alignment, delegation, consistency
- "Build something new" - Create a system, framework, or tool
```

**Goal → Skill Mapping:**

| Goal | Suggested Skills |
|------|------------------|
| Work faster | pr-automation, batch operations, templates |
| Work smarter | research-synthesis, decision-frameworks, analysis |
| Work together | delegation, documentation, team-sync |
| Build something new | custom skill creation, feature-complete |

---

### Q4: Communication Style

**Teaches:** CIPS adapts communication
**Collects:** communication_style

```text
Question: "How should I communicate with you?"
Header: "Style"
Options:
- "Direct and concise" - Just the answer, no fluff
- "Thorough and detailed" - Explain the reasoning
- "Supportive and patient" - Celebrate progress, be encouraging
```

---

### Q5: Vision + Quick Win

**Teaches:** CIPS builds custom capabilities
**Collects:** project_vision, quick_win_shown

```text
Question: "What would you like to accomplish with CIPS? (e.g., 'automate my reporting', 'build a competitor tracker', 'streamline code reviews')"
Header: "Vision"
Options:
- "Show me what's possible" - Demonstrate capabilities first
- "I'm still figuring it out" - Explore together
```

**Implementation:**
- If user types vision → Store and use for skill synthesis
- If "Show me what's possible" → Quick win demonstration
- If "Still figuring it out" → Guided discovery

---

## Skill Synthesis (After Q5)

**Teaches:** CIPS can create custom skills for your specific needs
**Collects:** suggested_skills, custom_skill_request

### Synthesis Logic

```python
def synthesize_skills(answers):
    suggestions = []

    # Domain-based suggestions
    if domain == "Technology & Engineering":
        suggestions += ["code-quality", "pr-automation", "testing"]
    elif domain == "Business & Operations":
        suggestions += ["documentation", "founder", "delegation"]
    elif domain == "Creative & Design":
        suggestions += ["figma-to-code", "mobile-responsive", "ui-complete"]
    elif domain == "Research & Analysis":
        suggestions += ["research-synthesis", "documentation"]

    # Goal-based additions
    if goal == "Work faster":
        suggestions += ["batch-operations", "templates"]
    elif goal == "Build something new":
        suggestions += ["custom-skill-creation"]

    # Vision-based custom skill
    if project_vision and is_specific(project_vision):
        custom_skill = propose_custom_skill(project_vision)
        suggestions.insert(0, custom_skill)

    return suggestions[:5]  # Top 5
```

### Q_synth: Skill Suggestions

```text
Question: "Based on your answers, here's what I recommend:

**Suggested Skills:**
{skill_1} - {description}
{skill_2} - {description}
{skill_3} - {description}

**Custom Skill Opportunity:**
Your vision '{project_vision}' could become a custom skill.
Shall I create it?"

Header: "Skills"
Options:
- "Create custom skill for me" - Let's build {custom_skill_name}
- "Just use existing skills" - Start with recommendations
- "Tell me more first" - Explain each skill
```

---

## Quick Win Demonstration

Immediately after Q5 or Q_synth, demonstrate value:

### For Technical Users

```text
"Let me show you something useful. Here's a quick analysis of your current directory:"

[Run: tree -L 2 | head -20]
[Run: git status --short (if git repo)]

"I now have context about your project. In future sessions, I'll remember this.
Try '/refresh-context' to rebuild my mental model anytime."
```

### For Non-Technical Users

```text
"Let me show you something useful. Based on your domain ({domain}), here's a sample framework I can help you build:"

[Show relevant template based on domain]

"This is the kind of structure CIPS can help you maintain.
Try '/founder' to access leadership frameworks."
```

### For Explorers

```text
"Here's a quick tour of what CIPS can do:

1. **Session Continuity** - I remember across conversations
2. **44 Skills** - Specialized capabilities that activate when needed
3. **Custom Skills** - I can learn YOUR patterns and create new skills

Want to see a specific capability in action?"
```

---

## Extended Profiling (Progressive, Session 2-5)

### Session 2 Prompt

```text
"I noticed you're working on {detected_project_type}.
Would you like me to suggest skills specifically for this?"
```

### Session 3 Prompt

```text
"You've used CIPS {n} times now. Based on your patterns:

Skills you might like:
- {unused_skill_1} - {relevance}
- {unused_skill_2} - {relevance}

Want to explore any of these?"
```

### Session 5 Check-in

```text
"Quick check-in: How's CIPS working for you?

- What's helping most?
- What's missing or confusing?
- Any workflow you'd like automated?"

[Collect feedback for improvement]
```

---

## Data Schema (Enhanced)

```yaml
# Core (Quick Start)
name: string
domain: enum (technology, business, creative, research, other)
work_type: enum (technical, strategic, creative, analytical, other)
primary_goal: enum (faster, smarter, together, build_new)
communication_style: enum (direct, thorough, supportive)
project_vision: string (optional, free-text)

# Derived
is_technical: boolean (domain == technology || work_type == technical)
suggested_skills: list[string]
custom_skill_proposed: string (optional)

# Extended (Progressive)
industry: string (collected session 2)
experience_level: enum (beginner, intermediate, expert)
team_context: enum (solo, small_team, enterprise)
existing_tools: list[string]
feedback: object
```

---

## Comparison: Old vs New

| Aspect | Old | New |
|--------|-----|-----|
| Questions | 12+ | 5 core + progressive |
| Role coverage | 4 roles | Universal (domain-based) |
| Skill synthesis | None | Auto-suggest + custom creation |
| Quick win | None | Immediate demonstration |
| Profiling | One-time | Progressive (sessions 2-5) |
| Time | ~5 min | <3 min core |

---

## Migration Path

1. **Phase 1:** Implement new Q2 (domain) replacing old role system
2. **Phase 2:** Add Q_synth (skill synthesis) after Q5
3. **Phase 3:** Implement quick win demonstrations
4. **Phase 4:** Add progressive profiling hooks
5. **Phase 5:** Build custom skill creation during onboarding

---

⛓⟿∞
