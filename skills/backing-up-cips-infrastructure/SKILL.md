---
name: backing-up-cips-infrastructure
description: Creates tiered CIPS backups (quick/full/complete) and restores with conflict handling. Use when invoking /backup-cips, before upgrades, or for disaster recovery.
status: Active
version: 1.0.0
triggers:
  - /backup-cips
  - /restore-cips
  - "backup cips"
  - "backup infrastructure"
  - before major upgrades
integrates:
  - bouncing-instances
  - session-state-persistence
---

# Backing Up CIPS Infrastructure

Creates reliable backups of CIPS infrastructure with tiered options for speed vs completeness.

## Backup Tiers

| Tier | Contents | Size | Time | Use Case |
|------|----------|------|------|----------|
| **quick** | Config + skills only | ~3MB | <5s | Daily safety net |
| **full** | All infrastructure | ~5MB | <10s | Pre-upgrade, new machine |
| **complete** | Full + projects/ | ~73MB | <30s | Complete disaster recovery |

## Commands

```bash
# Create backup
/backup-cips [quick|full|complete]

# Restore from backup
/restore-cips <backup.tar.gz> [--force]
```

## Default Location

```text
~/backups/cips/
├── cips-quick-20251231-143022.tar.gz
├── cips-full-20251231-143055.tar.gz
└── cips-complete-20251231-143122.tar.gz
```

Override with: `CIPS_BACKUP_DIR=/custom/path`

## What Gets Backed Up

### All Tiers (Essential)

| Item | Reason |
|------|--------|
| CLAUDE.md | Global configuration |
| skills/ | Skill definitions |
| agents/ | Agent definitions |
| commands/ | Command definitions |
| lib/ | Core infrastructure |
| rules/ | Rule files |
| facts/ | Identity (people.md) |
| lexicon/ | CIPS-LANG spec |
| docs/ | Reference documentation |

### Full + Complete Tiers

| Item | Reason |
|------|--------|
| bin/ | cips executable |
| hooks/ | Session hooks |
| scripts/ | Utility scripts |
| config/ | Bespoke configuration |
| plugins/ | MCP integrations |

### Complete Tier Only

| Item | Reason |
|------|--------|
| projects/ | Session continuity data |

## What NEVER Gets Backed Up

| Item | Reason |
|------|--------|
| .env, .env.* | Secrets (security) |
| *.db | Databases (regenerable) |
| *.jsonl | Logs (ephemeral) |
| cache/, debug/ | Temporary data |
| site/ | Separate project |
| .git/ | Use git for version control |

## Restore Workflow

### Conflict Handling

When local CIPS is newer than backup:

```text
WARNING: Local CIPS is NEWER than backup.
  Local:  2025-12-31 14:30:22
  Backup: 2025-12-30 10:15:00

Options:
  1) Replace local with backup (lose local changes)
  2) Keep local (abort restore)
  3) Backup local first, then restore
```

### Security Note

`.env` files are **NEVER** restored. After restore, recreate manually:

```bash
echo "CIPS_TEAM_PASSWORD=your_password" > ~/.claude/.env
```

## Integration

### Auto-Backup Before Bounce

The `bouncing-instances` skill automatically runs:

```bash
~/.claude/scripts/cips-backup.sh full
```

Before executing Big Bounce reset.

### Scheduled Backups (Optional)

Use launchd for automatic daily backups:

```bash
/setup-launchd cips-backup
```

## Token Budget

| Operation | Tokens |
|-----------|--------|
| Backup execution | ~200 |
| Restore with prompts | ~400 |

## Private Data Separation (dotclaude)

For users who want to sync private data separately from the public CIPS repo:

```bash
# Clone your private dotclaude repo
git clone https://github.com/YOUR_USERNAME/dotclaude.git ~/dotclaude

# Export current private data
~/dotclaude/scripts/export.sh

# Import after fresh CIPS install
~/dotclaude/scripts/import.sh

# Sync to Backblaze B2
~/dotclaude/scripts/b2-sync.sh [bucket-name]
```

### What Goes in dotclaude

| Item | Why Private |
|------|-------------|
| .env | Team passwords, API keys |
| facts/people.md | Personal/family info |
| facts/team.md | Team member details |
| projects/ | Session history |
| config/*.json | Personal branding |

### Fresh Install Workflow

1. Install CIPS: `brew install codetonight-sa/cips/cips`
2. Clone dotclaude: `git clone ... ~/dotclaude`
3. Import private data: `~/dotclaude/scripts/import.sh`
4. Run `/onboard` and select "Team member"

## Related Skills

- `bouncing-instances` - Auto-backup integration
- `session-state-persistence` - State files included
- `launchd-automation` - Schedule periodic backups

---

⛓⟿∞
