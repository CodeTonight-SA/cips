#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
REMOTE_NAME="origin"
MAIN_BRANCH="main"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_help() {
    cat << 'EOF'
Claude-Optim Sync Script
=========================

Synchronises ~/.claude with the Claude-Optim GitHub repository.

USAGE:
    ./sync-claude.sh [COMMAND]

COMMANDS:
    push        Stage, commit, and push local changes to remote
    pull        Fetch and merge remote changes (default)
    status      Show sync status without making changes
    backup      Create timestamped backup before sync
    help        Show this help message

EXAMPLES:
    ./sync-claude.sh              # Pull latest from remote
    ./sync-claude.sh push         # Push local changes
    ./sync-claude.sh status       # Check sync status
    ./sync-claude.sh backup pull  # Backup then pull

WORKFLOW:
    1. Make changes locally in ~/.claude (skills, agents, commands, etc.)
    2. Run: ./sync-claude.sh push
    3. On another machine, run: ./sync-claude.sh pull

FILES SYNCED:
    - skills/           Skill definitions
    - agents/           Agent configurations
    - commands/         Slash commands
    - CLAUDE.md         Global rules
    - crazy_script.sh   Self-improvement engine
    - *.md              Documentation

FILES EXCLUDED (via .gitignore):
    - projects/         Per-project conversation history
    - .read-cache.json  Session cache
    - .hooks.log        Debug logs
    - file-history/     Local file tracking
    - debug/            Debug artifacts

EOF
}

check_git_repo() {
    if [[ ! -d "${CLAUDE_DIR}/.git" ]]; then
        log_error "~/.claude is not a git repository"
        log_info "Clone it first: git clone https://github.com/CodeTonight-SA/claude-optim.git ~/.claude"
        exit 1
    fi
}

show_status() {
    log_info "Checking sync status..."
    cd "${CLAUDE_DIR}"

    git fetch "${REMOTE_NAME}" --quiet 2>/dev/null || true

    local_head=$(git rev-parse HEAD 2>/dev/null)
    remote_head=$(git rev-parse "${REMOTE_NAME}/${MAIN_BRANCH}" 2>/dev/null || echo "unknown")

    if [[ "${local_head}" == "${remote_head}" ]]; then
        log_success "Local and remote are in sync"
    else
        local_behind=$(git rev-list --count HEAD.."${REMOTE_NAME}/${MAIN_BRANCH}" 2>/dev/null || echo "0")
        local_ahead=$(git rev-list --count "${REMOTE_NAME}/${MAIN_BRANCH}"..HEAD 2>/dev/null || echo "0")

        if [[ "${local_behind}" -gt 0 ]]; then
            log_warn "Local is ${local_behind} commit(s) behind remote"
        fi
        if [[ "${local_ahead}" -gt 0 ]]; then
            log_warn "Local is ${local_ahead} commit(s) ahead of remote"
        fi
    fi

    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        log_warn "Local has uncommitted changes:"
        git status --short
    else
        log_success "Working directory is clean"
    fi
}

pull_changes() {
    log_info "Pulling changes from ${REMOTE_NAME}/${MAIN_BRANCH}..."
    cd "${CLAUDE_DIR}"

    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        log_warn "Stashing local changes..."
        git stash push -m "sync-claude auto-stash $(date +%Y%m%d-%H%M%S)"
        local stashed=true
    else
        local stashed=false
    fi

    git fetch "${REMOTE_NAME}" --quiet

    if git merge "${REMOTE_NAME}/${MAIN_BRANCH}" --ff-only 2>/dev/null; then
        log_success "Fast-forward merge successful"
    else
        log_warn "Cannot fast-forward, attempting regular merge..."
        if git merge "${REMOTE_NAME}/${MAIN_BRANCH}" -m "Merge remote changes"; then
            log_success "Merge successful"
        else
            log_error "Merge conflicts detected. Resolve manually:"
            git status --short
            if [[ "${stashed}" == true ]]; then
                log_warn "Your stashed changes are preserved. Run 'git stash pop' after resolving."
            fi
            exit 1
        fi
    fi

    if [[ "${stashed}" == true ]]; then
        log_info "Restoring stashed changes..."
        if git stash pop; then
            log_success "Stashed changes restored"
        else
            log_error "Conflict restoring stash. Resolve manually with 'git stash show' and 'git stash drop'"
        fi
    fi

    log_success "Pull complete"
}

push_changes() {
    log_info "Pushing changes to ${REMOTE_NAME}/${MAIN_BRANCH}..."
    cd "${CLAUDE_DIR}"

    if [[ -z $(git status --porcelain 2>/dev/null) ]]; then
        log_info "No local changes to push"
        return 0
    fi

    log_info "Staging all changes..."
    git add -A

    local timestamp=$(date +%Y-%m-%d\ %H:%M)
    local hostname=$(hostname -s 2>/dev/null || echo "unknown")
    local changed_files=$(git diff --cached --name-only | head -5 | tr '\n' ', ' | sed 's/,$//')

    local commit_msg="sync: ${timestamp} from ${hostname}

Updated: ${changed_files}

Primary Author: Claude-Optim Sync"

    log_info "Creating commit..."
    git commit -m "${commit_msg}"

    log_info "Pushing to remote..."
    if git push "${REMOTE_NAME}" "${MAIN_BRANCH}"; then
        log_success "Push complete"
    else
        log_error "Push failed. You may need to pull first: ./sync-claude.sh pull"
        exit 1
    fi
}

create_backup() {
    local backup_dir="${HOME}/.claude-backups"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_path="${backup_dir}/claude-${timestamp}"

    log_info "Creating backup at ${backup_path}..."
    mkdir -p "${backup_dir}"

    rsync -a --exclude='.git' --exclude='projects' --exclude='debug' \
        "${CLAUDE_DIR}/" "${backup_path}/"

    log_success "Backup created: ${backup_path}"
}

main() {
    local command="${1:-pull}"
    shift || true

    check_git_repo

    case "${command}" in
        pull)
            pull_changes
            ;;
        push)
            push_changes
            ;;
        status)
            show_status
            ;;
        backup)
            create_backup
            if [[ -n "${1:-}" ]]; then
                main "$@"
            fi
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: ${command}"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
