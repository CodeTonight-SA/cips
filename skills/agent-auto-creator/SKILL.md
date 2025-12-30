---
name: creating-agents-automatically
description: Recursive meta-skill that detects workflow patterns and automatically generates Claude Code agent definitions. Use when user invokes /create-agent or patterns warrant new agent.
status: Active
version: 1.1.0
triggers:
  - /create-agent
  - "create agent"
  - workflow pattern detected
---

# Agent Auto-Creator Skill

**Purpose:** Recursive meta-skill that detects workflow patterns and automatically generates Claude Code agent definitions.

**Token Budget:** <5000 per generation

**Reference:** See [reference.md](./reference.md) for pattern detection scripts, agent generation workflow, pattern library, and token economics.

---

## Overview

The Agent Auto-Creator:

1. Monitors conversation patterns for repeated workflows
2. Detects when a dedicated agent would provide value
3. Automatically generates agent Markdown files with proper YAML frontmatter
4. Validates and registers new agents
5. **Self-improves:** Optimizes its own pattern detection algorithms

---

## Triggers

### Automatic

- Workflow pattern appears 3+ times (Rule of Three)
- Token waste >10k on repeated manual work
- Efficiency Auditor flags inefficiency pattern

### Manual

- User says "create agent for X"
- User invokes `/create-agent` command

---

## Pattern Detection

### Phase 1: Monitor Workflow Patterns

Track signals across conversation history:

| Signal Type | Example |
|-------------|---------|
| Repetition | `git status.*git diff.*git commit` 3+ times |
| Token Waste | Reading `node_modules/` multiple times |
| Manual Work | User performs 5+ step workflows regularly |

### Phase 2: Validate Pattern Stability

Before suggesting agent, verify:

1. **Frequency:** Pattern appears ≥3 times
2. **Consistency:** Steps remain similar across occurrences
3. **Token Cost:** Manual approach costs ≥5k tokens per occurrence
4. **Automation Potential:** Task can be codified in agent prompt

### Phase 3: Calculate ROI

```text
Agent Creation Cost: ~800 tokens
Manual Approach Cost: [avgTokenCost] × [expectedFrequency]
Sessions to Break Even: 800 / [tokensSavedPerUse]

If breakEvenSessions <= 3 → Strong candidate
```

---

## Agent Generation

### Step 1: Pattern Analysis

Extract pattern characteristics:
- Name (kebab-case)
- Required tools
- Average token cost
- Complexity level

### Step 2: Model Selection

| Condition | Model |
|-----------|-------|
| Low tokens (<2k) + low complexity | haiku |
| Complex reasoning needed | sonnet |
| Default | haiku |

### Step 3: Generate Agent File

```bash
~/.claude/scripts/create-agents.sh create \
  --name "$PATTERN_NAME" \
  --description "$DESCRIPTION" \
  --model "$MODEL" \
  --tools "$TOOLS" \
  --triggers "$TRIGGERS" \
  --token-budget "$TOKEN_BUDGET" \
  --priority "$PRIORITY"
```

### Step 4: Validate & Register

```bash
~/.claude/scripts/create-agents.sh validate
```

Log to `~/.claude/metrics.jsonl` for tracking.

---

## Built-In Patterns

| Pattern | Signature | Priority |
|---------|-----------|----------|
| pr-workflow | `git status.*git diff.*git commit.*git push` | high |
| dependency-guardian | `node_modules\|venv\|\.next` | critical |
| file-read-optimizer | `Read.*same_file.*Read.*same_file` | critical |
| history-mining | `have we.*before\|search.*history` | high |

---

## Token Economics

### Creation Cost

| Step | Tokens |
|------|--------|
| Pattern Detection | 500 (amortized) |
| Agent Spec Generation | 200 |
| Template Fill | 100 |
| Validation | 100 |
| Registration | 100 |
| **Total** | **~1000** |

### Runtime Savings (Per Agent)

| Agent | Savings |
|-------|---------|
| Context Refresh | 5-8k per session |
| Dependency Guardian | 50k+ per violation |
| File Read Optimizer | 5-10k per session |
| PR Workflow | 1-2k per PR |

### ROI

```text
Investment: 1k tokens to create agent
Return: 15k+ tokens saved per session
Break-even: <1 session
Long-term ROI: 1500%+ over 10 sessions
```

---

## Recursive Self-Improvement

The agent monitors its OWN performance:

1. **Accuracy:** If suggestions rejected >30% → Refine pattern detection
2. **Efficiency:** If creation takes >1000 tokens → Optimize template
3. **Coverage:** Detect new pattern types not in current rules

---

## User Interaction

### Suggestion Mode

```text
🤖 AGENT AUTO-CREATOR: Pattern Detected

I've noticed you've created PRs manually 5 times in the last 3 sessions,
spending ~15k tokens each time.

Would you like me to create a "pr-workflow" agent to automate this?

Expected savings: 13k tokens per PR (~87% reduction)
Break-even: 1 use

[Create Agent] [Not Now] [Never for This Pattern]
```

### Silent Mode

Configure in settings.json for autonomous operation with notification after creation.

---

## Anti-Patterns

| Don't | Why |
|-------|-----|
| Create agent for <3 occurrences | Not proven pattern yet |
| Skip ROI calculation | May create low-value agents |
| Ignore validation failures | Broken agents waste more tokens |
| Create without logging | Can't track effectiveness |

---

## Integration

| Component | Usage |
|-----------|-------|
| `optim.sh` | Hook into detect/generate phases |
| `metrics.jsonl` | Track creation and usage metrics |
| `self-improvement-engine` | Layer 3 recursive optimization |

---

**Skill Status:** ✅ Active
**Maintainer:** LC Scheepers
**Last Updated:** 2025-12-30

⛓⟿∞
