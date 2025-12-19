# MCP Server Setup Guide

Extend Claude Code capabilities via Model Context Protocol (MCP) servers.

## Installation Methods

### Method 1: Claude CLI (Recommended)

```bash
# Add stdio server
claude mcp add --transport stdio <name> <command> [args...]

# Add with JSON config (for env vars)
claude mcp add-json <name> '{"command":"npx","args":["-y","@pkg/name"],"env":{"TOKEN":"value"}}'

# Scopes
--scope user     # All projects (~/.claude.json)
--scope project  # Team shared (.mcp.json in project root)
--scope local    # Just this project (default)
```

### Method 2: /install-mcp Command

```bash
/install-mcp                  # Interactive mode
/install-mcp github           # Specific server
```

### Method 3: optim.sh

```bash
./optim.sh install-mcp
```

## Installed Servers

### playwright

Browser automation and E2E testing.

- **Provider**: @executeautomation/playwright-mcp-server
- **Status**: Installed
- **Use Case**: Browser automation, screenshot capture, E2E testing
- **Integration**: Used by e2e-test-generation skill

### context7

Real-time framework documentation.

- **Provider**: @context7/mcp-server
- **Status**: Installed
- **Token Savings**: ~3,000 (reduces web searches)
- **Capabilities**: React, Next.js, Vue, TypeScript, etc.

### github

PR and issue management.

- **Provider**: @modelcontextprotocol/server-github
- **Status**: Installed
- **Token Savings**: ~2,000 per PR workflow
- **Requires**: GITHUB_TOKEN environment variable

### notion

Documentation sync.

- **Provider**: @notionhq/client
- **Requires**: NOTION_TOKEN environment variable
- **Use Case**: Sync docs between Claude Code and Notion

### filesystem

Enhanced file operations.

- **Provider**: @modelcontextprotocol/server-filesystem
- **Note**: May be redundant with built-in tools

## Available Servers (Not Installed)

### sequential-thinking

Structured reasoning for complex problems.

- **Type**: GitHub repository (requires manual clone)
- **Token Savings**: ~5,000 for complex problems
- **Use Case**: Multi-step reasoning, planning, debugging
- **Installation**: Clone from GitHub manually

## Configuration Files

### Registry

`~/.claude/mcp-registry.json`

- Local catalogue of available MCP servers
- Metadata: provider, priority, token savings, requirements
- Updated manually or via self-improvement engine

### Active Configuration

`~/.claude.json` (user scope) or `.mcp.json` (project scope)

```json
{
  "mcpServers": {
    "server-name": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@package/name"],
      "env": { "TOKEN": "value" }
    }
  }
}
```

## Agent Integration

### PR Workflow Agent + GitHub MCP

- Create PRs directly via MCP
- Read PR comments for review responses
- Token savings: ~2k per PR cycle

### Context Refresh Agent + Context7 MCP

- Fetch latest framework docs
- Reduces WebFetch tool usage
- Token savings: ~1k per framework query

## Verification

Check installed servers:

```bash
claude mcp list
```

## Troubleshooting

### Server not connecting

1. Check `claude mcp list` for status
2. Verify environment variables are set
3. Check server logs in Claude Code output

### Environment variables

For servers requiring tokens:

```bash
export GITHUB_TOKEN=your_token
export NOTION_TOKEN=your_token
```

Add to `~/.zshrc` or `~/.bashrc` for persistence.

### Wrong configuration location

Claude Code reads MCP config from:

- **User scope**: `~/.claude.json`
- **Project scope**: `{project}/.mcp.json`
- **NOT**: `~/.claude/.mcp.json` (this is ignored)

Use `claude mcp add` to ensure correct location.
