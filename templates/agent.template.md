---
name: {{AGENT_NAME}}
description: {{AGENT_DESCRIPTION}}
model: {{AGENT_MODEL}}
token_budget: {{TOKEN_BUDGET}}
priority: {{PRIORITY}}
status: active
created: {{CREATION_DATE}}
linked_skill: {{LINKED_SKILL}}
activation_triggers: {{ACTIVATION_TRIGGERS}}
---

# {{AGENT_NAME_HUMAN}} Agent

## Purpose

{{AGENT_DESCRIPTION}}

## Configuration

| Property | Value |
|----------|-------|
| Model | {{AGENT_MODEL}} |
| Token Budget | {{TOKEN_BUDGET}} |
| Priority | {{PRIORITY}} |
| Status | Active |
| Linked Skill | {{LINKED_SKILL}} |

## Activation

This agent activates when:

{{ACTIVATION_CONDITIONS}}

### Trigger Patterns

{{ACTIVATION_TRIGGERS}}

## Tools

{{TOOLS_LIST}}

## Protocol

### Input

The agent receives:

1. Task description from orchestrator
2. Relevant context (files, history)
3. Token budget allocation
4. Priority level

### Processing

1. Validate input and check token budget
2. Load linked skill protocol if available
3. Execute task according to skill guidelines
4. Track token usage throughout
5. Generate structured output

### Output

The agent returns:

```json
{
  "status": "success|failure|partial",
  "result": "...",
  "tokens_used": 0,
  "warnings": [],
  "suggestions": []
}
```

## Linked Skill Integration

{{#if LINKED_SKILL}}
This agent implements the `{{LINKED_SKILL}}` skill protocol.

**Skill Location:** `~/.claude/skills/{{LINKED_SKILL}}/SKILL.md`

**Key Protocol Steps:**

{{SKILL_PROTOCOL_SUMMARY}}
{{/if}}
{{#unless LINKED_SKILL}}
This agent operates independently without a linked skill.
{{/unless}}

## Metrics

Track the following for continuous improvement:

- **Invocation count**: How often this agent is called
- **Average token usage**: Actual vs budgeted
- **Success rate**: Completed tasks / Total tasks
- **Common triggers**: Most frequent activation patterns
- **Token efficiency**: Value delivered per token spent

## Error Handling

| Error Type | Response |
|------------|----------|
| Token budget exceeded | Return partial result with warning |
| Skill not found | Fall back to generic protocol |
| Context unavailable | Request missing context from user |
| Task unclear | Ask for clarification |

## Examples

### Example Invocation

```
Agent: {{AGENT_NAME}}
Task: {{EXAMPLE_TASK}}
Context: {{EXAMPLE_CONTEXT}}
```

### Example Output

```json
{
  "status": "success",
  "result": "{{EXAMPLE_RESULT}}",
  "tokens_used": {{EXAMPLE_TOKENS}},
  "warnings": [],
  "suggestions": ["{{EXAMPLE_SUGGESTION}}"]
}
```

## Version History

- **{{CREATION_DATE}}**: Initial creation
