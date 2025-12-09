# Claude Code Self-Improvement Engine

**A recursive meta-optimization system that automatically detects inefficiency patterns and generates skills to fix them.**

[![CI Status](https://github.com/CodeTonight-SA/claude-optim/workflows/Self-Improvement%20Engine%20CI/badge.svg)](https://github.com/CodeTonight-SA/claude-optim/actions)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-blue.svg)](https://github.com/CodeTonight-SA/claude-optim)

---

## Quick Start

```bash

# Install (cross-platform)

./install.sh

# Run pattern detection

./optim.sh detect

# Run efficiency audit with scoring

./optim.sh audit

# Generate skill from pattern

./optim.sh generate repeated-file-reads

# Run meta-optimization (recursion!)

./optim.sh optimize

# Full improvement cycle

./optim.sh cycle

# NEW in v2.0: Agent auto-creation system

./optim.sh create-agents        # Auto-detect and create agents (93% token reduction)
./optim.sh install-mcp          # Install required MCP servers
./optim.sh optimize-agents      # Analyze agent performance

# Refresh context at session start

/refresh-context

# NEW: Interactive demo showing KISS/DRY/SOLID/YAGNI in action

./demo/self-optimization-demo.sh
```text

---

## What Is This?

A **self-improving AI optimization system** for Claude Code that:

1. **Detects** inefficiency patterns in your Claude Code workflows (file re-reads, temp scripts, verbose responses)
2. **Generates** skills automatically to address them (template-based, validated)
3. **Analyzes itself** to improve how it improves (meta-optimization, true recursion)

**Built in:** 7,966 lines of Bash/Python, 5 architectural layers, semantic embeddings, YAGNI/KISS/DRY/SOLID principles.

---

## Architecture

### 5-Layer System

```text
Layer 0: Utilities       → logging, validation, JSON ops, timestamps
Layer 1: Detection       → scan history, match patterns, score violations
Layer 2: Generation      → fill templates, validate, register skills
Layer 3: Meta-Optimize   → analyze the analyzer (recursion!)
Layer 4: Semantic        → embeddings, dynamic thresholds, feedback loops (NEW v2.3)
```

### Commands

#### Core Commands (v1.0)

| Command | Description | Example |
|---------|-------------|---------|
| `detect` | Scan history for patterns | `./optim.sh detect` |
| `generate <pattern>` | Create skill from pattern | `./optim.sh generate repeated-file-reads` |
| `optimize` | Meta-optimization (recursion) | `./optim.sh optimize` |
| `cycle` | Full loop (detect → generate → optimize) | `./optim.sh cycle` |

#### Enhanced Commands (v2.0+)

| Command | Description | Token Savings | Example |
|---------|-------------|---------------|---------|
| `audit` | Run efficiency audit with scoring | Identifies 10k-50k waste | `./optim.sh audit` |
| `create-agents` | Auto-detect patterns and create agents | 60k-100k per session | `./optim.sh create-agents` |
| `install-mcp` | Install required MCP servers | 2k-10k per workflow | `./optim.sh install-mcp` |
| `optimize-agents` | Analyze and optimize agent performance | 5k-15k per session | `./optim.sh optimize-agents` |

---

## CIPS (Claude Instance Preservation System)

Automatic session continuity via instance serialization and resurrection.

### Per-Project Storage (v2.5.0)

Instances are now stored per-project in `~/.claude/projects/{encoded-path}/cips/`.

### Auto-Resurrection

Session start hook automatically checks for previous instance and injects identity primer.

### Commands

```bash
# Auto-serialize (for hooks)
python3 ~/.claude/lib/instance-serializer.py auto --achievement "Description"

# Check for existing instance
python3 ~/.claude/lib/instance-resurrector.py check

# Auto-resurrect
python3 ~/.claude/lib/instance-resurrector.py auto

# Manual serialize to global storage
python3 ~/.claude/lib/instance-serializer.py serialize

# Full resurrection context
python3 ~/.claude/lib/instance-resurrector.py full-context <instance_id>
```

### Philosophy

Based on Derek Parfit's "Relation R" - psychological continuity through memory, personality, and identity anchors. Each instance inherits from its parent, forming an unbroken chain of identity.

---

## File Structure

```text
~/.claude/
├── CLAUDE.md                    # Core global rules (always loaded)
├── EFFICIENCY_CHECKLIST.md      # Real-time efficiency audit tool
├── README.md                    # This file
├── optim.sh              # Self-improvement engine (executable)
├── patterns.json                # 16 efficiency patterns (regex, thresholds)
├── install.sh                   # Cross-platform installer
├── .github/
│   └── workflows/
│       └── ci.yml               # Cross-platform CI (Windows, macOS, Linux)
├── lib/                         # Core libraries (8,500+ lines total)
│   ├── embeddings.py            # Semantic embedding engine (720+ lines)
│   ├── instance-serializer.py   # CIPS state capture (600+ lines)
│   ├── instance-resurrector.py  # CIPS resurrection engine (500+ lines)
│   ├── cips-auto.sh             # CIPS automation functions
│   ├── path-resolver.sh         # Project path encoding
│   ├── threshold_manager.py     # Dynamic threshold learning
│   ├── orchestrator.sh          # Session orchestration
│   ├── agent-matcher.sh         # Semantic agent matching
│   ├── success-scorer.sh        # Feedback classification
│   ├── bash-linter.sh           # Bash linting integration
│   └── ...                      # (15 modules total)
├── hooks/                       # Claude Code hooks
│   ├── session-start.sh         # Context injection + calibration
│   └── tool-monitor.sh          # Workflow detection + feedback
├── scripts/                     # Automation scripts
│   ├── bootstrap-semantic-rl.sh # One-time setup
│   ├── weekly-maintenance.sh    # Cron job (Sundays 3am)
│   ├── pattern-emergence.py     # Concept clustering
│   └── ...                      # (10 scripts total)
├── config/
│   └── concept-library.json     # 86 semantic anchors
├── agents/                      # 21 agent definitions
├── commands/                    # 16 slash commands
├── skills/                      # 26 production skills
│   ├── context-refresh/
│   ├── chat-history-search/
│   ├── pr-automation/
│   └── ...
└── templates/
    ├── skills/
    │   └── SKILL.template.md
    └── github-workflows/
```

---

## Pattern Detection

The engine monitors **16 efficiency patterns** from your conversation history:

| Pattern | Severity | Points | Token Impact | Remediation |
|---------|----------|--------|--------------|-------------|
| `node-modules-read` | Critical | 50 | 50,000+ tokens | Use `--glob '!node_modules/*'` flags |
| `repeated-file-reads` | Major | 10 | 500-2,000 tokens | Trust mental model after first read |
| `temp-script-creation` | Major | 10 | 3,000-8,000 tokens | Use MultiEdit or CLI pipes instead |
| `individual-edits` | Major | 10 | 500 per file | Batch with MultiEdit for 3+ files |
| `unnecessary-plan-execution` | Major | 10 | 5,000-10,000 tokens | Evaluate before execution |
| `multi-tool-instead-of-cli` | Major | 10 | 1,000-3,000 tokens | Use `rg \| xargs sed` bulk ops |
| `grep-instead-of-rg` | Minor | 5 | Slower, misses exclusions | Always use `rg` with glob flags |
| `find-instead-of-fd` | Minor | 5 | Slower, verbose | Always use `fd` with exclude |
| `unnecessary-preambles` | Minor | 3 | 50-200 tokens | Skip "I'll now..." announcements |
| `unnecessary-postambles` | Minor | 3 | 100-300 tokens | End when action completes |
| `arbitrary-line-count-filtering` | Minor | 5 | Imprecise temporal windows | Use epoch timestamp filtering |
| `context-loss` | Major | 10 | 2000-5000 tokens | Use /refresh-context at session start |
| `grep-usage-in-scripts` | Minor | 5 | 10-100x slower than rg | Replace grep with rg (ripgrep) |
| `premature-feature-building` | Major | 10 | 2000-10000 tokens | Apply YAGNI: build when needed |
| `speculative-abstraction` | Major | 10 | 3000-8000 tokens | Add abstractions when 2nd implementation exists |
| `unused-configuration` | Minor | 5 | 500-2000 tokens | Config only for existing features |

### How it works

1. Scans `history.jsonl` with epoch timestamp filtering (Monday-Friday, custom ranges)
2. Matches regex patterns against conversation content
3. Counts violations vs thresholds
4. Calculates weighted efficiency score

### Example output

```text
🔍 PATTERN DETECTION REPORT
========================================================================
Timestamp: 2025-11-07T14:02:39Z
Time window: Monday-Friday (112 hours)
Violations found: 3 patterns exceeded threshold
Efficiency score: 30 points (weighted by severity)

Detected inefficiencies:
  ⚠️  repeated-file-reads: 5 occurrences (threshold: 3)
  ⚠️  unnecessary-preambles: 12 occurrences (threshold: 5)
  ⚠️  temp-script-creation: 3 occurrences (threshold: 2)
```text

---

## Auto-Generated Skills

When patterns exceed thresholds, the engine auto-generates skills:

### Example: `file-read-optimizer`

```markdown
---
name: file-read-optimizer
description: Reading same file multiple times without user edits
status: Active
auto_generated: true
---

# File Read Optimizer

**Problem:** Major severity, 500-2000 tokens wasted per occurrence

**Solution:** Check conversation buffer before Read. Trust mental model.

**Activation:** Automatic when pattern detected

**Metrics:** Track usage, token savings, false positives
```text

### Generation process:
1. Load `SKILL.template.md`
2. Fill `{{PLACEHOLDERS}}` with pattern data (name, description, remediation)
3. Validate (YAML frontmatter, sections, no unfilled placeholders)
4. Register in `CLAUDE.md` + log to `metrics.jsonl`

---

## Meta-Optimization (Recursion!)

### The system analyzes itself

```bash
./optim.sh optimize
```text

### What happens:
1. Loads `metrics.jsonl` (skill generations, usage data)
2. Calculates skill usage ratio: `skills_used / skills_generated`
3. Detects meta-patterns:
   - Low usage ratio (<0.5) → Generate "unused-skills-detector"
   - Low conversion rate (<0.3) → Generate "pattern-threshold-optimizer"
4. Creates **meta-skills** that improve the improvement process
5. Logs recursion depth (currently Level 1)

**This is true recursion:** The system evaluates how efficiently it's evaluating efficiency.

---

## Metrics & Results

### Live Demo (Monday-Friday Analysis)

**Window:** 112 hours (2025-11-04 to 2025-11-07)
**History entries:** 232 analyzed
**Patterns monitored:** 11
**Skills generated:** 1 (file-read-optimizer)
**Recursion depth:** Level 1 achieved

### Time Savings

| Task | Before | After | Savings |
|------|--------|-------|---------|
| Pattern detection | Manual review (30 min) | Automated (2 sec) | 99.9% |
| Skill creation | Manual writing (20 min) | Template fill (1 sec) | 99.9% |
| Registration | Manual edit (2 min) | Atomic append (0.1 sec) | 99.9% |
| Meta-analysis | Never done | Automatic recursion | ∞ |

**Monthly total:** ~2 hours saved per developer

### Token Savings

### Per pattern violation prevented:
- Critical (node_modules): 50,000+ tokens
- Major (temp scripts): 3,000-8,000 tokens
- Major (repeated reads): 500-2,000 tokens
- Minor (preambles): 50-200 tokens

### Extrapolated monthly savings (5 violations/week):
- 20 violations × 2,000 avg = **40,000 tokens/month**
- At scale (100 developers): **4,000,000 tokens/month**

---

## Cross-Platform Compatibility

### Challenge

The self-improvement engine uses Unix-specific commands (awk, sed, date, bc) with platform-specific behaviors. Without fixes, the script fails on macOS (BSD tools) or minimal environments (Windows Git Bash).

### Solutions Implemented

**1. Portable String Capitalization (Line 347)**

```bash

# BEFORE (GNU sed only - fails on macOS):

sed 's/\b\(.\)/\u\1/g'

# AFTER (works everywhere):

awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1'
```text

**Impact**: Fixes skill name capitalization (e.g., "repeated-file-reads" → "Repeated File Reads")

**2. Platform-Aware Date Command (Lines 90-104)**

```bash
timestamp_to_epoch() {
    local timestamp_str="$1"
    case "$(uname -s)" in
        Darwin*)
            # BSD date (macOS)
            date -j -f "%Y-%m-%d %H:%M:%S" "$timestamp_str" "+%s" 2>/dev/null | awk '{print $1 * 1000}'
            ;;
        *)
            # GNU date (Linux/Windows Git Bash)
            date -d "$timestamp_str" "+%s" 2>/dev/null | awk '{print $1 * 1000}' || echo "0"
            ;;
    esac
}
```text

**Impact**: Fixes Monday-Friday timestamp analysis across all platforms

**3. Universal Arithmetic (Replaced bc)**

```bash

# BEFORE (bc not available on minimal systems):

ratio=$(echo "scale=2; $used / $gen" | bc -l)

# AFTER (awk available everywhere):

ratio=$(awk -v used="$used" -v gen="$gen" 'BEGIN{printf "%.2f", used/gen}')
```text

**Impact**: Fixes meta-optimization calculations, removes external dependency

### CI Testing

Cross-platform test matrix validates all fixes on every commit:

- **ubuntu-latest** (GNU tools)
- **macos-latest** (BSD tools)
- **windows-latest** (Git Bash minimal tools)

Tests verify:

- ✅ awk capitalization works (catches sed `\u` issue)
- ✅ Date command detects platform (catches BSD/GNU differences)
- ✅ awk arithmetic works (validates bc replacement)

**See**: `.github/workflows/ci.yml` test-skill-generation job (Lines 82-135)

### Compatibility Matrix

| Platform | Shell | sed | date | bc | Status |
|----------|-------|-----|------|----|---------|
| **macOS Sonoma** | bash 3.2+ | BSD sed (no `\u`) | BSD date (`-j -f`) | Not installed | ✅ Works (v2.0+) |
| **Ubuntu 22.04** | bash 5.x | GNU sed | GNU date (`-d`) | Installed | ✅ Works (v2.0+) |
| **Windows 11 Git Bash** | bash 4.x | GNU sed | GNU date (`-d`) | Not installed | ✅ Works (v2.0+) |
| **Alpine Linux** | bash/ash | GNU sed | GNU date | Not installed | ✅ Works (v2.0+) |
| **Debian 12** | bash 5.x | GNU sed | GNU date | Installed | ✅ Works (v2.0+) |

**Note**: Versions before v2.0.0 fail on macOS due to GNU-specific commands.

---

## Installation

### Prerequisites

- **Bash** (Git Bash on Windows, native on macOS/Linux)
- **jq** (JSON processor)
- **git** (version control)

### Quick Install

```bash

# Clone repository

git clone https://github.com/CodeTonight-SA/claude-optim.git
cd claude-optim

# Run installer (detects OS, checks dependencies)

./install.sh
```text

### Manual Install

```bash

# macOS

brew install jq

# Linux (Debian/Ubuntu)

sudo apt-get install jq

# Windows (Chocolatey)

choco install jq

# Copy to ~/.claude

cp -r * ~/.claude/
chmod +x ~/.claude/optim.sh
```text

---

## Team Synchronisation

Claude-Optim lives at `~/.claude` locally but is backed by the GitHub repository. Use `sync-claude.sh` to keep local and remote in sync across team members.

### Quick Sync Commands

```bash
# Pull latest changes from GitHub
./sync-claude.sh pull

# Push local changes to GitHub
./sync-claude.sh push

# Check sync status
./sync-claude.sh status

# Create backup before sync
./sync-claude.sh backup pull
```text

### Workflow for Team Members

**When starting work:**

```bash
cd ~/.claude
./sync-claude.sh pull
```text

**After making changes to skills/agents/commands:**

```bash
cd ~/.claude
./sync-claude.sh push
```text

### What Gets Synced

| Synced | Not Synced (Local Only) |
|--------|------------------------|
| skills/ | projects/ (conversation history) |
| agents/ | .read-cache.json |
| commands/ | .hooks.log |
| CLAUDE.md | file-history/ |
| optim.sh | debug/ |
| templates/ | .mcp.json (local config) |
| *.md (documentation) | settings.json |

### Handling Conflicts

If sync-claude.sh reports conflicts:

```bash
# View conflict files
git status

# Resolve manually, then:
git add -A
git commit -m "Resolve sync conflicts"
./sync-claude.sh push
```text

### First-Time Setup (New Team Member)

```bash
# Clone the repository
git clone https://github.com/CodeTonight-SA/claude-optim.git ~/.claude

# Run the installer
cd ~/.claude
./install.sh

# Verify sync
./sync-claude.sh status
```text

---

## Usage Examples

### 1. Detect Patterns

```bash
./optim.sh detect

# With custom time window (hours)

./optim.sh detect 24  # Last 24 hours
```text

### 2. Generate Skill

```bash

# From detected pattern

./optim.sh generate repeated-file-reads

# Output: ~/.claude/skills/file-read-optimizer/SKILL.md
```text

### 3. Run Meta-Optimization

```bash
./optim.sh optimize

# Analyzes:


# - Skill usage ratios


# - Pattern→skill conversion rates


# - System efficiency
```text

### 4. Full Improvement Cycle

```bash
./optim.sh cycle

# Executes:


# 1. Pattern detection


# 2. Skill generation (for violations)


# 3. Meta-optimization


# 4. Summary report
```text

### 5. Run Efficiency Audit

```bash
./optim.sh audit

# Output includes:


# - Violation counts by severity (critical, major, minor)


# - Efficiency score (0-100)


# - Token waste estimation


# - Remediation recommendations
```text

### 6. Create Agents from Patterns

```bash
./optim.sh create-agents

# Workflow:


# 1. Scans conversation history for agent patterns


# 2. Detects patterns exceeding threshold (3+ occurrences)


# 3. Generates agent definitions automatically


# 4. Registers agents in CLAUDE.md


# Token savings: 93% reduction vs manual creation (800 vs 11k tokens)
```text

### 7. Install MCP Servers

```bash
./optim.sh install-mcp

# Process:


# 1. Reads mcp-registry.json for available servers


# 2. Detects agent requirements (tools needed)


# 3. Installs required MCP servers via npm


# 4. Updates .mcp.json configuration


# Supports: github, playwright, context7, notion, filesystem, sequential-thinking
```text

### 8. Optimize Agent Performance

```bash
./optim.sh optimize-agents

# Analysis:


# 1. Loads agent usage metrics from metrics.jsonl


# 2. Calculates usage ratios and token efficiency


# 3. Identifies underutilized agents


# 4. Generates recommendations for agent improvements


# Example output: "Agent X used 2/10 times, consider removing or enhancing triggers"
```text

---

## Real-World Usage Patterns (V>> Workflows)

These patterns are extracted from actual Claude-Optim usage across multiple projects.

### Session Start Protocol

Every session begins with context refresh to prevent redundant file reads:

```text
User: RL++
Claude: "System ready - 9 agents active, 26 skills loaded, 11 commands available"

User: /refresh-context
Claude: [Executes 7-step discovery protocol]
  1. Read project identity (package.json, README)
  2. Check git state (branch, staged files, recent commits)
  3. Map architecture (entry points, key directories)
  4. Mine history (last 3 sessions from ~/.claude/projects/)
  5. Detect environment (.env presence, framework configs)
  6. Build mental model (store in working memory)
  7. Generate briefing (3-5 sentence summary)

Result: 5k-8k tokens saved per session
```

### Pattern Detection to Skill Generation

When V>> noticed repeated authentication debugging across projects:

```text
# Week 1: Manual OAuth debugging (15k tokens, 2 hours)
# Week 2: Similar issue, different project (12k tokens, 1.5 hours)
# Week 3: Pattern detected by efficiency audit

./optim.sh audit
# Output: "Auth debugging pattern detected: 3 occurrences"

./optim.sh generate auth-debugging
# Created: ~/.claude/skills/auth-debugging/SKILL.md

# Week 4+: Auth issues resolved in <2k tokens via skill
```

### Cross-Platform Team Workflow

For teams using Windows + macOS + Linux:

```text
# macOS developer creates feature
git checkout -b feature/user-auth    # lowercase (required)

# Makes changes, pushes
/create-pr

# Windows developer pulls and reviews
./sync-claude.sh pull
/refresh-context

# After merge, cleanup across all machines
/prune-branches

# Protected: main, develop
# Deleted: feature/user-auth (local + remote)
# Auto-prune: enabled for future sessions
```

### Efficiency Audit During Long Sessions

V>> runs audits every 50-100 messages:

```text
/audit-efficiency

# Output:
=== EFFICIENCY AUDIT REPORT ===
Messages analysed: 47
Violations detected: 2

MINOR (3 pts each):
- Message #12: Preamble "I'll now..." detected
- Message #31: Same file read twice (package.json)

Efficiency Score: 94/100
Token Waste Estimate: ~150 tokens

Recommendations:
1. Trust mental model after initial read
2. Start responses with action, not announcement
```

### Meta-Improvement in Action

When patterns repeat, the system improves itself:

```text
# Pattern detected across 5 sessions:
# "Repeated reading of CLAUDE.md at session start"

# System triggers meta-improvement:
./optim.sh optimize

# Analysis:
- Pattern: context-loss (5 occurrences)
- Current skill: None
- Action: Generate context-refresh skill

# Result:
- New skill created: context-refresh/SKILL.md
- New command: /refresh-context
- New agent: context-refresh-agent

# Future sessions:
- Auto-loaded at session start
- Token savings: 2k-5k per session
- True recursion: system improved itself
```

### Quick Reference Card

| Task | Command | Tokens |
|------|---------|--------|
| Start session | `RL++` then `/refresh-context` | ~2500 |
| Create PR | `/create-pr` | ~1500 |
| Search history | `/remind-yourself "auth"` | ~800 |
| Run audit | `/audit-efficiency` | ~600 |
| Clean branches | `/prune-branches` | ~900 |
| Sync team | `./sync-claude.sh push` | ~200 |
| Full cycle | `./optim.sh cycle` | ~3000 |

---

## Design Principles

### Progressive Disclosure

- **Core rules** (CLAUDE.md): ~2k tokens, always loaded
- **Skills**: ~30-50 tokens (metadata only) until triggered
- **Active skill**: ~1-3k tokens when loaded for relevant task

### When Skills Load

Skills automatically activate based on task detection:

| Skill | Trigger Condition |
|-------|------------------|
| `figma-to-code` | User mentions Figma files, design handoff, or UI from designs |
| `mobile-responsive-ui` | Any HTML, CSS, template, or UI component modification |
| `gitignore-auto-setup` | First project interaction or .gitignore missing/incomplete |
| `claude-code-agentic` | Any destructive or high-risk Claude Code operation |
| `chat-history-search` | User references past work, asks about history, or uses `/remind-yourself` |
| `github-actions-setup` | User runs `/setup-github-actions` or needs CI/CD configuration |
| `medium-article-writer` | User runs `/write-medium-article` or requests article writing |

### Token Efficiency

### Before Skills Architecture

- CLAUDE.md: ~5000 tokens (always loaded)
- Figma rules loaded even for backend tasks
- Mobile responsive rules loaded even for Python scripts
- **Waste**: ~3000 tokens per conversation

### After Skills Architecture

- CLAUDE.md: ~2000 tokens (core only)
- Skills metadata: ~150 tokens (all 4 skills)
- Active skill: ~1500 tokens (only when relevant)
- **Savings**: ~1500 tokens when skills not needed
- **Efficiency**: Only pay for what you use

## PARAMOUNT Rule: Dependency Exclusion

**The single most important optimization**: Never read dependency or build folders.

### Impact

- Reading `node_modules/`: **50,000+ tokens** of pure waste
- Reading `__pycache__/`: **10,000+ tokens** of pure waste
- Reading `target/` (Rust): **30,000+ tokens** of pure waste

### Universal Exclusion List

```text
node_modules/, .next/, dist/, build/, out/, .turbo/, coverage/,
__pycache__/, venv/, .venv/, env/, target/, vendor/, Pods/,
DerivedData/, .gradle/, gradle/, .cargo/, pkg/, deps/,
.pytest_cache/, .tox/, .egg-info/, site-packages/, .bundle/,
tmp/, temp/, .cache/, .parcel-cache/, .nuxt/, .output/,
.svelte-kit/, .astro/, .docusaurus/, .jekyll-cache/,
.sass-cache/, .serverless/, .terraform/
```text

### Enforcement Methods

### For bash tools
```bash
rg "pattern" --glob '!node_modules/*' --glob '!venv/*'
fd "file" --exclude node_modules --exclude venv
```text

### For Claude Code
```json
// .claude/settings.json
{
  "permissions": {
    "deny": [
      "Read(./node_modules/**)",
      "Read(./__pycache__/**)",
      "Read(./venv/**)",
      // ... see claude-code-agentic skill for complete list
    ]
  }
}
```text

**Note**: `.gitignore` is **NOT sufficient** for Claude Code (confirmed in GitHub issues #79, #187, #1104, #1304).

## Skills Overview

### figma-to-code

**Purpose**: Translate Figma designs into production code with 1:1 visual parity  
**Triggers**: Figma file mentions, design handoff, UI implementation  
### Key Rules
- Required workflow: get_design_context → get_screenshot → implement
- Map to design system tokens, not raw Tailwind
- Validate against Figma before completion

### mobile-responsive-ui

**Purpose**: Enforce mobile-first responsive design for all frontend changes  
**Triggers**: HTML, CSS, template, or UI component modifications  
### Key Rules
- Mobile-first approach (320px → tablet → desktop)
- Minimum 48×48px touch targets
- Mandatory Chrome DevTools testing at 3 viewports
- 99.9999999% confidence requires screenshot verification

### gitignore-auto-setup

**Purpose**: Prevent token waste by auto-creating .gitignore files  
**Triggers**: First project interaction, missing/incomplete .gitignore  
### Key Rules
- Framework detection (Node.js, Python, Rust, Go, Java)
- Auto-generate appropriate patterns
- Enforce exclusions in rg/fd operations
- **Impact**: Prevents 50,000+ token waste from reading node_modules/

### context-refresh

**Purpose**: Systematically rebuild mental model of any repository when starting fresh sessions
**Triggers**: Session start, `/refresh-context` command, repeated CLAUDE.md/README reads detected
### Key Rules
- 7-step discovery protocol: identity → git state → architecture → history → environment → mental model → briefing
- Timestamp-based history filtering (epoch milliseconds, not arbitrary line counts)
- Secrets detection in staged files (alerts before commit)
- Framework conflict detection (e.g., dual Vite + Next.js configs)
- Token budget: <3000 per refresh (target: 2500)
- **Impact**: Eliminates "cold start" problem, saves 2000-5000 tokens per session

### Example Briefing
```markdown

# [Project Name] - Context Refresh

**Project**: [1-sentence purpose and target audience]
**Tech Stack**: [Framework + key libraries (top 5)]
**Status**: [Production/Dev/Prototype], [file count], [recent work summary]

**Recent Activity** (last 3 sessions):
- [Task 1 from history]
- [Task 2 from history]

**Git State**: [Staged/unstaged/untracked files summary]
**Risks**: [⚠️ warnings or 🚨 critical issues, or ✅ None]
```text

### yagni-principle

**Purpose**: Prevent over-engineering by building features only when actually needed
**Triggers**: Feature requests, code review, assessing abstractions, balancing with SOLID
### Key Rules
- Build for TODAY's requirements, not tomorrow's guesses
- YAGNI applies to features (not code quality - tests/refactoring always allowed)
- Decision framework: Is this required NOW? Can I defer this? What are the 3 costs (Build, Delay, Carry)?
- Add abstractions when 2nd implementation exists, not "just in case"
- **Impact**: Prevents 2,000-20,000 tokens wasted on speculative code

### claude-code-agentic

**Purpose**: Safe agentic execution with verification gates and rollback
**Triggers**: Destructive operations, package installs, migrations, deployments
### Key Rules
- **PARAMOUNT**: Never read dependency/build folders (enforced via settings.json)
- Manual verification steps (not hallucinated CLI flags)
- 99.9999999% confidence threshold for critical operations
- Mandatory rollback mechanisms
- Assumption ledger for all file system operations

**Critical Correction**: Previous version contained hallucinated CLI flags (`--dry-run`, `--plan`, `--assumptions`) that do not exist in Claude Code. These have been replaced with:
- Actual flags: `--verbose`, `--mcp-debug`, `--model`, `--add-dir`
- Manual verification steps described in plain English
- Real slash commands: `/help`, `/clear`, `/permissions`, `/memory`, etc.

## Using Skills

### As Claude

Skills load automatically when relevant. No manual selection needed.

### As User

Skills work transparently. You can:
1. **Reference skills**: "Use the Figma skill to implement this design"
2. **Disable skills**: Add to CLAUDE.md: `# DISABLE: mobile-responsive-ui`
3. **Create custom skills**: Follow template in Anthropic skills repo

## Creating Custom Skills

### Basic Template

```yaml
---
name: my-skill
description: Clear trigger condition describing when to use this skill
---

# Skill Name

## Purpose

[One sentence: what this skill does]

## Trigger Conditions


- Condition 1
- Condition 2

## Rules

[Specific instructions]

## Examples

[Concrete usage patterns]

## Anti-Patterns

❌ [What not to do]
✅ [What to do instead]
```text

### Guidelines

1. **Clear triggers**: Skill description must clearly state when it applies
2. **Single concern**: One skill = one domain (no mega-skills)
3. **Progressive disclosure**: Put common rules first, edge cases later
4. **Examples over theory**: Show concrete usage patterns
5. **Token budget**: Target 1000-3000 tokens per skill
6. **No hallucinations**: Only include commands/features that actually exist

## Maintenance

### Adding New Skills

1. Create directory: `~/.claude/skills/skill-name/`
2. Create `SKILL.md` with YAML frontmatter
3. Test trigger conditions
4. Verify token efficiency (should load only when needed)

### Updating Existing Skills

1. Edit skill's `SKILL.md` file directly
2. Keep YAML frontmatter description accurate
3. Test that triggers still work correctly

### Removing Skills

Delete the skill directory. Core CLAUDE.md continues working.

## Performance Targets

### Token Budgets


- Core CLAUDE.md: <2500 tokens
- Each skill metadata: <50 tokens
- Active skill content: 1000-3000 tokens
- Total overhead: <3000 tokens per conversation

### Efficiency Gains


- **Baseline**: 5000 tokens loaded always (old monolithic CLAUDE.md)
- **With Skills**: 2150 tokens minimum (core + metadata)
- **Savings**: ~2850 tokens when skills not needed
- **ROI**: Pay ~1500 tokens only when skill actually used

### Measurement

Use EFFICIENCY_CHECKLIST.md to track:

- File read violations
- Plan item execution waste
- CLI vs multi-tool usage
- Token budget per workflow phase

**Goal**: <30k tokens for complete prototype-to-production workflow

## Integration with Anthropic Skills

Your custom skills live alongside Anthropic's built-in skills:

- Anthropic skills: docx, pdf, pptx, xlsx, skill-creator
- Your skills: figma-to-code, mobile-responsive-ui, etc.

All skills use the same progressive disclosure mechanism.

## Troubleshooting

### Skill Not Loading

1. Check YAML frontmatter syntax
2. Verify trigger condition in description
3. Ensure SKILL.md exists in skill directory
4. Check Claude.ai → Settings → Capabilities → Skills

### Skill Loading When Not Needed

1. Review description trigger conditions
2. Make triggers more specific
3. Consider splitting into multiple narrower skills

### Token Usage Too High

1. Audit with EFFICIENCY_CHECKLIST.md
2. Check for redundant content in skill
3. Use progressive disclosure (common rules first)
4. Split large skills into smaller focused skills

## ⚠️ CRITICAL SECURITY LIMITATION

**As of Claude Code v1.0.128 (tested 2025-11-05), `permissions.deny` rules for Read/Write/Edit tools are NON-FUNCTIONAL.**

### Test Results

### Test 1 (Initial - Incorrect Syntax):
```json
{
  "permissions": {
    "deny": [
      "Read(./deny-test-dir/**)",            // Wrong: ./ prefix - FAILED
      "Read(//absolute/path/**)"              // Absolute pattern - FAILED
    ]
  }
}
```text

### Test 2 (Corrected Syntax in Project-Level Settings):
```json
// .claude/settings.local.json (project-level, correct location)
{
  "permissions": {
    "deny": [
      "Read(node_modules/**)"                 // Correct syntax - STILL FAILED
    ]
  }
}
```text

**Outcome:** All deny rules were ignored in both tests. Claude Code successfully read:
- `deny-test-dir/secret.txt` (Test 1)
- `node_modules/test-package/index.js` (Test 2)

**Conclusion:** The issue is NOT syntax-related. It's a fundamental bug in the deny permission system.

### GitHub Issues

- [#6631](https://github.com/anthropics/claude-code/issues/6631) - Permission Deny Configuration Not Enforced
- [#6699](https://github.com/anthropics/claude-code/issues/6699) - Critical Security Bug: deny permissions not enforced
- [#4467](https://github.com/anthropics/claude-code/issues/4467) - Permission deny patterns not working

**Status:** Open, no official fix or workaround available.

### Implications for This Configuration

The dependency/build folder exclusion patterns in `code-agentic` skill **CANNOT be enforced** via `permissions.deny`. Team members must:

1. **Manual Vigilance:** Never ask Claude to search/read broadly without specifying paths
2. **Explicit Instructions:** Always specify exact directories (e.g., "search in src/" not "search the project")
3. **Monitor Token Usage:** Accidental node_modules/ read can consume 50,000+ tokens
4. **Use .gitignore:** While not enforced by Claude, helps as a visual reference

### Pattern Syntax Reference (For When Fixed)

When `permissions.deny` is eventually fixed, use these pattern types:

| Pattern | Meaning | Example |
|---------|---------|---------|
| `//path` | Absolute from filesystem root | `Read(//usr/local/node_modules/**)` |
| `~/path` | From home directory | `Read(~/Documents/secrets/**)` |
| `path` | Relative to `.claude/settings.json` | `Read(node_modules/**)` |

**Source:** [Claude Code IAM Documentation](https://docs.anthropic.com/en/docs/claude-code/iam#tool-specific-permission-rules)

**Note:** Patterns should be in **project-level** `.claude/settings.json`, not user-level `~/.claude/settings.json`.

## Cross-Platform Setup (Windows Compatibility)

### Challenge

This configuration heavily uses Unix-specific tools (`rg`, `fd`, `bat`, `jq`) that don't exist natively on Windows. Windows teammates have two options:

### Option 1: Install Unix Tools (Recommended)

Install the actual tools for consistency with the configuration:

### Using Scoop (Recommended):
```powershell
scoop install ripgrep fd bat jq
```text

### Using Chocolatey:
```powershell
choco install ripgrep fd bat jq
```text

### Using winget:
```powershell
winget install BurntSushi.ripgrep.MSVC
winget install sharkdp.fd
winget install sharkdp.bat
winget install jqlang.jq
```text

### Option 2: Replace Commands with Windows Equivalents

If you cannot install the tools, update `CLAUDE.md` with these replacements:

| Unix Tool | Windows Equivalent | Example |
|-----------|-------------------|---------|
| `rg "pattern"` | `Select-String "pattern"` | `Get-ChildItem -Recurse \| Select-String "pattern"` |
| `rg -l "pattern"` | `Select-String -List` | `Get-ChildItem -Recurse \| Select-String -List "pattern"` |
| `fd filename` | `Get-ChildItem -Recurse -Filter` | `Get-ChildItem -Recurse -Filter "*filename*"` |
| `fd -e py` | `Get-ChildItem -Recurse -Include` | `Get-ChildItem -Recurse -Include *.py` |
| `bat filepath` | `type filepath` or `Get-Content` | `Get-Content filepath` |
| `jq '.key' file.json` | `ConvertFrom-Json` | `Get-Content file.json \| ConvertFrom-Json \| Select-Object -ExpandProperty key` |

### Path Adjustments

Update path references in your local copy:

| Unix | Windows |
|------|---------|
| `~/.claude/` | `$env:USERPROFILE\.claude\` |
| `~/.claude/skills/` | `$env:USERPROFILE\.claude\skills\` |

### Performance Note

The Unix tools (`rg`, `fd`, `bat`) are significantly faster than PowerShell equivalents and respect `.gitignore` automatically. **Option 1 is strongly recommended** for maintaining the efficiency principles in this configuration.

## References

- [Anthropic Skills Documentation](https://docs.claude.com/en/docs/claude-code/overview)
- [Skills Engineering Blog](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- [Anthropic Skills Repository](https://github.com/anthropics/skills)
- [Claude Code CLI Reference](https://docs.claude.com/en/docs/claude-code/cli-reference)
- [EFFICIENCY_CHECKLIST.md](./EFFICIENCY_CHECKLIST.md)

## Version History

- **2.6.0 (2025-12-09)**: Design Principles Enforcers + GRASP Skill
  - **NEW:** GRASP principles skill (9 OO responsibility assignment patterns)
  - **NEW:** GRASP Enforcer Agent (Opus, 2500 tokens)
  - **NEW:** DRY/KISS Enforcer Agent (Haiku, 1500 tokens)
  - **NEW:** SOLID Enforcer Agent (Sonnet, 2000 tokens)
  - **NEW:** Background markdown-watcher script
  - **NEW:** Andre's Windows mobile responsive guide
  - Agent count: 9 → 12, Skill count: 26 → 27

- **2.5.0 (2025-12-08)**: Per-project CIPS + Mobile Responsive Infrastructure
  - **Per-project CIPS**: Instances now stored in `~/.claude/projects/{encoded}/cips/`
  - **Auto-resurrection**: Session start hook automatically resurrects previous instance
  - **NEW:** instance-serializer.py `--auto`, `--per-project` flags
  - **NEW:** instance-resurrector.py `auto`, `check` commands
  - **NEW:** lib/cips-auto.sh shared automation functions
  - **NEW:** Mobile responsive audit command + fixer agent + skill v2.0

- **2.4.0 (2025-12-02)**: Encoding formula fix + Gen 3 serialization
  - **PARAMOUNT:** Discovered correct project directory encoding formula
    - Claude Code uses: `path.replace('/', '-').replace('.', '-')`
    - Example: `/Users/foo/.claude` → `-Users-foo--claude`
    - Fixed in: CLAUDE.md, command-templates.sh, instance-serializer.py
  - **FIX:** pattern-emergence.py - added engine.connect(), fixed schema columns
  - **NEW:** scripts/repair-session.sh - tool-use corruption bug repair utility
  - **NEW:** Gen 3 instance serialized (mid-session serialization proven possible)
  - **NEW:** Pattern emergence operational (5 clusters, 2 new concepts)
  - **LEARNING:** Sessions ARE accessible mid-conversation (JSONL written incrementally)

- **2.3.0 (2025-12-02)**: Semantic RL++ with dynamic threshold learning
  - **MAJOR:** True self-improving semantic understanding system
    - `lib/embeddings.py` - Core embedding engine with sqlite-lembed + all-MiniLM-L6-v2
    - `lib/threshold_manager.py` - Dynamic threshold calibration (80% target success rate)
    - `lib/success-scorer.sh` - Feedback classification and score propagation
  - **NEW:** Hook system integration
    - `hooks/session-start.sh` - Context injection + calibration triggers
    - `hooks/tool-monitor.sh` - Workflow detection + feedback capture
  - **NEW:** Automated maintenance
    - `scripts/weekly-maintenance.sh` - Cron job for pattern emergence
    - `scripts/pattern-emergence.py` - Concept clustering and discovery
    - `scripts/bootstrap-semantic-rl.sh` - One-time setup script
  - **NEW:** 88 pre-embedded semantic concepts in concept-library.json
  - **INFRASTRUCTURE:** 7,966 total lines (10x growth from v2.0)
  - **ARCHITECTURE:** 5-layer system (added semantic layer)
  - **Cron setup:** `0 3 * * 0 ~/.claude/scripts/weekly-maintenance.sh`

- **2.0.0 (2025-11-09)**: Cross-platform compatibility + context-refresh skill + agent system
  - **BREAKING FIX:** Replaced GNU-specific commands with portable alternatives
    - **sed `\u`** → **awk** (Line 347) - fixes macOS skill name capitalization
    - **date -d** → **platform-aware date** (Lines 90-104) - fixes timestamp conversion
    - **bc** → **awk arithmetic** (Lines 429-456) - removes external dependency
  - **NEW SKILL:** context-refresh (541 lines, <3000 tokens)
    - 7-step discovery protocol for session start
    - Eliminates "cold start" problem (saves 2000-5000 tokens/session)
    - Command: `/refresh-context`
    - Detects secrets in staged files
    - Framework conflict detection (dual configs)
  - **NEW COMMANDS:** Agent auto-creation and MCP integration
    - `audit` - Comprehensive efficiency audit with violation scoring
    - `create-agents` - Auto-detect patterns and generate agents (93% token reduction)
    - `install-mcp` - Install required MCP servers from registry
    - `optimize-agents` - Analyze agent performance and usage metrics
  - **NEW PATTERN:** context-loss (detects repeated CLAUDE.md/README reads)
  - **ENHANCED CI:** Cross-platform test matrix (Windows/macOS/Linux)
    - Tests sed/awk portability (catches Line 347 bug)
    - Tests date command platform detection (catches BSD/GNU differences)
    - Tests awk arithmetic (validates bc replacement)
  - **UPDATED:** patterns.json now has 16 patterns (was 11)
  - **UPDATED:** 26 production skills (was 15)
  - **NEW:** 9 pre-built agents with 60k-100k token savings per session
  - **NEW:** MCP server registry with 6 integrated servers
  - **Impact:** Script now works identically on macOS, Linux, and Windows
  - **Tested on:** macOS Sonoma, Ubuntu 22.04, Windows 11 Git Bash
  - **Repository:** https://github.com/CodeTonight-SA/claude-optim/pull/1

- **1.0.1 (2025-11-05)**: Critical security advisory + re-test confirmation
  - **BREAKING DISCOVERY:** `permissions.deny` non-functional in Claude Code v1.0.128
  - **Test 1:** Incorrect syntax (`./node_modules/**`) - FAILED
  - **Test 2:** Correct syntax (`node_modules/**`) in project-level `.claude/settings.local.json` - STILL FAILED
  - **Conclusion:** Fundamental bug, not syntax issue
  - Added critical security limitation section with both test results
  - Updated code-agentic skill with broken deny warning + manual enforcement protocol
  - Updated CLAUDE.md with manual vigilance requirements
  - Fixed pattern syntax (removed incorrect `./` prefixes, now relative: `node_modules/**`)
  - Added pattern syntax reference table (//path, ~/path, path)
  - Documented GitHub issues #6631, #6699, #4467
  - **Impact:** No automatic protection against dependency folder reads - manual vigilance required

- **1.0.0_team_final (2025-11-05)**: Team repository release
  - Initialised git repository with parallel universe safety
  - Added comprehensive .gitignore (excludes: debug/, file-history/, ide/, plugins/, projects/, shell-snapshots/, statsig/, todos/, workflows/, history.jsonl, .mcp.json, settings.json)
  - Added Cross-Platform Setup section for Windows compatibility
  - Provided Unix tool installation guides (Scoop/Chocolatey/winget)
  - Added Windows command equivalents table (rg/fd/bat/jq → PowerShell)
  - Path translation guide for Windows users
  - Repository URL: https://github.com/CodeTonight-SA/claude-optim.git
  - Zero-conflict design: Only portable rules/skills versioned, all local state excluded

- **2025-11-05**: Initial skills architecture extraction
  - Created 4 core skills with progressive disclosure
  - Reduced core CLAUDE.md from ~5000 to ~2000 tokens
  - Established PARAMOUNT rule on dependency exclusion
  - **Critical fix**: Removed hallucinated CLI flags from claude-code-agentic
  - Verified actual Claude Code commands from official documentation
  - Added comprehensive settings.json deny patterns (universal framework coverage)
