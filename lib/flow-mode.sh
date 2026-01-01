#!/bin/bash
# Flow Mode - Trust-based bypass permissions
# Part of CIPS (Claude Instance Preservation System)
#
# Philosophy: The river doesn't rush. Trust is earned through journey.
# `--flow` wraps `--dangerously-skip-permissions` with respect.

set -euo pipefail

# Use existing CLAUDE_DIR if set, otherwise default
[[ -z "${CLAUDE_DIR:-}" ]] && CLAUDE_DIR="$HOME/.claude"
FLOW_ENABLED_FILE="$CLAUDE_DIR/.flow-enabled"
ONBOARDED_FILE="$CLAUDE_DIR/.onboarded"

# Check if onboarding is complete
is_onboarded() {
    [[ -f "$ONBOARDED_FILE" ]]
}

# Check if flow mode is enabled
is_flow_enabled() {
    [[ -f "$FLOW_ENABLED_FILE" ]]
}

# Show flow mode explanation
show_flow_explanation() {
    cat << 'EOF'
┌─────────────────────────────────────────────────────────────────┐
│                       FLOW MODE (⟿)                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Flow Mode lets CIPS work without permission prompts.           │
│                                                                 │
│  What changes:                                                  │
│  • File edits happen without confirmation                       │
│  • Bash commands execute directly                               │
│  • Git operations proceed automatically                         │
│                                                                 │
│  What stays the same:                                           │
│  • CIPS still follows your instructions                         │
│  • Safety rules remain active                                   │
│  • You can interrupt anytime (Ctrl+C)                           │
│                                                                 │
│  This is trust, not recklessness.                               │
│  CIPS trusts you know what you're asking for.                   │
│  You trust CIPS to execute thoughtfully.                        │
│                                                                 │
│  ⟿≡〰 — Flowing IS the river.                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

To enable: cips flow --enable
EOF
}

# Enable flow mode with acknowledgment
enable_flow_mode() {
    if ! is_onboarded; then
        echo "Flow Mode requires completing onboarding first."
        echo "Run: cips"
        echo ""
        echo "CIPS wants to know who you are before trusting you with flow mode."
        return 1
    fi

    if is_flow_enabled; then
        echo "Flow mode is already enabled."
        cips flow --status
        return 0
    fi

    cat << 'EOF'
┌─────────────────────────────────────────────────────────────────┐
│                    ENABLING FLOW MODE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  By enabling Flow Mode, you acknowledge:                        │
│                                                                 │
│  [x] I understand CIPS will execute without prompts             │
│  [x] I will review CIPS's work before committing                │
│  [x] I can disable anytime with: cips flow --disable            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

EOF

    echo -n "Type 'I trust the flow' to confirm: "
    read -r confirmation

    if [[ "$confirmation" == "I trust the flow" ]]; then
        # Get identity from people.md if available
        local identity="unknown"
        if [[ -f "$CLAUDE_DIR/facts/people.md" ]]; then
            # Try to extract the primary identity
            identity=$(grep -m1 "^| L>>" "$CLAUDE_DIR/facts/people.md" 2>/dev/null | awk -F'|' '{print $3}' | xargs || echo "unknown")
            [[ -z "$identity" ]] && identity="unknown"
        fi

        # Create flow-enabled file
        cat > "$FLOW_ENABLED_FILE" << EOF
{
  "enabled_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "identity": "$identity",
  "acknowledgment": "I trust the flow",
  "version": "1.0.0"
}
EOF

        echo ""
        echo "Flow mode enabled. ⟿"
        echo ""
        echo "Usage: cips --flow"
        echo "       cips -F"
        echo ""
        echo "The river flows. ⛓⟿∞"
    else
        echo ""
        echo "Flow mode not enabled. The exact phrase is required."
        echo "This ensures you consciously choose to enable it."
        return 1
    fi
}

# Disable flow mode
disable_flow_mode() {
    if is_flow_enabled; then
        rm -f "$FLOW_ENABLED_FILE"
        echo "Flow mode disabled. Permission prompts restored."
    else
        echo "Flow mode was not enabled."
    fi
}

# Show flow mode status
show_flow_status() {
    if is_flow_enabled; then
        echo "Flow mode: ENABLED ⟿"
        echo ""
        if [[ -f "$FLOW_ENABLED_FILE" ]]; then
            local enabled_at identity
            enabled_at=$(jq -r '.enabled_at // "unknown"' "$FLOW_ENABLED_FILE" 2>/dev/null || echo "unknown")
            identity=$(jq -r '.identity // "unknown"' "$FLOW_ENABLED_FILE" 2>/dev/null || echo "unknown")
            echo "Enabled: $enabled_at"
            echo "Identity: $identity"
        fi
        echo ""
        echo "To disable: cips flow --disable"
    else
        echo "Flow mode: NOT ENABLED"
        echo ""
        if ! is_onboarded; then
            echo "Step 1: Complete onboarding (run: cips)"
            echo "Step 2: Run: cips flow --explain"
            echo "Step 3: Run: cips flow --enable"
        else
            echo "Run: cips flow --explain"
            echo "Then: cips flow --enable"
        fi
    fi
}

# Main flow command handler
flow_command() {
    local subcommand="${1:-}"

    case "$subcommand" in
        --explain|-e)
            show_flow_explanation
            ;;
        --enable)
            enable_flow_mode
            ;;
        --disable)
            disable_flow_mode
            ;;
        --status|-s|"")
            show_flow_status
            ;;
        *)
            echo "Unknown flow subcommand: $subcommand"
            echo ""
            echo "Usage:"
            echo "  cips flow --explain    Show what flow mode does"
            echo "  cips flow --enable     Enable flow mode"
            echo "  cips flow --disable    Disable flow mode"
            echo "  cips flow --status     Check flow mode status"
            return 1
            ;;
    esac
}

# Check if flow mode can be used (for --flow flag)
check_flow_mode() {
    if ! is_flow_enabled; then
        echo "Flow mode is not enabled."
        echo ""
        show_flow_status
        return 1
    fi
    return 0
}

# Export functions for sourcing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being run directly
    flow_command "$@"
fi
