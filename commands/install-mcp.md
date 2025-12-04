# Install MCP Server Command

Automated MCP (Model Context Protocol) server installation and configuration.

## Usage

```text
/install-mcp [server-name|--auto-detect|--all]
```text

## Examples

### Install Specific Server

```bash
/install-mcp github
```text

Installs GitHub MCP server with interactive token setup:
1. Runs `npm install -g @modelcontextprotocol/server-github`
2. Prompts for GitHub Personal Access Token
3. Updates `~/.claude/.mcp.json` configuration
4. Verifies installation

### Auto-Detect Required Servers

```text
/install-mcp --auto-detect
```text

Scans all agents in `~/.claude/agents/`, identifies required MCP servers based on their capabilities, and installs missing ones.

Example output:
```text
🔍 Scanning agents for MCP requirements...

Found requirements:
- pr-workflow agent → Requires: github
- (no other MCP requirements detected)

📦 Installing required MCP servers:
- github: @modelcontextprotocol/server-github

✅ Installed 1 MCP server
⚠️  Restart Claude Code to activate
```text

### Install All Registered Servers

```text
/install-mcp --all
```text

Installs ALL servers from `~/.claude/mcp-registry.json` (high and medium priority only).

**Warning:** This installs multiple packages. Approve each installation.

## Interactive Configuration

For servers requiring environment variables (API tokens, credentials):

```text
Installing GitHub MCP Server...

GitHub Personal Access Token required.
Scopes needed: repo, workflow, read:org

Get token at: https://github.com/settings/tokens

Enter token (input hidden): ********

✅ Token saved to ~/.claude/.mcp.json
```text

## Available Servers

From `~/.claude/mcp-registry.json`:

| Server | Priority | Enhances | Token Savings |
|--------|----------|----------|---------------|
| github | High | pr-workflow | 2k per PR |
| context7 | Medium | (general) | 3k per lookup |
| playwright | Medium | (testing) | 1k per test |
| sequential-thinking | Low | (reasoning) | 5k per complex task |
| notion | Low | (docs) | 1k per sync |

## Verification

After installation:

```bash
# Test MCP server
npx @modelcontextprotocol/server-github --version

# Check configuration
cat ~/.claude/.mcp.json | jq

# Verify in Claude Code
# Restart Claude Code, then:
# MCP servers should appear in available tools
```text

## Troubleshooting

**Issue:** Installation fails with permission error
### Solution
```bash
sudo npm install -g [package] --unsafe-perm
```text

**Issue:** Token not working
### Solution
1. Verify token scopes at GitHub settings
2. Regenerate token with correct scopes
3. Update `~/.claude/.mcp.json` manually

**Issue:** Server not appearing in Claude Code
### Solution
1. Restart Claude Code completely
2. Check `~/.claude/.mcp.json` syntax with `jq`
3. Review logs: `~/.claude/debug/*.log`

## Integration

- Reads from `~/.claude/mcp-registry.json`
- Updates `~/.claude/.mcp.json`
- Delegates to `~/.claude/scripts/install-mcp-servers.sh`
- Logs installations to `~/.claude/metrics.jsonl`

## See Also

- `/create-agent` - Create agents that use MCP servers
- `~/.claude/mcp-registry.json` - Available servers registry
- `~/.claude/AGENTS_SETUP_PLAN.md` - MCP integration documentation
