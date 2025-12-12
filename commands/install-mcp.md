# Install MCP Server Command

Automated MCP (Model Context Protocol) server installation using the official `claude mcp add` CLI.

## Usage

```text
/install-mcp [server-name|--list|--verify]
```

## Examples

### Install Specific Server

```bash
/install-mcp github
```

Installs GitHub MCP server:

1. Runs `claude mcp add --scope user --transport stdio github -- npx -y @modelcontextprotocol/server-github`
2. Prompts for GitHub Personal Access Token (if required)
3. Verifies installation with `claude mcp list`

### List Available Servers

```text
/install-mcp --list
```

Shows all servers from `~/.claude/mcp-registry.json` with their status.

### Verify Current Installation

```text
/install-mcp --verify
```

Runs `claude mcp list` to show connected servers and their health.

## How It Works

**IMPORTANT**: This command uses the official `claude mcp add` CLI, NOT npm install.

```bash
# Correct method (what this command does)
claude mcp add --scope user --transport stdio github -- npx -y @modelcontextprotocol/server-github

# Wrong method (deprecated)
npm install -g @modelcontextprotocol/server-github  # DON'T DO THIS
```

### Configuration Locations

| Scope | Location | Use Case |
|-------|----------|----------|
| `user` | `~/.claude.json` → `mcpServers` | All projects (recommended) |
| `project` | `.mcp.json` in project root | Team shared |
| `local` | Project-specific in ~/.claude.json | Just this project |

## Interactive Configuration

For servers requiring environment variables:

```text
Installing GitHub MCP Server...

GitHub Personal Access Token required.
Scopes needed: repo, workflow, read:org

Get token at: https://github.com/settings/tokens

Enter token (input hidden): ********

Running: claude mcp add --scope user -e GITHUB_TOKEN=*** github -- npx -y @modelcontextprotocol/server-github

Verifying...
github: npx -y @modelcontextprotocol/server-github - Connected
```

## Available Servers

From `~/.claude/mcp-registry.json`:

| Server | Priority | Requires Token | Token Savings |
|--------|----------|----------------|---------------|
| github | High | GITHUB_TOKEN | 2k per PR |
| context7 | Medium | No | 3k per lookup |
| playwright | Medium | No | 1k per test |
| notion | Low | NOTION_TOKEN | 1k per sync |
| filesystem | Low | No | 500 |

## Verification

After installation:

```bash
# Check all MCP servers
claude mcp list

# Expected output:
# github: npx -y @modelcontextprotocol/server-github - Connected
# context7: npx -y @upstash/context7-mcp - Connected
```

## Troubleshooting

**Issue:** Server not appearing after install

**Solution:**

1. Restart Claude Code completely
2. Run `claude mcp list` to verify
3. Check `~/.claude.json` for `mcpServers` key

**Issue:** Token not working

**Solution:**

1. Remove server: `claude mcp remove github`
2. Re-add with correct token: `claude mcp add --scope user -e GITHUB_TOKEN=xxx github -- npx -y @modelcontextprotocol/server-github`

**Issue:** Wrong scope used

**Solution:**

```bash
# Remove from wrong scope
claude mcp remove --scope local github

# Add to correct scope
claude mcp add --scope user github -- npx -y @modelcontextprotocol/server-github
```

## Integration

- Reads server definitions from `~/.claude/mcp-registry.json`
- Uses `claude mcp add` CLI (official method)
- Stores config in `~/.claude.json` under `mcpServers` key
- Verifies with `claude mcp list`

## See Also

- `claude mcp --help` - Official MCP CLI documentation
- `~/.claude/mcp-registry.json` - Available servers registry
- `~/.claude/CLAUDE.md` - MCP Server Integration section
