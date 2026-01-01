# Check Last Plan

Load and display the most recently cached plan from a previous session.

## Usage

```text
/check-last-plan
```

## Behavior

1. Read `~/.claude/cache/last-plan.json`
2. Display plan summary (id, cached time, project)
3. Show plan content
4. If plan exists for current project: offer to continue or start fresh
5. If plan exists for different project: show info, ask if relevant

## Output Format

```text
=== Cached Plan ===
ID: {plan_id}
Project: {project_path}
Cached: {cached_at} ({relative time})

{plan_content_summary}

Continue with this plan?
```

## No Plan Found

```text
No cached plan found for current project.

Use plan mode to create a new plan, or check if a plan exists for another project:
- Plans directory: ~/.claude/plans/
```

## Integration

- **Skill**: check-last-plan (`skills/check-last-plan/SKILL.md`)
- **Agent**: plan-persistence-agent (`agents/plan-persistence-agent.md`)
- **Library**: `lib/plan-persistence.sh`

## Related Commands

- Enter plan mode to create new plans
- `/refresh-context` to rebuild mental model
