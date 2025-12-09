#!/usr/bin/env bash
#
# Claude Code Self-Improvement Engine - Cross-Platform Installer
#
# Supports: macOS, Linux, Windows (Git Bash / WSL)
#
# Usage: ./install.sh
#

set -euo pipefail

readonly INSTALL_DIR="${HOME}/.claude"
readonly REPO_URL="https://github.com/CodeTonight-SA/claude-optim.git"

log_info() {
    echo "[INFO] $*"
}

log_success() {
    echo "[SUCCESS] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

detect_os() {
    case "$(uname -s)" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

check_dependencies() {
    local os="$1"
    local missing=()

    if ! command -v jq &>/dev/null; then
        missing+=("jq")
    fi

    if ! command -v git &>/dev/null; then
        missing+=("git")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing[*]}"
        echo ""
        echo "Installation instructions:"
        case "$os" in
            macos)
                echo "  brew install ${missing[*]}"
                ;;
            linux)
                echo "  sudo apt-get install ${missing[*]}  # Debian/Ubuntu"
                echo "  sudo dnf install ${missing[*]}      # Fedora"
                echo "  sudo pacman -S ${missing[*]}        # Arch"
                ;;
            windows)
                echo "  choco install ${missing[*]}         # Chocolatey"
                echo "  Or download from official websites"
                ;;
        esac
        return 1
    fi

    log_success "All dependencies installed"
    return 0
}

install_files() {
    log_info "Installing Claude Code Self-Improvement Engine..."

    if [[ ! -d "$INSTALL_DIR" ]]; then
        log_info "Creating $INSTALL_DIR..."
        mkdir -p "$INSTALL_DIR"
    fi

    if [[ -d "$INSTALL_DIR/.git" ]]; then
        log_info "Repository exists, pulling latest..."
        cd "$INSTALL_DIR"
        git pull origin main
    else
        log_info "Cloning repository..."
        git clone "$REPO_URL" "$INSTALL_DIR"
        cd "$INSTALL_DIR"
    fi

    if [[ -f "optim.sh" ]]; then
        chmod +x optim.sh
        log_success "optim.sh is executable"
    fi

    log_success "Installation complete"
}

verify_installation() {
    log_info "Verifying installation..."

    local required_files=(
        "CLAUDE.md"
        "patterns.json"
        "optim.sh"
        "EFFICIENCY_CHECKLIST.md"
        "README.md"
    )

    for file in "${required_files[@]}"; do
        if [[ -f "$INSTALL_DIR/$file" ]]; then
            echo "  ✓ $file"
        else
            log_error "Missing required file: $file"
            return 1
        fi
    done

    jq empty "$INSTALL_DIR/patterns.json" || {
        log_error "patterns.json is invalid JSON"
        return 1
    }

    log_success "All required files present and valid"
}

post_install_setup() {
    log_info "Running post-install setup..."

    cd "$INSTALL_DIR"

    # Make all scripts executable
    for script in *.sh scripts/*.sh hooks/*.sh lib/*.sh demo/*.sh; do
        if [[ -f "$script" ]]; then
            chmod +x "$script"
        fi
    done 2>/dev/null || true
    log_success "Scripts made executable"

    # Initialize metrics.jsonl if missing
    if [[ ! -f "$INSTALL_DIR/metrics.jsonl" ]]; then
        echo '{"event":"system_initialized","timestamp":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"}' > "$INSTALL_DIR/metrics.jsonl"
        log_success "Initialized metrics.jsonl"
    fi

    # Index skills if skill-loader exists
    if [[ -f "$INSTALL_DIR/lib/skill-loader.sh" ]]; then
        log_info "Indexing skills..."
        # shellcheck source=/dev/null
        source "$INSTALL_DIR/lib/skill-loader.sh"
        if type index_all_skills &>/dev/null; then
            index_all_skills > /dev/null 2>&1 || true
            log_success "Skills indexed"
        fi
    fi

    # Index commands if command-executor exists
    if [[ -f "$INSTALL_DIR/lib/command-executor.sh" ]]; then
        log_info "Indexing commands..."
        # shellcheck source=/dev/null
        source "$INSTALL_DIR/lib/command-executor.sh"
        if type index_all_commands &>/dev/null; then
            index_all_commands > /dev/null 2>&1 || true
            log_success "Commands indexed"
        fi
    fi

    # Clean duplicate CLAUDE.md entries
    clean_claude_md_duplicates

    log_success "Post-install setup complete"
}

clean_claude_md_duplicates() {
    local claude_md="$INSTALL_DIR/CLAUDE.md"
    if [[ ! -f "$claude_md" ]]; then
        return 0
    fi

    log_info "Cleaning duplicate CLAUDE.md entries..."

    # Remove lines with "null: Auto-generated" (invalid entries)
    local temp_file
    temp_file=$(mktemp)
    rg -v '^\- \*\*null\*\*: Auto-generated' "$claude_md" > "$temp_file" 2>/dev/null || cat "$claude_md" > "$temp_file"

    # Remove duplicate auto-generated entries (keep first occurrence)
    awk '!seen[$0]++' "$temp_file" > "${temp_file}.dedup"
    mv "${temp_file}.dedup" "$claude_md"
    rm -f "$temp_file"

    log_success "Cleaned CLAUDE.md duplicates"
}

show_next_steps() {
    echo ""
    echo "================================================================"
    echo "🎉 Installation Complete!"
    echo "================================================================"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Navigate to the installation directory:"
    echo "   cd $INSTALL_DIR"
    echo ""
    echo "2. Run pattern detection:"
    echo "   ./optim.sh detect"
    echo ""
    echo "3. Generate a skill from a pattern:"
    echo "   ./optim.sh generate repeated-file-reads"
    echo ""
    echo "4. Run meta-optimization (recursion):"
    echo "   ./optim.sh optimize"
    echo ""
    echo "5. Run full improvement cycle:"
    echo "   ./optim.sh cycle"
    echo ""
    echo "================================================================"
    echo "Documentation: $INSTALL_DIR/README.md"
    echo "================================================================"
}

main() {
    echo "================================================================"
    echo "Claude Code Self-Improvement Engine - Installer"
    echo "================================================================"
    echo ""

    local os
    os=$(detect_os)
    log_info "Detected OS: $os"

    check_dependencies "$os" || exit 1

    install_files || exit 1

    verify_installation || exit 1

    post_install_setup || exit 1

    show_next_steps
}

main "$@"
