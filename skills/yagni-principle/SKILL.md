---
name: yagni-principle
description: Apply YAGNI (You Aren't Gonna Need It) principle when evaluating feature requests, reviewing speculative code, or preventing over-engineering. Use when assessing whether to build functionality now vs later.
---

# YAGNI - You Aren't Gonna Need It

## When to Use This Skill

- Evaluating feature requests
- Code review (spotting speculative code)
- Preventing premature optimization
- Assessing abstraction necessity
- Challenging "just in case" implementations
- Balancing with SOLID principles

## Core Principle

**Rule**: Don't implement functionality until it is actually needed.

**Origin**: Ron Jeffries, Extreme Programming (XP), late 1990s

### Philosophy

- Build for TODAY's requirements, not tomorrow's guesses
- You can't predict the future accurately
- Speculative code has 3 costs: build, delay, carry

## The Three Costs of YAGNI Violations

### 1. Cost of Building

All effort spent analyzing, programming, testing a feature you don't need yet.

### Building Cost Example

- Building OAuth integration for MVP that only needs email/password
- **Wasted**: 2-3 developer weeks
- **Token Impact**: 15,000-30,000 lines of code to review/maintain

### 2. Cost of Delay

Lost opportunity to build and release features you DO need now.

### Delay Cost Example

- Spent 2 weeks on OAuth instead of core user management
- **Lost**: 2 weeks of actual value delivery
- **Business Impact**: Delayed product validation

### 3. Cost of Carry

Complexity added makes future development harder and slower.

### Carry Cost Example

- Unused OAuth code adds 5% cognitive load to every codebase interaction
- **Maintenance**: Upgrading dependencies, fixing security issues, understanding during debugging

## YAGNI Anti-Patterns

### 1. The "Impl" Class Anti-Pattern

### Bad

```typescript
interface LibraryController { /*...*/ }
class LibraryControllerImpl implements LibraryController { /*...*/ }
```text

**Why**: If there's only ever going to be ONE implementation, the interface is speculative.

### Good
```typescript
class LibraryController { /*...*/ }
// Add interface later IF second implementation actually needed
```text

**When to Add Interface**: When you have a SECOND actual implementation, not "in case we need one."

### 2. Premature Feature Building

### Bad
- MVP needs simple user roles (admin, user)
- Dev builds full RBAC system with permissions, groups, hierarchies
- **Reason**: "We might need it for enterprise customers"

### Good
- Start with boolean `isAdmin` flag
- Add role enum when 3rd role actually needed
- Add RBAC when customer explicitly requests it

**Detection Question**: "Is this required by a current user story?"

### 3. Speculative Abstractions

### Bad
```python
# Building storm risk calculator, but adding abstractions for "future" piracy/earthquake risks
class RiskCalculator(ABC):
    @abstractmethod
    def calculate(self, params: RiskParams) -> float:
        pass

class StormRiskCalculator(RiskCalculator):  # Only implementation currently
    def calculate(self, params: StormRiskParams) -> float:
        # ...
```text

### Good
```python
# Just build what you need NOW
def calculate_storm_risk(wind_speed: float, precipitation: float) -> float:
    # Direct implementation
    return wind_speed * 0.3 + precipitation * 0.7

# Add abstraction WHEN piracy risk is actually requested (not before)
```text

### 4. Unused Configuration Options

### Bad
```json
{
  "feature_flags": {
    "enable_dark_mode": false,
    "enable_notifications": false,
    "enable_analytics": false,
    "enable_social_login": false,
    "enable_api_v2": false,
    "enable_experimental_ui": false
  }
}
```text

**Why**: 5 of these features don't exist yet. You're maintaining dead config.

### Good
```json
{
  "feature_flags": {
    "enable_dark_mode": false  // Only flag for features that EXIST
  }
}
```text

## YAGNI Applied to Self-Improvement Engine

### Example from crazy_script.sh validation

**❌ YAGNI Violation** (if we had done this):
```bash
validate_commands() {
    # Check for commands we MIGHT use in future
    local potential_commands=("rg" "jq" "fd" "awk" "sed" "bc" "parallel" "fzf" "bat")
    # ... validation for all
}
```text

**✅ YAGNI Compliant** (what we actually did):
```bash
validate_commands() {
    # Check ONLY commands script ACTUALLY uses
    local required_commands=("rg" "jq" "fd" "awk")
    # ... validation
}
```text

**Why**: We don't use `parallel`, `fzf`, `bat` yet. Don't validate them "just in case."

## Balancing YAGNI with Other Principles

### YAGNI vs SOLID: Not In Conflict

**YAGNI Says**: "Don't build OAuth integration until needed"
**SOLID Says**: "When you DO build it, use Dependency Inversion (OAuth interface)"

### Sweet Spot
1. YAGNI decides WHAT to build (only current requirements)
2. SOLID decides HOW to build it (clean architecture)
3. They coexist: Build simple things, build them well

### YAGNI vs DRY: Timing Difference

**DRY Says**: "After 3rd duplication, abstract" (Rule of Three)
**YAGNI Says**: "Don't create abstraction for hypothetical 3rd use case"

### Example
- Two similar functions exist (email validation, phone validation)
- **YAGNI**: Don't create `GenericValidator` class "in case we add SSN validation"
- **DRY**: If SSN validation is ACTUALLY added (3rd instance), THEN abstract

### YAGNI vs KISS: Complementary

**KISS**: Keep current solution simple
**YAGNI**: Don't add features that complicate future

**Both say**: Build less, build simpler

## Decision Framework

### Before adding ANY feature, ask

1. **Is this required NOW?**
   - ✅ Yes, user story demands it → Build it
   - ❌ No, "might need later" → Don't build it

2. **Is this code quality (not feature)?**
   - ✅ Tests, refactoring, clean code → Always allowed (YAGNI exception)
   - ❌ Speculative feature → YAGNI applies

3. **Can I defer this?**
   - ✅ Yes, can build when needed → Defer
   - ❌ No, required for current work → Build now

4. **What are the 3 costs?**
   - **Build**: How long to build?
   - **Delay**: What am I NOT building instead?
   - **Carry**: How much complexity does this add?

## YAGNI in Code Review

### Red Flags
- "This might be useful later"
- "We'll probably need this for..."
- "Just in case we want to..."
- "Future-proofing for when..."
- TODO comments for features not in roadmap

### Review Questions
1. "Is this feature in current sprint?"
2. "Can you link the user story requiring this?"
3. "What happens if we delete this and add it later?"

## Examples from Self-Improvement Engine

### ✅ YAGNI Compliant

**1. Validation Functions** (added in recent PR):
```bash
validate_history() { ... }   # ACTUALLY used in cmd_detect, cmd_cycle
validate_patterns() { ... }  # ACTUALLY used in cmd_detect, cmd_cycle
validate_commands() { ... }  # ACTUALLY used in cmd_detect, cmd_cycle
```text
**Why**: These are CURRENTLY needed, not speculative.

### 2. Pattern Count
- Started with 11 patterns
- Added `context-loss`, `grep-usage-in-scripts` when ACTUALLY detected
- Didn't pre-add 20 patterns "we might detect later"

### ❌ YAGNI Violation (hypothetical)

### If we had added
```bash
validate_docker() { ... }    # Script doesn't use Docker yet
validate_kubernetes() { ... } # No K8s integration
validate_ci_environment() { ... } # Not running in CI yet
```text
**Why**: Speculative. Don't exist yet. YAGNI violation.

## Metrics

**YAGNI Violations = Wasted Effort**

| Violation Type | Time Cost | Token Cost | Maintenance Cost |
|----------------|-----------|------------|------------------|
| Premature OAuth | 2-3 weeks | 20k+ tokens | Ongoing security updates |
| Unused abstractions | 1-2 days | 3-5k tokens | Cognitive load on every change |
| Speculative config | 2 hours | 500 tokens | Dead code confusion |

## Summary

**YAGNI in one sentence**: Build features when you actually need them, not when you think you might need them.

### Remember
- You can't predict the future
- Code you don't write is code you don't maintain
- Deferring is not procrastinating—it's wisdom
- YAGNI is about features, not code quality
