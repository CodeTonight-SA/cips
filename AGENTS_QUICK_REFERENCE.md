# Claude Agents - Quick Reference Card

Print this and keep it handy! 📋

---

## 🚀 The 8 Essential Agents

| # | Agent Name | Model | Trigger | Token Savings |
|---|------------|-------|---------|---------------|
| 1 | **Context Refresh** | Haiku | Session start, `/refresh-context` | 5-8k per session |
| 2 | **Dependency Guardian** | Haiku | AUTO (all file ops) | 50k+ per violation prevented |
| 3 | **File Read Optimizer** | Haiku | AUTO (before reads) | 5-10k per session |
| 4 | **PR Workflow** | Sonnet | "create PR", `/create-pr` | 1-2k per PR |
| 5 | **History Mining** | Haiku | "search history", `/remind-yourself` | 5-20k per search |
| 6 | **Efficiency Auditor** | Haiku | End of workflow, `/audit-efficiency` | N/A (reports savings) |
| 7 | **YAGNI Enforcer** | Haiku | Planning phase, "make it flexible" | 5-20k per prevented feature |
| 8 | **Direct Implementation** | Sonnet | Multi-step workflows, temp scripts | 3-5k per avoided script |

**Total Potential Savings:** 60-100k tokens per session (30-50% of budget)

---

## 📍 When To Use Each Agent

### Start of Session

```text
@Context-Refresh-Agent: Build mental model of this project
```text

### During Development


- **Searching code?** → Dependency Guardian blocks automatically
- **Reading same file twice?** → File Read Optimizer warns automatically
- **Planning architecture?** → @YAGNI-Enforcer-Agent: Review this plan
- **Multi-file operation?** → @Direct-Implementation-Agent: Execute batch operation

### End of Workflow
```text
@PR-Workflow-Agent: Create PR for feature branch
@Efficiency-Auditor-Agent: Analyse recent workflow
```text

### When Stuck
```text
@History-Mining-Agent: Have we solved [problem] before?
```text

---

## 🎯 Agent Invocation Syntax

### Explicit Delegation:
```text
@Agent-Name: [task description]
```text

### Automatic Triggers:
- Dependency Guardian: AUTO on all Glob/Grep/Read/Bash
- File Read Optimizer: AUTO before Read operations

### Via Commands:
- `/refresh-context` → Context Refresh Agent
- `/create-pr` → PR Workflow Agent
- `/remind-yourself` → History Mining Agent
- `/audit-efficiency` → Efficiency Auditor Agent

---

## 🔧 Model Selection Guide

### Use Haiku 4.5 for:
- Monitoring tasks (Dependency Guardian, File Read Optimizer)
- Searches (History Mining, pattern detection)
- Simple analysis (Efficiency Auditor, YAGNI checks)
- **Benefits:** 2x speed, 3x cost savings

### Use Sonnet 4.5 for:
- Complex reasoning (PR descriptions, architecture)
- Code generation (Direct Implementation)
- Multi-step workflows
- **Benefits:** Higher quality output, better context understanding

---

## 📊 Efficiency Score Card

### After Each Workflow, Track

| Metric | Target | Your Score |
|--------|--------|------------|
| Files read multiple times | 0 | ___ |
| node_modules/ reads | 0 | ___ |
| Temp scripts created | 0 | ___ |
| Batch operations used | 100% | ___% |
| Premature features built | 0 | ___ |
| **Total Violation Points** | **0-9** | **___** |

### Grading:
- 0 points: 🏆 Perfect
- 1-9 points: ✅ Good
- 10-29 points: ⚠️ Needs Improvement
- 30+ points: 🚨 Critical

---

## 🛠️ MCP Servers Priority

### Install Now:
```bash

# GitHub MCP (enhances PR Workflow Agent)

npm install -g @modelcontextprotocol/server-github
```text

### Install Soon:
```bash

# Context7 (real-time docs)

npm install -g @context7/mcp-server
```text

### Optional:
- Sequential Thinking MCP (complex reasoning)
- Notion MCP (project docs integration)

---

## 💡 Common Workflows

### Perfect Session Start
```text
1. @Context-Refresh-Agent: Analyse this project
2. [Review output, understand current state]
3. @History-Mining-Agent: Recent work on [feature]
4. [Begin implementation with context]
```text

### Feature Implementation
```text
1. @YAGNI-Enforcer-Agent: Review plan for [feature]
2. @Direct-Implementation-Agent: Execute batch changes
3. [Dependency Guardian & File Read Optimizer monitor automatically]
4. @PR-Workflow-Agent: Create PR
5. @Efficiency-Auditor-Agent: Analyse session
```text

### Debugging Unknown Issue
```text
1. @History-Mining-Agent: Search for [error message]
2. [Apply past solution or continue debugging]
3. @Direct-Implementation-Agent: Apply fix across codebase
```text

---

## 🎓 Best Practices

### DO:
- ✅ Use Context Refresh at every session start
- ✅ Let Dependency Guardian and File Read Optimizer monitor automatically
- ✅ Invoke YAGNI Enforcer during planning phase
- ✅ Run Efficiency Auditor at end of complex workflows
- ✅ Trust agent recommendations (they enforce your rules)

### DON'T:
- ❌ Override Dependency Guardian warnings (they prevent 50k+ token waste)
- ❌ Re-read files when File Read Optimizer warns
- ❌ Build features YAGNI Enforcer flags as premature
- ❌ Create temp scripts when Direct Implementation suggests CLI alternative

---

## 📈 Measuring Success

**Week 1:** Establish baseline (track violations without agents)
**Week 2:** Deploy all 8 agents, track improvements
**Week 3+:** Compare metrics

### Expected Improvements:
- 30-50% reduction in token usage
- 40-60% faster session startup (Context Refresh)
- 80-90% reduction in repeated file reads
- 100% prevention of node_modules/ reads
- 2-3x faster PR creation

---

## 🔍 Troubleshooting Quick Guide

### Agent not responding?
- Check invocation: Use `@Agent-Name:` format
- Verify agent created: Check `/agents` list

### Wrong model (too slow)?
- Update agent config: Haiku for monitoring, Sonnet for reasoning

### Agent context too large?
- Agents use separate context windows
- Main agent only receives summary

### MCP server failing?
- Check `~/.claude/.mcp.json` syntax
- Verify npm package installed
- Restart Claude Code

---

## 📚 Full Documentation

**Comprehensive Guide:** [CLAUDE_AGENTS_SETUP.md](./CLAUDE_AGENTS_SETUP.md)
- Complete agent descriptions (copy-paste ready)
- MCP server installation
- Integration details
- Testing checklist

### Related Files:
- `~/.claude/CLAUDE.md` - Global rules
- `~/.claude/EFFICIENCY_CHECKLIST.md` - Scoring framework
- `~/.claude/skills/` - Skill protocols
- `~/.claude/patterns.json` - Violation definitions

---

## 🎯 Your First Steps

1. **Create agents** (30 min)
   - Open Claude Code: `claude`
   - Type: `/agents`
   - Copy-paste descriptions from CLAUDE_AGENTS_SETUP.md

2. **Install GitHub MCP** (5 min)
   ```bash
   npm install -g @modelcontextprotocol/server-github
   # Add to ~/.claude/.mcp.json
   ```text

3. **Test workflow** (10 min)
   - Start session: `@Context-Refresh-Agent: Analyse this project`
   - Search code: Trigger Dependency Guardian
   - Create PR: `@PR-Workflow-Agent: Create PR`

4. **Review results**
   - `@Efficiency-Auditor-Agent: Analyse this session`
   - Check token savings

---

**🤖 Happy Automating!**

*Last Updated: 2025-01-14*
*Claude Code Agents v1.0*
