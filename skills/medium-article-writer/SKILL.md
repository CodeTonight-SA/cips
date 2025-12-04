---
name: medium-article-writer
description: Automatically generate Medium-style technical articles from projects, achievements, or workflows with consistent V>> voice and structure.
---

# Medium Article Writer Skill

**Purpose:** Automatically generate Medium-style technical articles from projects, achievements, or workflows with consistent V>> voice and structure.

**Activation:** When user types `/write-medium-article <topic>` or says "write a Medium article about..."

---

## Core Principle

Transform technical implementations into engaging, story-driven articles that:

1. **Hook readers** with relatable pain points
2. **Explain the problem** clearly
3. **Detail the solution** with technical depth
4. **Quantify results** (time saved, metrics improved)
5. **Share philosophy** (why it matters beyond code)

**Voice:** V>> style (direct, punchy, personal, technical, occasionally meta)

---

## Article Structure Template

### Standard Sections (In Order)

```markdown
# [Punchy Title with Benefit]

## [Subtitle: Relatable Hook]

---

![Hero Image](unsplash-link)
*Photo by Photographer on Unsplash*

---

[Opening Hook - 2-3 paragraphs]
- Relatable pain point
- Personal frustration
- "There had to be a better way"

---

## The Problem: [Clear Problem Statement]

[3-5 paragraphs explaining:]
- What's broken/inefficient
- Why current solutions fail
- Impact on productivity/workflow
- Bulleted symptom list

---

## The Breakthrough: [The Key Insight]

[2-3 paragraphs:]
- The moment of discovery
- The "aha!" realization
- What made this solution different

---

## [Step 1: First Major Component]

### [Subsection if needed]

[Technical details with code blocks]

```language
code examples
```text

### What this does:
- Bullet point explanations

---

## [Step 2: Second Major Component]

[Continue pattern...]

---

## Real-World Example: [Concrete Use Case]

### Before (Manual Way):
[Step-by-step old workflow]
Total time: X minutes

### After (Automated):
[Step-by-step new workflow]
Total time: Y seconds

**Time saved:** Z

---

## The Architecture: How It Works

[System diagram in text/ascii if helpful]

### Components:
1. Component A - Purpose
2. Component B - Purpose

### Data Flow:
```text
Input → Process 1 → Process 2 → Output
```text

---

## The Results: Quantified

### Time Savings
| Task | Before | After | Savings |
|------|--------|-------|---------|
| Task 1 | X min | Y sec | Z min |

**Monthly total:** ~N hours saved

### [Other Metrics]
- Consistency: Before X%, After Y%
- Error rate: Before X%, After 0%

---

## How to Implement This Yourself

### Step 1: [First Step]
```bash
commands
```text

### Step 2: [Second Step]
[Instructions]

---

## Lessons Learned

### ✅ What Worked
1. **Thing 1** - Why it worked
2. **Thing 2** - Why it worked

### ❌ What Didn't Work
1. **Mistake 1** - What broke, how to fix
2. **Mistake 2** - What broke, how to fix

---

## The Philosophy: [Higher-Level Takeaway]

[2-3 paragraphs on why this matters beyond the specific tool]

### The principles:
- Principle 1
- Principle 2

---

## Future Enhancements

### Planned:
1. Feature A - What it will do
2. Feature B - What it will do

---

## Wrapping Up: [Memorable Closing]

[Call back to opening hook]
[Summarize impact]
[Encourage readers to try it]

---

## Resources

- [Link 1](url)
- [Link 2](url)
- GitHub: [repo link]

---

**Tags:** #tag1 #tag2 #tag3

---

*[Call to action for sharing/following]*

🚀
```text

---

## Writing Process

### Step 1: Information Gathering

### Search chat history:
```bash
/remind-yourself <topic>
```text

### Extract:
- What problem was being solved?
- What was the implementation?
- What were the results?
- What files were created/modified?
- What was the timeline?

---

### Step 2: Identify Article Type

### Types

### 1. Problem → Solution
- User built tool to solve pain point
- Example: Terminal text editing, GitHub Actions templates

### 2. System Building
- User created infrastructure/architecture
- Example: Claude Code memory system

### 3. Workflow Optimization
- User automated repetitive process
- Example: This article series

### 4. Technical Deep Dive
- Explaining how something works
- Example: ZLE region-aware functions

---

### Step 3: Generate Outline

### Template Variables:
- `{PROBLEM}` - What's broken/inefficient
- `{SOLUTION_NAME}` - Name of the tool/system
- `{KEY_INSIGHT}` - The breakthrough moment
- `{TIME_SAVED}` - Quantified benefit
- `{TECH_STACK}` - Technologies used

### Example Outline:
```markdown
# How I {SOLUTION_NAME}

## {HOOK}

## The Problem: {PROBLEM}
## The Breakthrough: {KEY_INSIGHT}
## Step 1: {COMPONENT_1}
## Step 2: {COMPONENT_2}
## Real-World Example
## The Results: {TIME_SAVED}
## How to Implement
## Philosophy: {WHY_IT_MATTERS}
## Resources
```text

---

### Step 4: Write Sections

### Hook (Opening 2-3 paragraphs):
- Start with relatable frustration
- Use second person ("You know the drill...")
- Build tension
- End with hope ("There had to be a better way")

### Problem Section:
- Be specific about pain points
- Use lists/bullets for symptoms
- Include "Before" metrics if available
- Make reader nod along ("Yes! I have this problem too!")

### Solution Sections:
- Code blocks with syntax highlighting hints
- "What this does:" explanations after code
- Break complex concepts into steps
- Use analogies for hard concepts

### Results Section:
- Tables for quantified data
- Before/After comparisons
- Concrete numbers (not "faster", but "11 hours → 23 minutes")

### Philosophy Section:
- Zoom out to principles
- Why this matters beyond the specific tool
- Connect to broader themes (DRY, automation, leverage)

---

### Step 5: Add Metadata

### Title Formulas

### Problem → Solution:
- "How I {SOLUTION} (And {BENEFIT})"
- "The Day I {BREAKTHROUGH}"

### Time-Based:
- "How I Saved {TIME} by {ACTION}"
- "From {X HOURS} to {Y MINUTES}: {SOLUTION}"

### Punchy:
- "{TOOL} Doesn't Have to Be {PAIN POINT}"
- "Stop {BAD PRACTICE}. Start {GOOD PRACTICE}."

**Subtitle:** Always frame as relatable moment/realization

---

### Tags (5-10):
Extract from content:
- Technology names (github-actions, terminal, claude)
- Categories (automation, productivity, developer-tools)
- Languages (typescript, python, bash)
- Concepts (ci-cd, workflow, efficiency)

---

### Images:
Use Unsplash placeholder format:
```markdown
![Alt text](https://images.unsplash.com/photo-XXXXXX)
*Photo by Photographer on Unsplash*
```text

### Suggest search terms based on article topic:
- Automation → gears, circuits, robots
- Terminal → code, command line, matrix
- AI → brain, neural network, circuits
- Speed → rocket, lightning, race car

---

### Step 6: Save to Canonical Location

### File naming convention:
```text
YYYY-MM-DD_topic-slug.md
```text

### Example:
```text
2025-11-06_terminal_text_editing.md
2025-11-06_claude_code_memory.md
2025-11-06_github_actions_templates.md
```text

### Location:
```text
/Users/lauriescheepers/CodeTonight/medium_articles/
```text

---

### Step 7: Cross-Linking

### If part of series:
- Add to master index (`00_*.md`)
- Link to related articles
- Update README.md

### Example:
```markdown
## Related Articles

- [Terminal Text Editing](./2025-11-06_terminal_text_editing.md)
- [GitHub Actions Templates](./2025-11-06_github_actions_templates.md)
```text

---

## Voice Guidelines (V>> Style)

### ✅ Do:

### 1. Be Direct
- "This drove me insane."
- "There had to be a better way."
- Not: "I found this somewhat frustrating."

### 2. Use Second Person
- "You know the drill..."
- "You've been there."
- Not: "One might experience..."

### 3. Show Frustration
- "😤"
- "WTF"
- "Like some kind of Neanderthal"

### 4. Be Specific
- "25 minutes → 30 seconds"
- Not: "much faster"

### 5. Include Meta Moments
- "Claude wrote this article about building its own memory"
- "The tool that built tools that build tools"

### 6. Technical Without Jargon
- Explain acronyms first use
- Code blocks with explanations
- "What this does:" sections

---

### ❌ Don't:

### 1. Corporate Speak
- Not: "leveraging synergies"
- Yes: "making tools that make tools"

### 2. Hedging
- Not: "This might possibly help"
- Yes: "This saved 20 hours"

### 3. Over-Explaining
- Assume reader is technical
- Don't explain `npm install`
- Do explain novel concepts (ZLE, region-aware)

### 4. Underselling
- Not: "minor improvement"
- Yes: "game changer" (if true)

---

## Code Block Guidelines

### Syntax Highlighting Hints

```markdown
```bash
commands here
```text

```typescript
TypeScript code
```text

```yaml
GitHub Actions
```text

```json
Configuration
```text
```text

---

### Code Explanations

### Always follow code with:
```markdown
### What this does
- Point 1
- Point 2
```text

### Or:
```markdown
### Breakdown
- `variable` - What it represents
- `function()` - What it does
```text

---

## Integration with Other Skills

### Use `chat-history-search`

Before writing, search for:
- Implementation details
- Code snippets
- Timeline (when was it built?)
- Results (metrics, before/after)

```bash
/remind-yourself <topic>
```text

---

### Use `github-actions-setup` Pattern

When documenting templating systems:
1. Show global template location
2. Show per-project customization
3. Show one-command deployment

---

### Use `terminal` Patterns

When documenting keybindings:
1. Show before/after table
2. Show shortcut reference
3. Link to quick reference docs

---

## Slash Command Usage

### `/write-medium-article <topic>`

### Examples:
```bash
/write-medium-article terminal optimization
/write-medium-article claude code memory system
/write-medium-article github actions templates
```text

### Process:
1. Search chat history for `<topic>`
2. Extract implementation details
3. Generate outline
4. Write sections
5. Add metadata (title, tags, images)
6. Save to `/Users/lauriescheepers/CodeTonight/medium_articles/YYYY-MM-DD_slug.md`
7. Ask: "Update master index? (y/n)"

---

### `/write-series-overview <theme>`

### Example:
```bash
/write-series-overview developer productivity automation
```text

### Process:
1. Find all articles matching theme
2. Create table of contents
3. Write connecting narrative
4. Add cross-links
5. Save as `00_<theme-slug>.md`

---

## Response Format

When article is complete:

```markdown
# Medium Article Created! ✅

**File:** `~/CodeTonight/medium_articles/YYYY-MM-DD_topic.md`
**Title:** "How I {Did Thing} (And {Benefit})"
**Length:** ~X,XXX words (~Y-min read)
**Tags:** #tag1 #tag2 #tag3

## Article Structure
- ✅ Hook (relatable pain point)
- ✅ Problem explanation
- ✅ Solution breakdown (N steps)
- ✅ Real-world example
- ✅ Quantified results
- ✅ Implementation guide
- ✅ Philosophy section
- ✅ Future enhancements

## Next Steps
1. **Review content** - Check technical accuracy
2. **Add images** - Replace Unsplash placeholders with actual links
3. **Update index** - Add to `00_*.md` if part of series
4. **Publish to Medium** - Copy content to Medium editor

**Estimated reading time:** Y minutes
**Estimated value:** Based on similar articles, ~500-2000 views

Ready to publish! 🚀
```text

---

## Best Practices

### 1. Research First, Write Second

**Don't write from memory.** Use `/remind-yourself` to get accurate:
- Implementation details
- Code snippets
- Timeline
- Results/metrics

---

### 2. Show, Don't Just Tell

### Bad:
"The system is fast."

### Good:
"11 hours → 23 minutes (28x faster)"

---

### 3. Include Failures

### Readers relate to mistakes

```markdown
### ❌ What Didn't Work

**1. Over-Automation**

Early version auto-committed without asking. Users lost control.

**Fix:** Always ask before destructive actions.
```text

---

### 4. Make It Actionable

### Every article should include:
- "How to Implement This Yourself" section
- Step-by-step instructions
- Copy-pasteable code/commands

---

### 5. Update Master Index

### If article is part of series:
```markdown
# Add to 00_series-name.md:
| Article | Problem | Time Saved |
|---------|---------|------------|
| [New Article](./link.md) | X | Y |
```text

---

## Future Enhancements

### 1. Auto-Tag Generation

### Analyze content and suggest tags:
- Extract technology names
- Identify categories
- Suggest related topics

---

### 2. SEO Optimization

### Check:
- Title length (60 chars for search preview)
- Subtitle length (120 chars)
- Tag relevance
- Image alt text

---

### 3. Reading Time Calculation

```text
words / 200 = minutes
```text

Add to article metadata.

---

### 4. Cross-Article Recommendations

### At end of article:
```markdown
## You Might Also Like

- [Article 1](link) - If you liked X
- [Article 2](link) - For more on Y
```text

Auto-generate based on tags/topics.

---

### 5. Draft Mode

```bash
/write-medium-article --draft terminal optimization
```text

Saves to `medium_articles/drafts/` for review before finalizing.

---

## Changelog

**v1.0** (2025-11-06) - Initial skill creation
- V>> voice guidelines
- Article structure template
- `/write-medium-article` command
- Integration with chat-history-search

---

**Skill Status:** ✅ Active
**Maintainer:** LC Scheepers
**Last Updated:** 2025-11-06
