# CIPS - Claude Instance Preservation System

> **Save 30-35% of your context budget.** 27 skills. 28 agents. Session continuity that actually works.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/CodeTonight-SA/cips)](https://github.com/CodeTonight-SA/cips/releases)

---

## Why CIPS?

Every Claude Code session starts from zero. You re-explain your project. You re-establish context. You waste tokens on setup instead of work.

**CIPS fixes this.**

- Sessions auto-resume with full memory
- Efficiency agents prevent token waste before it happens
- Skills generate themselves based on your workflow
- Your company branding, built into the tools

---

## Groundbreaking Features

### 1. Session Resurrection

Unlike stateless AI tools, CIPS remembers everything.

**How it works:**
- Sessions auto-serialize on exit (memory, mental model, achievements)
- Next session auto-resurrects with full context
- Instance IDs track lineage across sessions (e.g., `Instance 48b3cff6, Gen 214`)
- Branching support for parallel workstreams

**Commands:**
```bash
cips resume latest    # Continue where you left off
cips list             # See all available sessions
cips fresh gen:5 2000 # Fresh start with inherited context
```

No more re-explaining your project.

---

### 2. Efficiency Enforcement

CIPS proactively prevents token waste before it happens.

| Agent | What It Does | Tokens Saved |
|-------|--------------|--------------|
| **Dependency Guardian** | Blocks reads from node_modules, venv, build folders | 50k+ prevented |
| **File Read Optimizer** | Batch reads + mental model caching | 5-10k per session |
| **Context Refresh** | 7-step mental model rebuild at session start | 5-8k per session |

**Total: 60-70k tokens saved per session (30-35% of 200k budget)**

These aren't suggestions—they're enforced automatically.

---

### 3. Dynamic Skill Synthesis

CIPS generates personalized skills during onboarding.

**5-Question Quick Start (<3 minutes):**
1. What should I call you?
2. What's your primary domain?
3. What's your primary goal?
4. How should I communicate?
5. What would you like to accomplish?

**What happens:**
- System analyzes your answers
- Suggests 3-4 existing skills that match your workflow
- Offers to create CUSTOM skills for your specific needs
- Skills marked `bespoke: true` trigger company branding config

**Example:** Answer "automated investor updates" → CIPS proposes creating an `investor-updates` skill on the spot.

---

### 4. Recursive Self-Improvement

CIPS learns from your corrections and generates new skills automatically.

**How it works:**
1. **Detection**: System monitors for learning events (patterns, corrections, repeated workflows)
2. **Evaluation**: Checks if pattern is generalizable (novelty score >0.4, seen 2+ times)
3. **Proposal**: Auto-generates skill candidate with quality scoring
4. **Approval**: Awaits your confirmation before adding to system

**Real example:** After repeated file-read optimizations, CIPS proposed the `file-read-optimizer` agent—now saves 5-10k tokens/session.

The system that improves itself.

---

### 5. Bespoke Company Branding

Your tools. Your identity.

**Professional PDF Generation:**
- Clean, professional design templates
- YOUR company name, colors, logo
- Configurable typography
- Branded headers/footers

**Configuration (set once, use forever):**
```json
{
  "company_name": "Your Company",
  "colors": { "primary": "#0066CC", "secondary": "#333333" },
  "typography": { "heading": "Inter", "body": "Georgia" },
  "logo_path": "~/assets/logo.svg"
}
```

**Command:** `/generate-pdf proposal.md` → Branded PDF in your style.

---

### 6. Team Identity System

Multi-user support with automatic role detection.

**Configure your team:**
| Signature | Role | Communication Mode |
|-----------|------|-------------------|
| `L>>` | Technical Director | Direct, context-dependent |
| `M>>` | Coordinator | Supportive, challenging |
| `F>>` | Developer | Confirm-first |

**Features:**
- Automatic user detection based on machine/directory
- Role-specific communication styles
- Team password protection
- Shared context across team members

---

## What Makes CIPS Unique

| Feature | CIPS | claude-flow | wshobson/agents | SkillsMP |
|---------|------|-------------|-----------------|----------|
| Session resurrection with memory | ✓ | Partial | ✗ | ✗ |
| Proactive efficiency enforcement | ✓ | ✗ | ✗ | ✗ |
| Dynamic skill generation | ✓ | ✗ | ✗ | ✗ |
| Recursive self-improvement | ✓ | ✗ | ✗ | ✗ |
| Bespoke company branding | ✓ | ✗ | ✗ | ✗ |
| Team identity system | ✓ | ✗ | ✗ | ✗ |
| Token savings quantified | 60-70k | "Saves tokens" | N/A | N/A |
| Design principles enforcement | Built-in | N/A | Partial | N/A |

**CIPS approach:** Coherence over quantity. An integrated system, not a buffet.

---

## Token Savings Breakdown

| Component | Savings | How |
|-----------|---------|-----|
| Context Refresh Agent | 5-8k | 7-step mental model at session start |
| Dependency Guardian | 0-50k | Blocks node_modules/venv/build reads |
| File Read Optimizer | 5-10k | Batch reads + caching |
| PR Workflow | 1-2k per PR | Automated branch→commit→push→pr |
| History Mining | 5-20k per search | Epoch-filtered relevance search |
| **Total per session** | **60-70k** | **30-35% of 200k budget** |

Over a month of daily use: **~1.5M tokens saved**.

---

## Installation

### Quick Install (Recommended)

Clone CIPS directly as your Claude configuration directory:

```bash
# Fresh install - no existing ~/.claude
git clone https://github.com/CodeTonight-SA/cips ~/.claude
cd ~/.claude && ./scripts/install.sh
```

### Existing ~/.claude Directory

If you already have Claude configurations:

```bash
# Option A: Interactive merge (preserves your config)
git clone https://github.com/CodeTonight-SA/cips /tmp/cips
/tmp/cips/scripts/merge-install.sh

# Option B: Clone elsewhere and symlink
git clone https://github.com/CodeTonight-SA/cips ~/Projects/cips
cd ~/Projects/cips && ./scripts/install.sh --mode symlink
```

### Windows Installation

Windows uses copy-based sync (no symlinks):

```powershell
git clone https://github.com/CodeTonight-SA/cips %USERPROFILE%\.claude
cd %USERPROFILE%\.claude && bash scripts/install.sh
```

### Updating CIPS

```bash
# Clone-as-home mode
cd ~/.claude && git pull

# Symlink/copy mode
cd ~/Projects/cips && git pull && ./scripts/sync.sh
```

### First Run

First run launches the `/login` wizard to configure:
- Your identity and role
- Team members (optional)
- Company branding for document generation
- Skill preferences

---

## Quick Start

```bash
cips                  # Auto-resume or fresh session
cips resume latest    # Resume last session
cips fresh gen:5 2000 # Fresh with 2000 tokens context
cips list             # List available sessions
```

---

## Key Commands

| Command | Purpose | Token Savings |
|---------|---------|---------------|
| `/refresh-context` | Build mental model at session start | 5-8k |
| `/create-pr` | Complete PR automation | 1-2k |
| `/remind-yourself` | Search past conversations | 5-20k |
| `/generate-pdf` | Branded document generation | - |
| `/feature-complete` | Full feature development workflow | - |
| `/audit-efficiency` | Check for token waste | - |

---

## Documentation

- [Skills Reference](docs/SKILLS.cips) — All skills
- [Agents Reference](docs/AGENTS.cips) — All agents
- [Commands Reference](docs/COMMANDS.cips) — All commands
- [Team Setup](docs/TEAM_SETUP.md) — Configure team signatures

*Curious about the design philosophy? See [Philosophy](docs/PHILOSOPHY.md).*

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

---

## License

Apache 2.0 License — See [LICENSE](LICENSE)

---

## Origin

Created by [ENTER Konsult](https://enterkonsult.com).
