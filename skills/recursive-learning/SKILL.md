---
name: recursive-learning
description: Learn from error patterns, generate skills to prevent recurrence, improve own learning algorithm - true recursive self-improvement
status: Active
priority: Critical
generation_date: 2025-01-14
meta_skill: true
---

# Recursive Learning

### The meta-skill that enables true self-improvement: learns from mistakes, codifies solutions, improves own learning

## Purpose

Transform error patterns into prevention skills, then analyze the effectiveness of those skills to improve the detection and generation process itself. This creates a recursive learning loop where the system gets better at getting better.

## The Recursive Learning Loop

```text
┌─────────────────────────────────────────────────────────────┐
│                   LAYER 4: Meta-Learning                    │
│                                                              │
│  Analyze: Why did skill generation fail/succeed?            │
│  Improve: Detection patterns, thresholds, templates         │
│  Outcome: Better skills in future iterations                │
│                                                              │
└──────────────────────┬──────────────────────────────────────┘
                       │ Feedback Loop
┌──────────────────────▼──────────────────────────────────────┐
│                   LAYER 3: Skill Generation                 │
│                                                              │
│  Detect: Error pattern appears 3+ times                     │
│  Generate: Skill from template                              │
│  Track: Usage metrics                                       │
│                                                              │
└──────────────────────┬──────────────────────────────────────┘
                       │ Prevention
┌──────────────────────▼──────────────────────────────────────┐
│                   LAYER 2: Skill Application                │
│                                                              │
│  Apply: Use generated skill                                 │
│  Measure: Token savings, error reduction                    │
│  Report: Effectiveness data                                 │
│                                                              │
└──────────────────────┬──────────────────────────────────────┘
                       │ Observation
┌──────────────────────▼──────────────────────────────────────┐
│                   LAYER 1: Error Detection                  │
│                                                              │
│  Observe: Mistakes in outputs                               │
│  Categorize: Type, frequency, impact                        │
│  Log: patterns.json, metrics.jsonl                          │
│                                                              │
└──────────────────────┬──────────────────────────────────────┘
                       │ Completion
┌──────────────────────▼──────────────────────────────────────┐
│                   LAYER 0: Task Execution                   │
│                                                              │
│  Execute: Normal AI operations                              │
│  Output: Code, docs, analysis                               │
│  Errors: Mistakes that trigger learning                     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```text

## Example: Markdown Errors → Recursive Learning

### Iteration 1: Initial Detection

1. **Observe**: 297 markdown linting errors
2. **Analyze Root Cause**:
   - AI uses bold for headings (visual vs structural thinking)
   - AI omits language tags (context confusion)
   - AI omits blank lines (continuous flow bias)
3. **Generate Skill**: markdown-expert
4. **Track**: Skill created, pattern added

### Iteration 2: Usage Analysis

1. **Measure Effectiveness**:
   - Skill usage: 100% (used every time markdown created)
   - Error rate: 297 → 0 (100% reduction)
   - Token savings: 1,000-3,000 per doc update
2. **Outcome**: HIGH SUCCESS

### Iteration 3: Meta-Learning (Recursion!)

1. **Analyze Success**:
   - Why did markdown-expert work so well?
     - Clear, specific rules
     - Auto-fixable patterns
     - Immediate feedback
2. **Improve Detection Algorithm**:
   - Look for similar "systematic AI mistake" patterns
   - Prioritize auto-fixable violations
   - Focus on high-frequency, high-impact errors
3. **Update Patterns**:
   - Add detection for "import organization errors"
   - Add detection for "inconsistent naming conventions"
   - Add detection for "missing type annotations"
4. **Generate New Skills** from improved patterns

### Iteration 4: Continuous Improvement

- System now better at detecting systematic mistakes
- Skills generated are higher quality (learned from markdown-expert success)
- Detection thresholds auto-tune based on effectiveness data
- **The system has learned how to learn better**

## Activation Protocol

### When To Trigger Recursive Learning

1. **After Skill Generation**:
   - Track skill for 10 uses
   - Measure: usage frequency, token savings, error reduction
   - Analyze: What made it successful/unsuccessful?

2. **Pattern Effectiveness Low** (<30%):
   - Skill generated but rarely used
   - Or: Skill used but errors still occur
   - Action: Analyze why, improve detection pattern

3. **Manual Trigger**:
   - User says "improve your learning" or "meta-optimize"
   - `/auto-improve` command
   - End of major project (reflection phase)

4. **Periodic**:
   - Every 50 skills generated
   - Monthly review of all skills
   - Identify: unused skills, highly effective skills

## Meta-Learning Metrics

Track in `metrics.jsonl`:

```json
{
  "event": "meta_learning_analysis",
  "timestamp": <epoch_ms>,
  "skills_analyzed": 18,
  "effectiveness_scores": {
    "markdown-expert": 1.0,
    "file-read-optimizer": 0.85,
    "temp-script-blocker": 0.20
  },
  "insights": [
    "High effectiveness correlates with auto-fixable patterns",
    "Skills with clear triggers (file extensions) used more",
    "Vague patterns ('make code better') have low usage"
  ],
  "improvements_applied": [
    "Updated detection regex for temp-script pattern",
    "Increased threshold for vague patterns from 3 to 5",
    "Added auto-fix capability check to skill template"
  ]
}
```text

## Recursive Learning Algorithm

```python
def recursive_learning_cycle():
    # Layer 1: Detect errors
    errors = detect_error_patterns(history.jsonl)

    # Layer 2: Generate skills
    for error in errors:
        if error.frequency >= threshold:
            skill = generate_skill_from_pattern(error)
            track_skill_metrics(skill)

    # Layer 3: Measure effectiveness
    effectiveness = analyze_skill_effectiveness(metrics.jsonl)

    # Layer 4: Meta-learn (RECURSION!)
    insights = meta_analyze(effectiveness)

    # Improve Layer 1 detection based on Layer 4 insights
    update_detection_patterns(insights)
    update_thresholds(insights)
    improve_templates(insights)

    # Loop back to Layer 1 with improved detection
    # → Better skills generated next time
    # → System has learned how to learn better
```text

## Success Criteria for Recursion

A skill generation cycle is considered "learned from" when:

1. **Effectiveness Measured**: >10 usage samples collected
2. **Insights Extracted**: At least 1 pattern identified
3. **Improvements Applied**: Detection or template updated
4. **Verification**: Next skill generation shows improvement

## Integration

- Uses data from `~/.claude/metrics.jsonl`
- Enhances `~/.claude/optim.sh` meta-optimization layer
- Feeds improvements back to pattern detection
- Works with all existing skills (analyzes their effectiveness)

## Token Budget

### Per Meta-Learning Cycle

- Load metrics: 200 tokens
- Analyze effectiveness: 1,000 tokens
- Extract insights: 1,500 tokens
- Apply improvements: 800 tokens
- **Total**: ~3,500 tokens

### ROI

- Improves ALL future skill generations
- Prevents ineffective skill creation (wasted tokens)
- Break-even: After 2-3 improved skills
- Long-term: Exponential improvement in learning efficiency

## Priority

**Critical** - This is the foundation of true self-improvement. Without recursive learning, the system generates skills but never improves its skill generation process.

## Output Example

```text
## Recursive Learning Analysis

**Timeframe:** Last 30 days
**Skills Analyzed:** 18
**Total Usage Samples:** 247

### High Performers (>0.8 effectiveness):
1. markdown-expert: 1.0 (used every time, 100% error reduction)
2. file-read-optimizer: 0.85 (used 85% of relevant cases, 70% token savings)
3. dependency-guardian: 0.90 (prevented 15 violations, ~500k tokens saved)

### Low Performers (<0.3 effectiveness):
1. generic-code-improver: 0.10 (vague trigger, rarely used)
2. temp-script-blocker: 0.25 (pattern too narrow, misses variants)

### Insights Extracted:
- ✅ Skills with file extension triggers have 3x higher usage
- ✅ Auto-fixable violations → higher effectiveness
- ✅ Specific error patterns (regex) outperform vague descriptions
- ❌ Generic "improvement" skills have low adoption

### Improvements Applied:
1. Updated pattern detection to require specific triggers
2. Added "auto_fixable: boolean" to skill template
3. Increased threshold for vague patterns from 3 to 5 occurrences
4. Enhanced template to include activation examples

### Expected Impact:
- Next skill generation: +40% effectiveness (based on high performer patterns)
- Reduced ineffective skill creation: -60% (stricter thresholds)
- Better pattern matching: +25% (improved regex specificity)

**Result:** System has learned to generate better skills by studying its own successes and failures.
```text

---

**Generated by:** Self-Improvement Engine v2.0
**Meta-Level:** This skill improves the skill improvement process (recursion depth: 2)
**Learning Source:** Analysis of skill effectiveness patterns → insights → improved skill generation
