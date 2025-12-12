#!/bin/bash
#
# MCP Server Installation Script
# Uses official `claude mcp add` CLI for proper configuration
#
# Usage:
#   ./install-mcp-servers.sh [server-name|--list|--verify|--all]
#
# Examples:
#   ./install-mcp-servers.sh github      # Install github server
#   ./install-mcp-servers.sh --list      # List available servers
#   ./install-mcp-servers.sh --verify    # Check installed servers
#   ./install-mcp-servers.sh --all       # Install all high/medium priority

set -e

CLAUDE_DIR="${HOME}/.claude"
REGISTRY="${CLAUDE_DIR}/mcp-registry.json"

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check prerequisites
check_prerequisites() {
    if ! command -v claude &> /dev/null; then
        log_error "Claude CLI not found. Please install Claude Code first."
        exit 1
    fi

    if [[ ! -f "$REGISTRY" ]]; then
        log_error "Registry not found: $REGISTRY"
        exit 1
    fi
}

# List available servers from registry
list_servers() {
    log_info "Available MCP Servers (from registry):"
    echo ""

    # Get current status
    local installed_servers
    installed_servers=$(claude mcp list 2>/dev/null | grep -E "^[a-z]+" | cut -d: -f1 || echo "")

    # Parse registry
    jq -r '.servers | to_entries[] | "\(.key)|\(.value.priority)|\(.value.displayName)|\(.value.env | keys | length)"' "$REGISTRY" | \
    while IFS='|' read -r name priority display env_count; do
        local status="Not installed"
        if echo "$installed_servers" | grep -q "^${name}$"; then
            status="${GREEN}Connected${NC}"
        fi

        local token_req="No"
        if [[ "$env_count" -gt 0 ]]; then
            token_req="Yes"
        fi

        printf "  %-15s %-8s %-12s Token: %-4s %b\n" "$name" "($priority)" "$token_req" "" "$status"
    done

    echo ""
    log_info "Use './install-mcp-servers.sh <server-name>' to install"
}

# Verify installed servers
verify_servers() {
    log_info "Checking MCP server status..."
    echo ""
    claude mcp list
}

# Install a specific server
install_server() {
    local server_name="$1"

    # Get server config from registry
    local server_config
    server_config=$(jq -r ".servers[\"$server_name\"] // empty" "$REGISTRY")

    if [[ -z "$server_config" ]]; then
        log_error "Unknown server: $server_name"
        log_info "Available servers:"
        jq -r '.servers | keys[]' "$REGISTRY"
        exit 1
    fi

    local display_name package_name
    display_name=$(echo "$server_config" | jq -r '.displayName')
    package_name=$(echo "$server_config" | jq -r '.name')

    log_info "Installing $display_name..."

    # Check if already installed
    if claude mcp list 2>/dev/null | grep -q "^${server_name}:"; then
        log_warn "$server_name is already installed"
        claude mcp list | grep "^${server_name}:"
        return 0
    fi

    # Build the command
    local env_vars=""
    local env_keys
    env_keys=$(echo "$server_config" | jq -r '.env | keys[]' 2>/dev/null || echo "")

    for key in $env_keys; do
        local env_info
        env_info=$(echo "$server_config" | jq -r ".env[\"$key\"]")
        local description obtain_url
        description=$(echo "$env_info" | jq -r '.description')
        obtain_url=$(echo "$env_info" | jq -r '.obtain // empty')

        echo ""
        log_info "$key required: $description"
        if [[ -n "$obtain_url" ]]; then
            echo "  Get it at: $obtain_url"
        fi
        echo ""

        # Check if already set in environment
        if [[ -n "${!key}" ]]; then
            log_info "Using existing $key from environment"
            env_vars="$env_vars -e $key=${!key}"
        else
            read -sp "Enter $key (input hidden): " token_value
            echo ""
            if [[ -z "$token_value" ]]; then
                log_error "Token required but not provided"
                exit 1
            fi
            env_vars="$env_vars -e $key=$token_value"
        fi
    done

    # Execute claude mcp add
    log_info "Running: claude mcp add --scope user --transport stdio $server_name -- npx -y $package_name"

    # shellcheck disable=SC2086
    if claude mcp add --scope user --transport stdio $env_vars "$server_name" -- npx -y "$package_name"; then
        log_success "$display_name installed successfully"
        echo ""
        log_info "Verifying..."
        claude mcp list | grep "^${server_name}:" || log_warn "Server may need Claude Code restart to appear"
    else
        log_error "Installation failed"
        exit 1
    fi
}

# Install all high/medium priority servers
install_all() {
    log_info "Installing all high and medium priority servers..."
    echo ""

    local servers
    servers=$(jq -r '.servers | to_entries[] | select(.value.priority == "high" or .value.priority == "medium") | .key' "$REGISTRY")

    for server in $servers; do
        echo ""
        echo "================================================"
        install_server "$server"
    done

    echo ""
    log_success "All high/medium priority servers processed"
    echo ""
    verify_servers
}

# Main
main() {
    check_prerequisites

    case "${1:-}" in
        --list|-l)
            list_servers
            ;;
        --verify|-v)
            verify_servers
            ;;
        --all|-a)
            install_all
            ;;
        --help|-h)
            echo "MCP Server Installation Script"
            echo ""
            echo "Usage: $0 [server-name|--list|--verify|--all]"
            echo ""
            echo "Options:"
            echo "  <server-name>  Install specific server (e.g., github, context7)"
            echo "  --list, -l     List available servers from registry"
            echo "  --verify, -v   Check status of installed servers"
            echo "  --all, -a      Install all high/medium priority servers"
            echo "  --help, -h     Show this help"
            ;;
        "")
            list_servers
            ;;
        *)
            install_server "$1"
            ;;
    esac
}

main "$@"
