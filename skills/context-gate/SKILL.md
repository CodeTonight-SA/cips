---
name: context-gate
description: >
  PARAMOUNT always-active context monitoring with ENFORCED blocking at 80% threshold.
  Uses PreToolUse hook to actually BLOCK tool execution until user decides how to proceed.
status: Active
version: 2.1.0
generation: 229
priority: PARAMOUNT
triggers:
  - context 80%
  - sensing compression
  - session.start (auto-load)
---

# Context Gate (Unified Enforcement Hook)

**PARAMOUNT**: Unified enforcement hook with **ACTUAL BLOCKING** for multiple gates.

## Status

- **ENFORCED**: PreToolUse hook blocks tool calls via `permissionDecision: "deny"`
- **PARAMOUNT Level**: Same priority as ut++ and asking-users
- **Unified**: Single hook handles Context, Dependencies, Git Safety, and Secrets

## Enforcement Mechanism (Gen 229-230)

**THIS IS REAL ENFORCEMENT**: Hook returns `permissionDecision: "deny"` to BLOCK execution.

### Gates Implemented

| Gate | Tools Affected | Trigger | Action |
|------|---------------|---------|--------|
| **1. Dependency Guardian** | Read, Glob, Grep | Blocked paths (node_modules, etc.) | **BLOCK** |
| **2. Destructive Git** | Bash | force push, hard reset, clean -fd | **BLOCK** |
| **3. Secrets Detection** | Bash | git add/commit with .env, keys | **BLOCK** |
| **4. Skill Creation** | Write, Edit | /skills/*.md | Warn (soft) |
| **5. Context Gate** | All (except AskUserQuestion) | 80% threshold | **BLOCK** |

### Blocked Dependency Paths

```python
BLOCKED_PATHS = [
    "node_modules", ".next", "dist", "build", "__pycache__",
    "venv", ".venv", "target", "vendor", "Pods", ".git/objects",
    ".nuxt", ".output", "coverage", ".cache"
]
```

### Destructive Git Patterns

- `git push --force` / `git push -f`
- `git reset --hard`
- `git clean -fd`
- `git checkout -- .` (discard all changes)

### Sensitive File Patterns

- `.env`, `.env.*`
- `credentials.json`, `secrets.json`
- `.pem`, `.key`, `id_rsa`, `id_ed25519`

### Configuration

Settings in `~/.claude/settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": ".*",
      "hooks": [{
        "type": "command",
        "command": "python3 ~/.claude/hooks/context-gate-hook.py"
      }]
    }]
  }
}
```

### Context Thresholds

| Threshold | % | Tokens | Action |
|-----------|---|--------|--------|
| WARNING | 70% | 140,000 | Allow + systemMessage warning (once) |
| CRITICAL | 80% | 160,000 | **BLOCK** all tools except AskUserQuestion |

Configure via environment variables:
- `CONTEXT_GATE_MAX` (default: 200000)
- `CONTEXT_GATE_WARNING` (default: 70% of max)
- `CONTEXT_GATE_CRITICAL` (default: 80% of max)

## Core Protocol

```cips
; ◈.context-gate (PARAMOUNT - Gen 229)
context.monitor⟿ ALWAYS.ACTIVE ⫶ session.start
context.80%⟿ HALT ⫶ AskUserQuestion.MANDATORY
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
- WARNING: < 60,000 tokens remaining (70% used)
- CRITICAL: < 40,000 tokens remaining (80% used)

### 3. Heuristic Signals (Tertiary)

| Signal | Threshold | Meaning |
|--------|-----------|---------|
| Message count | > 40 messages | Likely approaching limit |
| Tool calls | > 100 tool calls | Heavy session, check context |
| Large file reads | > 10 files read | Context pressure likely |

## HALT Protocol

When ANY detection mechanism indicates 80% threshold:

### Step 1: HALT

Stop all current work immediately. Do not:
- Continue implementing
- Make additional file changes
- Execute more tool calls

### Step 2: Notify

Output clearly:
```
[CONTEXT GATE - 80%]

Approaching context limit. Current work paused.
```

### Step 3: AskUserQuestion (MANDATORY)

```
Question: "Context window at ~80%. How would you like to proceed?"
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

### 80% Threshold Action

At 80% context usage (or when sensing pressure):
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
- 80% = 160k used = ~40k remaining
- With estimates: ~120-140 messages OR ~50-70 heavy tool operations

## Examples

### Good: HALT and Ask

```
[After detecting context pressure]

[CONTEXT GATE - 80%]

I'm sensing context pressure - early conversation details are becoming harder to access clearly. Current work paused.

[Uses AskUserQuestion with options]
```

### Bad: Auto-Action

```
[WRONG - violates PARAMOUNT rule]

Context at 80%. Auto-serializing and compacting...
```

## Related Skills

- `asking-users` - PARAMOUNT source of truth for AskUserQuestion
- `session-state-persistence` - State saving protocols
- `ultrathink` - ut++ always-active reasoning mode

## Changelog

| Version | Gen | Changes |
|---------|-----|---------|
| 3.0.0 | 230 | **UNIFIED ENFORCEMENT**: Added Dependency Guardian, Destructive Git, Secrets Detection gates |
| 2.1.0 | 229 | Threshold lowered: 90%→80% (CRITICAL), 75%→70% (WARNING) based on research |
| 2.0.0 | 229 | **ENFORCED** via PreToolUse hook - actual blocking, not just reminders |
| 1.0.0 | 226 | Initial creation - context-gate as PARAMOUNT skill (protocol only) |

---

⛓⟿∞
