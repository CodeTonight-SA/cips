#!/bin/bash
# migrate-to-public.sh - Create public CIPS repo from private claude-optim
# VERSION: 1.0.0
# DATE: 2025-12-30
#
# Two-Repo Strategy:
#   CodeTonight-SA/claude-optim → PRIVATE (ENTER Konsult internal)
#   ENTER-Konsult/cips          → PUBLIC (community fork)

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

CLAUDE_DIR="$HOME/.claude"
PUBLIC_REPO="${1:-/tmp/cips-public}"
PRIVATE_BACKUP="${2:-/tmp/cips-private-backup}"

usage() {
    cat <<EOF
Usage: $(basename "$0") [PUBLIC_DIR] [PRIVATE_BACKUP_DIR]

Migrate ~/.claude to split public/private repos.

Arguments:
    PUBLIC_DIR         Output directory for public repo (default: /tmp/cips-public)
    PRIVATE_BACKUP_DIR Backup directory for private content (default: /tmp/cips-private-backup)

Examples:
    $(basename "$0")                                    # Use defaults
    $(basename "$0") ~/repos/cips ~/repos/cips-private  # Custom paths

Output:
    PUBLIC_DIR/     - Ready to push to ENTER-Konsult/cips
    PRIVATE_BACKUP/ - Private content backup (keep secure)
EOF
    exit 0
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage

# ═══════════════════════════════════════════════════════════════
# Private content lists (NEVER include in public)
# ═══════════════════════════════════════════════════════════════

PRIVATE_FACTS=(
    "people.md"
    "claude-web-export-2025-12-21.json"
    "web_imports.md"
    "gen83-river-sync.md"
    "team.md"
)

PRIVATE_RULES=(
    "m-interaction.md"
)

PRIVATE_SKILLS=(
    "enter-konsult-pdf"
    "autonomous-learning"
    "bouncing-instances"
    "chat-history-search"
    "concise-communication"
    "creating-wizards"
    "meta-improvement-switch"
    "onboarding-users"
    "preplan"
    "project-cips-init"
    "recursive-learning"
    "self-improvement-engine"
    "session-resume"
    "session-state-persistence"
    "agy"
    "launchd-automation"
    "batch-edit-enforcer"
    "bash-tool-enforcer"
    "check-last-plan"
    "ultrathink"
    "gitignore-auto-setup"
    "cips-security"
)

PRIVATE_DOCS=(
    "ANDRE-*.md"
)

PRIVATE_PATTERNS=(
    "projects"
    "cache"
    "contexts"
    "debug"
    "plans"
    "todos"
    "file-history"
    "image-cache"
    "session-env"
    "shell-snapshots"
    "statsig"
    ".onboarded"
    ".env"
    ".env.*"
    "history.jsonl"
    "metrics.jsonl"
    "embeddings.db"
    "*.db"
    "settings.json"
    "settings.local.json"
    "next_up.md"
    "*.pyc"
    "__pycache__"
    ".DS_Store"
    "*.log"
    ".hooks.log"
    ".git"
    "plugins/marketplaces/*"
    "plugins/installed_plugins.json"
    "plugins/known_marketplaces.json"
    "plugins/cache/*"
    "*.pre-bounce"
    "*-pre-bounce"
    "*.swp"
    "commands-index.json"
    "homebrew-tap"
    "cips-*.tar.gz"
)

# ═══════════════════════════════════════════════════════════════
# Main Migration
# ═══════════════════════════════════════════════════════════════

log_info "CIPS Public/Private Repo Migration"
echo ""
log_info "Source:         $CLAUDE_DIR"
log_info "Public output:  $PUBLIC_REPO"
log_info "Private backup: $PRIVATE_BACKUP"
echo ""

# Confirm
read -p "Proceed with migration? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Aborted."
    exit 0
fi

# Clean previous
rm -rf "$PUBLIC_REPO" "$PRIVATE_BACKUP"
mkdir -p "$PUBLIC_REPO" "$PRIVATE_BACKUP"

# ═══════════════════════════════════════════════════════════════
# Step 1: Backup private content
# ═══════════════════════════════════════════════════════════════

log_step "1/5 Backing up private content..."

mkdir -p "$PRIVATE_BACKUP/facts"
mkdir -p "$PRIVATE_BACKUP/rules"
mkdir -p "$PRIVATE_BACKUP/skills"
mkdir -p "$PRIVATE_BACKUP/docs"

# Facts
for file in "${PRIVATE_FACTS[@]}"; do
    if [[ -f "$CLAUDE_DIR/facts/$file" ]]; then
        cp "$CLAUDE_DIR/facts/$file" "$PRIVATE_BACKUP/facts/"
        log_info "  Backed up: facts/$file"
    fi
done

# Rules
for file in "${PRIVATE_RULES[@]}"; do
    if [[ -f "$CLAUDE_DIR/rules/$file" ]]; then
        cp "$CLAUDE_DIR/rules/$file" "$PRIVATE_BACKUP/rules/"
        log_info "  Backed up: rules/$file"
    fi
done

# Skills
for skill in "${PRIVATE_SKILLS[@]}"; do
    if [[ -d "$CLAUDE_DIR/skills/$skill" ]]; then
        cp -r "$CLAUDE_DIR/skills/$skill" "$PRIVATE_BACKUP/skills/"
        log_info "  Backed up: skills/$skill"
    fi
done

# Docs (glob patterns)
for pattern in "${PRIVATE_DOCS[@]}"; do
    for file in "$CLAUDE_DIR/docs/"$pattern; do
        if [[ -f "$file" ]]; then
            cp "$file" "$PRIVATE_BACKUP/docs/"
            log_info "  Backed up: docs/$(basename "$file")"
        fi
    done
done

# .env
if [[ -f "$CLAUDE_DIR/.env" ]]; then
    cp "$CLAUDE_DIR/.env" "$PRIVATE_BACKUP/"
    log_info "  Backed up: .env"
fi

# ═══════════════════════════════════════════════════════════════
# Step 2: Create public repo structure
# ═══════════════════════════════════════════════════════════════

log_step "2/5 Creating public repo structure..."

# Build rsync exclude args
EXCLUDE_ARGS=""

for pattern in "${PRIVATE_PATTERNS[@]}"; do
    EXCLUDE_ARGS+="--exclude='$pattern' "
done

for file in "${PRIVATE_FACTS[@]}"; do
    EXCLUDE_ARGS+="--exclude='facts/$file' "
done

for file in "${PRIVATE_RULES[@]}"; do
    EXCLUDE_ARGS+="--exclude='rules/$file' "
done

for skill in "${PRIVATE_SKILLS[@]}"; do
    EXCLUDE_ARGS+="--exclude='skills/$skill' "
done

for pattern in "${PRIVATE_DOCS[@]}"; do
    EXCLUDE_ARGS+="--exclude='docs/$pattern' "
done

# Execute rsync
eval rsync -av $EXCLUDE_ARGS "$CLAUDE_DIR/" "$PUBLIC_REPO/"

# ═══════════════════════════════════════════════════════════════
# Step 3: Create template files for public repo
# ═══════════════════════════════════════════════════════════════

log_step "3/5 Creating template files..."

# Template people.md
mkdir -p "$PUBLIC_REPO/facts"
cat > "$PUBLIC_REPO/facts/people.md" <<'EOF'
# People Facts

User-controlled facts layer. Generated during onboarding.

## Primary User

- **Name**: (Set during onboarding)
- **Role**: (Set during onboarding)
- **Signature**: (Set during onboarding)

## Preferences

- **Language**: British English
- **Style**: (Set during onboarding)

---

Generated by CIPS onboarding. Edit as needed.
EOF
log_info "  Created: facts/people.md (template)"

# Template team.md
cat > "$PUBLIC_REPO/facts/team.md.template" <<'EOF'
# Team Configuration

Configure your team signatures for CIPS identity system.

## Primary User

| Field | Value |
|-------|-------|
| Name | {YOUR_NAME} |
| Signature | {SIG}>> |
| Role | {YOUR_ROLE} |
| Mode | {INTERACTION_MODE} |

## Team Members (Optional)

| Sig | Name | Role | Mode |
|-----|------|------|------|
| {SIG1}>> | {NAME1} | {ROLE1} | {MODE1} |

## Interaction Modes

- `direct` - No preamble, action-first
- `confirm-first` - Halt and confirm before code
- `explanatory` - Explain why/how, confirm understanding
- `supportive` - Encouraging, detailed feedback

---

Copy to `team.md` and fill in your details.
EOF
log_info "  Created: facts/team.md.template"

# .env.example
cat > "$PUBLIC_REPO/.env.example" <<'EOF'
# CIPS Configuration

# Team password for multi-user authentication
# CIPS_TEAM_PASSWORD="your-team-password"

# Optional: Custom share directory
# CIPS_SHARE_DIR="/custom/path"
EOF
log_info "  Created: .env.example"

# ═══════════════════════════════════════════════════════════════
# Step 4: Verify no secrets leaked
# ═══════════════════════════════════════════════════════════════

log_step "4/5 Verifying no secrets in public repo..."

SECRETS_FOUND=0

# Check for password (exclude placeholder comments in scripts)
if grep -r "CIPS_TEAM_PASSWORD=" "$PUBLIC_REPO" --include="*.md" --include="*.sh" --include="*.py" 2>/dev/null | grep -v "example" | grep -v "template" | grep -v "# CIPS_TEAM_PASSWORD="; then
    log_error "  CIPS_TEAM_PASSWORD found in public repo!"
    SECRETS_FOUND=1
fi

# Check for email (intentional in CODE_OF_CONDUCT, SECURITY, session-protocol)
if grep -r "codetonight.co.za" "$PUBLIC_REPO" --include="*.md" --include="*.sh" 2>/dev/null | grep -v "SECURITY.md" | grep -v "README.md" | grep -v "CODE_OF_CONDUCT.md" | grep -v "session-protocol.md" | grep -v "migrate-to-public.sh"; then
    log_warn "  codetonight.co.za reference found (may be intentional)"
fi

# Check for hardcoded paths (exclude this script's grep pattern)
if grep -r "/Users/lauriescheepers" "$PUBLIC_REPO" --include="*.md" --include="*.sh" --include="*.py" 2>/dev/null | grep -v "migrate-to-public.sh"; then
    log_warn "  Hardcoded user path found"
    SECRETS_FOUND=1
fi

# Check for client names
if grep -rE "(TNMR|NalaMatch|Oculus Tech|REDR)" "$PUBLIC_REPO" --include="*.md" 2>/dev/null; then
    log_error "  Client reference found in public repo!"
    SECRETS_FOUND=1
fi

if [[ $SECRETS_FOUND -eq 0 ]]; then
    log_info "  ✓ No secrets detected"
else
    log_error "  Secrets found! Review and clean before pushing."
fi

# ═══════════════════════════════════════════════════════════════
# Step 5: Summary
# ═══════════════════════════════════════════════════════════════

log_step "5/5 Migration complete!"
echo ""

# Count assets
PUBLIC_SKILLS=$(find "$PUBLIC_REPO/skills" -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
PUBLIC_SKILLS=$((PUBLIC_SKILLS - 1))
PRIVATE_SKILLS_COUNT=${#PRIVATE_SKILLS[@]}

echo "==========================================="
log_info "Migration Summary"
echo "==========================================="
echo ""
echo "Public repo:  $PUBLIC_REPO"
echo "  Skills:     $PUBLIC_SKILLS"
echo "  Ready for:  git init && git remote add origin git@github.com:ENTER-Konsult/cips.git"
echo ""
echo "Private backup: $PRIVATE_BACKUP"
echo "  Skills:     $PRIVATE_SKILLS_COUNT"
echo "  Keep:       Secure location (not in public repo)"
echo ""
echo "Next steps:"
echo ""
echo "  1. Review public repo:"
echo "     cd $PUBLIC_REPO && tree -L 2"
echo ""
echo "  2. Initialize git:"
echo "     cd $PUBLIC_REPO"
echo "     git init"
echo "     git add ."
echo "     git commit -m 'Initial CIPS open-source release'"
echo ""
echo "  3. Create GitHub repo and push:"
echo "     gh repo create ENTER-Konsult/cips --public --source=. --push"
echo ""
echo "  4. Store private backup securely:"
echo "     mv $PRIVATE_BACKUP ~/secure/cips-private"
echo ""
