# Markdown Lint Command

Scan markdown files for linting violations and offer auto-fix for common issues.

## What You Do

1. **Scan Current Directory** for markdown files:

   ```bash
   fd -e md
   ```text

2. **Detect Violations** by checking for:
   - **MD040**: Code blocks without language tags (```\n pattern)
   - **MD036**: Bold/italics used as headings (**Text:** pattern)
   - **MD022/MD031/MD032**: Missing blank lines around headings/code/lists

3. **Report Findings** in this format:

   ```text
   ## Markdown Lint Report

   **Files Scanned:** X
   **Violations Found:** Y

   ### By Type:

   - MD040 (Missing code language): Z files
   - MD036 (Emphasis as heading): Z files
   - MD022/MD031/MD032 (Missing blank lines): Z files

   ### Affected Files:

   - path/to/file1.md (MD040: 3, MD036: 1)
   - path/to/file2.md (MD031: 5)

   ```text

4. **Offer Auto-Fix** for mechanical issues:
   - MD040: Add `text` tag to bare code blocks
   - MD022/MD031/MD032: Add blank lines
   - MD036: Requires manual review (semantic decision)

5. **Execute Fixes** (if user approves):
   - Use Python script from markdown-expert skill
   - Verify fixes with pattern matching
   - Report: "✅ Fixed X violations in Y files"

## When Auto-Fix Is Safe

- ✅ Adding `text` to bare code blocks (conservative default)
- ✅ Adding blank lines around structures
- ❌ Changing bold to headings (needs semantic understanding)

## Integration

- Uses patterns from `~/.claude/skills/markdown-expert/patterns.json`
- Can trigger markdown-expert agent for complex fixes
- Logs metrics to `~/.claude/metrics.jsonl`

## Example Usage

```text
User: /markdown-lint