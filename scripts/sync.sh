#!/usr/bin/env bash
#
# CIPS Sync Script
# Synchronises repository changes to runtime location.
#
# Usage: ./sync.sh [--dry-run] [--force]
#

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# ============================================================================
# COLOURS AND OUTPUT
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ============================================================================
# CORE DIRECTORIES AND FILES (same as install.sh)
# ============================================================================

readonly CORE_DIRS=(
    "skills"
    "agents"
    "commands"
    "lib"
    "docs"
    "rules"
    "lexicon"
    "hooks"
    "config"
    "scripts"
    "bin"
)

readonly CORE_FILES=(
    "CLAUDE.md"
    "LICENSE"
    "README.md"
    "CODE_OF_CONDUCT.md"
    "CONTRIBUTING.md"
    "SECURITY.md"
)

# ============================================================================
# DETECT INSTALLATION MODE
# ============================================================================

detect_installation_mode() {
    if [[ -d "$CLAUDE_DIR/.git" ]]; then
        echo "clone"
    elif [[ -f "$CLAUDE_DIR/.cips-symlinked" ]]; then
        echo "symlink"
    elif [[ -f "$CLAUDE_DIR/.cips-copy-source" ]]; then
        echo "copy"
    else
        echo "unknown"
    fi
}

get_source_dir() {
    local mode="$1"

    case "$mode" in
        clone)
            echo "$CLAUDE_DIR"
            ;;
        symlink)
            cat "$CLAUDE_DIR/.cips-symlinked"
            ;;
        copy)
            cat "$CLAUDE_DIR/.cips-copy-source" 2>/dev/null || echo "$REPO_DIR"
            ;;
        *)
            echo "$REPO_DIR"
            ;;
    esac
}

# ============================================================================
# CONFLICT RESOLUTION
# ============================================================================

ask_conflict_resolution() {
    local file="$1"
    local local_path="$2"
    local repo_path="$3"

    echo ""
    echo "Conflict: $file"
    echo "==========${file//?/=}"
    echo ""
    echo "1) Keep local version"
    echo "2) Use repository version"
    echo "3) View diff"
    echo ""
    read -rp "Choice [1/2/3]: " choice

    case "$choice" in
        1) echo "keep-local" ;;
        2) echo "use-repo" ;;
        3)
            echo ""
            diff -u "$local_path" "$repo_path" 2>/dev/null | head -50 || true
            echo ""
            ask_conflict_resolution "$file" "$local_path" "$repo_path"
            ;;
        *) echo "keep-local" ;;
    esac
}

# ============================================================================
# SYNC FUNCTIONS
# ============================================================================

sync_clone_mode() {
    log_info "Clone mode: Syncing via git..."

    cd "$CLAUDE_DIR"

    echo ""
    echo "Current status:"
    git status --short
    echo ""

    # Check for uncommitted changes
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
        log_warn "You have uncommitted changes."
        read -rp "Stash and continue? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            git stash
        else
            log_info "Sync cancelled."
            exit 0
        fi
    fi

    git pull --rebase

    log_success "Sync complete."
}

sync_symlink_mode() {
    local source_dir
    source_dir=$(cat "$CLAUDE_DIR/.cips-symlinked")

    log_info "Symlink mode: Source at $source_dir"

    if [[ ! -d "$source_dir" ]]; then
        log_error "Source directory not found: $source_dir"
        exit 1
    fi

    cd "$source_dir"

    echo ""
    echo "Current status:"
    git status --short
    echo ""

    git pull --rebase

    # Refresh symlinks in case new directories were added
    log_info "Refreshing symlinks..."

    for dir in "${CORE_DIRS[@]}"; do
        if [[ -d "$source_dir/$dir" ]]; then
            if [[ ! -L "$CLAUDE_DIR/$dir" ]]; then
                log_warn "Creating missing symlink: $dir/"
            fi
            ln -sfn "$source_dir/$dir" "$CLAUDE_DIR/$dir"
        fi
    done

    for file in "${CORE_FILES[@]}"; do
        if [[ -f "$source_dir/$file" ]]; then
            ln -sf "$source_dir/$file" "$CLAUDE_DIR/$file"
        fi
    done

    log_success "Sync complete."
}

sync_copy_mode() {
    local source_dir
    source_dir=$(cat "$CLAUDE_DIR/.cips-copy-source" 2>/dev/null || echo "$REPO_DIR")
    local dry_run="${1:-false}"
    local force="${2:-false}"

    log_info "Copy mode: Source at $source_dir"

    if [[ ! -d "$source_dir" ]]; then
        log_error "Source directory not found: $source_dir"
        log_info "Please specify source: ./sync.sh --source /path/to/cips"
        exit 1
    fi

    # Update source first
    log_info "Updating source repository..."
    cd "$source_dir"
    git pull --rebase

    echo ""

    # Track changes
    local new_files=()
    local modified_files=()

    # Find changed files in core directories
    for dir in "${CORE_DIRS[@]}"; do
        if [[ -d "$source_dir/$dir" ]]; then
            while IFS= read -r -d '' file; do
                local relative_path="${file#$source_dir/}"
                local target_file="$CLAUDE_DIR/$relative_path"

                if [[ ! -f "$target_file" ]]; then
                    new_files+=("$relative_path")
                elif ! diff -q "$file" "$target_file" &>/dev/null; then
                    modified_files+=("$relative_path")
                fi
            done < <(find "$source_dir/$dir" -type f -print0 2>/dev/null)
        fi
    done

    # Find changed core files
    for file in "${CORE_FILES[@]}"; do
        if [[ -f "$source_dir/$file" ]]; then
            if [[ ! -f "$CLAUDE_DIR/$file" ]]; then
                new_files+=("$file")
            elif ! diff -q "$source_dir/$file" "$CLAUDE_DIR/$file" &>/dev/null; then
                modified_files+=("$file")
            fi
        fi
    done

    # Show summary
    echo "Changes detected:"
    echo "  New files:      ${#new_files[@]}"
    echo "  Modified files: ${#modified_files[@]}"

    if [[ ${#new_files[@]} -eq 0 ]] && [[ ${#modified_files[@]} -eq 0 ]]; then
        log_success "Already up to date."
        return
    fi

    if [[ "$dry_run" == "true" ]]; then
        echo ""
        echo "New files:"
        for f in "${new_files[@]}"; do echo "  + $f"; done
        echo ""
        echo "Modified files:"
        for f in "${modified_files[@]}"; do echo "  M $f"; done
        echo ""
        log_info "(Dry run - no changes made)"
        return
    fi

    # Handle force mode
    if [[ "$force" == "true" ]]; then
        log_info "Force mode: Overwriting all files..."

        for file in "${new_files[@]}" "${modified_files[@]}"; do
            local dir
            dir=$(dirname "$CLAUDE_DIR/$file")
            mkdir -p "$dir"
            cp "$source_dir/$file" "$CLAUDE_DIR/$file"
        done

        log_success "Sync complete (forced ${#new_files[@]} new, ${#modified_files[@]} modified)."
        return
    fi

    # Interactive mode - ask for each conflict
    local synced=0
    local skipped=0

    # Copy new files without asking
    for file in "${new_files[@]}"; do
        local dir
        dir=$(dirname "$CLAUDE_DIR/$file")
        mkdir -p "$dir"
        cp "$source_dir/$file" "$CLAUDE_DIR/$file"
        log_success "Added: $file"
        ((synced++))
    done

    # Ask for each modified file
    for file in "${modified_files[@]}"; do
        local resolution
        resolution=$(ask_conflict_resolution "$file" "$CLAUDE_DIR/$file" "$source_dir/$file")

        case "$resolution" in
            use-repo)
                cp "$source_dir/$file" "$CLAUDE_DIR/$file"
                log_success "Updated: $file"
                ((synced++))
                ;;
            keep-local)
                log_info "Kept local: $file"
                ((skipped++))
                ;;
        esac
    done

    echo ""
    log_success "Sync complete. Updated: $synced, Skipped: $skipped"
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    local dry_run=false
    local force=false
    local source_override=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run) dry_run=true ;;
            --force) force=true ;;
            --source)
                shift
                source_override="$1"
                ;;
            -h|--help)
                echo "Usage: sync.sh [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --dry-run     Show what would be synced without making changes"
                echo "  --force       Overwrite all files without asking"
                echo "  --source DIR  Specify source repository directory"
                echo "  -h, --help    Show this help"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
        shift
    done

    echo ""
    echo "CIPS Sync"
    echo "========="
    echo ""

    local mode
    mode=$(detect_installation_mode)
    log_info "Installation mode: $mode"

    # Override source if specified
    if [[ -n "$source_override" ]]; then
        if [[ "$mode" == "copy" ]]; then
            echo "$source_override" > "$CLAUDE_DIR/.cips-copy-source"
        elif [[ "$mode" == "symlink" ]]; then
            echo "$source_override" > "$CLAUDE_DIR/.cips-symlinked"
        fi
    fi

    case "$mode" in
        clone)
            sync_clone_mode
            ;;
        symlink)
            sync_symlink_mode
            ;;
        copy)
            sync_copy_mode "$dry_run" "$force"
            ;;
        unknown)
            log_error "Cannot determine installation mode."
            log_info "This doesn't appear to be a CIPS installation."
            log_info "Run 'scripts/install.sh' to install CIPS first."
            exit 1
            ;;
    esac
}

main "$@"
