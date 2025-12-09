# Agent Auto-Creator Skill

**Version:** 1.0.0
**Purpose:** Recursive meta-skill that detects workflow patterns and automatically generates Claude Code agent definitions
**Token Budget:** <5000 per generation
**Integration:** Self-improvement engine (optim.sh)

---

## Overview

The Agent Auto-Creator is a recursive meta-skill that:

1. Monitors conversation patterns for repeated workflows
2. Detects when a dedicated agent would provide value
3. Automatically generates agent Markdown files with proper YAML frontmatter
4. Validates and registers new agents
5. **Self-improves:** Optimizes its own pattern detection algorithms

---

## Triggers

### Automatic Triggers

- Workflow pattern appears 3+ times (Rule of Three)
- Token waste >10k on repeated manual work
- Efficiency Auditor flags inefficiency pattern
- Self-improvement engine detects opportunity

### Manual Triggers

- User says "create agent for X"
- User invokes `/create-agent` command
- Developer explicitly requests agent generation

---

## Pattern Detection Algorithm

### Phase 1: Monitor Workflow Patterns

Track these signals across conversation history:

### Repetition Signals

```bash
# Count repeated command patterns
tail -n 1000 ~/.claude/history.jsonl | \
jq -s '[.[] | select(.content | test("git status.*git diff.*git commit"))] | length'

# If count >= 3 → Suggest "pr-workflow" agent
```text

### Token Waste Signals:
```bash
# Detect expensive repeated operations
# Example: Reading node_modules/ multiple times
rg "node_modules" ~/.claude/history.jsonl -c

# If count > 0 → Suggest "dependency-guardian" agent
```text

### Manual Work Signals:
- User manually formats data across multiple sessions
- User repeatedly asks "how do I..." for same task
- User performs 5+ step workflows regularly

### Phase 2: Validate Pattern Stability

Before suggesting agent, verify:

1. **Frequency:** Pattern appears ≥3 times
2. **Consistency:** Steps remain similar across occurrences
3. **Token Cost:** Manual approach costs ≥5k tokens per occurrence
4. **Automation Potential:** Task can be codified in agent prompt

### Validation Criteria:
```json
{
  "pattern": "pr-workflow",
  "occurrences": 5,
  "avgTokenCost": 15000,
  "consistency": 0.85,
  "automatable": true,
  "suggestAgent": true
}
```text

### Phase 3: Calculate ROI

```text
Agent Creation Cost: ~800 tokens (template fill + validation)
Manual Approach Cost: [avgTokenCost] × [expectedFrequency]
Sessions to Break Even: 800 / [tokensSavedPerUse]

If breakEvenSessions <= 3 → Strong candidate for agent
```text

---

## Agent Generation Workflow

### Step 1: Pattern Analysis

```bash
# Extract pattern characteristics
PATTERN_NAME="pr-workflow"
OCCURRENCES=$(count_pattern_occurrences "$PATTERN_NAME")
STEPS=$(extract_common_steps "$PATTERN_NAME")
TOOLS=$(identify_required_tools "$PATTERN_NAME")
AVG_TOKENS=$(calculate_avg_token_cost "$PATTERN_NAME")
```text

### Step 2: Determine Agent Specifications

**Name:** Kebab-case derived from pattern
- Pattern: "Create Pull Request" → Agent: "pr-workflow"

**Description:** One-line summary of purpose
- Template: "Automates [workflow] to save [X] tokens per use"

### Model Selection:
```bash
if [[ $AVG_TOKENS -lt 2000 ]] && [[ $COMPLEXITY == "low" ]]; then
  MODEL="haiku"  # Fast, lightweight tasks
elif [[ $REASONING == "complex" ]]; then
  MODEL="sonnet"  # Complex reasoning needed
else
  MODEL="haiku"  # Default to cost-effective
fi
```text

**Tools:** Minimal necessary set
```bash
# Extract tools used in pattern
TOOLS=$(rg "tool_use" history | jq -r '.tool' | sort -u | tr '\n' ',')
```text

**Token Budget:** Based on historical usage
```bash
TOKEN_BUDGET=$(( AVG_TOKENS * 120 / 100 ))  # 20% buffer
```text

**Priority:** Based on frequency and impact
```bash
if [[ $OCCURRENCES -ge 10 ]] && [[ $AVG_TOKENS -gt 10000 ]]; then
  PRIORITY="critical"
elif [[ $OCCURRENCES -ge 5 ]]; then
  PRIORITY="high"
else
  PRIORITY="medium"
fi
```text

### Step 3: Generate Agent File

```bash
# Use create-agents.sh script
~/.claude/scripts/create-agents.sh create \
  --name "$PATTERN_NAME" \
  --description "$DESCRIPTION" \
  --model "$MODEL" \
  --tools "$TOOLS" \
  --triggers "$TRIGGERS" \
  --token-budget "$TOKEN_BUDGET" \
  --priority "$PRIORITY"
```text

### Step 4: Validate Generated Agent

```bash
# Check YAML frontmatter
~/.claude/scripts/create-agents.sh validate

# Test invocation (dry run)
test_agent_invocation "$PATTERN_NAME"
```text

### Step 5: Register & Log

```bash
# Log creation to metrics
echo "{
  \"event\": \"agent_created\",
  \"timestamp\": $(date +%s000),
  \"agentName\": \"$PATTERN_NAME\",
  \"createdBy\": \"agent-auto-creator\",
  \"expectedSavings\": $EXPECTED_SAVINGS
}" >> ~/.claude/metrics.jsonl

# Update documentation
update_agent_registry "$PATTERN_NAME"
```text

---

## Recursive Self-Improvement

### Meta-Pattern Detection

The agent-auto-creator monitors its OWN performance:

```bash
# Analyze agent creation patterns
tail -n 5000 ~/.claude/metrics.jsonl | \
jq -s '[.[] | select(.event == "agent_created")] |
  group_by(.createdBy) |
  map({
    creator: .[0].createdBy,
    count: length,
    avgSavings: (map(.expectedSavings) | add / length)
  })'
```text

### Self-Optimization Triggers

1. **Accuracy Improvement:**
   - If agent suggestions rejected >30% → Refine pattern detection
   - If agents created but unused → Improve ROI calculation

2. **Efficiency Improvement:**
   - If agent creation takes >1000 tokens → Optimize template
   - If validation fails frequently → Enhance pre-checks

3. **Coverage Expansion:**
   - Detect new pattern types not in current detection rules
   - Add new pattern signatures to patterns.json

### Recursive Enhancement

```bash
# Generate improved version of self
if detect_meta_pattern "agent-auto-creator-improvements"; then
  log "Recursive improvement detected"

  # Create enhanced agent-auto-creator-v2
  create_agent_from_meta_pattern

  # A/B test: Run both versions, compare performance
  compare_agent_versions "agent-auto-creator" "agent-auto-creator-v2"

  # If v2 performs better, promote to primary
  if [[ $V2_PERFORMANCE > $V1_PERFORMANCE ]]; then
    promote_agent_version "v2"
  fi
fi
```text

---

## Integration with Self-Improvement Engine

### Hook into optim.sh

### Detection Phase (Layer 1)

```bash
# In optim.sh detect() function
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
```text

### Generation Phase (Layer 2)

```bash
# In optim.sh generate() function
generate_agents_from_patterns() {
  while read -r pattern; do
    log "Generating agent for pattern: $pattern"

    # Delegate to agent-auto-creator skill
    invoke_skill "agent-auto-creator" "$pattern"

    # Or use create-agents.sh directly
    create_agent_from_detected_pattern "$pattern"
  done < "${CLAUDE_DIR}/detected_agent_patterns.txt"
}
```text

### Optimization Phase (Layer 3 - Recursive)

```bash
# In optim.sh optimize_self() function
optimize_agent_creator() {
  log "Optimizing agent-auto-creator recursively"

  # Analyze agent creation metrics
  local creation_metrics=$(jq -s '[.[] | select(.event == "agent_created")]' \
    ~/.claude/metrics.jsonl)

  # Detect meta-patterns (patterns about pattern detection)
  local meta_patterns=$(detect_meta_patterns "$creation_metrics")

  # Improve pattern detection algorithms
  if [ -n "$meta_patterns" ]; then
    enhance_pattern_detection "$meta_patterns"
    regenerate_skill "agent-auto-creator"
  fi
}
```text

---

## Pattern Library

### Built-In Patterns

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
```text

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
```text

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
```text

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
```text

### Custom Pattern Addition

Users can add custom patterns to `~/.claude/skills/agent-auto-creator/patterns.json`:

```json
{
  "customPatterns": [
    {
      "name": "test-runner",
      "signature": "npm test|pytest|cargo test",
      "minOccurrences": 5,
      "tools": ["Bash", "Read"],
      "model": "haiku",
      "tokenBudget": 3000,
      "priority": "medium"
    }
  ]
}
```text

---

## Token Economics

### Creation Cost

```text
Pattern Detection: 500 tokens (amortized over multiple patterns)
Agent Spec Generation: 200 tokens
Template Fill: 100 tokens
Validation: 100 tokens
Registration: 100 tokens
Total: ~1000 tokens per agent
```text

### Runtime Savings (Per Agent)

```text
Context Refresh Agent: 5-8k tokens saved per session
Dependency Guardian: 50k+ tokens saved per violation prevented
File Read Optimizer: 5-10k tokens saved per session
PR Workflow: 1-2k tokens saved per PR
Average: 15k-20k tokens saved per agent per session
```text

### ROI Calculation

```text
Investment: 1k tokens to create agent
Return: 15k+ tokens saved per session
Break-even: <1 session
Long-term ROI: 1500%+ over 10 sessions
```text

---

## Success Metrics

Track in `~/.claude/metrics.jsonl`:

### Agent Creation Metrics:
- Total agents created
- Creation success rate
- Average creation time (tokens)
- User acceptance rate (% of suggestions accepted)

### Agent Performance Metrics:
- Invocations per agent
- Average tokens used per invocation
- Tokens saved vs manual approach
- User satisfaction (implicit from usage)

### Self-Improvement Metrics:
- Recursion depth achieved
- Meta-patterns detected
- Self-optimization cycles completed
- Performance improvement over time

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
```text

### Silent Mode

If configured for autonomous operation:

```bash
# In settings.json
{
  "agentAutoCreator": {
    "mode": "autonomous",
    "minOccurrences": 3,
    "minTokenSavings": 5000,
    "notifyUser": false
  }
}
```text

Agent is created automatically, user notified after:

```text
✅ Created 'pr-workflow' agent based on detected pattern.
   Available now via @pr-workflow or automatically on PR creation.
```text

---

## Advanced Features

### A/B Testing

Test multiple agent variants:

```bash
# Create two versions with different approaches
create_agent "pr-workflow-v1" --model haiku
create_agent "pr-workflow-v2" --model sonnet

# Route 50% of invocations to each
ab_test_agents "pr-workflow-v1" "pr-workflow-v2" --split 50

# After 10 invocations each, promote winner
promote_winning_variant
```text

### Continuous Learning

Agent definitions improve over time:

```bash
# Collect usage feedback
log_agent_feedback() {
  echo "{
    \"event\": \"agent_feedback\",
    \"agentName\": \"$1\",
    \"success\": $2,
    \"tokensSaved\": $3,
    \"userSatisfaction\": $4
  }" >> metrics.jsonl
}

# Regenerate agent with improvements weekly
if should_regenerate_agent "$AGENT_NAME"; then
  analyze_usage_patterns "$AGENT_NAME"
  generate_improved_version "$AGENT_NAME"
  deprecate_old_version "$AGENT_NAME"
fi
```text

### Community Sharing

Export successful agents:

```bash
# Export agent for sharing
export_agent() {
  local agent_name="$1"
  local export_file="${agent_name}-export.json"

  jq -n \
    --arg name "$agent_name" \
    --arg description "$(get_agent_description "$agent_name")" \
    --arg usage "$(get_agent_usage_stats "$agent_name")" \
    '{
      name: $name,
      description: $description,
      usageStats: ($usage | fromjson),
      file: "agents/\($name).md"
    }' > "$export_file"

  log "Agent exported to $export_file"
}
```text

---

## Conclusion

The Agent Auto-Creator is a recursive meta-skill that:
- ✅ Detects patterns automatically (Rule of Three)
- ✅ Generates agents programmatically (<1k tokens)
- ✅ Saves 15k+ tokens per agent per session (1500%+ ROI)
- ✅ Self-improves recursively (optimizes own algorithms)
- ✅ Integrates with self-improvement engine
- ✅ Enables zero-touch automation

**Next Evolution:** Community marketplace for sharing agents globally.
