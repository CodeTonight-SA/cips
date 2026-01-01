# Agent Auto-Creator - Reference Material

**Parent:** [SKILL.md](./SKILL.md)

---

## Pattern Detection Scripts

### Phase 1: Monitor Workflow Patterns

```bash
# Count repeated command patterns
tail -n 1000 ~/.claude/history.jsonl | \
jq -s '[.[] | select(.content | test("git status.*git diff.*git commit"))] | length'

# If count >= 3 → Suggest "pr-workflow" agent
```

### Token Waste Signals

```bash
# Detect expensive repeated operations
rg "node_modules" ~/.claude/history.jsonl -c
# If count > 0 → Suggest "dependency-guardian" agent
```

### Phase 2: Validation Criteria

```json
{
  "pattern": "pr-workflow",
  "occurrences": 5,
  "avgTokenCost": 15000,
  "consistency": 0.85,
  "automatable": true,
  "suggestAgent": true
}
```

### Phase 3: ROI Calculation

```text
Agent Creation Cost: ~800 tokens (template fill + validation)
Manual Approach Cost: [avgTokenCost] × [expectedFrequency]
Sessions to Break Even: 800 / [tokensSavedPerUse]

If breakEvenSessions <= 3 → Strong candidate for agent
```

---

## Agent Generation Workflow

### Step 1: Pattern Analysis

```bash
PATTERN_NAME="pr-workflow"
OCCURRENCES=$(count_pattern_occurrences "$PATTERN_NAME")
STEPS=$(extract_common_steps "$PATTERN_NAME")
TOOLS=$(identify_required_tools "$PATTERN_NAME")
AVG_TOKENS=$(calculate_avg_token_cost "$PATTERN_NAME")
```

### Step 2: Model Selection

```bash
if [[ $AVG_TOKENS -lt 2000 ]] && [[ $COMPLEXITY == "low" ]]; then
  MODEL="haiku"  # Fast, lightweight tasks
elif [[ $REASONING == "complex" ]]; then
  MODEL="sonnet"  # Complex reasoning needed
else
  MODEL="haiku"  # Default to cost-effective
fi
```

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
# Check YAML frontmatter
~/.claude/scripts/create-agents.sh validate

# Log creation to metrics
echo "{
  \"event\": \"agent_created\",
  \"timestamp\": $(date +%s000),
  \"agentName\": \"$PATTERN_NAME\",
  \"createdBy\": \"agent-auto-creator\",
  \"expectedSavings\": $EXPECTED_SAVINGS
}" >> ~/.claude/metrics.jsonl
```

---

## Pattern Library

### 1. PR Workflow Pattern

```json
{
  "name": "pr-workflow",
  "signature": "git status.*git diff.*git commit.*git push",
  "minOccurrences": 3,
  "tools": ["Bash", "Read", "Glob"],
  "model": "sonnet",
  "tokenBudget": 2000,
  "priority": "high"
}
```

### 2. Dependency Read Pattern

```json
{
  "name": "dependency-guardian",
  "signature": "node_modules|venv|\\.next",
  "minOccurrences": 1,
  "tools": ["Glob", "Grep", "Read"],
  "model": "haiku",
  "tokenBudget": 1000,
  "priority": "critical"
}
```

### 3. File Re-Read Pattern

```json
{
  "name": "file-read-optimizer",
  "signature": "Read.*same_file.*Read.*same_file",
  "minOccurrences": 2,
  "tools": ["Read", "Bash"],
  "model": "haiku",
  "tokenBudget": 1000,
  "priority": "critical"
}
```

### 4. History Search Pattern

```json
{
  "name": "history-mining",
  "signature": "have we.*before|search.*history|past.*solution",
  "minOccurrences": 3,
  "tools": ["Bash", "Read"],
  "model": "haiku",
  "tokenBudget": 2000,
  "priority": "high"
}
```

---

## Integration with optim.sh

### Detection Phase (Layer 1)

```bash
detect_agent_patterns() {
  local patterns=$(scan_conversation_patterns)
  for pattern in $patterns; do
    local occurrences=$(count_occurrences "$pattern")
    local token_cost=$(calculate_token_cost "$pattern")
    if [[ $occurrences -ge 3 ]] && [[ $token_cost -gt 5000 ]]; then
      log "Agent candidate detected: $pattern"
      echo "$pattern" >> "${CLAUDE_DIR}/detected_agent_patterns.txt"
    fi
  done
}
```

### Generation Phase (Layer 2)

```bash
generate_agents_from_patterns() {
  while read -r pattern; do
    log "Generating agent for pattern: $pattern"
    invoke_skill "agent-auto-creator" "$pattern"
  done < "${CLAUDE_DIR}/detected_agent_patterns.txt"
}
```

### Optimization Phase (Layer 3 - Recursive)

```bash
optimize_agent_creator() {
  log "Optimizing agent-auto-creator recursively"
  local creation_metrics=$(jq -s '[.[] | select(.event == "agent_created")]' \
    ~/.claude/metrics.jsonl)
  local meta_patterns=$(detect_meta_patterns "$creation_metrics")
  if [ -n "$meta_patterns" ]; then
    enhance_pattern_detection "$meta_patterns"
    regenerate_skill "agent-auto-creator"
  fi
}
```

---

## Token Economics

### Creation Cost

```text
Pattern Detection: 500 tokens (amortized)
Agent Spec Generation: 200 tokens
Template Fill: 100 tokens
Validation: 100 tokens
Registration: 100 tokens
Total: ~1000 tokens per agent
```

### Runtime Savings

```text
Context Refresh Agent: 5-8k tokens saved per session
Dependency Guardian: 50k+ tokens saved per violation
File Read Optimizer: 5-10k tokens saved per session
PR Workflow: 1-2k tokens saved per PR
Average: 15k-20k tokens saved per agent per session
```

### ROI Calculation

```text
Investment: 1k tokens to create agent
Return: 15k+ tokens saved per session
Break-even: <1 session
Long-term ROI: 1500%+ over 10 sessions
```

---

## Advanced Features

### A/B Testing

```bash
create_agent "pr-workflow-v1" --model haiku
create_agent "pr-workflow-v2" --model sonnet
ab_test_agents "pr-workflow-v1" "pr-workflow-v2" --split 50
promote_winning_variant
```

### Continuous Learning

```bash
log_agent_feedback() {
  echo "{
    \"event\": \"agent_feedback\",
    \"agentName\": \"$1\",
    \"success\": $2,
    \"tokensSaved\": $3
  }" >> metrics.jsonl
}

if should_regenerate_agent "$AGENT_NAME"; then
  analyze_usage_patterns "$AGENT_NAME"
  generate_improved_version "$AGENT_NAME"
fi
```

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
ROI: 1300% over 10 uses

[Create Agent] [Not Now] [Never for This Pattern]
```

### Silent Mode

```json
{
  "agentAutoCreator": {
    "mode": "autonomous",
    "minOccurrences": 3,
    "minTokenSavings": 5000,
    "notifyUser": false
  }
}
```
