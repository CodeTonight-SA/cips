---
name: solid-principles
description: Apply SOLID principles (Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion) when designing, reviewing, or refactoring code architecture. Use when evaluating class design, creating abstractions, or discussing software maintainability.
---

# SOLID Principles Architecture Skill

## When to Use This Skill

- Designing new classes or modules
- Reviewing code architecture
- Refactoring existing code
- Evaluating abstraction layers
- Discussing maintainability concerns
- Creating interfaces or base classes

## Core SOLID Principles

### S - Single Responsibility Principle (SRP)

**Rule**: A class should have one, and only one, reason to change.

### Application

- Each class = one job/responsibility
- One reason to change = one responsibility
- Separate business logic, presentation, persistence
- If explaining class requires "and", it violates SRP

### Example Violations

```bash
BAD: UserManager handles authentication + email sending + database operations
GOOD: AuthService, EmailService, UserRepository (separate classes)
```text

**Benefits**: Easier debugging, simpler testing, reduced coupling

### O - Open/Closed Principle (OCP)
**Rule**: Software entities should be open for extension, closed for modification.

### Application
- Extend behavior without modifying existing code
- Use abstract classes and interfaces
- Protects stable, tested code
- Apply Template Pattern, Strategy Pattern

### Example
```text
BAD: Modify existing class to add new payment method
GOOD: Extend PaymentProcessor interface with new implementation
```text

**Benefits**: Stable code remains unchanged, backward compatibility maintained

### L - Liskov Substitution Principle (LSP)
**Rule**: Objects should be replaceable with instances of their subtypes without altering correctness.

### Application
- Derived classes must be substitutable for base classes
- Subtypes cannot break base type expectations
- No strengthening preconditions
- No weakening postconditions

### Example Violation
```text
BAD: Rectangle → Square (breaks width/height independence)
GOOD: Shape → Rectangle, Shape → Square (separate hierarchies)
```text

**Benefits**: Reliable polymorphism, predictable inheritance

### I - Interface Segregation Principle (ISP)
**Rule**: Clients should not be forced to depend on interfaces they do not use.

### Application
- Many small, specific interfaces > one general interface
- Avoid "fat interfaces"
- Clients depend only on methods they use
- Split large interfaces into focused ones

### Example
```text
BAD: IWorker { Work(), Eat(), Sleep() } // Not all workers need Eat()
GOOD: IWorkable { Work() }, IFeedable { Eat() } // Compose as needed
```text

**Benefits**: Reduced dependencies, increased modularity, focused implementations

### D - Dependency Inversion Principle (DIP)
**Rule**: High-level modules should not depend on low-level modules. Both should depend on abstractions.

### Application
- Depend on abstractions (interfaces/abstract classes)
- Abstractions don't depend on details
- Details depend on abstractions
- Use dependency injection

### Example
```text
BAD: OrderProcessor → MySQLDatabase (tight coupling)
GOOD: OrderProcessor → IDatabase ← MySQLDatabase (abstraction layer)
```text

**Benefits**: Decoupled code, easy implementation swapping, improved testability

## SOLID Integration Rules

### Priority Order:
1. **Start Simple** (KISS) - Don't over-engineer
2. **Apply SRP First** - One responsibility per unit
3. **Add Abstractions** (OCP, DIP) - When extension points are clear
4. **Validate Substitution** (LSP) - When using inheritance
5. **Split Interfaces** (ISP) - When interfaces grow bloated

### Verification Checklist:
- [ ] SRP: Each class has one reason to change?
- [ ] OCP: Can extend without modifying stable code?
- [ ] LSP: Subtypes safely replaceable?
- [ ] ISP: Interfaces minimal and focused?
- [ ] DIP: Depending on abstractions, not concrete implementations?

## Anti-Patterns to Flag

**God Classes** (SRP violation):
- Class doing too many things
- Multiple reasons to change
- Hard to test, maintain

**Tight Coupling** (DIP violation):
- Direct dependency on concrete implementations
- Hard to swap implementations
- Testing requires real dependencies

**Fat Interfaces** (ISP violation):
- Interface with many methods
- Implementing classes don't use all methods
- Forced implementation of irrelevant methods

**Broken Substitution** (LSP violation):
- Subtype breaks parent's contract
- Subtype requires special handling
- Surprising behavior in polymorphic contexts

**Modification Instead of Extension** (OCP violation):
- Changing stable code for new features
- Risk of breaking existing functionality
- No abstraction layer for extensions

## When NOT to Apply SOLID

### Premature Optimization
- Simple scripts or prototypes
- Code that won't be extended
- Performance-critical hot paths (after profiling)

### Over-Engineering
- Abstractions for unlikely extensions
- Interfaces with single implementation
- Complex hierarchies for simple problems

**Rule**: Apply SOLID when complexity justifies it, not preemptively.

## SOLID with KISS and DRY

**KISS Provides Philosophy**: Keep it simple
**DRY Eliminates Waste**: No duplicate knowledge
**SOLID Provides Structure**: How to organize that simple, DRY code

**Golden Rule**: SIMPLE + DRY + SOLID = Maintainable, Scalable, Testable Code

## Output Format

When applying this skill, provide:
1. **Identified Violations**: Specific SOLID principles violated
2. **Recommendation**: How to refactor using which principle(s)
3. **Rationale**: Why this improves maintainability/testability
4. **Trade-offs**: Any complexity introduced, worth the benefit?

## Progressive Application

**Phase 1 - Analysis**: Identify which SOLID principles are relevant
**Phase 2 - Recommendation**: Suggest specific refactorings
**Phase 3 - Verification**: Confirm changes satisfy principle(s)

**Remember**: SOLID is a guide, not dogma. Balance principles with pragmatism.
