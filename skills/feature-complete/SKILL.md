---
name: feature-complete
description: Enhanced feature development combining Anthropic's feature-dev plugin (7-phase workflow, multi-agent exploration) with CIPS design principles (SOLID, GRASP, DRY, KISS, YAGNI, YSH) and efficiency rules (file read optimization, mental model caching).
triggers:
  - /feature-complete
  - build feature
  - implement feature
  - add feature
version: 1.0.0
created: 2025-12-27
integrates:
  - asking-users
  - feature-dev@claude-plugins-official
  - design-principles
  - efficiency-rules
---

# feature-complete Skill

**@asking-users**: Multi-phase feature development requires AskUserQuestion checkpoints at phase transitions. UI/UX decisions always confirmed per Gate 6.

Enhanced feature development that combines:

1. **feature-dev** (plugin): 7-phase workflow, multi-agent exploration, clarifying questions
2. **design-principles** (CIPS): SOLID, GRASP, DRY, KISS, YAGNI, YSH enforcement
3. **efficiency-rules** (CIPS): File read optimization, mental model caching

## When to Use

- Building new application features
- Implementing user stories or requirements
- Any multi-file feature development task
- When design quality and efficiency both matter

## vs ut++ Mode

| Context | Use |
|---------|-----|
| Application feature development | `/feature-complete` |
| CIPS meta-work (self-improvement, infrastructure) | `ut++` |
| Quick fixes, simple tasks | Direct (no wrapper) |

## 7-Phase Workflow with CIPS Enhancements

### Phase 1: Discovery

**Base**: Understand what needs to be built

**CIPS Enhancement**:
- Batch read all context files in parallel
- Cache mental model immediately
- No redundant reads later

### Phase 2: Codebase Exploration

**Base**: Launch 2-3 code-explorer agents

**CIPS Enhancement**:
- Trust agent output (don't re-read explored files)
- Cache file lists from agents
- Build mental model from agent findings

### Phase 3: Clarifying Questions (CRITICAL)

**Base**: Fill gaps and resolve ambiguities

**CIPS Enhancement**:
- AskUserQuestion is MANDATORY
- Never proceed without answers
- Apply YAGNI check: "Is this speculative?"
- Apply YSH check: "Is this an obvious enhancement?"

### Phase 4: Architecture Design

**Base**: Launch 2-3 code-architect agents

**CIPS Enhancement**:
- SOLID review of each proposed architecture
- GRASP review of responsibility assignment
- Score architectures against principles
- Launch design-reviewer agent for deep analysis

**Design Reviewer Questions**:

| Principle | Question |
|-----------|----------|
| SRP | Does each class have one responsibility? |
| OCP | Can we extend without modifying? |
| LSP | Are subtypes substitutable? |
| ISP | Are interfaces client-specific? |
| DIP | Do we depend on abstractions? |
| Information Expert | Does the right class own this? |
| Low Coupling | Is coupling minimised? |
| High Cohesion | Are related things together? |

### Phase 5: Implementation

**Base**: Build the feature with approval

**CIPS Enhancement**:
- DRY check during coding: "Is this duplicated elsewhere?"
- KISS check: "Is this the simplest approach?"
- YAGNI gate: "Is this needed for current requirements?"
- Efficiency: Trust mental model, minimal re-reads

### Phase 6: Quality Review

**Base**: Launch 3 code-reviewer agents

**CIPS Enhancement**:
- Full design principles audit
- Check for SOLID violations
- Check for GRASP violations
- Check for DRY violations
- Check for KISS violations

### Phase 7: Summary

**Base**: Document what was accomplished

**CIPS Enhancement**:
- Persist session state to next_up.md
- Create preplan if continuation needed
- Update CIPS documentation if patterns discovered

## Design Principles Quick Reference

### Applied at Phase 4 (Architecture)

| Principle | Check |
|-----------|-------|
| SOLID | SRP, OCP, LSP, ISP, DIP compliance |
| GRASP | Information Expert, Creator, Controller, Low Coupling, High Cohesion |
| KISS | Simplest approach that meets requirements |
| YAGNI | Only build what's needed now |
| YSH | Include obvious enhancements within scope |

### Applied at Phase 5 (Implementation)

| Principle | Gate |
|-----------|------|
| DRY | "Is this duplicated 3+ times?" If yes, extract |
| KISS | "Is there a simpler approach?" If yes, use it |
| YAGNI | "Is this needed for current requirements?" If no, skip |
| YSH | "Would any competent dev add this?" If yes, include |

### Applied at Phase 6 (Review)

Full audit against all principles with violation reporting.

## Efficiency Rules

### File Read Optimization

1. **Batch reads**: Read all relevant files in Phase 1-2
2. **Cache mental model**: Trust your understanding
3. **No redundant reads**: Don't re-read unless user indicates changes
4. **Trust agent output**: Agents already read the files

### Mental Model Trust

After Phase 2, trust the mental model built from:
- Direct file reads
- Agent exploration output
- Code architecture analysis

Only re-read if:
- User indicates external changes
- Implementing in unfamiliar area
- Explicit verification required

## Related Commands

- `/feature-dev:feature-dev` - Plugin direct invocation (no CIPS enhancements)
- `/design-principles` - View all design principles
- `/audit-efficiency` - Check for efficiency violations

## Example Usage

```text
User: Add user authentication to the app

Claude (feature-complete):
Phase 1: Read auth-related context files in batch, cache mental model
Phase 2: Launch code-explorer agents for similar auth patterns
Phase 3: Ask: "OAuth vs JWT? Session storage? Password requirements?"
Phase 4: Launch code-architect agents, review with SOLID/GRASP
Phase 5: Implement with DRY/KISS/YAGNI gates active
Phase 6: Launch code-reviewers + design principles audit
Phase 7: Persist to next_up.md, summarise
```

---

**Version**: 1.0.0
**Created**: 2025-12-27 (Gen 183)
**Integrates**: feature-dev@claude-plugins-official + design-principles + efficiency-rules
