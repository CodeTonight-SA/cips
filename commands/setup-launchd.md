# Setup Launchd

Create self-reloading macOS launchd agents with automatic plist validation.

## Usage

```text
/setup-launchd
```

## What It Does

1. Prompts for task details (script path, schedule, label)
2. Creates main agent plist with WakeFromSleep
3. Creates reload script with plutil validation
4. Creates watcher agent with WatchPaths
5. Loads both agents
6. Verifies installation

## Output

- `~/Library/LaunchAgents/com.{org}.{name}.plist` - Main scheduled agent
- `~/Library/LaunchAgents/com.{org}.{name}-watcher.plist` - Auto-reload watcher
- `{project}/scripts/reload-launchd.sh` - Validated reload script

## Example

```text
User: /setup-launchd
Claude: What script should run? → scripts/backup.py
Claude: What schedule? → Daily at 3am
Claude: What label? → com.myorg.backup
[Creates and loads agents]
```

## See Also

- Skill: `~/.claude/skills/launchd-automation/SKILL.md`
