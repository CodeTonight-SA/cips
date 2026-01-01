---
description: Run comprehensive efficiency audit on recent conversation history, detecting pattern violations and providing actionable recommendations
disable-model-invocation: false
---

# Audit Efficiency

Runs a comprehensive efficiency audit using the self-improvement engine to analyze recent conversation history for pattern violations.

## What It Does

1. Scans recent conversation history (configurable time window, default: 4 hours)
2. Detects efficiency pattern violations across 16 patterns
3. Calculates efficiency score (0-100) and assigns grade (Perfect/Good/Needs Improvement/Critical)
4. Reports major vs minor violations with point deductions
5. Provides actionable recommendations for each violation

## Usage

```bash
/audit-efficiency [hours]
```text

### Parameters:
- `hours` (optional): Hours of history to analyze (default: 4)

### Examples:
- `/audit-efficiency` - Audit last 4 hours
- `/audit-efficiency 8` - Audit last 8 hours
- `/audit-efficiency 24` - Audit last 24 hours (full day)

## Output

The audit report includes:

### Efficiency Score
- **100/100 (Perfect)**: 0 violations
- **Good**: 1-2 minor violations only
- **Needs Improvement**: 3-5 violations
- **Critical**: 6+ violations or any major violation

### Violations Summary
- Total violations count
- Major violations (10+ points each)
- Minor violations (3-5 points each)
- Total points deducted

### Detected Inefficiencies
For each violation:
- Pattern name
- Occurrence count
- Severity (major/minor/critical)
- Points deducted
- Token impact

### Recommendations
Specific remediation steps for each detected pattern, including:
- File read optimization protocols
- Batch operation suggestions
- CLI tool replacements (grep→rg, find→fd)
- Communication conciseness improvements
- YAGNI principle applications

## Integration

This command executes:
```bash
~/.claude/optim.sh audit $ARGUMENTS
```text

The underlying script:
- Validates dependencies (rg, jq, fd, awk)
- Validates history.jsonl and patterns.json integrity
- Uses epoch timestamp filtering (Monday-Friday analysis windows)
- Follows KISS/DRY/SOLID/YAGNI principles

## Related

- `/detect-inefficiency` - Pattern detection without full audit report
- `/refresh-context` - Systematic context rebuild at session start
- See `EFFICIENCY_CHECKLIST.md` for detailed violation protocols
- See `patterns.json` for all 16 efficiency patterns
