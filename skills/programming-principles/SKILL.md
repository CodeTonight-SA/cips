---
name: programming-principles
description: Provides comprehensive guidance for writing efficient, maintainable, and scalable code using industry-standard programming principles. Use this skill when designing, implementing, or reviewing code to ensure adherence to best practices.
---

# Programming Principles SKILL

## KISS, DRY, SOLID, Modularization & Separation of Concerns

### Purpose

This skill provides comprehensive guidance for writing efficient, maintainable, and scalable code using industry-standard programming principles. Use this skill when designing, implementing, or reviewing code to ensure adherence to best practices.

---

## When to Use This Skill

### Always use when:

- Starting new projects or features
- Refactoring existing code
- Conducting code reviews
- Teaching/mentoring developers
- Debugging complex systems
- Planning system architecture
- Evaluating third-party code

### Especially critical for:

- Production systems
- Team-based development
- Long-term maintenance projects
- Critical business logic
- Public APIs
- Shared libraries/modules

---

## Core Principles

### 1. KISS (Keep It Simple, Stupid)

**Fundamental Rule**: Simplicity is the ultimate sophistication.

### Application Strategy

### Step 1 - Understand Requirements

```text
Before coding:
1. What is the core problem?
2. What is the minimal solution?
3. Am I adding unnecessary features?
4. Can I solve this with existing patterns?
```text

### Step 2 - Choose Simplest Approach
```text
Decision Tree:
- Simple conditional → if/else (NOT complex pattern)
- Basic iteration → for loop (NOT fancy functional chain)
- Single responsibility → function (NOT class hierarchy)
- Known algorithm → use standard library (NOT reinvent)
```text

### Step 3 - Avoid Complexity Traps
```text
DO NOT:
❌ Create abstractions "for future flexibility"
❌ Use design patterns without clear need
❌ Over-optimize without measurements
❌ Add features "we might need"
❌ Use advanced language features when basic works

DO:
✓ Solve the actual stated problem
✓ Use clearest possible implementation
✓ Write code a junior can understand
✓ Keep functions under 30 lines
✓ One level of abstraction per function
```text

### KISS Verification Questions
1. Can I explain this to a junior in 30 seconds?
2. Would I understand this code in 6 months?
3. Could this be simpler and still work?
4. Am I being clever or clear?
5. Does every line serve a purpose?

---

### 2. DRY (Don't Repeat Yourself)

**Fundamental Rule**: Every piece of knowledge has ONE authoritative representation.

### Application Strategy

### Step 1 - Identify Duplication Types
```bash
Type 1: Literal Code Duplication
- Same code copy-pasted multiple times
- Action: Extract to function/method immediately

Type 2: Logic Duplication
- Same business rule in multiple places
- Action: Create single source of truth

Type 3: Knowledge Duplication
- Same concept represented differently
- Action: Unify representation

Type 4: Process Duplication
- Repeated manual steps
- Action: Automate
```text

### Step 2 - Apply Rule of Three
```text
First occurrence: Write inline
Second occurrence: Notice but don't abstract yet
Third occurrence: NOW abstract

Why? Avoid premature abstraction based on insufficient data
```text

### Step 3 - Create Abstraction
```text
Abstraction Checklist:
1. Clear, descriptive name
2. Single responsibility
3. Well-defined inputs/outputs
4. No side effects (if possible)
5. Comprehensive documentation
6. Test coverage
```text

### Step 4 - Refactor Usage
```text
1. Replace first occurrence
2. Test
3. Replace second occurrence
4. Test
5. Replace third occurrence
6. Test
7. Remove old code
8. Final integration test
```text

### DRY Anti-Patterns to Avoid
```text
❌ Abstracting too early (before Rule of Three)
❌ Wrong abstraction (worse than duplication)
❌ Over-generalization (trying to predict future)
❌ Coupling unrelated concepts (coincidental similarity)
❌ Complex abstractions for simple patterns
```text

### When NOT to DRY
```bash
Acceptable duplication:
- Different business domains (coincidental similarity)
- Different rates of change
- Different reasons to change
- Test code (clarity > reuse)
- Configuration files (explicit > imported)
```text

---

### 3. SOLID Principles

**Fundamental Rule**: Organize code for maintainability and extensibility.

#### S - Single Responsibility Principle

**Definition**: One class/function = one reason to change.

### Implementation Steps

### Step 1 - Identify Responsibilities
```text
Ask: What does this class/function DO?
If answer has "AND" → multiple responsibilities → VIOLATION

Examples:
❌ "Validates user AND saves to database"
✓ "Validates user"
✓ "Saves to database" (separate)
```text

### Step 2 - Separate Concerns
```text
Business Logic → separate from → I/O
Calculation → separate from → Presentation  
Data Access → separate from → Validation
```text

### Step 3 - Refactor
```text
Original (BAD):
class UserManager {
  validateUser()
  saveUser()
  sendEmail()
  generateReport()
}

Refactored (GOOD):
class UserValidator { validateUser() }
class UserRepository { saveUser() }
class EmailService { sendEmail() }
class ReportGenerator { generateReport() }
class UserService { 
  // Orchestrates above services
}
```text

#### O - Open/Closed Principle

**Definition**: Open for extension, closed for modification.

### Implementation Steps

### Step 1 - Identify Extension Points
```text
What might change in the future?
- Different algorithms
- Different data sources
- Different processing rules
- Different output formats
```text

### Step 2 - Use Abstraction
```text
Create interfaces/abstract classes for variation points:

interface PaymentProcessor {
  process(amount)
}

class CreditCardProcessor implements PaymentProcessor
class PayPalProcessor implements PaymentProcessor
class CryptoProcessor implements PaymentProcessor
```text

### Step 3 - Depend on Abstractions
```python
class OrderService {
  constructor(paymentProcessor: PaymentProcessor) {
    this.processor = paymentProcessor
  }
  
  checkout(order) {
    this.processor.process(order.total)
  }
}
```text

**Result**: Add new payment methods WITHOUT modifying OrderService.

#### L - Liskov Substitution Principle

**Definition**: Subtypes must be substitutable for base types.

### Implementation Steps

### Step 1 - Define Base Contract
```text
Base class establishes contract:
- Preconditions (what it requires)
- Postconditions (what it guarantees)
- Invariants (what stays constant)
```text

### Step 2 - Honor Contract in Subtypes
```text
Rules:
1. Don't strengthen preconditions (make stricter)
2. Don't weaken postconditions (guarantee less)
3. Preserve invariants
4. Don't throw new exceptions
```text

### Example
```text
❌ VIOLATION:
class Rectangle {
  setWidth(w) { this.width = w }
  setHeight(h) { this.height = h }
}

class Square extends Rectangle {
  setWidth(w) { this.width = this.height = w }
  setHeight(h) { this.width = this.height = h }
}

// Breaks LSP: Square changes width when setting height

✓ CORRECT:
Don't inherit Square from Rectangle
They have different behavioral contracts
```text

### Step 3 - Test Substitutability
```text
Any code using base type should work with derived type:

function test(rect: Rectangle) {
  rect.setWidth(5)
  rect.setHeight(10)
  assert(rect.width == 5)  // Should pass for ALL subtypes
}
```text

#### I - Interface Segregation Principle

**Definition**: Many specific interfaces > one general interface.

### Implementation Steps

### Step 1 - Identify Client Needs
```text
What does EACH client actually need?
Not: What CAN we provide?
But: What do THEY use?
```text

### Step 2 - Create Focused Interfaces
```text
❌ FAT INTERFACE:
interface Worker {
  work()
  eat()
  sleep()
  code()
  attend_meetings()
}

class Robot implements Worker {
  // Robot doesn't eat or sleep!
  // Forced to implement irrelevant methods
}

✓ SEGREGATED:
interface Workable { work() }
interface Eatable { eat() }
interface Sleepable { sleep() }
interface Codeable { code() }

class Human implements Workable, Eatable, Sleepable
class Robot implements Workable, Codeable
```text

### Step 3 - Compose Interfaces
```text
Clients depend only on what they need:

function manageWorker(worker: Workable) {
  worker.work()
  // Doesn't care about eat/sleep
}
```text

#### D - Dependency Inversion Principle

**Definition**: Depend on abstractions, not concretions.

### Implementation Steps

### Step 1 - Identify Dependencies
```text
High-level module: Business logic
Low-level module: Database, API, File system

❌ Direct dependency:
class OrderService {
  database = new MySQLDatabase()
  
  saveOrder(order) {
    this.database.insert(order)
  }
}

Problem: Can't change database without modifying OrderService
```text

### Step 2 - Create Abstraction
```text
interface OrderRepository {
  save(order)
  find(id)
  delete(id)
}
```text

### Step 3 - Inject Dependency
```text
✓ Inverted dependency:
class OrderService {
  constructor(repository: OrderRepository) {
    this.repository = repository
  }
  
  saveOrder(order) {
    this.repository.save(order)
  }
}

// Now can use ANY implementation:
new OrderService(new MySQLRepository())
new OrderService(new MongoRepository())
new OrderService(new MockRepository()) // for tests!
```text

### Benefits
- Testable (inject mocks)
- Flexible (swap implementations)
- Decoupled (business logic independent of infrastructure)

---

### 4. Modularization & Separation of Concerns

**Fundamental Rule**: Divide system into independent modules with clear boundaries.

### Application Strategy

### Step 1 - Identify Concerns
```text
Common concerns:
- Data access
- Business logic
- Presentation
- Validation
- Authorization
- Logging
- Error handling
- Configuration
```text

### Step 2 - Create Modules
```text
Module characteristics:
✓ Single, well-defined concern
✓ Clear public interface
✓ Hidden implementation details
✓ Minimal dependencies
✓ High internal cohesion
✓ Low external coupling
```text

### Step 3 - Define Boundaries
```bash
Module communication rules:
1. Use well-defined interfaces
2. Pass data, not references to internals
3. Handle errors at boundaries
4. Document contracts
5. Version interfaces
```text

### Example Architecture
```text
modules/
├── domain/          (Business logic)
│   ├── entities/
│   ├── services/
│   └── interfaces/
├── infrastructure/  (External systems)
│   ├── database/
│   ├── api/
│   └── filesystem/
├── application/     (Use cases)
│   └── services/
└── presentation/    (UI/API)
    ├── controllers/
    └── views/

Dependencies flow: presentation → application → domain
Infrastructure implements domain interfaces
```text

---

## Integration Workflow

### Phase 1: Planning
```text
1. Read requirements
2. Identify core problems (KISS)
3. Check for existing solutions (DRY)
4. Design module structure (Separation)
5. Define interfaces (ISP, DIP)
6. Identify responsibilities (SRP)
7. Plan for extension (OCP)
8. Verify contracts (LSP)
```text

### Phase 2: Implementation
```text
1. Start simple (KISS)
2. One responsibility at a time (SRP)
3. Notice duplication, wait for Rule of Three (DRY)
4. Use interfaces for dependencies (DIP, ISP)
5. Ensure substitutability (LSP)
6. Keep extension points (OCP)
7. Test each module independently
```text

### Phase 3: Refactoring
```bash
1. Third duplication? Abstract (DRY)
2. Multiple responsibilities? Split (SRP)
3. Modification needed? Extend instead (OCP)
4. Subtype issues? Fix contract (LSP)
5. Fat interfaces? Segregate (ISP)
6. Concrete dependencies? Invert (DIP)
7. Too complex? Simplify (KISS)
8. Concerns mixed? Separate
```text

### Phase 4: Review
```text
Checklist:
□ Is it simple? (KISS)
□ Is it DRY? (DRY)
□ Single responsibility? (SRP)
□ Open for extension? (OCP)
□ Substitutable? (LSP)
□ Minimal interfaces? (ISP)
□ Depends on abstractions? (DIP)
□ Concerns separated?
□ Independently testable?
□ Well documented?
```text

---

## Common Scenarios

### Scenario 1: Adding New Feature
```text
Question: Should I modify existing class or create new one?

Answer:
1. Does it fit existing class's responsibility? → Modify
2. Is it a different concern? → Create new
3. Does it require changing stable code? → Extend via OCP
4. Would it make class have >1 responsibility? → Create new

Default: Create new, prefer composition over modification
```text

### Scenario 2: Duplication Detected
```text
Question: Should I abstract this now?

Answer:
1. How many occurrences? 
   - 2 → Wait
   - 3+ → Abstract
2. Same business domain? 
   - Yes → Abstract
   - No → Leave separate
3. Change together? 
   - Yes → Abstract
   - No → Leave separate
```text

### Scenario 3: Complex Function
```text
Question: How do I simplify this?

Steps:
1. Extract functions for logical blocks
2. Each function: one level of abstraction
3. Descriptive names for each
4. Remove nesting by early returns
5. Extract conditionals to named functions
6. Split into multiple focused functions
```text

### Scenario 4: Testing Difficulty
```text
Problem: Can't test this code

Solutions:
1. Inject dependencies (DIP)
2. Split responsibilities (SRP)
3. Use interfaces for mocking (DIP, ISP)
4. Remove side effects
5. Make functions pure
6. Separate I/O from logic
```text

---

## Anti-Pattern Recognition

### Smell 1: "God Class"
```text
Signs:
- >500 lines
- >10 methods
- Multiple responsibilities
- Depends on everything

Fix: Apply SRP, extract classes
```text

### Smell 2: "Shotgun Surgery"
```text
Signs:
- One change requires editing many files
- Same logic duplicated

Fix: Apply DRY, centralize knowledge
```text

### Smell 3: "Primitive Obsession"
```text
Signs:
- Complex logic using basic types
- Validation scattered everywhere

Fix: Create domain objects (SRP)
```text

### Smell 4: "Rigid Hierarchy"
```text
Signs:
- Can't add features without modification
- Inheritance for code reuse

Fix: Apply OCP, prefer composition
```text

### Smell 5: "Interface Bloat"
```text
Signs:
- Interfaces with many methods
- Implementations with empty methods

Fix: Apply ISP, split interfaces
```text

---

## Measurement & Metrics

### Code Quality Indicators:
```text
✓ Functions: Avg <30 lines
✓ Classes: Avg <200 lines
✓ Cyclomatic complexity: <10
✓ Coupling: Low (few dependencies)
✓ Cohesion: High (related functionality)
✓ Test coverage: >80%
✓ DRY violations: <5%
✓ SOLID adherence: >90%
```text

### Review Frequency:
```text
- Every commit: Quick principle check
- Weekly: Deep review of new code
- Monthly: Refactoring session
- Quarterly: Architecture review
```text

---

## Learning Path

### Beginner:
1. Master KISS
2. Recognize duplication (DRY)
3. Understand SRP
4. Practice in toy projects

### Intermediate:
1. Apply OCP
2. Grasp LSP
3. Implement ISP
4. Use DIP
5. Refactor real code

### Advanced:
1. Design systems with principles
2. Balance trade-offs
3. Know when to break rules
4. Teach others
5. Contribute to standards

---

## Critical Reminders

### Priority
KISS > DRY > SOLID > Optimization

### When in Doubt
Choose clarity over cleverness

### Trade-offs
- Abstractions add complexity
- DRY can create coupling
- SOLID can be over-engineered
- Simple beats perfect

### Golden Rule
> Code is written once, read 100 times. Optimize for reading.

---

## References & Resources

### Essential Reading:
1. "Clean Code" - Robert C. Martin
2. "The Pragmatic Programmer" - Hunt & Thomas
3. "Refactoring" - Martin Fowler
4. "Design Patterns" - Gang of Four

### Online Resources:
- Martin Fowler's Refactoring Catalog
- Uncle Bob's SOLID principles series
- Sandi Metz's rules for developers
- Kent Beck's simple design rules

### Practice:
- Code katas focusing on principles
- Refactoring exercises
- Open source contributions
- Peer code reviews

---

*Skill Version: 1.0*  
*Last Updated: 2025-11-05*  
*Effectiveness: Production-tested*  
*Authority: Industry standards + Research-backed*
