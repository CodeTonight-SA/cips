# Agent Auto-Creator Skill

**Recursive meta-skill for automated Claude Code agent generation**

## Quick Start

```bash
# Detect patterns from conversation history
./skills/agent-auto-creator/detect-patterns.sh

# Generate agent from detected pattern
~/.claude/scripts/create-agents.sh create-from-spec ./detected_patterns/pr-workflow.json

# Or use interactive mode
~/.claude/scripts/create-agents.sh create
```text

## What It Does

1. **Monitors** conversation patterns for repeated workflows
2. **Detects** when token savings >5k per session
3. **Generates** agent Markdown files automatically
4. **Self-improves** by analyzing its own performance (recursive)

## Integration

- **Self-Improvement Engine:** Hooks into `optim.sh` Layer 2
- **Pattern Detection:** Uses `patterns.json` for signature matching
- **Metrics Tracking:** Logs to `~/.claude/metrics.jsonl`
- **Agent Creation:** Delegates to `create-agents.sh` script

## Files

- `SKILL.md` - Complete skill documentation
- `patterns.json` - Pattern signatures and detection rules
- `README.md` - This file

## ROI

- **Investment:** 1k tokens to create agent
- **Return:** 15k+ tokens saved per session
- **Break-even:** <1 session
- **Long-term:** 1500%+ ROI over 10 sessions

## See Also

- [AGENTS_SETUP_PLAN.md](../../AGENTS_SETUP_PLAN.md) - Complete technical spec
- [create-agents.sh](../../scripts/create-agents.sh) - Agent generation script
- [optim.sh](../../optim.sh) - Self-improvement engine
