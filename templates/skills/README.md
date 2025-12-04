# Skill Templates

Templates for auto-generating new skills via the `self-improvement-engine` meta-skill.

## Files

### `SKILL.template.md`

Complete skill structure with placeholders for auto-generation.

### Usage:

```bash
# Via self-improvement-engine
/generate-skill <pattern-name>

# Manual (for reference)
cp SKILL.template.md ~/.claude/skills/new-skill/SKILL.md
# Replace all {{PLACEHOLDERS}}
```text

### Placeholders:
- `{{SKILL_NAME}}` - Kebab-case skill identifier (e.g., `file-caching`)
- `{{SKILL_TITLE}}` - Human-readable title (e.g., `File Caching Skill`)
- `{{PURPOSE_STATEMENT}}` - One sentence: what this skill does
- `{{TRIGGER_DESCRIPTION}}` - When to activate (for YAML frontmatter)
- `{{ACTIVATION_CONDITION}}` - Detailed activation conditions
- `{{CORE_PRINCIPLE_EXPLANATION}}` - Why this skill exists
- `{{TRIGGER_CONDITIONS_LIST}}` - Bulleted list of trigger scenarios
- `{{STEP_N_NAME}}` - Workflow step titles
- `{{STEP_N_DESCRIPTION}}` - Step explanations
- `{{STEP_N_COMMAND_EXAMPLE}}` - Code examples
- `{{INTEGRATION_NOTES}}` - How this skill works with others
- `{{RESPONSE_TEMPLATE}}` - Expected output format
- `{{ANTI_PATTERN_N}}` - What NOT to do
- `{{CORRECT_PATTERN_N}}` - Correct approach
- `{{TOKEN_BUDGET}}` - Target token usage (e.g., `<2000 tokens`)
- `{{OPTIMIZATION_TIPS}}` - Performance best practices
- `{{EXAMPLE_N_SCENARIO}}` - Real-world example scenarios
- `{{EXAMPLE_N_CODE}}` - Example code blocks
- `{{CREATION_DATE}}` - ISO date (e.g., `2025-11-06`)
- `{{MAINTAINER}}` - Author name
- `{{CHANGELOG_ENTRY_N}}` - Version history items

### `command.template.sh`
Bash wrapper for slash command integration (reference implementation).

**Note:** Actual slash commands in Claude Code are defined differently. This template is for documentation and manual command creation if needed.

### Placeholders:
- `{{SKILL_NAME}}` - Skill identifier
- `{{COMMAND_NAME}}` - Command name (e.g., `remind-yourself`)
- `{{COMMAND_DESCRIPTION}}` - What the command does
- `{{CREATION_DATE}}` - ISO date
- `{{COMMAND_LOGIC}}` - Custom command implementation
- `{{CUSTOM_COMMAND_LOGIC}}` - Additional logic for command

## Template Variables Reference

### Naming Conventions

### Skill Names (kebab-case):
- `file-caching`
- `command-aliasing`
- `error-recovery`

### Skill Titles (Title Case):
- `File Caching Skill`
- `Command Aliasing Skill`
- `Error Recovery Skill`

### Command Names (lowercase, hyphens):
- `cache-files`
- `create-alias`
- `recover-error`

### Token Budget Guidelines

| Complexity | Budget |
|------------|--------|
| Simple automation | <1000 tokens |
| Medium workflow | 1000-3000 tokens |
| Complex multi-step | 3000-5000 tokens |
| Never exceed | 10000 tokens |

### Skill Categories

Auto-detected by pattern type:

### Efficiency:
- Patterns: Repeated actions, redundant reads, slow operations
- Examples: `file-caching`, `batch-operations`

### Quality:
- Patterns: Errors, inconsistencies, violations
- Examples: `error-recovery`, `lint-enforcement`

### Automation:
- Patterns: Manual repetitive tasks, copy-paste workflows
- Examples: `command-aliasing`, `template-deployment`

### Knowledge:
- Patterns: Context loss, re-discovery, memory issues
- Examples: `chat-history-search`, `knowledge-graph`

## Auto-Generation Process

### 1. Pattern Detection
Self-improvement-engine scans `history.jsonl` for inefficiency signatures.

### 2. Template Selection
Based on pattern category, selects appropriate template.

### 3. Placeholder Filling
Extracts context from detected pattern:
- Skill name from pattern type
- Examples from actual occurrences
- Token budget from similar skills
- Integration notes from skill dependencies

### 4. Validation
Checks generated skill for:
- Valid YAML frontmatter
- No unfilled placeholders
- Reasonable token budget
- Clear trigger conditions

### 5. Deployment
- Save to `~/.claude/skills/<skill-name>/SKILL.md`
- Update `~/.claude/CLAUDE.md` Skills System section
- Create command reference (if applicable)
- Trigger Medium article generation

## Manual Customization

If auto-generated skill needs refinement:

```bash
# Edit generated skill
micro ~/.claude/skills/auto-generated-skill/SKILL.md

# Test trigger conditions
# (Use skill in real scenario to verify it activates)

# Update if needed
# Add examples, refine workflows, adjust token budget
```text

## Best Practices

### 1. Keep Templates Generic
Templates should work for 80% of use cases without modification.

### 2. Use Clear Placeholder Names
`{{TOKEN_BUDGET}}` is better than `{{TB}}` or `{{BUDGET}}`

### 3. Provide Examples in Comments
```markdown
<!-- Example: {{SKILL_NAME}} -> "file-caching" -->
```text

### 4. Version Templates
When updating templates, increment version in git commit message.

### 5. Test Generation
After template changes, test with `/generate-skill test-pattern` to verify no breakage.

## Changelog

**v1.0** (2025-11-06) - Initial template creation
- Created SKILL.template.md with 30+ placeholders
- Created command.template.sh for reference
- Defined placeholder naming conventions
- Established token budget guidelines

---

**Last Updated:** 2025-11-06
