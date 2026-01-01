---
name: markdown-expert
description: Enforce markdown linting standards for all documentation to prevent common AI mistakes like missing code language tags, emphasis as headings, and missing blank lines
auto_generated: true
generation_date: 2025-01-14
status: Active
---

# Markdown Expert

**Auto-generated skill from pattern analysis of 297 markdown linting violations**

## Problem

AI models frequently generate markdown with systematic errors:

- **MD040** (62 instances): Missing language specifiers on code blocks
- **MD036** (5 instances): Using bold/italics instead of proper headings
- **MD022/MD031/MD032** (78 instances): Missing blank lines around structures
- **MD013** (27 instances): Lines exceeding 120 characters
- **MD012** (8 instances): Multiple consecutive blank lines
- **MD024** (2 instances): Duplicate sibling headings
- **Token Impact**: 1,000-3,000 tokens wasted per documentation update (re-work, confusion, inconsistency)

## Root Cause Analysis

### Why AI Models Make These Mistakes

1. **Structural vs Visual Thinking**
   - AI prioritizes visual appearance over structural correctness
   - Bold text "looks like" a heading
   - Code blocks "look fine" without language specifiers

2. **Continuous Flow Bias**
   - Training on prose leads to continuous writing
   - Blank lines feel like "interrupting the flow"
   - Semantic connection (heading → related code) overcomes syntax rules

3. **Context Confusion**
   - Pseudo-code, examples, outputs blur the line
   - "What language is `@Agent-Name: task`?" → defaults to bare fence
   - Metadata at document start feels like "not really a heading"

4. **Training Data Quality**
   - Much markdown in training data violates linting rules
   - GitHub READMEs have inconsistent standards
   - AI learns "common patterns" not "correct patterns"

## Solution Rules

### ALWAYS Specify Language on Code Blocks (MD040 Fix)

```markdown
❌ WRONG:
\```
npm install
\```

✅ CORRECT:
\```bash
npm install
\```
```text

### Language Tag Reference

- Shell commands → `bash` or `shell`
- Plain text/examples → `text`
- Outputs/logs → `console` or `text`
- Agent invocations → `text`
- JSON config → `json`
- YAML config → `yaml`
- TypeScript → `typescript` or `ts`
- JavaScript → `javascript` or `js`
- Python → `python`
- Pseudocode → `text`

### NEVER Use Bold/Italics for Headings (MD036 Fix)

```markdown
❌ WRONG:
**Date:** 2025-01-14
**Status:** PRODUCTION READY

✅ CORRECT (Option A - Not a heading):
Date: 2025-01-14
Status: PRODUCTION READY

✅ CORRECT (Option B - Proper heading):
## Metadata
Date: 2025-01-14
Status: PRODUCTION READY
```text

### ALWAYS Add Blank Lines Around Structures (MD022, MD031, MD032 Fix)

```markdown
❌ WRONG:
### Heading
Content here
- List item
---
## Next Section

✅ CORRECT:
### Heading

Content here

- List item

---

## Next Section
```text

### Specific Rules

- Blank line BEFORE heading (unless it's the first line)
- Blank line AFTER heading
- Blank line BEFORE horizontal rule (`---`)
- Blank line AFTER horizontal rule (`---`)
- Blank line BEFORE code block
- Blank line AFTER code block
- Blank line BEFORE list
- Blank line AFTER list

### Common Mistake - Horizontal Rules

Horizontal rules (`---`) are treated as heading-level structures and require blank lines before and after:

```markdown
❌ WRONG - Metadata after horizontal rule:
Content here
---
**Last Updated**: 2025-01-14
**Status**: Active

✅ CORRECT - Blank lines around rule:
Content here

---

Last Updated: 2025-01-14
Status: Active
```text

**Note:** Avoid using bold for metadata that resembles headings (MD036). Use plain text or proper headings instead.

### NEVER Exceed Line Length Limit (MD013 Fix)

Keep lines under 120 characters for readability and diff clarity:

```markdown
❌ WRONG - Long skill description:
- **skill-name**: This is a very long description that exceeds the 120 character limit and makes the markdown difficult to read in diffs and on narrow screens

✅ CORRECT - Wrapped with continuation:
- **skill-name**: This is a very long description that exceeds the 120 character limit and makes the
  markdown difficult to read in diffs and on narrow screens
```text

### Wrapping Strategies

1. **List items**: Use indented continuation (2 spaces)
2. **Code blocks**: Split long commands with `\` (bash) or refactor
3. **Prose**: Natural sentence breaks

### NEVER Use Multiple Consecutive Blank Lines (MD012 Fix)

Use only ONE blank line for spacing:

```markdown
❌ WRONG - Multiple blank lines:
### Section 1


- Content here

✅ CORRECT - Single blank line:
### Section 1

- Content here
```text

### NEVER Duplicate Heading Text (MD024 Fix)

Make sibling headings unique to avoid confusion:

```markdown
❌ WRONG - Duplicate headings under same parent:
## Features
### Example
(content)
### Example    ← Duplicate!
(content)

✅ CORRECT - Unique descriptive headings:
## Features
### Example: Basic Usage
(content)
### Example: Advanced Configuration
(content)
```text

**Note:** Headings with the same text are allowed if they're under DIFFERENT parent sections.

## Activation Triggers

- When writing new markdown files
- When editing existing markdown files
- When user says "write documentation" or "create README"
- Automatic during commit prep (if markdown changes detected)

## Verification Checklist

Before submitting any markdown:

- [ ] All code blocks have language tags (MD040)
- [ ] No bold/italics used as headings (MD036)
- [ ] Blank lines around all headings (MD022)
- [ ] Blank lines around all horizontal rules (MD022)
- [ ] Blank lines around all code blocks (MD031)
- [ ] Blank lines around all lists (MD032)
- [ ] No bold used for metadata that looks like headings (MD036)
- [ ] All lines under 120 characters (MD013)
- [ ] No multiple consecutive blank lines (MD012)
- [ ] No duplicate sibling headings (MD024)

## Integration

- Works with `.markdownlint.json` configuration
- Complements `EFFICIENCY_CHECKLIST.md` (prevents re-work)
- Can be enforced via pre-commit hooks
- Integrates with markdown-expert agent (auto-fix)

## Token Budget

**Prevention**: 0 tokens (rules enforced during generation)
**Fix**: 100-500 tokens per file (if violations found)
**Savings**: 1,000-3,000 tokens per documentation update (no re-work)

## Metrics

Track via `metrics.jsonl`:

```bash
{
  "event": "markdown_lint_check",
  "timestamp": <epoch_ms>,
  "violations_found": <count>,
  "violations_fixed": <count>,
  "files_checked": <count>
}
```text

## Priority

**High** - Documentation quality directly impacts team productivity and token efficiency

---

**Generated by:** Self-Improvement Engine v2.0
**Pattern Source:** Analysis of 297 markdown linting errors across 8 files
**Learning**: AI models systematically make predictable markdown errors - codify prevention
