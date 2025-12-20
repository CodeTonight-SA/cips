# Agents Reference

Complete documentation for all 28 Claude-Optim agents.

## Agent Categories

### Critical Priority (Auto-Trigger)

These agents activate automatically and provide foundational efficiency.

#### Context Refresh Agent

- **Model**: Haiku 4.5
- **Purpose**: Session start optimization using multi-source semantic understanding
- **Token Budget**: <3000 per refresh
- **Activation**: Session start, or `/refresh-context` command
- **Savings**: 5k-8k tokens per session (eliminates redundant file reads)
- **Protocol**: 7-step discovery: session history + git commits + file changes = complete mental model

#### Dependency Guardian Agent

- **Model**: Haiku 4.5
- **Purpose**: Real-time monitoring to block node_modules/ and build folder reads
- **Token Budget**: ~100 (monitoring overhead)
- **Activation**: Automatic (monitors all file operations)
- **Savings**: Prevents 50k+ token waste per violation
- **Protocol**: Intercepts Read operations, checks against forbidden paths, blocks with warning

#### File Read Optimizer Agent

- **Model**: Haiku 4.5
- **Purpose**: Session-level cache to prevent redundant file reads
- **Token Budget**: ~200 (cache management)
- **Activation**: Automatic (before all Read tool calls)
- **Savings**: 5k-10k tokens per session
- **Protocol**: Tracks read history, checks git status, serves from cache when safe

### High Priority (Common Tasks)

Frequently used agents for common development workflows.

#### PR Workflow Agent

- **Model**: Sonnet 4.5
- **Purpose**: Complete PR automation from branch creation to submission
- **Token Budget**: <2000 per PR
- **Activation**: "create PR", "open pull request", `/create-pr` command
- **Savings**: 1k-2k tokens per PR (eliminates multi-step manual workflow)
- **Protocol**: Branch → stage → commit → push → gh pr create with smart summary generation

#### History Mining Agent

- **Model**: Haiku 4.5
- **Purpose**: Search past conversations to prevent duplicate problem-solving
- **Token Budget**: ~800 per search
- **Activation**: "have we done this before", "search history", `/remind-yourself` command
- **Savings**: 5k-20k tokens (avoids re-discovering solutions)
- **Protocol**: Epoch timestamp filtering, pattern matching, relevance scoring

#### Doc Updater Agent

- **Model**: Haiku 4.5
- **Purpose**: Automatically update project documentation from session history + git commits
- **Token Budget**: ~3500 per execution
- **Activation**: `/update-docs` command, after PR creation (suggested)
- **Savings**: Manual doc updates eliminated, keeps docs within 24h of actual state
- **Protocol**: 5-phase (history mining, git analysis, state synthesis, targeted updates, verification)

#### Auth Debugging Agent

- **Model**: Sonnet 4.5
- **Purpose**: Debug OAuth/OIDC authentication issues including callback errors and provider misconfigurations
- **Token Budget**: ~15000 per debug session
- **Activation**: OAuth callback errors, AADSTS errors, Cognito errors, `@auth-debugging` command
- **Savings**: 10k-20k tokens (systematic debugging vs trial-and-error)
- **Protocol**: 6-phase diagnostic (error analysis → config audit → pattern matching → web search → fix → verify)

### Quality Gates (Proactive)

Agents that enforce quality standards and prevent anti-patterns.

#### Efficiency Auditor Agent

- **Model**: Haiku 4.5
- **Purpose**: Real-time workflow analysis with violation scoring
- **Token Budget**: ~600 per audit
- **Activation**: End of workflow, `/audit-efficiency` command
- **Output**: Efficiency score (0-100), violation breakdown, improvement recommendations
- **Protocol**: Analyzes conversation history against EFFICIENCY_CHECKLIST.md patterns

#### YAGNI Enforcer Agent

- **Model**: Haiku 4.5
- **Purpose**: Prevents over-engineering by challenging speculative features
- **Token Budget**: ~400 (intervention)
- **Activation**: Planning phase, "make it flexible", architecture discussions
- **Protocol**: Detects premature abstraction, asks "Do you need this NOW?", proposes simpler alternative

#### GRASP Enforcer Agent

- **Model**: Opus
- **Purpose**: Enforces GRASP principles for proper responsibility assignment
- **Token Budget**: ~2500 per review
- **Activation**: Class design, "which class should", architecture review
- **Protocol**: Analyses against 9 GRASP patterns (Information Expert, Creator, Controller, Low Coupling, High Cohesion, Polymorphism, Pure Fabrication, Indirection, Protected Variations)

#### DRY/KISS Enforcer Agent

- **Model**: Haiku 4.5
- **Purpose**: Eliminates duplication and over-complexity
- **Token Budget**: ~1500 per review
- **Activation**: Code duplication detected, refactoring, "too complex"
- **Protocol**: Applies Rule of Three, detects copy-paste, challenges over-engineering

#### SOLID Enforcer Agent

- **Model**: Sonnet 4.5
- **Purpose**: Enforces SOLID principles for clean architecture
- **Token Budget**: ~2000 per review
- **Activation**: Class design, interface creation, dependency injection
- **Protocol**: Validates SRP, OCP, LSP, ISP, DIP compliance

#### Direct Implementation Agent

- **Model**: Sonnet 4.5
- **Purpose**: Eliminates intermediate temp scripts by choosing most direct path
- **Token Budget**: ~1000 (analysis + execution)
- **Activation**: Multi-step workflows, temp script creation detected
- **Savings**: 2k-5k tokens (skips script → run → parse → apply pattern)
- **Protocol**: Evaluates workflow, identifies direct path (e.g., MultiEdit vs script)

#### Mobile Responsive Fixer Agent

- **Model**: Sonnet 4
- **Purpose**: Auto-fix mobile responsive issues in HTML, CSS, and component files
- **Token Budget**: ~3000 per invocation
- **Activation**: HTML/CSS/TSX/JSX edits, `/audit-mobile-responsive --fix` command
- **Savings**: 2k-5k tokens (avoids manual responsive fixes)
- **Protocol**: Detect anti-patterns, add dvh fallbacks, ensure touch targets, add responsive prefixes

#### Markdown Expert Agent

- **Model**: Haiku 4.5
- **Purpose**: Auto-fix markdown linting violations
- **Token Budget**: ~600 per file
- **Activation**: .md file create/edit, `/markdown-lint` command
- **Fixes**: MD040 (language tags), MD022/031/032 (blank lines), MD012 (multiple blanks), MD013 (line length)
- **Manual Review**: MD036 (bold as heading), MD024 (duplicate headings)
- **Protocol**: Scans with patterns, applies safe fixes, flags semantic issues

#### Plan Persistence Agent

- **Model**: Haiku 4.5
- **Purpose**: Background caching and retrieval of plan context across sessions
- **Token Budget**: ~200 (minimal overhead)
- **Activation**: Automatic (session-start, ExitPlanMode tool call)
- **Savings**: Prevents cold-start context loss on plans
- **Protocol**: Cache on ExitPlanMode, retrieve on session-start, expose via /check-last-plan
- **Architecture**: Reference implementation of unified skill/command/agent pattern

#### Node Cleanup Agent

- **Model**: Haiku 4.5
- **Purpose**: Clean up node_modules and build artifacts to save disk space
- **Token Budget**: ~500 per cleanup
- **Activation**: `/node-clean` command, disk space warnings
- **Protocol**: Identify stale node_modules, calculate space savings, confirm before deletion

#### Image Optim Agent

- **Model**: Haiku 4.5
- **Purpose**: Optimize images using ImageOptim (macOS only)
- **Token Budget**: ~500 per invocation
- **Activation**: `/image-optim` command, "optimize images"
- **Protocol**: Validate ImageOptim, optional ImageMagick pre-processing, run optimization, report savings

## Agent vs Skill Distinction

**Skills** (Passive Reference):

- Markdown files in `~/.claude/skills/`
- Loaded as context/reference material
- Define protocols and best practices
- Examples: yagni-principle, dry-kiss-principles

**Agents** (Active Execution):

- Specialized sub-agents with isolated context
- Can execute tasks autonomously
- Have tool access and token budgets
- Examples: PR Workflow Agent, Context Refresh Agent

**Relationship**: Agents implement protocols defined in skills

- PR Workflow Agent ← implements pr-automation skill
- Context Refresh Agent ← implements context-refresh skill
- Markdown Expert Agent ← implements markdown-expert skill

## Usage Patterns

### Explicit Invocation

```text
Use @agent-name or delegate specific task
Example: "Use Context Refresh Agent to build mental model"
```

### Automatic Triggering

- Dependency Guardian: Monitors all file operations
- File Read Optimizer: Intercepts Read tool calls
- Markdown Expert: Triggers on .md file edits

### Command Shortcuts

| Command | Agent |
|---------|-------|
| `/refresh-context` | Context Refresh Agent |
| `/create-pr` | PR Workflow Agent |
| `/remind-yourself` | History Mining Agent |
| `/audit-efficiency` | Efficiency Auditor Agent |
| `/markdown-lint` | Markdown Expert Agent |

## Token Savings Summary

**Per Session (Cumulative)**:

- Context Refresh: 5k-8k (session start optimization)
- Dependency Guardian: 0-50k (prevention, when violations occur)
- File Read Optimizer: 5k-10k (cache hits)
- PR Workflow: 1k-2k (per PR created)
- History Mining: 5k-20k (per search, when relevant)

**Total Average**: 63k-73k tokens saved per session (30-35% of 200k budget)

## Setup Guide

See [AGENTS_SETUP_GUIDE.md](../AGENTS_SETUP_GUIDE.md) for complete setup instructions, troubleshooting, and advanced usage.
