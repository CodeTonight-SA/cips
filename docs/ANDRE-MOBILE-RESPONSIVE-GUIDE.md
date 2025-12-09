# Mobile Responsive Agent Guide for Andre (Windows)

Guide for using Claude-Optim's Mobile Responsive Fixer Agent on the REDR-prototype project.

## Part 1: Windows Setup

### 1.1 Prerequisites

You need these tools installed on Windows:

| Tool | Purpose | Installation |
|------|---------|--------------|
| Git Bash | Run bash scripts | Comes with [Git for Windows](https://gitforwindows.org/) |
| jq | JSON processing | `choco install jq` |
| ripgrep (rg) | Fast pattern search | `choco install ripgrep` |
| fd | Fast file finding | `choco install fd` |

**Install Chocolatey first** (if not installed):

```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

**Then install the tools:**

```powershell
choco install jq ripgrep fd -y
```

### 1.2 Path Reference

| Unix Path | Windows Path |
|-----------|--------------|
| `~/.claude` | `%USERPROFILE%\.claude` or `C:\Users\Andre\.claude` |
| `~/projects` | `%USERPROFILE%\projects` or wherever your projects live |

## Part 2: Install/Update Claude-Optim

### 2.1 First-Time Installation

Open **Git Bash** (not PowerShell) and run:

```bash
# Clone the repository to ~/.claude
git clone https://github.com/CodeTonight-SA/claude-optim.git ~/.claude

# Navigate to it
cd ~/.claude

# Run the installer (handles Windows automatically)
./install.sh
```

### 2.2 Updating Existing Installation

If you already have Claude-Optim installed:

```bash
cd ~/.claude

# Pull latest changes
./sync-claude.sh pull

# Or manually:
git pull origin main
./install.sh
```

### 2.3 Verify Installation

```bash
cd ~/.claude

# Check key files exist
ls CLAUDE.md patterns.json optim.sh

# Check agents are present
ls agents/mobile-responsive-fixer-agent.md

# Check skills are present
ls skills/mobile-responsive-ui/SKILL.md
```

You should see all files listed without errors.

## Part 3: Project Setup for REDR-prototype

### 3.1 Navigate to Project

```bash
# Replace with your actual path
cd /c/Users/Andre/projects/REDR-prototype
# Or whatever your project path is
```

### 3.2 Create Feature Branch from Main

```bash
# Ensure you're on main and up to date
git checkout main
git pull origin main

# Create your feature branch (lowercase, use hyphens)
git checkout -b fix/mobile-responsive-screens
```

**Important**: Branch names must be lowercase (Windows/macOS are case-insensitive, Linux is not).

## Part 4: Using the Mobile Responsive Agent

### 4.1 Start Claude Code Session

In your REDR-prototype directory:

```bash
claude
```

### 4.2 Initialize Session (Every Time)

Once Claude Code starts:

```text
You: RL++
Claude: "System ready - 9 agents active, 26 skills loaded..."

You: /refresh-context
Claude: [Builds mental model of REDR-prototype]
```

### 4.3 Run Mobile Responsive Audit

#### Step 1: Run the Audit

```text
You: /audit-mobile-responsive
```

This scans your codebase and produces a report like:

```text
MOBILE RESPONSIVE AUDIT REPORT

Project: /path/to/REDR-prototype
Files Scanned: 127
Violations Found: 8

CRITICAL (10 pts each):
  src/styles/global.css:45 - vh without dvh fallback
    Found: height: 100vh
    Fix: height: 100dvh; /* with fallback */ height: 100vh;

MAJOR (5 pts each):
  src/components/Button.tsx:12 - Touch target too small
    Found: className="p-2" (32px)
    Fix: className="p-3 min-h-12 min-w-12"

SCORE: 73/100 (Needs Improvement)
```

#### Step 2: Auto-Fix Issues

```text
You: /audit-mobile-responsive --fix
```

The agent will automatically fix issues it can safely handle.

### 4.4 Manual Agent Invocation

You can also ask Claude directly:

```text
You: Fix mobile responsive issues in src/components/Header.tsx

You: Check all buttons in the app for proper touch target sizes

You: Add dvh fallbacks to all vh usages in the CSS files
```

The agent activates automatically when you edit HTML, CSS, TSX, or JSX files.

## Part 5: What the Agent Fixes

### 5.1 TailwindCSS Fixes

| Issue | Before | After |
|-------|--------|-------|
| Fixed width without responsive | `w-64` | `w-full md:w-64` |
| Fixed width arbitrary | `w-[500px]` | `w-full md:w-[500px]` |
| Small touch target | `p-2` on button | `p-2 min-h-12 min-w-12` |
| Missing responsive text | `text-xl` | `text-lg md:text-xl` |
| Fixed height | `h-[300px]` | `h-auto md:h-[300px]` |

### 5.2 CSS Fixes

| Issue | Before | After |
|-------|--------|-------|
| vh without dvh | `height: 100vh` | `height: 100vh; height: 100dvh;` |
| Fixed container | `width: 800px` | `max-width: 800px; width: 100%;` |
| Hover without focus | `:hover { }` | `:hover, :focus { }` |
| Desktop-first query | `@media (max-width:` | `@media (min-width:` |

### 5.3 HTML Fixes

| Issue | Before | After |
|-------|--------|-------|
| Missing viewport meta | (none) | `<meta name="viewport" content="width=device-width, initial-scale=1.0">` |
| Fixed img dimensions | `width="500"` | `style="max-width:100%"` |

## Part 6: Testing Your Fixes

### 6.1 Mandatory Viewport Testing

Before marking work complete, test at these viewports:

| Device | Width | How to Test |
|--------|-------|-------------|
| iPhone SE | 375px | Chrome DevTools > Device Mode |
| iPad | 768px | Chrome DevTools > Device Mode |
| Desktop | 1920px | Browser window maximised |

**Chrome DevTools shortcut**: `Ctrl+Shift+M` (in DevTools) to toggle device mode.

### 6.2 Checklist

Run through this before committing:

- [ ] No horizontal scroll at any breakpoint
- [ ] All text readable without zooming (min 16px body text)
- [ ] Touch targets at least 48x48px with 8px spacing
- [ ] Modals scrollable if content exceeds viewport
- [ ] Navigation accessible on mobile (hamburger or bottom tabs)
- [ ] Images scale appropriately (no overflow)
- [ ] dvh used for full-height sections

## Part 7: Commit and Create PR

### 7.1 Stage and Commit

```bash
# Stage your changes
git add -A

# Commit (no emoji, professional format)
git commit -m "fix: mobile responsive issues across components

Added responsive prefixes, touch target sizing, and dvh fallbacks.
Audit score improved from 73 to 95.

Primary Author: Andre"
```

### 7.2 Push Branch

```bash
git push -u origin fix/mobile-responsive-screens
```

### 7.3 Create PR (Inside Claude Code)

```text
You: /create-pr
```

Claude will automate the PR creation with a proper summary.

Or manually via `gh`:

```bash
gh pr create --title "fix: mobile responsive issues" --body "## Summary
- Fixed touch targets on buttons
- Added dvh fallbacks
- Added responsive prefixes to fixed widths

## Test Plan
- Tested at 375px, 768px, 1920px viewports
- No horizontal scroll
- All interactive elements have 48px minimum touch target"
```

## Part 8: Quick Reference

### Commands

| Command | What It Does |
|---------|--------------|
| `RL++` | Load all Claude-Optim systems |
| `/refresh-context` | Build mental model of project |
| `/audit-mobile-responsive` | Scan for mobile issues (report only) |
| `/audit-mobile-responsive --fix` | Scan and auto-fix issues |
| `/create-pr` | Automate PR creation |

### Agent Triggers (Automatic)

The mobile-responsive-fixer-agent activates automatically when you:

- Edit `.html` files
- Edit `.css` or `.scss` files
- Edit `.tsx` or `.jsx` files (React components)
- Edit `.vue` files

### Scoring

| Score | Grade | Action |
|-------|-------|--------|
| 90-100 | Excellent | Ready to merge |
| 70-89 | Good | Minor fixes needed |
| 50-69 | Needs Work | Address major issues first |
| 0-49 | Critical | Do not deploy |

## Troubleshooting

### "Command not found: rg"

Install ripgrep: `choco install ripgrep`

### "Permission denied" on scripts

In Git Bash:

```bash
chmod +x ~/.claude/*.sh ~/.claude/scripts/*.sh
```

### Agent not activating

Make sure you ran `RL++` at session start. The agent system needs to be loaded.

### Audit finds nothing but page looks broken

The audit catches common patterns but not all issues. Manual review is still needed for:

- Complex layout issues requiring design decisions
- Framework-specific responsive patterns
- Third-party component styling

## Support

Questions? Check:

- `~/.claude/skills/mobile-responsive-ui/SKILL.md` - Full protocol
- `~/.claude/agents/mobile-responsive-fixer-agent.md` - Agent details
- `~/.claude/README.md` - Full system documentation

Or ask in the team chat.

---

**Last Updated**: 2025-12-08
**Author**: Claude-Optim Team
