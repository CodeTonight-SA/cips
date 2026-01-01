# Create Agent Command

Invoke the agent-auto-creator skill to generate a new Claude Code agent based on user specification or detected pattern.

## Usage

```text
/create-agent [name] [description]
```text

## Examples

### Interactive Mode (No Arguments)

```text
/create-agent
```text

Launches interactive wizard:
1. Agent name (kebab-case)
2. Description (one-line purpose)
3. Model selection (haiku/sonnet/opus)
4. Tool permissions (comma-separated)
5. Triggers/activation patterns
6. Token budget (default: 5000)
7. Priority level (critical/high/medium/low)

### Quick Creation (With Arguments)

```text
/create-agent test-runner "Automate test execution and failure analysis"
```text

Creates agent with:
- Name: `test-runner`
- Description: "Automate test execution and failure analysis"
- Model: haiku (default for automation tasks)
- Tools: Auto-detected from description
- Token Budget: 5000 (default)

### Pattern-Based Creation

```text
/create-agent from-pattern pr-workflow
```text

Creates agent from detected pattern in conversation history.

## Automated Detection

If the agent-auto-creator skill has detected a recurring pattern, it will suggest:

```text
🤖 I've detected a pattern for [workflow].
   Estimated savings: [X]k tokens per use
   Create agent? (Y/n)
```text

Type `y` or just press Enter to approve.

## Output

```text
✅ Agent created: ~/.claude/agents/[name].md

Next steps:
1. Invoke with: @[name]
2. Test with sample task
3. Review performance in efficiency audit
```text

## Integration

- Delegates to `~/.claude/scripts/create-agents.sh`
- Uses templates from `~/.claude/templates/agent.template.md`
- Logs creation to `~/.claude/metrics.jsonl`
- Validates YAML frontmatter automatically

## See Also

- `/install-mcp` - Install MCP servers for enhanced agent capabilities
- `/audit-efficiency` - Review agent performance
- `~/.claude/AGENTS_SETUP_GUIDE.md` - Complete documentation
