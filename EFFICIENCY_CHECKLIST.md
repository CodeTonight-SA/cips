# Efficiency Checklist

Real-time audit checklist for adherence to Critical Efficiency Rules. Use during any workflow to track violations and maintain token efficiency.

## Scoring System

- **Perfect**: 0 violations
- **Good**: 1-2 minor violations
- **Needs Improvement**: 3-5 violations
- **Critical**: 6+ violations or any major violation

## Violation Categories

### Major Violations (10 points each)

- Reading same file 3+ times without user edit
- Creating temp script for simple batch operation
- Using multiple tool calls when 1 CLI command suffices
- Reading from node_modules/ or venv/ without exclusions
- Executing plan item that doesn't improve code
- Building features before they're requested (YAGNI violation)
- Invoking Skill tool when action is trivially inferable (3k+ token waste)

### Minor Violations (3 points each)

- Reading same file twice in 10 messages
- Unnecessary preamble/postamble
- Asking permission instead of executing
- Not using batch operations when available
- Verbose explanations when concise suffices

## Rule 1: File Read Optimization

### Checklist

- [ ] Checked conversation buffer before read?
- [ ] File last read within 10 messages?
- [ ] User indicated external changes?
- [ ] Phase 1 batch read completed?
- [ ] Trusting mental model in Phase 2+?

### Common Violations

❌ Re-reading `package.json` to check dependencies already cached  
❌ Reading `tsconfig.json` again after no edits  
❌ Not batching initial discovery reads  
✅ Single batch read of all relevant files upfront  
✅ Trusting buffer memory after edits

### Token Impact

- Unnecessary re-read: ~500-2000 tokens
- Missing batch read: 3-5x more reads than needed

## Rule 2: Plan Item Evaluation Gate

### Checklist

- [ ] Read current state before executing?
- [ ] Evaluated if change actually needed?
- [ ] Proposed skip if code already satisfies?
- [ ] Asked clarification if uncertain?
- [ ] Avoided checklist-following blindly?

### Common Violations

❌ Extracting sections when code already modular  
❌ Adding interfaces when they exist  
❌ Refactoring optimal structure  
✅ Skipping unnecessary extraction  
✅ Verifying need before execution

### Token Impact

- Unnecessary plan execution: ~5000-10000 tokens
- Wasted edits on already-correct code: ~2000-5000 tokens

## Rule 3: Implementation Directness

### Checklist

- [ ] Chose most direct implementation path?
- [ ] Used MultiEdit for batch changes?
- [ ] Avoided temp script for simple operations?
- [ ] Used CLI bulk operations?
- [ ] Only scripted when truly complex (>50 line regex)?

### Common Violations

❌ Creating script to transform data instead of inline  
❌ Individual file edits instead of MultiEdit batch  
❌ Multi-step process when single command suffices  
✅ MultiEdit for 6 similar file changes  
✅ Single CLI command for bulk operation

### Token Impact

- Temp script approach: ~3000-8000 tokens vs ~500 direct
- Individual edits: ~500 per file vs ~800 batch

## Rule 4: Concise Communication

### Checklist

- [ ] No preambles ("I'll now...")?
- [ ] No postambles (summaries)?
- [ ] Minimal explanation unless asked?
- [ ] Started with action?
- [ ] Ended when action completes?

### Common Violations

❌ "I'll now proceed to..." before every action  
❌ Summarizing what was just done  
❌ Explaining simple operations  
✅ Direct execution without announcement  
✅ Ending when done

### Token Impact

- Unnecessary preambles: ~50-200 tokens each
- Postambles: ~100-300 tokens each

## Rule 5: YAGNI (Feature Necessity)

### Checklist

- [ ] Feature required by current user story?
- [ ] Can this be deferred until actually needed?
- [ ] Avoided "just in case" code?
- [ ] Avoided premature abstractions?
- [ ] Configuration only for existing features?

### Common Violations

❌ Adding OAuth when only email/password needed
❌ Creating interface with single implementation
❌ Building feature flags for non-existent features
❌ "Future-proofing" for hypothetical requirements
✅ Building only what current requirements demand
✅ Deferring features until user story exists

### Token Impact

- Premature OAuth integration: ~20,000 tokens wasted
- Speculative abstractions: ~3,000-8,000 tokens
- Unused config: ~500-2,000 tokens per option

### Decision Questions

Before building:

1. Is this required NOW (not "might be")?
2. What's the cost if we build it later?
3. Am I confusing code quality with features?
4. Can I link this to a user story?

### YAGNI Exceptions

YAGNI does NOT apply to:

- Writing tests
- Refactoring for clarity
- Following SOLID principles
- Performance optimization for current features
- Security best practices

YAGNI ONLY applies to:

- Features not yet requested
- Abstractions for hypothetical cases
- "Just in case" functionality

## Rule 6: Markdown Linting Standards

### Checklist

- [ ] All code blocks have language tags (MD040)
- [ ] No bold/italics used as headings (MD036)
- [ ] Blank lines around all headings (MD022)
- [ ] Blank lines around all code blocks (MD031)
- [ ] Blank lines around all lists (MD032)
- [ ] All lines under 120 characters (MD013)
- [ ] No multiple consecutive blank lines (MD012)
- [ ] No duplicate sibling headings (MD024)

### Common Violations

**MD040 - Missing Language Tags**:

❌ WRONG - Bare code block:

```text
npm install
```

✅ CORRECT - With language tag:

```bash
npm install
```

**MD036 - Bold as Heading**:

❌ WRONG - Bold text as heading:

**Purpose:** Session optimization

✅ CORRECT - Proper heading:

## Purpose

Session optimization

**MD022/MD031/MD032 - Missing Blank Lines**:

❌ WRONG - No spacing:

```markdown
### Heading
Content here
- List item
```

✅ CORRECT - Proper spacing:

```markdown
### Heading

Content here

- List item
```

**MD013 - Line Length**:

❌ WRONG - Long skill description exceeding 120 characters:

```markdown
- **skill-name**: This is a very long description that exceeds the 120 character limit and makes markdown difficult to read
```

✅ CORRECT - Wrapped with continuation:

```markdown
- **skill-name**: This is a very long description that exceeds the 120 character limit and makes
  markdown difficult to read
```

**MD012 - Multiple Blank Lines**:

❌ WRONG - Double spacing:

```markdown
### Section 1


- Content
```

✅ CORRECT - Single blank line:

```markdown
### Section 1

- Content
```

**MD024 - Duplicate Headings**:

❌ WRONG - Same heading under same parent:

```markdown
## Features
### Example
(content)
### Example    ← Duplicate!
```

✅ CORRECT - Unique descriptive headings:

```markdown
## Features
### Example: Basic Usage
(content)
### Example: Advanced Configuration
```

### Token Impact

- Markdown errors: 1,000-3,000 tokens wasted per documentation update (re-work, confusion, linter failures)
- Prevention via /markdown-lint: ~600 tokens per file scan
- Auto-fix for MD040, MD022/031/032: Safe, automated
- Manual review for MD036, MD024: Requires semantic understanding

### Language Tag Reference

When in doubt, use these mappings:

- Shell commands → `bash` or `shell`
- Plain text/examples → `text`
- Outputs/logs → `console` or `text`
- JSON config → `json`
- YAML config → `yaml`
- TypeScript → `typescript` or `ts`
- JavaScript → `javascript` or `js`
- Python → `python`
- Pseudocode → `text`

### Automation

Use `/markdown-lint` command or let Markdown Expert Agent auto-trigger on .md file edits.

**Auto-fix Available For**:

- MD040: Adds language tags (defaults to `text` if ambiguous)
- MD022/MD031/MD032: Adds blank lines around structures
- MD012: Removes extra blank lines
- MD013: Wraps long lines (list continuation, code block splits)

**Manual Review Required For**:

- MD036: Bold text might be intentional emphasis, not a heading
- MD024: Duplicate headings under different parents are allowed

## Rule 7: Skill Tool Optimization

### Checklist

- [ ] Is the action trivially inferable?
- [ ] Do I already know the file path/command?
- [ ] Does this need protocol reference or just execution?
- [ ] Can I skip Skill tool and execute directly?

### Common Violations

❌ Loading Skill tool for `/agy known-file.md` (path obvious)
❌ Loading Skill tool for `/create-pr` on simple single-file change
❌ Loading entire skill protocol when action is one bash command
✅ Direct bash execution when path/action is clear
✅ Skill tool only for semantic inference or complex protocols

### Token Impact

- Unnecessary Skill invocation: ~2000-4000 tokens
- Direct execution: ~100-300 tokens
- **Savings: 90-95% for trivial cases**

### Decision Gate

```text
Before Skill tool invocation, ask:
"Do I already know what to do?"
├── YES → Execute directly, skip Skill tool
└── NO  → Invoke Skill tool for protocol
```

### Origin

Gen 60 (2025-12-20): Detected 3k token waste on `/agy skill md` when direct bash would suffice.

## Core Bash Tools Violations

### Checklist

- [ ] Used `rg` instead of `grep`?
- [ ] Used `fd` instead of `find`?
- [ ] Applied exclusion flags (--glob, --exclude)?
- [ ] Used `bat` for previews?
- [ ] Used `jq` for JSON?
- [ ] Chose single CLI command over multiple tools?

### Common Violations

❌ Using `grep -r` instead of `rg`
❌ Using `find` instead of `fd`
❌ Forgetting `--glob '!node_modules/*'`
❌ Multiple Read calls instead of `rg | xargs`
✅ `rg -l "pattern" | xargs sed` for bulk changes
✅ `fd -e js` for finding JavaScript files

### Token Impact

- Reading node_modules/ accidentally: ~50000+ tokens
- Multiple tool calls vs CLI: ~1000-3000 tokens saved

## Workflow Token Budget Tracking

### Phase 1: Discovery (Target: <5k tokens)

- Initial batch file reads: _____ tokens
- Codebase structure map: _____ tokens
- Violations: _____

### Phase 2: Planning (Target: <2k tokens)

- Plan generation: _____ tokens
- Plan evaluation: _____ tokens
- Violations: _____

### Phase 3: Execution (Target: <20k tokens)

- Code generation: _____ tokens
- Edits/operations: _____ tokens
- Violations: _____

### Phase 4: Verification (Target: <3k tokens)

- Testing: _____ tokens
- Validation: _____ tokens
- Violations: _____

### Total Workflow

- **Target**: <30k tokens
- **Actual**: _____ tokens
- **Efficiency Score**: _____ / 100
- **Major Violations**: _____
- **Minor Violations**: _____

## Anti-Pattern Examples

### Anti-Pattern: Redundant Reads

```text
Read package.json (line 1)
Edit package.json (line 100)
Read package.json again (line 150)  # VIOLATION
```text

### Good Pattern: Buffer Memory
```text
Read package.json (line 1)
[Store in mental model: has express@4.18.0]
Edit package.json (line 100)
[Update mental model: added typescript@5.0.0]
Use mental model without re-read
```text

### Anti-Pattern: Individual Edits
```text
Edit component1.tsx
Edit component2.tsx
Edit component3.tsx
Edit component4.tsx
Edit component5.tsx
Edit component6.tsx
```text

### Good Pattern: Batch MultiEdit
```text
MultiEdit [component1, component2, component3, component4, component5, component6]
```text

### Anti-Pattern: Temp Script
```bash
# Create extract-names.js
# Run node extract-names.js > names.txt
# Read names.txt
# Parse and apply manually
# Delete script
```text

### Good Pattern: Direct CLI
```bash
rg -o '"name":\s*"([^"]+)"' --replace '$1' data.json
```text

## Real-Time Audit Questions

Ask yourself continuously:

1. **Have I read this file in the last 10 messages?**
   - If yes → Use buffer memory
   - If no → Read once, then trust buffer

2. **Can this be done in 1 CLI command?**
   - If yes → Use CLI
   - If no → Verify complexity justifies multi-step

3. **Does executing this plan item improve code?**
   - If yes → Execute
   - If no → Propose skip
   - If uncertain → Ask user

4. **Am I explaining when I should be executing?**
   - If yes → Stop explaining, start doing
   - If no → Continue

5. **Is this script temporary for a simple task?**
   - If yes → Do it inline/CLI instead
   - If no → Script justified

## Session Summary Template

```markdown
## Efficiency Report

**Workflow**: [Description]
**Token Usage**: [Actual] / [Target]
**Efficiency Score**: [Score] / 100

### Violations
- Major: [Count]
- Minor: [Count]

### Top Issues
1. [Issue description]
2. [Issue description]
3. [Issue description]

### Improvements Made
1. [Improvement description]
2. [Improvement description]

### Next Session Goals
- [ ] Reduce file re-reads by X%
- [ ] Increase batch operations usage
- [ ] Eliminate temp scripts
```text

---

## Session: ExampleApp Auth Page Redesign (2025-11-06)

### Workflow Overview
**Task**: Redesign login/register pages for visual consistency with landing page, create reusable link component, automate PR creation, document PR workflow as skill.

### Token Usage
- **Phase 1 (Discovery)**: ~6k (file reads, skills discovery, web search)
- **Phase 2 (Planning)**: ~3k (plan generation, enhanced with skills)
- **Phase 3 (Execution)**: ~9k (MultiEdit operations, component creation, PR workflow)
- **Phase 4 (Documentation)**: ~4k (skill creation, CLAUDE.md update, efficiency tracking)
- **Total**: ~22k / 30k target ✅

### Efficiency Score: 92/100

### Violations
- **Major**: 0
- **Minor**: 2
  1. Read register page twice (user made edit between reads - acceptable)
  2. Web search for `gh pr` reference (could have been cached from past sessions)

### Wins
✅ **MultiEdit Usage**: 5 separate MultiEdit operations (login, register, footer, etc.)
✅ **Component Reusability**: Created AppLinkButton (DRY) - used in 3 locations immediately
✅ **No Temp Scripts**: All changes via direct edits
✅ **Skill Documentation**: Automated pattern → documented as pr-automation skill
✅ **Efficient PR Creation**: <2k tokens for complete PR workflow (branch, commit, push, create)
✅ **Batch Git Operations**: Single command chains (`git add X Y Z && git rm A B`)

### Pattern Recognition Applied
1. **Identified reusable workflow** (PR creation)
2. **Documented as skill** (`pr-automation/SKILL.md`)
3. **Added to global config** (`CLAUDE.md` skills list)
4. **Committed to skills repo** (`~/.claude` repo updated)
5. **Updated efficiency tracking** (this entry)

### Token Budget Breakdown
| Phase | Budget | Actual | Variance |
|-------|--------|--------|----------|
| Discovery | 5k | 6k | +1k (web search) |
| Planning | 2k | 3k | +1k (enhanced plan) |
| Execution | 20k | 9k | -11k (efficient!) |
| Documentation | 3k | 4k | +1k (comprehensive skill) |
| **Total** | **30k** | **22k** | **-8k** ✅ |

### Key Optimizations
1. **Cached file memory** - Didn't re-read files after edits (trusted mental model)
2. **Batch edits** - MultiEdit for related changes (not individual Edits)
3. **HEREDOC usage** - Proper formatting for git commit messages and PR bodies
4. **Single-pass refactoring** - No iteration loops
5. **Skills integration** - Applied `programming-principles`, `mobile-responsive-ui` from discovery phase

### Components Created
- `AppLinkButton` (51 lines) - Reusable link component with variants
- `AppConfetti` (173 lines) - Easter egg animation (previous session)
- `pr-automation` skill (535 lines) - PR workflow documentation

### Pattern Documented
### PR Automation Workflow
1. Analyze changes (`git status`, `git diff`)
2. Create feature branch (if needed)
3. Stage files with batch operations
4. Commit with HEREDOC message format
5. Push with `-u` flag
6. Create PR with `gh pr create` (HEREDOC body)
7. Return PR URL
8. **Token budget: <2k per PR**

### Next Session Goals
- [ ] Apply pr-automation skill when user requests PR
- [ ] Create slash command mapping: `/create-pr` → pr-automation skill
- [ ] Add skill for automated testing before PR creation
- [ ] Reduce web searches (cache common CLI command formats)

### Files Modified (Example)
- `app/auth/login/page.tsx` (93 lines changed)
- `app/auth/register/page.tsx` (61 lines changed)
- `components/app-link-button.tsx` (51 lines, new)
- `app/page.tsx` (76 lines changed - footer links refactored)

### Files Created (Skills)
- `~/.claude/skills/pr-automation/SKILL.md` (535 lines)
- `~/.claude/templates/github-workflows/` (directory structure)

### PR Created
**URL**: https://github.com/your-org/your-project/pull/35
**Title**: "Redesign auth pages for visual consistency"
**Status**: Open, awaiting review

### Lessons Learned
1. **Pattern recognition is key** - When you repeat a workflow, document it as a skill
2. **HEREDOC > string escaping** - Always use HEREDOC for multi-line git/gh commands
3. **Batch operations save tokens** - Single command with multiple args > multiple commands
4. **Skills repo is valuable** - Centralizing automation patterns enables cross-project reuse
5. **Efficiency tracking works** - Real-time monitoring kept this session 27% under budget

## Skills Integration

When skills are active, verify:
- [ ] Skill loaded only when relevant?
- [ ] Skill instructions followed?
- [ ] No redundant skill content in context?
- [ ] Progressive disclosure working?

Each skill should add ~30-50 tokens until loaded, then 1000-3000 tokens when active.

## Continuous Improvement

After each workflow:
1. Count violations by category
2. Calculate efficiency score
3. Identify top 3 improvement areas
4. Set specific goals for next session
5. Track progress over time

**Goal**: Maintain <2 violations per workflow within 4 weeks.
