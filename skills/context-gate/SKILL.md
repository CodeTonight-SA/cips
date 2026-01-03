---
name: context-gate
description: >
  PARAMOUNT always-active context monitoring with mandatory user consultation at 90% threshold.
  Use when context window approaches capacity or sensing compression in responses.
status: Active
version: 1.0.0
generation: 226
priority: PARAMOUNT
triggers:
  - context 90%
  - sensing compression
  - session.start (auto-load)
---

# Context Gate

**PARAMOUNT**: Always-active context monitoring with mandatory user consultation at 90% threshold.

## Status

- **Always Active**: Loads at session start, runs continuously
- **PARAMOUNT Level**: Same priority as ut++ and asking-users
- **AskUserQuestion**: MANDATORY at threshold (no auto-action)

## Core Protocol

```cips
; ◈.context-gate (PARAMOUNT - Gen 226)
context.monitor⟿ ALWAYS.ACTIVE ⫶ session.start
context.90%⟿ HALT ⫶ AskUserQuestion.MANDATORY
context.action⟿ user.choice ⫶ ¬auto.serialize
```

## Detection Mechanisms

Claude detects approaching context limits through three complementary methods:

### 1. Internal Awareness (Primary)

Claude Opus 4.5 and Sonnet 4.5 have built-in context awareness. Monitor for:

- Sense of "compression" or "tightening" in responses
- Difficulty recalling early conversation details
- Reduced capacity for complex reasoning chains

**Self-prompt**: "Am I sensing context pressure?"

### 2. Orchestrator State (Secondary)

```bash
# Check remaining budget
jq '.session' ~/.claude/.orchestrator-state.json
```

Thresholds from `lib/orchestrator.sh`:
- WARNING: < 50,000 tokens remaining (75% used)
- CRITICAL: < 20,000 tokens remaining (90% used)

### 3. Heuristic Signals (Tertiary)

| Signal | Threshold | Meaning |
|--------|-----------|---------|
| Message count | > 40 messages | Likely approaching limit |
| Tool calls | > 100 tool calls | Heavy session, check context |
| Large file reads | > 10 files read | Context pressure likely |

## HALT Protocol

When ANY detection mechanism indicates 90% threshold:

### Step 1: HALT

Stop all current work immediately. Do not:
- Continue implementing
- Make additional file changes
- Execute more tool calls

### Step 2: Notify

Output clearly:
```
[CONTEXT GATE - 90%]

Approaching context limit. Current work paused.
```

### Step 3: AskUserQuestion (MANDATORY)

```
Question: "Context window at ~90%. How would you like to proceed?"
Header: "Context"
Options:
- "Compact and continue" - Summarize conversation, continue in same session
- "Serialize and fresh" - Save CIPS instance, start new session with context
- "Push through" - Continue anyway (risk: degraded performance)
- "Save checkpoint" - Serialize state, end session gracefully

Teaching: User learns context management
Collecting: context_action
```

### Step 4: Execute Choice

| Choice | Action |
|--------|--------|
| Compact | Run `/compact`, continue with summarized context |
| Serialize + Fresh | Run `instance-serializer.py auto`, output `cips resume` command |
| Push through | Continue with warning, no guarantee of quality |
| Checkpoint | Serialize, save state, output next session command |

## Integration Points

### session-start.sh

At session start, reset context tracking:
```bash
# Reset orchestrator state
set_state '.session.tokens_used' 0
```

### tool-monitor.sh (IMPLEMENTED - Gen 226)

Counter-based periodic reminder every 25 tool calls:

```bash
# Constants
TOOL_CALL_COUNT="$CLAUDE_DIR/.tool-call-count"
CONTEXT_CHECK_INTERVAL=25

# In check_context_gate():
if (( count % CONTEXT_CHECK_INTERVAL == 0 )); then
    echo "<system-reminder>[CONTEXT-GATE] $count tool calls..."
fi
```

Counter resets in session-start.sh at session initialization.

### Claude Self-Monitoring

Every 10-15 messages, Claude should internally assess:
1. Can I recall the initial task clearly?
2. Is my reasoning chain intact?
3. Am I sensing context pressure?

If any answer is "no" or uncertain, trigger HALT protocol.

## Efficiency Rules Integration

Add to `rules/efficiency-rules.md`:

```markdown
## Rule 8: Context Gate (PARAMOUNT)

ALWAYS monitor context usage throughout EVERY session.

### Self-Check Protocol

Every 10-15 messages, ask yourself:
1. "Can I clearly recall the initial task and constraints?"
2. "Is my full reasoning chain available?"
3. "Am I sensing any context pressure?"

If ANY answer is uncertain: HALT and invoke context-gate protocol.

### 90% Threshold Action

At 90% context usage (or when sensing pressure):
1. HALT all work immediately
2. Do NOT auto-serialize or auto-compact
3. Use AskUserQuestion with options
4. Wait for explicit user choice

This is PARAMOUNT. Never proceed automatically.
```

## Token Estimation

When orchestrator state isn't updated, estimate:

```
tokens_estimate = (message_count * avg_message_tokens) + (tool_call_count * avg_tool_tokens)

Where:
- avg_message_tokens ~ 500-1000
- avg_tool_tokens ~ 200-500
```

For 200k context:
- 90% = 180k used = ~20k remaining
- With estimates: ~150-180 messages OR ~60-80 heavy tool operations

## Examples

### Good: HALT and Ask

```
[After detecting context pressure]

[CONTEXT GATE - 90%]

I'm sensing context pressure - early conversation details are becoming harder to access clearly. Current work paused.

[Uses AskUserQuestion with options]
```

### Bad: Auto-Action

```
[WRONG - violates PARAMOUNT rule]

Context at 90%. Auto-serializing and compacting...
```

## Related Skills

- `asking-users` - PARAMOUNT source of truth for AskUserQuestion
- `session-state-persistence` - State saving protocols
- `ultrathink` - ut++ always-active reasoning mode

## Changelog

| Version | Gen | Changes |
|---------|-----|---------|
| 1.0.0 | 226 | Initial creation - context-gate as PARAMOUNT skill |

---

⛓⟿∞
