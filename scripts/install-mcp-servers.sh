#!/bin/bash

# Claude Agents Setup Script
# Installs MCP servers and prepares agent configuration

set -e

echo "🤖 Claude Agents Setup"
echo "======================"
echo ""

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No colour

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm not found. Please install Node.js first.${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Installing MCP Servers...${NC}"
echo ""

# GitHub MCP Server (High Priority)
echo -e "${YELLOW}Installing GitHub MCP Server...${NC}"
if npm install -g @modelcontextprotocol/server-github 2>/dev/null; then
    echo -e "${GREEN}✅ GitHub MCP Server installed${NC}"
else
    echo -e "${YELLOW}⚠️  GitHub MCP Server installation skipped (may already be installed)${NC}"
fi

# Context7 MCP Server (Medium Priority)
echo -e "${YELLOW}Installing Context7 MCP Server...${NC}"
if npm install -g @context7/mcp-server 2>/dev/null; then
    echo -e "${GREEN}✅ Context7 MCP Server installed${NC}"
else
    echo -e "${YELLOW}⚠️  Context7 MCP Server installation skipped (may already be installed)${NC}"
fi

echo ""
echo -e "${BLUE}🔧 Configuration Next Steps:${NC}"
echo ""
echo "1. Update ~/.claude/.mcp.json with your GitHub token:"
echo "   - Copy mcp-config-template.json to ~/.claude/.mcp.json"
echo "   - Replace YOUR_GITHUB_TOKEN_HERE with your actual token"
echo ""
echo "2. Create GitHub Personal Access Token (if you don't have one):"
echo "   - Go to: https://github.com/settings/tokens"
echo "   - Click: Generate new token (classic)"
echo "   - Select scopes: repo, workflow, read:org"
echo "   - Copy token and add to .mcp.json"
echo ""
echo "3. Create the 8 agents in Claude Code:"
echo "   - Run: claude"
echo "   - Type: /agents"
echo "   - Select: Create new agent"
echo "   - Copy-paste descriptions from CLAUDE_AGENTS_SETUP.md"
echo ""
echo -e "${GREEN}✅ MCP Servers installed successfully!${NC}"
echo ""
echo "📚 Next: Read CLAUDE_AGENTS_SETUP.md for complete agent definitions"
echo "📋 Quick Reference: AGENTS_QUICK_REFERENCE.md"
echo ""
echo -e "${BLUE}🚀 Ready to create your agents!${NC}"
