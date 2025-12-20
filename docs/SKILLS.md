# Skills Reference

Complete catalog of all 36 Claude-Optim skills.

Skills are task-specific protocols organized in `~/.claude/skills/`. They load automatically based on task relevance.

## Skill Categories

### Session Management

| Skill | Command | Description |
|-------|---------|-------------|
| context-refresh | `/refresh-context` | Rebuild mental model at session start. 7-step discovery protocol in <3000 tokens. |
| session-resume | `/resume-session` | Bridge CIPS with Claude Code's `--resume`. Fresh mode provides ~2k semantic context. |
| check-last-plan | `/check-last-plan` | Persist plan context across sessions. Auto-caches on ExitPlanMode. |
| preplan | `/preplan` | Intent Injection - prepare executable plans for future CIPS sessions. ~1000 token savings. |
| session-state-persistence | - | Auto-update state files on milestone completion. |
| chat-history-search | `/remind-yourself` | Search past conversations. Use epoch timestamp filtering for precision. |

### Development Workflow

| Skill | Command | Description |
|-------|---------|-------------|
| pr-automation | `/create-pr` | Efficient PR creation with gh CLI, <2k tokens per PR. |
| gitops | `/gitops` | GitOps workflow for trunk-based development, branch strategy, releases. |
| branch-cleanup | `/prune-branches` | Git branch pruning with safety gates and dry-run previews. |
| github-actions-setup | `/setup-ci` | Auto-configure CI/CD workflows from global templates. |
| github-secrets-setup | `/setup-github-secrets` | Securely upload secrets via gh CLI. NEVER commits secrets. |

### Code Quality

| Skill | Command | Description |
|-------|---------|-------------|
| design-principles | `/design-principles` | Unified SOLID/GRASP/DRY/KISS/YAGNI principles. |
| markdown-expert | `/markdown-lint` | Auto-fix markdown linting violations (MD040, MD022, etc.). |
| batch-edit-enforcer | - | Enforce MultiEdit over individual Edit calls. |
| code-agentic | - | Agentic execution protocols with verification gates. |

### Testing

| Skill | Command | Description |
|-------|---------|-------------|
| e2e-test-generation | `/generate-e2e-tests` | Playwright + Vitest + MSW infrastructure. 80%+ coverage. <15k tokens. |

### UI/UX

| Skill | Command | Description |
|-------|---------|-------------|
| mobile-responsive-ui | `/audit-mobile-responsive` | Mobile-first with TailwindCSS, dvh/container queries. 2025 best practices. |
| figma-to-code | `/figma` | Figma design → production code with 1:1 visual parity. |
| image-optim | `/image-optim` | macOS image optimization via ImageOptim + optional ImageMagick pre-processing. |

### Documentation

| Skill | Command | Description |
|-------|---------|-------------|
| auto-update-documentation | `/update-docs` | Synthesize session history + git commits. Token budget ~3500. |
| medium-article-writer | `/write-medium-article` | Auto-generate Medium-style technical articles. |
| enter-konsult-pdf | `/generate-pdf` | Professional PDFs in ENTER Konsult brand style (Swiss Minimalism). |

### Legal

| Skill | Command | Description |
|-------|---------|-------------|
| legal-ops | `/contract-formal` | Senior attorney-level contracts. Contra proferentem compliant. |
| legal-ops | `/contract-simplification` | Plain language versions for client understanding. |

### API/Integration

| Skill | Command | Description |
|-------|---------|-------------|
| api-reverse-engineering | `/reverse-api` | Reverse engineer authenticated web APIs from DevTools captures. |

### System Improvement

| Skill | Command | Description |
|-------|---------|-------------|
| self-improvement-engine | `/auto-improve` | 10-step improvement cycle. Pattern detection → skill generation. |
| recursive-learning | - | Learn from errors, generate skills to prevent recurrence. |
| meta-improvement-switch | - | Pause project work to enhance infrastructure, then resume. |
| agent-auto-creator | `/create-agent` | Create new agents from template. |

### Efficiency

| Skill | Command | Description |
|-------|---------|-------------|
| dependency-guardian | - | Block reads from node_modules/ and build folders. |
| concise-communication | - | No preambles, action-first communication. |
| bash-tool-enforcer | - | Enforce rg over grep, fd over find. |
| bash-command-safety | - | Prevent semicolon-after-subshell anti-pattern. |

### Utilities

| Skill | Command | Description |
|-------|---------|-------------|
| agy | `/agy` | Open file in Google Antigravity IDE with intelligent inference. Fast-fail if ambiguous. |
| node-cleanup | `/node-clean` | Clean up node_modules and build artifacts. |
| gitignore-auto-setup | - | Automatic .gitignore creation to prevent token waste. |
| meta-unused_skills-blocker | - | Block generation of low-usage skills. |

### macOS Automation

| Skill | Command | Description |
|-------|---------|-------------|
| launchd-automation | `/setup-launchd` | Self-reloading launchd agents with WatchPaths + plutil validation. |

## Full Skill Descriptions

### api-reverse-engineering

Systematically reverse engineer authenticated web APIs from browser DevTools captures. Builds authenticated client, parameter mapper, validation system, and monitoring alerts. Legal when using own credentials.

### chat-history-search

Search past conversations and maintain context across sessions. **Always verify timestamp direction (HEAD=oldest, TAIL=newest) before scraping logs.** Use epoch timestamp filtering for temporal precision.

### claude-code-agentic

Agentic execution protocols with verification gates, rollback mechanisms, and confidence thresholds.

### context-refresh

Systematically rebuild mental model of any repository when starting fresh sessions. Eliminates "cold start" problem by executing 7-step discovery protocol in <3000 tokens.

### design-principles

Unified software design principles - SOLID, GRASP, DRY, KISS, YAGNI. Consolidates 5 previous separate skills into one comprehensive reference.

### e2e-test-generation

Automated E2E test infrastructure setup with Playwright, Vitest, MSW, and GitHub Actions. Generates 80%+ coverage tests based on proven production patterns (366 tests). Creates config files, test templates, CI/CD workflow, and comprehensive documentation.

### enter-konsult-pdf

Generate professional PDF documents and blog-ready HTML in ENTER Konsult brand style (Swiss Minimalism). Full-bleed Paper Grey background (#EAEAEA), orange accents (#ea580c), pandoc+weasyprint generation.

### figma-to-code

Figma design → production code with 1:1 visual parity. Handles design tokens, component extraction, and responsive implementation.

### image-optim

macOS-only image optimization using ImageOptim CLI. Lossless compression, metadata removal, with optional ImageMagick pre-processing for resize/convert.

### gitops

GitOps workflow automation for trunk-based development, branch strategy, release management, and deployment patterns.

### legal-ops

Multi-faceted legal document generation:

- **Formal contracts**: Senior attorney level, contra proferentem compliant
- **Simplified versions**: Plain language for client understanding

Extends Claude Code beyond coding to professional legal operations.

### mobile-responsive-ui

Mobile-first responsive design enforcement:

- TailwindCSS patterns
- dvh/svh/lvh viewport units with fallbacks
- Container queries
- Touch targets (min 48px)
- Framework-specific guidance (React, Vue, vanilla)

### pr-automation

Efficient PR creation with gh CLI. Complete workflow: branch → stage → commit → push → pr create. <2k tokens per PR.

### self-improvement-engine

Meta-skill that automates the 10-step improvement cycle:

1. Pattern detection
2. Skill generation
3. Command creation
4. Agent creation
5. Documentation updates

**FULLY OPERATIONAL** via `~/.claude/optim.sh` with true recursion.

### session-resume

Intelligent session resumption bridging CIPS with Claude Code's `--resume`. Supports resume by instance ID, generation, slug, or "latest". Fresh mode provides ~2k semantic context instead of full history.

### launchd-automation

Self-reloading macOS launchd agents with automatic plist validation:

- Two-agent architecture (main + watcher)
- WatchPaths triggers reload on plist edit
- plutil syntax validation before reload
- WakeFromSleep for reliable scheduled execution
- Complete templates for common schedule patterns

Origin: NalaMatch nannysync implementation (Gen 15, Dec 2025).

## Skill Location

All skills are stored in `~/.claude/skills/{skill-name}/SKILL.md`.

To view a skill's full protocol:

```bash
cat ~/.claude/skills/{skill-name}/SKILL.md
```
