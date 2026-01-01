---
description: Enhanced feature development combining feature-dev (7-phase workflow) with CIPS design principles (SOLID, GRASP, DRY, KISS, YAGNI)
argument-hint: Feature description
---

# feature-complete

Invoke the enhanced feature development skill that combines:

1. **feature-dev** (plugin): 7-phase workflow, multi-agent exploration, clarifying questions
2. **design-principles** (CIPS): SOLID, GRASP, DRY, KISS, YAGNI, YSH enforcement
3. **efficiency-rules** (CIPS): File read optimization, mental model caching

## 7-Phase Workflow with CIPS Enhancements

| Phase | Base (feature-dev) | CIPS Enhancement |
|-------|-------------------|------------------|
| 1. Discovery | Understand requirements | Batch read, cache mental model |
| 2. Exploration | Multi-agent codebase analysis | Trust agent output, no re-reads |
| 3. Questions | Clarify ambiguities | YAGNI/YSH checks, AskUserQuestion mandatory |
| 4. Architecture | Design approaches | SOLID/GRASP review via design-reviewer agent |
| 5. Implementation | Build feature | DRY/KISS/YAGNI gates active |
| 6. Review | Quality audit | Full design principles audit |
| 7. Summary | Document | Persist to next_up.md |

## Usage

```
/feature-complete                    # General feature task
/feature-complete user authentication # Specific feature
```

## Mode Selection

- Use `/feature-complete` for application feature development
- Use `ut++` for CIPS meta-work (self-improvement, infrastructure)
- Use direct execution for simple/trivial tasks

See: ~/.claude/skills/feature-complete/SKILL.md
