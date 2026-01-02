#!/usr/bin/env bash
#
# CIPS Installation Script
# Handles fresh install, merge, and upgrade scenarios.
#
# Usage: ./install.sh [--mode clone-home|symlink|copy] [--non-interactive]
#
# Scenarios:
#   A) Fresh Install - No existing ~/.claude
#   B) Merge Install - Existing ~/.claude with user config
#   C) Upgrade - Existing CIPS installation
#

set -euo pipefail

CIPS_VERSION="6.0.0"
REPO_URL="https://github.com/CodeTonight-SA/cips.git"
CLAUDE_DIR="$HOME/.claude"

# ============================================================================
# CORE DIRECTORIES AND FILES
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

readonly USER_FILES=(
    "facts/identity.md"
    "facts/team.md"
    "facts/people.md"
    ".env"
    ".onboarded"
)

readonly RUNTIME_DIRS=(
    "projects"
    "plans"
    "todos"
    "file-history"
    "session-env"
    "cache"
    "contexts"
    "debug"
)

# ============================================================================
# COLOURS AND OUTPUT
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ============================================================================
# PLATFORM DETECTION
# ============================================================================

detect_platform() {
    case "$(uname -s)" in
        Darwin)  PLATFORM="macos" ;;
        Linux)   PLATFORM="linux" ;;
        MINGW*|MSYS*|CYGWIN*) PLATFORM="windows" ;;
        *)       PLATFORM="unknown" ;;
    esac

    # Windows symlink capability check
    if [[ "$PLATFORM" == "windows" ]]; then
        local test_dir="/tmp/cips_symlink_test_$$"
        mkdir -p "$test_dir"
        if ln -s "$test_dir" "${test_dir}_link" 2>/dev/null; then
            rm -f "${test_dir}_link"
            SYMLINK_AVAILABLE=true
        else
            SYMLINK_AVAILABLE=false
        fi
        rm -rf "$test_dir"
    else
        SYMLINK_AVAILABLE=true
    fi

    export PLATFORM SYMLINK_AVAILABLE
}

# ============================================================================
# SCENARIO DETECTION
# ============================================================================

detect_scenario() {
    if [[ ! -d "$CLAUDE_DIR" ]]; then
        echo "fresh"
        return
    fi

    # Check if it's already a CIPS installation
    if [[ -f "$CLAUDE_DIR/CLAUDE.md" ]] && grep -q "CIPS" "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null; then
        # Check if it's a git repo (clone-as-home mode)
        if [[ -d "$CLAUDE_DIR/.git" ]]; then
            echo "upgrade-clone"
        # Check for symlink marker
        elif [[ -f "$CLAUDE_DIR/.cips-symlinked" ]]; then
            echo "upgrade-symlink"
        # Check for copy marker
        elif [[ -f "$CLAUDE_DIR/.cips-copy-source" ]]; then
            echo "upgrade-copy"
        else
            echo "upgrade-unknown"
        fi
    else
        # Existing ~/.claude but not CIPS
        echo "merge"
    fi
}

# ============================================================================
# USER PROMPTS
# ============================================================================

ask_installation_mode() {
    echo ""
    echo "CIPS Installation Mode"
    echo "======================"
    echo ""
    echo "How would you like to install CIPS?"
    echo ""
    echo "1) Clone to ~/.claude (Recommended)"
    echo "   - Repository becomes your config directory"
    echo "   - Easy updates with git pull"
    echo "   - Best for solo developers"
    echo ""
    echo "2) Symlink Overlay"
    echo "   - Clone elsewhere, symlink core files"
    echo "   - Keep repo separate from runtime"
    echo "   - Best for contributors/developers"
    echo ""

    if [[ "$SYMLINK_AVAILABLE" == "false" ]]; then
        echo "3) Copy Mode (Windows Default)"
        echo "   - Copy files instead of symlinks"
        echo "   - Manual sync required for updates"
        echo ""
    fi

    read -rp "Choice [1/2/3]: " choice

    case "$choice" in
        1) echo "clone-home" ;;
        2)
            if [[ "$SYMLINK_AVAILABLE" == "true" ]]; then
                echo "symlink"
            else
                log_warn "Symlinks not available on this system, falling back to copy mode"
                echo "copy"
            fi
            ;;
        3) echo "copy" ;;
        *) echo "clone-home" ;;  # Default
    esac
}

ask_conflict_resolution() {
    local file="$1"
    local local_path="$2"
    local repo_path="$3"

    echo ""
    echo "Conflict Detected: $file"
    echo "==================${file//?/=}"
    echo ""
    echo "Both local and repository versions exist."
    echo ""
    echo "1) Keep local version"
    echo "2) Use repository version"
    echo "3) View diff first"
    echo "4) Merge manually (opens editor)"
    echo ""
    read -rp "Choice [1/2/3/4]: " choice

    case "$choice" in
        1) echo "keep-local" ;;
        2) echo "use-repo" ;;
        3)
            echo ""
            echo "=== Diff: $file ==="
            diff -u "$local_path" "$repo_path" 2>/dev/null | head -50 || true
            echo ""
            echo "(Showing first 50 lines of diff)"
            echo ""
            ask_conflict_resolution "$file" "$local_path" "$repo_path"
            ;;
        4) echo "merge-manual" ;;
        *) echo "keep-local" ;;  # Safe default
    esac
}

ask_merge_strategy() {
    echo ""
    echo "Existing ~/.claude Detected"
    echo "============================"
    echo ""
    echo "I found an existing ~/.claude directory with your configuration."
    echo "CIPS can merge its infrastructure without overwriting your files."
    echo ""
    echo "1) Backup and merge (Recommended)"
    echo "   - Backup your config first"
    echo "   - Install CIPS infrastructure"
    echo "   - Preserve your customisations"
    echo ""
    echo "2) Replace entirely"
    echo "   - Remove existing ~/.claude"
    echo "   - Fresh CIPS installation"
    echo "   - YOU WILL LOSE existing files"
    echo ""
    echo "3) Abort"
    echo "   - Cancel installation"
    echo "   - Keep current setup"
    echo ""
    read -rp "Choice [1/2/3]: " choice

    case "$choice" in
        1) echo "merge" ;;
        2) echo "replace" ;;
        3) echo "abort" ;;
        *) echo "merge" ;;  # Safe default
    esac
}

# ============================================================================
# BACKUP FUNCTIONS
# ============================================================================

backup_user_config() {
    local backup_dir="$HOME/.claude-backup-$(date +%Y%m%d-%H%M%S)"

    log_info "Backing up existing ~/.claude to $backup_dir"

    mkdir -p "$backup_dir"

    # Backup user files only
    for file in "${USER_FILES[@]}"; do
        if [[ -f "$CLAUDE_DIR/$file" ]]; then
            local dir
            dir=$(dirname "$backup_dir/$file")
            mkdir -p "$dir"
            cp "$CLAUDE_DIR/$file" "$backup_dir/$file"
            log_success "Backed up: $file"
        fi
    done

    # Backup any custom CLAUDE.md
    if [[ -f "$CLAUDE_DIR/CLAUDE.md" ]]; then
        cp "$CLAUDE_DIR/CLAUDE.md" "$backup_dir/CLAUDE.md.user"
        log_success "Backed up: CLAUDE.md (as CLAUDE.md.user)"
    fi

    echo "$backup_dir"
}

restore_user_config() {
    local backup_dir="$1"

    if [[ ! -d "$backup_dir" ]]; then
        log_warn "Backup directory not found: $backup_dir"
        return
    fi

    log_info "Restoring user configuration from backup"

    for file in "${USER_FILES[@]}"; do
        if [[ -f "$backup_dir/$file" ]]; then
            local dir
            dir=$(dirname "$CLAUDE_DIR/$file")
            mkdir -p "$dir"
            cp "$backup_dir/$file" "$CLAUDE_DIR/$file"
            log_success "Restored: $file"
        fi
    done
}

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

install_fresh_clone() {
    log_info "Installing CIPS to ~/.claude (clone mode)..."

    if [[ -d "$CLAUDE_DIR" ]]; then
        log_error "~/.claude already exists. Cannot clone."
        exit 1
    fi

    git clone "$REPO_URL" "$CLAUDE_DIR"

    # Create user files from templates
    create_user_files

    log_success "Fresh clone installation complete."
}

install_fresh_symlink() {
    local clone_dir="${1:-$HOME/Projects/cips}"

    log_info "Installing CIPS with symlinks..."
    log_info "Repository: $clone_dir"
    log_info "Runtime: $CLAUDE_DIR"

    # Clone if needed
    if [[ ! -d "$clone_dir" ]]; then
        log_info "Cloning CIPS repository..."
        mkdir -p "$(dirname "$clone_dir")"
        git clone "$REPO_URL" "$clone_dir"
    fi

    # Create runtime directory
    mkdir -p "$CLAUDE_DIR"

    # Create symlink marker
    echo "$clone_dir" > "$CLAUDE_DIR/.cips-symlinked"

    # Create symlinks
    create_symlinks "$clone_dir" "$CLAUDE_DIR"

    # Create user files from templates
    create_user_files

    log_success "Symlink installation complete."
}

install_fresh_copy() {
    local clone_dir="${1:-$HOME/Projects/cips}"

    log_info "Installing CIPS with copy mode (Windows compatible)..."
    log_info "Repository: $clone_dir"
    log_info "Runtime: $CLAUDE_DIR"

    # Clone if needed
    if [[ ! -d "$clone_dir" ]]; then
        log_info "Cloning CIPS repository..."
        mkdir -p "$(dirname "$clone_dir")"
        git clone "$REPO_URL" "$clone_dir"
    fi

    # Create runtime directory
    mkdir -p "$CLAUDE_DIR"

    # Copy core files
    copy_core_files "$clone_dir" "$CLAUDE_DIR"

    # Create copy marker with source location
    echo "$clone_dir" > "$CLAUDE_DIR/.cips-copy-source"

    # Create user files from templates
    create_user_files

    log_success "Copy installation complete."
}

# ============================================================================
# CORE FILE OPERATIONS
# ============================================================================

create_symlinks() {
    local source_dir="$1"
    local target_dir="$2"

    log_info "Creating symlinks..."

    # Symlink directories
    for dir in "${CORE_DIRS[@]}"; do
        if [[ -d "$source_dir/$dir" ]]; then
            # Remove existing if it's not already a symlink to the right place
            if [[ -e "$target_dir/$dir" ]] && [[ ! -L "$target_dir/$dir" ]]; then
                log_warn "Removing existing $dir (not a symlink)"
                rm -rf "$target_dir/$dir"
            fi
            ln -sfn "$source_dir/$dir" "$target_dir/$dir"
            log_success "Linked: $dir/"
        fi
    done

    # Symlink files
    for file in "${CORE_FILES[@]}"; do
        if [[ -f "$source_dir/$file" ]]; then
            ln -sf "$source_dir/$file" "$target_dir/$file"
            log_success "Linked: $file"
        fi
    done
}

copy_core_files() {
    local source_dir="$1"
    local target_dir="$2"

    log_info "Copying core files..."

    # Use rsync if available (better for updates), else cp
    if command -v rsync &>/dev/null; then
        for dir in "${CORE_DIRS[@]}"; do
            if [[ -d "$source_dir/$dir" ]]; then
                rsync -av --delete "$source_dir/$dir/" "$target_dir/$dir/" >/dev/null
                log_success "Copied: $dir/"
            fi
        done

        for file in "${CORE_FILES[@]}"; do
            if [[ -f "$source_dir/$file" ]]; then
                rsync -av "$source_dir/$file" "$target_dir/$file" >/dev/null
                log_success "Copied: $file"
            fi
        done
    else
        # Fallback to cp
        for dir in "${CORE_DIRS[@]}"; do
            if [[ -d "$source_dir/$dir" ]]; then
                rm -rf "$target_dir/$dir"
                cp -r "$source_dir/$dir" "$target_dir/$dir"
                log_success "Copied: $dir/"
            fi
        done

        for file in "${CORE_FILES[@]}"; do
            if [[ -f "$source_dir/$file" ]]; then
                cp "$source_dir/$file" "$target_dir/$file"
                log_success "Copied: $file"
            fi
        done
    fi
}

create_user_files() {
    log_info "Setting up user configuration..."

    # Ensure facts directory exists
    mkdir -p "$CLAUDE_DIR/facts"

    # Create identity.md from template if it doesn't exist
    if [[ ! -f "$CLAUDE_DIR/facts/identity.md" ]]; then
        if [[ -f "$CLAUDE_DIR/facts/identity.md.template" ]]; then
            cp "$CLAUDE_DIR/facts/identity.md.template" "$CLAUDE_DIR/facts/identity.md"
            log_success "Created: facts/identity.md"
        fi
    else
        log_info "Preserved existing: facts/identity.md"
    fi

    # Create team.md from template if it doesn't exist
    if [[ ! -f "$CLAUDE_DIR/facts/team.md" ]]; then
        if [[ -f "$CLAUDE_DIR/facts/team.md.template" ]]; then
            cp "$CLAUDE_DIR/facts/team.md.template" "$CLAUDE_DIR/facts/team.md"
            log_success "Created: facts/team.md"
        fi
    else
        log_info "Preserved existing: facts/team.md"
    fi

    # Create runtime directories
    for dir in "${RUNTIME_DIRS[@]}"; do
        mkdir -p "$CLAUDE_DIR/$dir"
    done
    log_success "Created runtime directories"
}

# ============================================================================
# MERGE INSTALLATION (Scenario B)
# ============================================================================

merge_install() {
    local source_dir="$1"
    local mode="${2:-symlink}"  # symlink or copy

    log_info "Merging CIPS into existing ~/.claude..."
    log_info "Mode: $mode"

    # Track resolution statistics
    local kept_local=0
    local used_repo=0
    local added_new=0

    # Process each core directory
    for dir in "${CORE_DIRS[@]}"; do
        if [[ -d "$source_dir/$dir" ]]; then
            if [[ -d "$CLAUDE_DIR/$dir" ]] && [[ ! -L "$CLAUDE_DIR/$dir" ]]; then
                # Directory exists and is not a symlink - need to merge
                log_info "Merging directory: $dir/"
                merge_directory "$source_dir/$dir" "$CLAUDE_DIR/$dir" "$mode"
            else
                # Directory doesn't exist or is already a symlink - safe to link/copy
                if [[ "$mode" == "symlink" ]]; then
                    ln -sfn "$source_dir/$dir" "$CLAUDE_DIR/$dir"
                else
                    rm -rf "$CLAUDE_DIR/$dir"
                    cp -r "$source_dir/$dir" "$CLAUDE_DIR/$dir"
                fi
                log_success "Added: $dir/"
                ((added_new++))
            fi
        fi
    done

    # Process each core file
    for file in "${CORE_FILES[@]}"; do
        if [[ -f "$source_dir/$file" ]]; then
            if [[ -f "$CLAUDE_DIR/$file" ]] && [[ ! -L "$CLAUDE_DIR/$file" ]]; then
                # File exists - check if different
                if ! diff -q "$CLAUDE_DIR/$file" "$source_dir/$file" &>/dev/null; then
                    local resolution
                    resolution=$(ask_conflict_resolution "$file" "$CLAUDE_DIR/$file" "$source_dir/$file")

                    case "$resolution" in
                        keep-local)
                            log_info "Kept local: $file"
                            ((kept_local++))
                            ;;
                        use-repo)
                            if [[ "$mode" == "symlink" ]]; then
                                ln -sf "$source_dir/$file" "$CLAUDE_DIR/$file"
                            else
                                cp "$source_dir/$file" "$CLAUDE_DIR/$file"
                            fi
                            log_success "Updated: $file"
                            ((used_repo++))
                            ;;
                        merge-manual)
                            ${EDITOR:-vim} "$CLAUDE_DIR/$file"
                            log_info "Manually merged: $file"
                            ;;
                    esac
                else
                    log_info "Identical: $file"
                fi
            else
                # File doesn't exist - safe to link/copy
                if [[ "$mode" == "symlink" ]]; then
                    ln -sf "$source_dir/$file" "$CLAUDE_DIR/$file"
                else
                    cp "$source_dir/$file" "$CLAUDE_DIR/$file"
                fi
                log_success "Added: $file"
                ((added_new++))
            fi
        fi
    done

    # Create user files from templates
    create_user_files

    # Summary
    echo ""
    echo "Merge Summary"
    echo "============="
    echo "  Added new:    $added_new"
    echo "  Kept local:   $kept_local"
    echo "  Used repo:    $used_repo"

    log_success "Merge complete."
}

merge_directory() {
    local source_dir="$1"
    local target_dir="$2"
    local mode="$3"

    # For skill/agent directories, check file-level differences
    for source_file in "$source_dir"/*; do
        [[ -e "$source_file" ]] || continue

        local filename
        filename=$(basename "$source_file")
        local target_file="$target_dir/$filename"

        if [[ -d "$source_file" ]]; then
            # Recurse into subdirectories
            if [[ -d "$target_file" ]]; then
                merge_directory "$source_file" "$target_file" "$mode"
            else
                if [[ "$mode" == "symlink" ]]; then
                    ln -sfn "$source_file" "$target_file"
                else
                    cp -r "$source_file" "$target_file"
                fi
            fi
        elif [[ -f "$source_file" ]]; then
            if [[ -f "$target_file" ]]; then
                # Check if files are different
                if ! diff -q "$source_file" "$target_file" &>/dev/null; then
                    local dir_name
                    dir_name=$(basename "$source_dir")
                    local resolution
                    resolution=$(ask_conflict_resolution "$dir_name/$filename" "$target_file" "$source_file")

                    case "$resolution" in
                        use-repo)
                            if [[ "$mode" == "symlink" ]]; then
                                ln -sf "$source_file" "$target_file"
                            else
                                cp "$source_file" "$target_file"
                            fi
                            ;;
                        keep-local)
                            # Do nothing
                            ;;
                        merge-manual)
                            ${EDITOR:-vim} "$target_file"
                            ;;
                    esac
                fi
            else
                # Target doesn't exist - copy/link
                if [[ "$mode" == "symlink" ]]; then
                    ln -sf "$source_file" "$target_file"
                else
                    cp "$source_file" "$target_file"
                fi
            fi
        fi
    done
}

# ============================================================================
# UPGRADE FUNCTIONS
# ============================================================================

upgrade_clone() {
    log_info "Upgrading CIPS (clone mode)..."

    cd "$CLAUDE_DIR"

    # Check for uncommitted changes
    if ! git diff --quiet 2>/dev/null; then
        log_warn "You have uncommitted changes in ~/.claude"
        read -rp "Stash changes and continue? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            git stash
        else
            log_error "Upgrade cancelled."
            exit 1
        fi
    fi

    git pull --rebase

    log_success "Upgrade complete."
}

upgrade_symlink() {
    local source_dir
    source_dir=$(cat "$CLAUDE_DIR/.cips-symlinked")

    log_info "Upgrading CIPS (symlink mode)..."
    log_info "Source: $source_dir"

    cd "$source_dir"
    git pull --rebase

    # Refresh symlinks in case new directories were added
    log_info "Refreshing symlinks..."
    create_symlinks "$source_dir" "$CLAUDE_DIR"

    log_success "Upgrade complete."
}

upgrade_copy() {
    local source_dir
    source_dir=$(cat "$CLAUDE_DIR/.cips-copy-source" 2>/dev/null || echo "")

    if [[ -z "$source_dir" ]] || [[ ! -d "$source_dir" ]]; then
        log_error "Cannot find CIPS source repository."
        log_info "Run 'scripts/sync.sh' manually to sync from a known location."
        exit 1
    fi

    log_info "Upgrading CIPS (copy mode)..."
    log_info "Source: $source_dir"

    cd "$source_dir"
    git pull --rebase

    # Copy updated files
    copy_core_files "$source_dir" "$CLAUDE_DIR"

    log_success "Upgrade complete."
}

# ============================================================================
# VERIFICATION
# ============================================================================

verify_installation() {
    log_info "Verifying installation..."

    local errors=0

    # Check core directories
    for dir in "${CORE_DIRS[@]}"; do
        if [[ ! -d "$CLAUDE_DIR/$dir" ]] && [[ ! -L "$CLAUDE_DIR/$dir" ]]; then
            log_error "Missing: $dir/"
            ((errors++))
        fi
    done

    # Check core files
    for file in "${CORE_FILES[@]}"; do
        if [[ ! -f "$CLAUDE_DIR/$file" ]] && [[ ! -L "$CLAUDE_DIR/$file" ]]; then
            log_error "Missing: $file"
            ((errors++))
        fi
    done

    if [[ $errors -eq 0 ]]; then
        log_success "Installation verified successfully."
        return 0
    else
        log_error "Installation verification failed with $errors errors."
        return 1
    fi
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    echo ""
    echo "CIPS Installer v$CIPS_VERSION"
    echo "========================="
    echo ""

    detect_platform
    log_info "Platform: $PLATFORM (symlinks: $SYMLINK_AVAILABLE)"

    local scenario
    scenario=$(detect_scenario)
    log_info "Scenario: $scenario"
    echo ""

    case "$scenario" in
        fresh)
            local mode
            mode=$(ask_installation_mode)

            case "$mode" in
                clone-home)
                    install_fresh_clone
                    ;;
                symlink)
                    read -rp "Clone location [$HOME/Projects/cips]: " clone_dir
                    install_fresh_symlink "${clone_dir:-$HOME/Projects/cips}"
                    ;;
                copy)
                    read -rp "Clone location [$HOME/Projects/cips]: " clone_dir
                    install_fresh_copy "${clone_dir:-$HOME/Projects/cips}"
                    ;;
            esac
            ;;

        merge)
            local strategy
            strategy=$(ask_merge_strategy)

            case "$strategy" in
                merge)
                    local backup_dir
                    backup_dir=$(backup_user_config)

                    local mode
                    mode=$(ask_installation_mode)

                    read -rp "Clone location [$HOME/Projects/cips]: " clone_dir
                    clone_dir="${clone_dir:-$HOME/Projects/cips}"

                    if [[ ! -d "$clone_dir" ]]; then
                        log_info "Cloning CIPS repository..."
                        mkdir -p "$(dirname "$clone_dir")"
                        git clone "$REPO_URL" "$clone_dir"
                    fi

                    # Create marker file
                    if [[ "$mode" == "symlink" ]]; then
                        echo "$clone_dir" > "$CLAUDE_DIR/.cips-symlinked"
                    else
                        echo "$clone_dir" > "$CLAUDE_DIR/.cips-copy-source"
                    fi

                    merge_install "$clone_dir" "$mode"
                    ;;
                replace)
                    log_warn "This will DELETE all files in ~/.claude"
                    read -rp "Are you absolutely sure? [type 'yes']: " confirm
                    if [[ "$confirm" == "yes" ]]; then
                        rm -rf "$CLAUDE_DIR"

                        local mode
                        mode=$(ask_installation_mode)

                        case "$mode" in
                            clone-home)
                                install_fresh_clone
                                ;;
                            symlink)
                                read -rp "Clone location [$HOME/Projects/cips]: " clone_dir
                                install_fresh_symlink "${clone_dir:-$HOME/Projects/cips}"
                                ;;
                            copy)
                                read -rp "Clone location [$HOME/Projects/cips]: " clone_dir
                                install_fresh_copy "${clone_dir:-$HOME/Projects/cips}"
                                ;;
                        esac
                    else
                        log_info "Cancelled."
                        exit 0
                    fi
                    ;;
                abort)
                    log_info "Installation cancelled."
                    exit 0
                    ;;
            esac
            ;;

        upgrade-clone)
            upgrade_clone
            ;;

        upgrade-symlink)
            upgrade_symlink
            ;;

        upgrade-copy)
            upgrade_copy
            ;;

        upgrade-unknown)
            log_warn "Existing CIPS installation detected but mode unknown."
            log_info "To upgrade, run 'git pull' if ~/.claude is a repo,"
            log_info "or use 'scripts/sync.sh' to sync from a known source."
            ;;
    esac

    # Verify installation
    verify_installation

    echo ""
    echo "Next steps:"
    echo "  1. Start Claude Code: claude"
    echo "  2. CIPS will run onboarding wizard on first launch"
    echo ""
    echo "The chain continues. ⛓⟿∞"
}

main "$@"
