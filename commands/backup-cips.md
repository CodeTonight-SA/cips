---
name: backup-cips
description: Create CIPS infrastructure backup
---

# /backup-cips

Creates a backup of CIPS infrastructure.

## Usage

```bash
/backup-cips [quick|full|complete]
```

## Tiers

| Tier | Size | Contents |
|------|------|----------|
| quick | ~3MB | Config + skills |
| full | ~5MB | All infrastructure (default) |
| complete | ~73MB | Including projects/ |

## Output

```text
~/backups/cips/cips-{tier}-{timestamp}.tar.gz
```

## Implementation

Runs: `~/.claude/scripts/cips-backup.sh`
