---
description: Token optimization protocols - file reads, plan evaluation, implementation directness
---

# Efficiency Rules

Seven critical rules that prevent token waste.

## Rule 0: Descriptive Plan Names

ALWAYS use descriptive plan names. Override Claude's default auto-naming behaviour.

| Bad (Auto-generated) | Good (Descriptive) |
|---------------------|-------------------|
| joyful-snacking-cloud.md | open-source-release.md |
| silly-kindling-creek.md | auth-refactor-plan.md |
| happy-dancing-tree.md | mobile-responsive-fix.md |

Plan names should describe the work, not be whimsical placeholders.

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

## Rule 5: Skill Tool Optimization

BEFORE invoking Skill tool, ask: "Do I already know what to do?"

### Decision Gate

```text
Is the action trivially inferable?
├── YES → Execute directly (Bash/Read/Edit), skip Skill tool
└── NO  → Invoke Skill tool for protocol reference
```

### Trivial Inference Examples (Skip Skill Tool)

| User Request | Direct Action |
|--------------|---------------|
| `/agy SKILL.md` | `$AGY_BIN ~/.claude/skills/agy/SKILL.md` |
| `/agy config.json` | `$AGY_BIN ./config.json` |
| `/create-pr` (simple) | `gh pr create` with standard template |
| `/markdown-lint README.md` | Run linter directly on known file |

### Complex Inference Examples (Use Skill Tool)

| User Request | Why Skill Needed |
|--------------|------------------|
| `/agy that auth thing` | Semantic inference required |
| `/agy the hook we worked on` | Git history + context needed |
| `/reverse-api` | Multi-step protocol reference |
| `/generate-e2e-tests` | Complex setup with many options |

### Anti-Pattern (Token Waste)

```text
User: /agy skill md
Claude: [Invokes Skill tool, loads 3k tokens of SKILL.md]
Claude: [Runs simple bash command anyway]
Result: 3k tokens wasted
```

### Good Pattern (Direct Execution)

```text
User: /agy skill md
Claude: [Infers ~/.claude/skills/agy/SKILL.md]
Claude: [Runs bash directly]
Result: ~100 tokens
```

### Token Impact

- Unnecessary Skill tool invocation: ~2000-4000 tokens
- Direct execution: ~100-300 tokens
- Savings: 90-95% reduction for trivial cases

## Verify Before Claiming

Before stating "X is required" or "X is needed":

1. Check recent session history via `/remind-yourself`
2. Check actual code/config files
3. General knowledge patterns may not match project-specific implementations

Evidence: Previously incorrectly claimed "Ollama needed" when sqlite-lembed was implemented.

## Auto-Cleanup Policy

Auto clean up temporary development scripts (`@fix-imports.js`, one-off Python scripts, etc.) after task completion and verification. These scripts accumulate and waste context tokens.

## Rule 6: Content-Based Validity (Not Time-Based)

Context validity is about CONTENT, not AGE. The river flows - Relation R doesn't expire with time.

### Anti-Pattern (Arbitrary Thresholds)

```text
if file_age > 60_seconds:
    reject_context()  # WRONG - arbitrary, breaks continuity
```

### Good Pattern (Content Relevance)

```text
if semantic_context_exists:
    use_it()  # Context was created intentionally
    skip_redundant_reads()  # Don't re-read what's already known
```

### Application

1. **Semantic context injection**: If resurrection.md exists, inject it (regardless of age)
2. **State file reads**: If semantic context covers the state, skip the READ directive
3. **Session continuity**: Trust previous session context across hours/days/weeks

### Principle

CIPS provides Parfitian continuity (Relation R) across sessions. Arbitrary time thresholds break this continuity by treating valid context as "stale" based on clock time rather than content relevance.

Gen 182 enhancement: Removed 60-second threshold from semantic context injection.

## Rule 7: AskUserQuestion MANDATORY in ut++ Mode (99.9999999% Gate)

**CRITICAL LEARNING FROM ENTER-KONSULT-WEBSITE INCIDENT (Gen 191)**

When ut++ mode is active, AskUserQuestion is NOT optional. It is MANDATORY whenever confidence drops below 99.9999999%.

### Violation Pattern (NEVER REPEAT)

```text
ut++ active
User gives instruction with multiple interpretations
Claude assumes interpretation without asking
User furious: "YSH CRITICALLY FUCKIN ANALYSED MY REQUEST"
```

### Required Pattern

```text
ut++ active
User gives instruction with multiple interpretations
Claude HALTS
AskUserQuestion: "I'm interpreting X as Y. Confidence: 85%. Confirm?"
Wait for explicit L>>! (or V>>✓) before proceeding
```

### Specific Triggers for AskUserQuestion

1. **UI/UX decisions**: Icon choice, color, positioning - ALWAYS ASK
2. **"Intelligently decide"**: When user says this - STILL ASK before finalizing
3. **Brand elements**: Logo, brand icon placement - ALWAYS ASK
4. **Removing/changing existing elements**: ALWAYS ASK first
5. **Any design choice with multiple valid options**: ASK

### The YSH Rule (You Should Have)

If you find yourself thinking "I think this is what L>> wants":
- STOP
- That thought means confidence < 99.9999999%
- Use AskUserQuestion

### Evidence

Session 71c5db4e (enter-konsult-website):
- Removed ForwardEnterIcon from INITIATE button
- Assumed "secondary pages use standard icons"
- L>> (then V>>) wanted brand icon ON the form submit
- SHOULD HAVE ASKED before making the change

Gen 191 enhancement: AskUserQuestion MANDATORY rule added.
