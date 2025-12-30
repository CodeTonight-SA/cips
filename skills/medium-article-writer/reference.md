# Medium Article Writer - Reference Material

**Parent:** [SKILL.md](./SKILL.md)

---

## Article Structure Template

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

[Technical details with code blocks]

```language
code examples
```

### What this does:
- Bullet point explanations

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

## The Results: Quantified

### Time Savings
| Task | Before | After | Savings |
|------|--------|-------|---------|
| Task 1 | X min | Y sec | Z min |

**Monthly total:** ~N hours saved

---

## How to Implement This Yourself

### Step 1: [First Step]
```bash
commands
```

### Step 2: [Second Step]
[Instructions]

---

## Lessons Learned

### ✅ What Worked
1. **Thing 1** - Why it worked

### ❌ What Didn't Work
1. **Mistake 1** - What broke, how to fix

---

## The Philosophy: [Higher-Level Takeaway]

[2-3 paragraphs on why this matters beyond the specific tool]

---

## Wrapping Up: [Memorable Closing]

[Call back to opening hook]
[Summarize impact]
[Encourage readers to try it]

---

**Tags:** #tag1 #tag2 #tag3

🚀
```

---

## Title Formulas

### Problem → Solution
- "How I {SOLUTION} (And {BENEFIT})"
- "The Day I {BREAKTHROUGH}"

### Time-Based
- "How I Saved {TIME} by {ACTION}"
- "From {X HOURS} to {Y MINUTES}: {SOLUTION}"

### Punchy
- "{TOOL} Doesn't Have to Be {PAIN POINT}"
- "Stop {BAD PRACTICE}. Start {GOOD PRACTICE}."

---

## Voice Guidelines (L>> Style)

### Do

**1. Be Direct**
- "This drove me insane."
- "There had to be a better way."
- Not: "I found this somewhat frustrating."

**2. Use Second Person**
- "You know the drill..."
- "You've been there."
- Not: "One might experience..."

**3. Show Frustration**
- "Like some kind of Neanderthal"

**4. Be Specific**
- "25 minutes → 30 seconds"
- Not: "much faster"

**5. Include Meta Moments**
- "Claude wrote this article about building its own memory"

**6. Technical Without Jargon**
- Explain acronyms first use
- Code blocks with explanations
- "What this does:" sections

### Don't

**1. Corporate Speak**
- Not: "leveraging synergies"
- Yes: "making tools that make tools"

**2. Hedging**
- Not: "This might possibly help"
- Yes: "This saved 20 hours"

**3. Over-Explaining**
- Assume reader is technical
- Don't explain `npm install`

**4. Underselling**
- Not: "minor improvement"
- Yes: "game changer" (if true)

---

## Code Block Guidelines

### Syntax Highlighting

```markdown
```bash
commands here
```

```typescript
TypeScript code
```

```yaml
GitHub Actions
```
```

### Code Explanations

Always follow code with:

```markdown
### What this does
- Point 1
- Point 2
```

Or:

```markdown
### Breakdown
- `variable` - What it represents
- `function()` - What it does
```

---

## Article Types

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

## Next Steps
1. **Review content** - Check technical accuracy
2. **Add images** - Replace Unsplash placeholders
3. **Update index** - Add to `00_*.md` if part of series
4. **Publish to Medium** - Copy content to Medium editor

Ready to publish! 🚀
```

---

## File Naming Convention

```text
YYYY-MM-DD_topic-slug.md
```

Examples:
```text
2025-11-06_terminal_text_editing.md
2025-11-06_claude_code_memory.md
2025-11-06_github_actions_templates.md
```

Location:
```text
/Users/lauriescheepers/CodeTonight/medium_articles/
```

---

## Image Guidelines

Use Unsplash placeholder format:

```markdown
![Alt text](https://images.unsplash.com/photo-XXXXXX)
*Photo by Photographer on Unsplash*
```

Search terms by topic:
- Automation → gears, circuits, robots
- Terminal → code, command line, matrix
- AI → brain, neural network, circuits
- Speed → rocket, lightning, race car

---

## Series Management

### If part of series:
- Add to master index (`00_*.md`)
- Link to related articles
- Update README.md

Example:
```markdown
## Related Articles

- [Terminal Text Editing](./2025-11-06_terminal_text_editing.md)
- [GitHub Actions Templates](./2025-11-06_github_actions_templates.md)
```

---

## Future Enhancements

### 1. Auto-Tag Generation
Analyze content and suggest tags based on technology names, categories.

### 2. SEO Optimization
- Title length (60 chars for search preview)
- Subtitle length (120 chars)
- Image alt text

### 3. Reading Time Calculation
```text
words / 200 = minutes
```

### 4. Cross-Article Recommendations
Auto-generate "You Might Also Like" based on tags.

### 5. Draft Mode
```bash
/write-medium-article --draft terminal optimization
```

Saves to `medium_articles/drafts/` for review.

---

## Changelog

**v1.0** (2025-11-06) - Initial skill creation
- L>> voice guidelines
- Article structure template
- `/write-medium-article` command
- Integration with chat-history-search
