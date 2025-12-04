---
name: dry-kiss-principles
description: Apply DRY (Don't Repeat Yourself) and KISS (Keep It Simple, Stupid) principles when writing, reviewing, or refactoring code. Use when eliminating duplication, simplifying complex logic, or evaluating abstraction timing.
---

# DRY & KISS Principles Skill

## When to Use This Skill

- Detecting code duplication
- Simplifying complex implementations
- Evaluating when to abstract
- Reviewing for over-engineering
- Refactoring repetitive patterns
- Assessing abstraction timing (Rule of Three)

## KISS - Keep It Simple, Stupid

**Definition**: Systems work best when kept simple rather than made unnecessarily complex.

**Origin**: U.S. Navy (1960), formalized by Kelly Johnson at Lockheed

### Core Philosophy

- Simplicity = key design goal
- Simple solutions easier to understand, implement, maintain, use
- NO value in being "clever"—value in being understandable
- Every function = ONE job
- Break complex problems into atomic tasks

### KISS Application Rules

### 1. Start Small, Solve Iteratively

- Begin with simplest solution that works
- Add complexity only when PROVEN necessary
- Avoid premature optimization

### 2. Clear Naming

- Variables/functions/classes = descriptive names
- No abbreviations unless standard (URL, ID, HTTP)
- Self-documenting code

### 3. Avoid Over-Engineering

```bash
BAD: ML model for simple if-else logic
GOOD: if-else for simple conditional logic

BAD: Complex nested abstractions for straightforward task
GOOD: Direct, readable implementation

BAD: Framework for 3-line operation
GOOD: 3 lines of clear code
```text

### 4. Feature Discipline
- Add features ONLY when truly necessary
- Each feature adds complexity cost
- Default to NO for new features

### KISS Verification Questions

Before writing code:
- Can this be simpler?
- Am I adding unnecessary abstraction?
- Would a junior developer understand this immediately?
- Am I being clever or clear?
- Does this function do ONE thing?

## DRY - Don't Repeat Yourself

**Definition**: Every piece of knowledge must have a single, unambiguous, authoritative representation within a system.

**Origin**: Andy Hunt and Dave Thomas, "The Pragmatic Programmer" (1999)

### Core Philosophy
- Eliminate logic duplication through abstraction
- Eliminate process duplication through automation
- Code reusability via modular components
- Centralized maintenance
- Single source of truth

### DRY vs WET

**DRY**: Don't Repeat Yourself
**WET**: Write Everything Twice / We Enjoy Typing / Waste Everyone's Time

### The Rule of Three

**CRITICAL**: The third time you encounter a pattern, abstract it into a reusable unit.

**DO NOT** abstract at first or second occurrence.

### Why?
- Premature abstraction is expensive
- Two similar functions may diverge over time
- "Duplication is far cheaper than the wrong abstraction" - Sandi Metz

### AHA Programming (Avoid Hasty Abstractions)

**Principle**: Wait to abstract until you understand how the abstraction needs to function.

### Rules
- Don't abstract at a specific duplication count
- Abstract when duplication ITSELF becomes the problem
- Avoid sunk cost fallacy of over-invested abstractions
- Optimize for change first, not theoretical reuse

### DRY Application Rules

### 1. Single Source of Truth
- Business logic in ONE place
- Validation logic centralized
- Configuration in config files
- Constants named and centralized

### 2. Reusable Components
```text
BAD: Copy-paste validation logic in 5 controllers
GOOD: validateUser() function called by all controllers

BAD: Same calculation in 3 places
GOOD: calculateTotal() utility function
```text

### 3. Automate Repetition
- Scripts for repetitive tasks
- Build automation
- Code generation where appropriate
- Framework features to eliminate boilerplate

### When NOT to DRY

### Premature Abstraction
- First occurrence: Write directly
- Second occurrence: Copy and modify
- Third occurrence: NOW abstract (Rule of Three)

### False Similarity
- Two functions look similar TODAY
- But serve different domains
- May diverge significantly in future
- Coupling them creates artificial dependency

### Example
```text
BAD: Abstract formatUserDisplay() and formatAdminDisplay() too early
GOOD: Let them evolve independently until third similar case appears
```text

## KISS + DRY Integration

**Phase 1 - KISS**: Start with simplest solution
**Phase 2 - Identify Duplication**: After building simple solution
**Phase 3 - Rule of Three**: Wait for third occurrence
**Phase 4 - Abstract**: Create reusable unit
**Phase 5 - Keep Simple**: Ensure abstraction remains clear

### Anti-Pattern
```text
❌ Over-engineer abstractions preemptively (violates KISS)
❌ Abstract at first duplication (violates Rule of Three)
❌ Create complex abstractions for 2 use cases
```text

### Good Pattern
```text
✅ Simple solution first
✅ Copy-paste second time with comment "TODO: Abstract if appears third time"
✅ Abstract on third occurrence with clear interface
✅ Keep abstraction simple and focused
```text

## Verification Checklist

### KISS Checks:
- [ ] Is this the simplest solution that works?
- [ ] Can ANY complexity be removed?
- [ ] Am I being clever or clear?
- [ ] Would this confuse a junior developer?
- [ ] Does each function have ONE clear purpose?
- [ ] Have I avoided premature optimization?

### DRY Checks:
- [ ] Is this logic duplicated elsewhere?
- [ ] Is this the THIRD occurrence (Rule of Three)?
- [ ] Will this abstraction survive future changes?
- [ ] Am I creating the RIGHT abstraction?
- [ ] Single source of truth established?
- [ ] Can I automate this repetitive process?

## Common Violations

### KISS Violations:
- Unnecessary design patterns
- Over-abstracted simple logic
- Premature optimization
- Complex solutions to simple problems
- "Clever" code that's hard to read
- Multiple nested callbacks/promises
- Abstract classes with one implementation

### DRY Violations:
- Copy-pasted code blocks
- Same validation in multiple places
- Duplicated business logic
- Manual processes that could be scripted
- Same knowledge in multiple locations
- Repeated error handling patterns

## Refactoring Triggers

### Simplify When (KISS)
- Function exceeds 50 lines
- Nested logic exceeds 4 levels
- Multiple "and" clauses in function description
- Difficult to name (indicates unclear purpose)
- Hard to test
- Junior developer confusion

### Abstract When (DRY)
- Third occurrence of same pattern (Rule of Three)
- Synchronized updates required in multiple places
- Bug appears in multiple similar code blocks
- Changes cascade across multiple files

## Output Format

When applying this skill:

### 1. KISS Analysis
- Complexity Assessment: [Simple/Moderate/Complex]
- Simplification Opportunities: [List specific items]
- Recommended Refactoring: [Concrete steps]

### 2. DRY Analysis
- Duplication Count: [1st/2nd/3rd+ occurrence]
- Abstraction Timing: [Too Early/Rule of Three Met/Overdue]
- Recommended Action: [Wait/Abstract Now/Already Optimal]

### 3. Trade-offs
- Simplicity vs Flexibility
- Duplication Cost vs Abstraction Cost
- Current Pain vs Future Benefit

## Critical Balance

### Remember
- Simple beats clever
- Clear beats concise  
- Two duplications < wrong abstraction
- Delete code > Add code
- Explicit > Implicit
- Boring code > Exciting code

**Master Rule**: Optimize for the READER, not the WRITER.

## Progressive Application

**Step 1**: Identify violations (KISS or DRY)
**Step 2**: Assess severity (How much pain?)
**Step 3**: Evaluate timing (Rule of Three for DRY)
**Step 4**: Propose refactoring (Specific, actionable)
**Step 5**: Verify improvement (Simpler AND DRYer?)
