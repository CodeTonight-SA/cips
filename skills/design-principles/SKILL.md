---
name: design-principles
description: Unified software design principles - SOLID, GRASP, DRY, KISS, YAGNI. Apply when designing, reviewing, or refactoring code architecture. Consolidates 5 previous separate skills.
triggers:
  - class design
  - architecture review
  - refactoring
  - code review
  - design patterns
  - responsibility assignment
  - over-engineering
  - duplication
version: 1.0.0
consolidates:
  - solid-principles
  - grasp-principles
  - dry-kiss-principles
  - yagni-principle
  - programming-principles
---

# Design Principles (Unified)

One skill for all software design guidance. Apply contextually based on the problem.

## Quick Reference

| Principle | When to Apply | Key Question |
|-----------|---------------|--------------|
| **YAGNI** | Feature requests, planning | "Do we need this NOW?" |
| **KISS** | Implementation | "Is this the simplest solution?" |
| **DRY** | Code review, refactoring | "Is this duplicated 3+ times?" |
| **SOLID** | Class/module design | "Is this easy to extend/test?" |
| **GRASP** | Responsibility assignment | "Which class should own this?" |

## YAGNI - You Aren't Gonna Need It

**Apply when**: Evaluating feature requests, reviewing speculative code

### Rules

1. Build features when needed, not when anticipated
2. Delete dead code immediately
3. No "just in case" abstractions
4. Premature optimisation is the root of all evil

### Red Flags

- "We might need this later"
- "Let's make it configurable"
- "What if requirements change?"
- Feature flags for unrequested features

## KISS - Keep It Simple, Stupid

**Apply when**: Choosing implementation approach

### Rules

1. Prefer explicit over clever
2. Readable > compact
3. Standard library > custom solution
4. Boring technology > bleeding edge

### Complexity Ladder (choose lowest sufficient)

1. Hardcoded value
2. Configuration variable
3. Simple function
4. Class with methods
5. Abstract interface
6. Plugin system

## DRY - Don't Repeat Yourself

**Apply when**: Spotting duplication, refactoring

### The Rule of Three

1. First time: Just write it
2. Second time: Note the duplication
3. Third time: Refactor to single source

### What DRY IS NOT

- Merging coincidentally similar code
- Premature abstraction
- Forcing unrelated things together

### Valid DRY Targets

- Business logic appearing in multiple places
- Configuration scattered across files
- Validation rules duplicated

## SOLID Principles

**Apply when**: Designing classes, creating abstractions, dependency management

### S - Single Responsibility

- One reason to change per class
- If you can't name it clearly, it does too much

### O - Open/Closed

- Open for extension, closed for modification
- Use composition over inheritance

### L - Liskov Substitution

- Subtypes must be substitutable for base types
- Don't violate parent class contracts

### I - Interface Segregation

- Many specific interfaces > one general interface
- Clients shouldn't depend on methods they don't use

### D - Dependency Inversion

- Depend on abstractions, not concretions
- High-level modules shouldn't depend on low-level modules

## GRASP - General Responsibility Assignment

**Apply when**: Deciding which class should own a method/data

### 9 Patterns

| Pattern | Question | Answer |
|---------|----------|--------|
| **Information Expert** | Who has the data? | That class owns the method |
| **Creator** | Who creates X? | Class that contains/aggregates X |
| **Controller** | Who handles system events? | Dedicated controller class |
| **Low Coupling** | How to minimise dependencies? | Reduce class interconnections |
| **High Cohesion** | How to keep focus? | Related responsibilities together |
| **Polymorphism** | How to handle type variants? | Use interfaces, not conditionals |
| **Pure Fabrication** | Need a class that isn't a domain concept? | Create service/utility class |
| **Indirection** | How to decouple? | Introduce intermediate class |
| **Protected Variations** | How to handle instability? | Wrap with stable interface |

## Decision Framework

```text
New feature request?
  └─→ YAGNI: Is it needed NOW?
        └─→ No: Don't build it
        └─→ Yes: Continue

Choosing implementation?
  └─→ KISS: What's the simplest approach?
        └─→ Use complexity ladder

Spotted similar code?
  └─→ DRY: Is it duplicated 3+ times?
        └─→ No: Leave it
        └─→ Yes: Extract to single source

Designing class structure?
  └─→ SOLID: Will this be easy to extend/test?
        └─→ Check each principle

Assigning responsibility?
  └─→ GRASP: Who has the information?
        └─→ Information Expert pattern
```

## Anti-Patterns to Avoid

| Anti-Pattern | Violated Principle | Fix |
|--------------|-------------------|-----|
| God class | SRP, High Cohesion | Split by responsibility |
| Shotgun surgery | DRY, Low Coupling | Consolidate related changes |
| Speculative generality | YAGNI, KISS | Remove unused abstractions |
| Copy-paste programming | DRY | Extract common code |
| Feature envy | Information Expert | Move method to data owner |

## Linked Slash Command

```bash
/design-principles
```

## Supersedes

This skill consolidates and replaces:

- `solid-principles`
- `grasp-principles`
- `dry-kiss-principles`
- `yagni-principle`
- `programming-principles`
