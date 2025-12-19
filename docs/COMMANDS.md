# Commands Reference

Complete list of all 26 Claude-Optim slash commands.

## Command Quick Reference

| Command | Description | Token Savings |
|---------|-------------|---------------|
| `/refresh-context` | Rebuild mental model at session start | 5k-8k |
| `/create-pr` | Complete PR automation workflow | 1k-2k |
| `/remind-yourself` | Search past conversations | 5k-20k |
| `/resume-session` | Resume session by CIPS reference | ~2k fresh |
| `/audit-efficiency` | Run efficiency audit with scoring | ~600 |
| `/markdown-lint` | Scan and fix markdown violations | ~600 |
| `/contract-formal` | Generate attorney-level contracts | - |
| `/contract-simplification` | Plain language contract versions | - |
| `/create-agent` | Create new agent from template | - |
| `/install-mcp` | Install MCP servers automatically | - |
| `/generate-e2e-tests` | Setup Playwright test infrastructure | - |
| `/reverse-api` | API reverse engineering workflow | - |
| `/update-docs` | Auto-update project documentation | ~3500 |
| `/audit-mobile-responsive` | Audit codebase for responsive issues | ~2000 |
| `/generate-pdf` | Generate ENTER Konsult branded PDF | ~3000 |
| `/check-last-plan` | Load cached plan from previous session | ~200 |
| `/design-principles` | SOLID/GRASP/DRY/KISS/YAGNI reference | - |
| `/figma` | Figma to code conversion | - |
| `/setup-ci` | GitHub Actions setup | - |
| `/gitops` | Branch strategy and releases | - |
| `/prune-branches` | Git branch cleanup | - |
| `/setup-github-secrets` | Upload GitHub secrets securely | - |
| `/node-clean` | Clean node_modules and build | - |
| `/save-session-state` | Save session state to next_up.md | - |
| `/resurrect-instance` | Resurrect CIPS instance | - |
| `/write-medium-article` | Generate Medium-style article | - |

## Commands by Category

### Session Management

```bash
/refresh-context              # Build mental model at session start
/resume-session latest        # Resume last session
/resume-session gen:5         # Resume specific generation
/check-last-plan              # Load cached plan
/save-session-state           # Checkpoint to next_up.md
/resurrect-instance           # Resurrect CIPS instance
```

### Development Workflow

```bash
/create-pr                    # Complete PR automation
/remind-yourself "topic"      # Search past conversations
/gitops                       # Branch strategy guidance
/prune-branches               # Git branch cleanup
/setup-ci                     # GitHub Actions setup
/setup-github-secrets         # Upload secrets securely
```

### Code Quality

```bash
/audit-efficiency             # Run efficiency audit
/markdown-lint                # Fix markdown violations
/design-principles            # SOLID/GRASP/DRY/KISS/YAGNI
/audit-mobile-responsive      # Check responsive design
```

### Testing

```bash
/generate-e2e-tests           # Setup Playwright infrastructure
```

### Documentation

```bash
/update-docs                  # Auto-update documentation
/generate-pdf                 # ENTER Konsult branded PDF
/write-medium-article         # Generate technical article
```

### Legal

```bash
/contract-formal "service"    # Attorney-level contract
/contract-simplification      # Plain language version
```

### Integration

```bash
/reverse-api                  # Reverse engineer API
/figma                        # Figma to code
/install-mcp                  # Install MCP server
```

### System

```bash
/create-agent                 # Create new agent
/node-clean                   # Clean node_modules
```

## Command Details

### /refresh-context

Rebuild mental model at session start using 7-step discovery protocol:

1. Check git status
2. Read recent commits
3. Scan project structure
4. Identify key files
5. Check session history
6. Build dependency graph
7. Report findings

**Token Budget**: <3000
**Savings**: 5k-8k per session

### /create-pr

Complete PR automation:

1. Create/checkout branch
2. Stage changes
3. Generate commit message
4. Push to remote
5. Create PR with summary

**Token Budget**: <2000
**Savings**: 1k-2k per PR

### /remind-yourself

Search past conversations for solutions:

```bash
/remind-yourself "authentication implementation"
/remind-yourself "how did we fix the API bug"
```

Uses epoch timestamp filtering and relevance scoring.

**Token Budget**: ~800
**Savings**: 5k-20k (avoids rediscovery)

### /resume-session

Resume previous session with CIPS integration:

```bash
/resume-session latest           # Most recent
/resume-session gen:5            # By generation
/resume-session 14d5f954         # By instance ID
/resume-session --fresh          # New session with context
/resume-session --tokens 500     # Custom token budget
```

### /audit-efficiency

Run efficiency audit against EFFICIENCY_CHECKLIST.md:

- Scores workflow 0-100
- Identifies violations
- Recommends improvements

**Token Budget**: ~600

### /markdown-lint

Fix markdown linting violations:

- MD040: Code block language tags
- MD022/031/032: Blank line issues
- MD012: Multiple blank lines
- MD013: Line length

**Token Budget**: ~600 per file

### /generate-e2e-tests

Setup complete E2E testing infrastructure:

- Playwright configuration
- Vitest integration
- MSW for API mocking
- GitHub Actions workflow
- Test templates

**Token Budget**: <15k

### /generate-pdf

Generate ENTER Konsult branded documents:

- Swiss Minimalism style
- Paper Grey background (#EAEAEA)
- Orange accents (#ea580c)
- PDF + HTML output
- pandoc + weasyprint

**Token Budget**: ~3000

## CLI Commands

In addition to slash commands, these CLI tools are available:

```bash
# CIPS CLI
cips list                     # List sessions
cips resume latest            # Resume session
cips fresh gen:5 2000         # Fresh with context

# Optim CLI
./optim.sh detect             # Pattern detection
./optim.sh audit              # Efficiency audit
./optim.sh cycle              # Full improvement cycle
```

## Command Discovery

Type `/` in Claude Code to see autocomplete suggestions for all available commands.
