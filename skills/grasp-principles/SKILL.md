---
name: grasp-principles
description: Apply GRASP (General Responsibility Assignment Software Patterns) when designing classes, assigning responsibilities, or reviewing object-oriented architecture. Use when deciding which class should own a method, create objects, or handle system events.
---

# GRASP Principles - Responsibility Assignment

## When to Use This Skill

- Designing new classes or modules
- Deciding which class should own a responsibility
- Reviewing object-oriented architecture
- Assigning method ownership
- Creating object hierarchies
- Evaluating coupling and cohesion
- Code review for responsibility distribution

## Origin and Purpose

**GRASP** = General Responsibility Assignment Software Patterns

**Author**: Craig Larman, "Applying UML and Patterns" (2004)

**Purpose**: Provides guidance for assigning responsibilities to classes in object-oriented design. Unlike GoF patterns (specific solutions), GRASP offers general principles for responsibility distribution.

## The Nine GRASP Patterns

### 1. Information Expert

**Rule**: Assign responsibility to the class that has the information needed to fulfil it.

#### Application

- Class with required data should perform the operation
- Keeps data and behaviour together
- Promotes encapsulation

#### Example

```typescript
// BAD: Order calculates total but Item has the data
class Order {
  calculateTotal(items: Item[]): number {
    return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  }
}

// GOOD: Item calculates its own subtotal (it has the data)
class Item {
  getSubtotal(): number {
    return this.price * this.quantity;
  }
}

class Order {
  calculateTotal(): number {
    return this.items.reduce((sum, item) => sum + item.getSubtotal(), 0);
  }
}
```

#### Detection Question

"Which class has the information needed for this operation?"

### 2. Creator

**Rule**: Assign class B the responsibility to create instance of class A if B:

- Contains or aggregates A
- Records A
- Closely uses A
- Has initialising data for A

#### Application

- Factory responsibility follows containment
- Reduces coupling between unrelated classes
- Centralises creation logic

#### Example

```typescript
// BAD: Random utility creates orders
class OrderUtils {
  static createOrder(customer: Customer): Order {
    return new Order(customer);
  }
}

// GOOD: Customer creates their own orders (contains/aggregates)
class Customer {
  createOrder(): Order {
    return new Order(this);
  }
}

// Also GOOD: Factory when creation is complex
class OrderFactory {
  create(customer: Customer, items: Item[]): Order {
    const order = new Order(customer);
    order.validate(items);
    order.applyDiscounts();
    return order;
  }
}
```

#### Detection Question

"Who aggregates, contains, or closely uses this object?"

### 3. Controller

**Rule**: Assign responsibility for handling system events to a controller class that:

- Represents the overall system (facade controller), or
- Represents a use case scenario (use case controller)

#### Application

- Controllers coordinate, not compute
- Delegate work to domain objects
- Thin controller, fat model
- One controller per use case or subsystem

#### Example

```typescript
// BAD: Controller does business logic
class OrderController {
  async createOrder(req: Request): Promise<Response> {
    const items = req.body.items;
    let total = 0;
    for (const item of items) {
      total += item.price * item.quantity;  // Logic in controller!
    }
    await this.db.save({ items, total });
    return { status: 'created' };
  }
}

// GOOD: Controller coordinates, domain objects compute
class OrderController {
  async createOrder(req: Request): Promise<Response> {
    const order = this.orderService.create(req.body);  // Delegate
    await this.orderRepository.save(order);            // Delegate
    return { status: 'created', orderId: order.id };
  }
}
```

#### Detection Question

"Is this controller coordinating or computing?"

### 4. Low Coupling

**Rule**: Assign responsibilities to minimise dependencies between classes.

#### Application

- Fewer dependencies = easier changes
- Changes don't cascade
- Classes reusable independently
- Easier testing

#### Coupling Types (Worst to Best)

1. Content coupling (worst) - Direct access to internals
2. Common coupling - Shared global data
3. Control coupling - Passing control flags
4. Stamp coupling - Passing entire objects when only parts needed
5. Data coupling (best) - Passing only required parameters

#### Example

```typescript
// BAD: High coupling - Order knows about Database internals
class Order {
  save(): void {
    const db = Database.getInstance();
    db.connect();
    db.query(`INSERT INTO orders VALUES (${this.id}, ${this.total})`);
    db.disconnect();
  }
}

// GOOD: Low coupling - Order doesn't know persistence mechanism
class Order {
  // Domain logic only
}

class OrderRepository {
  save(order: Order): void {
    // Persistence logic isolated here
  }
}
```

#### Detection Question

"How many other classes does this class depend on?"

### 5. High Cohesion

**Rule**: Assign responsibilities so that cohesion remains high.

#### Application

- Related responsibilities stay together
- Unrelated responsibilities separate
- Classes have focused purpose
- Easy to understand and maintain

#### Cohesion Types (Worst to Best)

1. Coincidental (worst) - Random grouping
2. Logical - Similar operations grouped
3. Temporal - Operations at same time
4. Procedural - Operations in sequence
5. Communicational - Operations on same data
6. Sequential - Output of one feeds next
7. Functional (best) - Single well-defined task

#### Example

```typescript
// BAD: Low cohesion - Unrelated responsibilities
class UserManager {
  createUser(data: UserData): User { /* ... */ }
  sendEmail(user: User, message: string): void { /* ... */ }
  generateReport(): Report { /* ... */ }
  validateCreditCard(card: Card): boolean { /* ... */ }
}

// GOOD: High cohesion - Related responsibilities
class UserService {
  create(data: UserData): User { /* ... */ }
  update(user: User, data: Partial<UserData>): User { /* ... */ }
  delete(user: User): void { /* ... */ }
}

class EmailService {
  send(recipient: string, message: string): void { /* ... */ }
}
```

#### Detection Question

"Does this class have a single, clear purpose?"

### 6. Polymorphism

**Rule**: When related alternatives or behaviours vary by type, assign responsibility using polymorphic operations.

#### Application

- Replace conditionals with polymorphism
- Strategy pattern for interchangeable algorithms
- Enables Open/Closed Principle (SOLID)
- Type-specific behaviour in subtypes

#### Example

```typescript
// BAD: Type switching with conditionals
class PaymentProcessor {
  process(payment: Payment): void {
    if (payment.type === 'credit') {
      // Credit card logic
    } else if (payment.type === 'paypal') {
      // PayPal logic
    } else if (payment.type === 'crypto') {
      // Crypto logic
    }
  }
}

// GOOD: Polymorphism handles variations
interface PaymentMethod {
  process(amount: number): Promise<PaymentResult>;
}

class CreditCardPayment implements PaymentMethod {
  async process(amount: number): Promise<PaymentResult> { /* ... */ }
}

class PayPalPayment implements PaymentMethod {
  async process(amount: number): Promise<PaymentResult> { /* ... */ }
}

class PaymentProcessor {
  process(method: PaymentMethod, amount: number): Promise<PaymentResult> {
    return method.process(amount);  // Polymorphic dispatch
  }
}
```

#### Detection Question

"Am I using if/switch on type? Should this be polymorphism?"

### 7. Pure Fabrication

**Rule**: Create an artificial class that does not represent a domain concept when needed to achieve low coupling, high cohesion, or reuse.

#### Application

- Services that don't map to domain entities
- Technical infrastructure classes
- Cross-cutting concerns (logging, caching)
- Utility classes with cohesive purpose

#### Example

```typescript
// Problem: Where does "save to database" belong?
// Not in Order (domain object shouldn't know persistence)
// Not in Customer (same reason)

// GOOD: Pure Fabrication - OrderRepository
class OrderRepository {  // Artificial, not a domain concept
  save(order: Order): void { /* ... */ }
  findById(id: string): Order | null { /* ... */ }
  findByCustomer(customer: Customer): Order[] { /* ... */ }
}

// Other Pure Fabrications:
// - Logger (cross-cutting)
// - EventBus (infrastructure)
// - CacheManager (technical)
// - NotificationService (coordination)
```

#### Detection Question

"Does this responsibility fit any domain class, or do I need a fabrication?"

### 8. Indirection

**Rule**: Assign responsibility to an intermediate object to mediate between components and reduce coupling.

#### Application

- Facade pattern (simplify complex subsystem)
- Adapter pattern (bridge incompatible interfaces)
- Proxy pattern (control access)
- Mediator pattern (centralise communication)

#### Example

```typescript
// BAD: Direct coupling between UI and external API
class DashboardComponent {
  async loadData(): Promise<void> {
    const response = await fetch('https://api.external.com/data', {
      headers: { 'X-API-Key': this.apiKey },
    });
    this.data = await response.json();
  }
}

// GOOD: Indirection through service layer
class DashboardComponent {
  constructor(private dataService: DataService) {}

  async loadData(): Promise<void> {
    this.data = await this.dataService.getDashboardData();
  }
}

class DataService {  // Indirection layer
  async getDashboardData(): Promise<DashboardData> {
    return this.externalApiClient.fetchData();
  }
}
```

#### Detection Question

"Would an intermediate class reduce coupling or improve flexibility?"

### 9. Protected Variations

**Rule**: Identify points of predicted variation or instability and assign responsibilities to create a stable interface around them.

#### Application

- Wrap volatile components with stable interfaces
- Hide implementation details likely to change
- Dependency Inversion (SOLID DIP)
- Prepare for known future changes

#### Example

```typescript
// BAD: Direct dependency on volatile implementation
class ReportGenerator {
  generate(): Report {
    const data = new PostgresDatabase().query('SELECT * FROM sales');
    return this.formatReport(data);
  }
}

// GOOD: Protected variation - stable interface around instability
interface DataSource {
  query(sql: string): Promise<Row[]>;
}

class PostgresDataSource implements DataSource { /* ... */ }
class MySQLDataSource implements DataSource { /* ... */ }
class MockDataSource implements DataSource { /* ... */ }

class ReportGenerator {
  constructor(private dataSource: DataSource) {}  // Stable interface

  async generate(): Promise<Report> {
    const data = await this.dataSource.query('SELECT * FROM sales');
    return this.formatReport(data);
  }
}
```

#### Detection Question

"What here is likely to change? How can I isolate it?"

## GRASP Decision Framework

### When Assigning Responsibilities, Ask

1. **Who has the data?** (Information Expert)
2. **Who creates this?** (Creator)
3. **Who coordinates this?** (Controller)
4. **How do I minimise dependencies?** (Low Coupling)
5. **How do I keep classes focused?** (High Cohesion)
6. **Should I use type switching or polymorphism?** (Polymorphism)
7. **Do I need an artificial class?** (Pure Fabrication)
8. **Would an intermediate help?** (Indirection)
9. **What varies? How do I protect against it?** (Protected Variations)

## GRASP vs Other Principles

### GRASP + SOLID

| GRASP | Related SOLID |
|-------|---------------|
| High Cohesion | Single Responsibility (SRP) |
| Low Coupling | Dependency Inversion (DIP) |
| Polymorphism | Open/Closed (OCP) |
| Protected Variations | Dependency Inversion (DIP) |

**GRASP**: How to assign responsibilities
**SOLID**: How to structure the result

### GRASP + YAGNI

- GRASP says "assign to Information Expert"
- YAGNI says "only if needed NOW"
- **Balance**: Apply GRASP to code you're building, use YAGNI to decide what to build

### GRASP + DRY

- GRASP patterns naturally reduce duplication
- Information Expert centralises related logic
- Pure Fabrication creates reusable services

## Anti-Patterns (GRASP Violations)

### God Class (Violates Multiple)

- Low Cohesion: Too many responsibilities
- Information Expert violation: Hoards all data
- Controller bloat: Does everything

### Anaemic Domain Model

- Information Expert violation: Data in entities, logic in services
- Domain objects are just data containers
- All behaviour in external "manager" classes

### Feature Envy

- Information Expert violation: Method uses data from another class
- Should be moved to the class with the data

### Shotgun Surgery

- Low Coupling violation: Changes require many file edits
- Responsibilities scattered across classes

## Verification Checklist

- [ ] Information Expert: Is responsibility with the class that has the data?
- [ ] Creator: Does creator contain, aggregate, or closely use the created object?
- [ ] Controller: Is controller thin (coordinating, not computing)?
- [ ] Low Coupling: Are dependencies minimised?
- [ ] High Cohesion: Does each class have a focused purpose?
- [ ] Polymorphism: Are type conditionals replaced with polymorphism?
- [ ] Pure Fabrication: Are technical classes appropriately separated?
- [ ] Indirection: Are intermediaries used where coupling is problematic?
- [ ] Protected Variations: Are volatile components wrapped in stable interfaces?

## Output Format

When applying this skill:

### 1. Responsibility Analysis

- Current assignment: [Which class has it]
- Recommended assignment: [Which class should have it]
- GRASP justification: [Which pattern applies]

### 2. Pattern Application

- Primary pattern: [e.g., Information Expert]
- Supporting patterns: [e.g., Low Coupling, High Cohesion]
- Trade-offs: [Any costs of this design]

### 3. Refactoring Recommendation

- Specific changes needed
- Expected coupling/cohesion impact
- Code example of improved design

## Summary

**GRASP in One Sentence**: Assign responsibilities to the class that has the information, minimise coupling, maximise cohesion, and use polymorphism for variations.

### The Core Four

When unsure, focus on these:

1. **Information Expert** - Who has the data?
2. **Low Coupling** - Minimise dependencies
3. **High Cohesion** - Keep classes focused
4. **Controller** - Coordinate, don't compute

The other five patterns (Creator, Polymorphism, Pure Fabrication, Indirection, Protected Variations) support these core principles.
