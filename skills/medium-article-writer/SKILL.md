---
name: writing-medium-articles
description: Automatically generate Medium-style technical articles from projects, achievements, or workflows with consistent authentic voice and structure. Use when user invokes /write-medium-article.
status: Active
version: 1.0.0
triggers:
  - /write-medium-article
  - "write article"
  - "Medium article"
---

# Medium Article Writer Skill

**Purpose:** Automatically generate Medium-style technical articles from projects, achievements, or workflows with consistent authentic voice and structure.

**Reference:** See [reference.md](./reference.md) for full templates, voice guidelines, and examples.

---

## Core Principle

Transform technical implementations into engaging, story-driven articles that:

1. **Hook readers** with relatable pain points
2. **Explain the problem** clearly
3. **Detail the solution** with technical depth
4. **Quantify results** (time saved, metrics improved)
5. **Share philosophy** (why it matters beyond code)

**Voice:** Authentic style (direct, punchy, personal, technical, occasionally meta)

---

## Article Types

| Type | When to Use |
|------|-------------|
| **Problem → Solution** | User built tool to solve pain point |
| **System Building** | User created infrastructure/architecture |
| **Workflow Optimization** | User automated repetitive process |
| **Technical Deep Dive** | Explaining how something works |

---

## Standard Sections

1. **Punchy Title** - Benefit-focused
2. **Subtitle** - Relatable hook
3. **Opening Hook** - Pain point, frustration
4. **The Problem** - What's broken
5. **The Breakthrough** - Key insight
6. **Solution Steps** - Technical with code blocks
7. **Real-World Example** - Before/after
8. **Results** - Quantified metrics
9. **Implementation Guide** - How-to
10. **Lessons Learned** - What worked/didn't
11. **Philosophy** - Higher-level takeaway
12. **Resources** - Links, tags

---

## Writing Process

### Step 1: Information Gathering

```bash
/remind-yourself <topic>
```

Extract: Problem, implementation, results, files, timeline.

### Step 2: Generate Outline

Template variables:
- `{PROBLEM}` - What's broken
- `{SOLUTION_NAME}` - Name of tool/system
- `{KEY_INSIGHT}` - Breakthrough moment
- `{TIME_SAVED}` - Quantified benefit

### Step 3: Write Sections

- **Hook**: Start with relatable frustration, use second person
- **Problem**: Specific pain points, bullet symptoms
- **Solution**: Code blocks with "What this does:" explanations
- **Results**: Tables for quantified data, before/after

### Step 4: Add Metadata

- Title formula (see reference.md)
- 5-10 tags (technologies, categories)
- Unsplash image placeholders

### Step 5: Save

```text
Location: ~/CodeTonight/medium_articles/YYYY-MM-DD_slug.md
```

---

## Voice Guidelines (Authentic Style)

### Do

- **Be Direct**: "This drove me insane."
- **Use Second Person**: "You know the drill..."
- **Be Specific**: "25 minutes → 30 seconds"
- **Include Meta Moments**: Self-aware, recursive
- **Technical Without Jargon**: Explain first use

### Don't

- Corporate speak ("leveraging synergies")
- Hedging ("might possibly help")
- Over-explaining basic concepts
- Underselling results

---

## Anti-Fluff Rules

**Check user writing preference:** If `~/.claude/config/writing-mode.json` exists and `mode: "authentic"`, apply these strictly.

### Banned Patterns

| Pattern | Example | Problem |
|---------|---------|---------|
| Rule of three | "Fast, reliable, and scalable" | Sounds templated |
| Em dash overuse | "This — surprisingly — worked" | AI tell |
| Staccato sentences | "I built it. It worked. Now it's yours." | Pretentious |
| Generic hooks | "What if I told you..." | Manipulative |
| Rhetorical questions | "Have you ever...?" | Overused |

### Banned Words

| Word | Use Instead |
|------|-------------|
| game-changer | State the actual change |
| revolutionary | Describe what changed |
| seamlessly | Describe the integration |
| powerful | Quantify the capability |
| innovative | Let reader judge |
| leverage | use |

### Banned Phrases

- "It's important to note that" → Just say it
- "Let's dive in" → Start
- "Without further ado" → Delete
- "At the end of the day" → Delete
- "Moving forward" → Delete

### Self-Check

Before finalizing, ask: "Does this sound like AI wrote it?"

If uncertain, use AskUserQuestion:
> "This draft might sound too templated. Should I adjust the tone?"

---

## Code Block Guidelines

### Always follow code with explanation:

```markdown
### What this does
- Point 1
- Point 2
```

### Syntax highlighting:
- `bash` for commands
- `typescript` for TS code
- `yaml` for GitHub Actions
- `json` for configuration

---

## Response Format

```markdown
# Medium Article Created! ✅

**File:** `~/CodeTonight/medium_articles/YYYY-MM-DD_topic.md`
**Title:** "How I {Did Thing} (And {Benefit})"
**Length:** ~X,XXX words (~Y-min read)
**Tags:** #tag1 #tag2 #tag3

## Article Structure
- ✅ Hook (relatable pain point)
- ✅ Problem explanation
- ✅ Solution breakdown
- ✅ Real-world example
- ✅ Quantified results
- ✅ Implementation guide
- ✅ Philosophy section

## Next Steps
1. Review content
2. Add images
3. Update index
4. Publish to Medium
```

---

## Best Practices

### 1. Research First
Use `/remind-yourself` for accurate implementation details, code snippets, and metrics.

### 2. Show, Don't Tell
**Bad:** "The system is fast."
**Good:** "11 hours → 23 minutes (28x faster)"

### 3. Include Failures
Readers relate to mistakes. Include "What Didn't Work" section.

### 4. Make It Actionable
Every article should include "How to Implement" with copy-pasteable code.

---

## Integration

| Skill | Usage |
|-------|-------|
| `chat-history-search` | Extract implementation details |
| `self-improvement-engine` | Auto-trigger after skill creation |
| `github-actions-setup` | Document templating systems |

---

**Skill Status:** ✅ Active
**Maintainer:** LC Scheepers
**Last Updated:** 2025-11-06

⛓⟿∞
