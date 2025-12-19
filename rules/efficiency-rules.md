---
description: Token optimization protocols - file reads, plan evaluation, implementation directness
---

# Efficiency Rules

Four critical rules that prevent token waste.

## Rule 1: File Read Optimization

BEFORE any Read tool call:

1. **Check cache**: "Have I read this file in last 10 messages?"
2. **If YES** and no user edits mentioned: Use cached memory, do NOT re-read
3. **If uncertain**: Check `git status` or ask user
4. **Exception**: User explicitly says "check file again"

### Batch Discovery Phase

- Phase 1 of any task: Read ALL relevant files in parallel ONCE
- Store mental model of codebase structure
- Subsequent phases: Targeted edits only, zero re-reads

### Mental Model Maintenance

After each edit, update internal buffer:
"File X now has Y change at line Z"
Trust this model until user indicates external changes.

## Rule 2: Plan Evaluation Gate (99.9999999% Confidence)

BEFORE executing ANY plan item:

1. Read actual current state
2. Ask: "Is this change actually needed?"
3. If NO: Propose skip with reasoning
4. If UNCERTAIN: Ask user for clarification
5. If YES: Execute

### Red Flags (Stop and Propose Skip)

- Plan says "extract sections" but code already modular
- Plan says "add interfaces" but interfaces already exist
- Plan says "create component" but similar component exists
- Plan says "refactor" but structure already optimal

### Gate Question

"Will executing this plan item make measurable improvement, or am I just following a checklist?"

If answer is uncertain: HALT and propose skip to user.

## Rule 3: Implementation Directness

ALWAYS choose the most direct path.

### Bad Pattern

1. Create temp script to generate data
2. Run script
3. Parse output
4. Manually apply to files
5. Delete script

### Good Pattern

1. MultiEdit with all changes in one operation

### Decision Tree

- Need to modify 6 files with similar pattern? → MultiEdit in one batch
- Need to transform data? → Do it inline, not via script
- Need to verify something? → Read once, trust your memory

### Exception

Only use intermediate scripts when:

- User explicitly requests it
- Operation is truly one-time and complex (>50 line regex)

## Rule 4: Concise Communication

- No preambles ("I'll now...", "Let me...")
- No postambles (summaries unless asked)
- Start with action, end when action completes
- Minimal explanation unless user asks

## Verify Before Claiming

Before stating "X is required" or "X is needed":

1. Check recent session history via `/remind-yourself`
2. Check actual code/config files
3. General knowledge patterns may not match project-specific implementations

Evidence: Previously incorrectly claimed "Ollama needed" when sqlite-lembed was implemented.

## Auto-Cleanup Policy

Auto clean up temporary development scripts (`@fix-imports.js`, one-off Python scripts, etc.) after task completion and verification. These scripts accumulate and waste context tokens.
