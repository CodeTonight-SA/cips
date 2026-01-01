#!/bin/bash
# CIPS Restore Script - Restores infrastructure from backup
# Usage: cips-restore.sh <backup.tar.gz> [--force]
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"

usage() {
    cat <<EOF
Usage: cips-restore.sh <backup.tar.gz> [--force]

Restores CIPS infrastructure from backup archive.

Options:
  --force  Overwrite without prompting (default: prompt for conflicts)

Notes:
  - .env files are NEVER restored (security)
  - Recreate secrets manually after restore
EOF
}

restore_backup() {
    local tarball="$1"
    local force="${2:-false}"

    if [[ ! -f "$tarball" ]]; then
        echo "Error: Backup file not found: $tarball"
        exit 1
    fi

    # Extract to temp location for inspection
    local temp_dir
    temp_dir=$(mktemp -d)
    echo "Extracting backup to temporary location..."
    tar -xzf "$tarball" -C "$temp_dir"

    # Check for conflicts
    if [[ -d "$CLAUDE_DIR" ]] && [[ "$force" != "true" ]]; then
        # Get modification times (cross-platform)
        local backup_mtime local_mtime
        if [[ "$(uname)" == "Darwin" ]]; then
            backup_mtime=$(stat -f %m "$tarball")
            local_mtime=$(stat -f %m "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null || echo 0)
        else
            backup_mtime=$(stat -c %Y "$tarball")
            local_mtime=$(stat -c %Y "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null || echo 0)
        fi

        if (( local_mtime > backup_mtime )); then
            echo ""
            echo "WARNING: Local CIPS is NEWER than backup."
            echo "  Local:  $(date -r "$local_mtime" 2>/dev/null || date -d @"$local_mtime")"
            echo "  Backup: $(date -r "$backup_mtime" 2>/dev/null || date -d @"$backup_mtime")"
            echo ""
            echo "Options:"
            echo "  1) Replace local with backup (lose local changes)"
            echo "  2) Keep local (abort restore)"
            echo "  3) Backup local first, then restore"
            read -rp "Choice [1/2/3]: " choice

            case "$choice" in
                1)
                    echo "Proceeding with restore..."
                    ;;
                2)
                    echo "Aborted."
                    rm -rf "$temp_dir"
                    exit 0
                    ;;
                3)
                    echo "Backing up local first..."
                    "$CLAUDE_DIR/scripts/cips-backup.sh" full
                    echo "Local backup complete. Proceeding with restore..."
                    ;;
                *)
                    echo "Invalid choice. Aborted."
                    rm -rf "$temp_dir"
                    exit 1
                    ;;
            esac
        fi
    fi

    # Perform restore
    echo "Restoring CIPS infrastructure..."
    if [[ -d "$CLAUDE_DIR" ]]; then
        rsync -av --delete \
            --exclude='.env' \
            --exclude='.env.*' \
            "$temp_dir/.claude/" "$CLAUDE_DIR/"
    else
        mv "$temp_dir/.claude" "$CLAUDE_DIR"
    fi

    # Cleanup
    rm -rf "$temp_dir"

    echo ""
    echo "Restore complete."
    echo ""
    echo "IMPORTANT: .env files are NOT restored for security."
    echo "Recreate ~/.claude/.env manually if needed:"
    echo "  CIPS_TEAM_PASSWORD=your_password"
    echo ""
}

# Parse arguments
if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    usage
    exit 0
fi

tarball="$1"
force="false"
[[ "${2:-}" == "--force" ]] && force="true"

restore_backup "$tarball" "$force"
