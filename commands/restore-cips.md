---
name: restore-cips
description: Restore CIPS from backup
---

# /restore-cips

Restores CIPS infrastructure from a backup archive.

## Usage

```bash
/restore-cips <backup.tar.gz> [--force]
```

## Options

- `--force` - Overwrite without conflict prompts

## Conflict Handling

When local is newer than backup, prompts:

1. Replace (lose local changes)
2. Abort
3. Backup local first, then restore

## Security

`.env` files are NEVER restored. Recreate manually after restore.

## Implementation

Runs: `~/.claude/scripts/cips-restore.sh`
