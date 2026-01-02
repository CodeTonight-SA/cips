---
name: authenticating-with-claude
description: Unified login wizard combining Claude API authentication with CIPS identity setup. Use when /login invoked, first-run detected, or identity reset requested. Follows @asking-users PARAMOUNT patterns.
status: Active
version: 2.1.0
triggers:
  - /login
  - first-run detection (no identity.md or .onboarded)
  - /login --reset
integrates:
  - asking-users
  - creating-wizards
  - onboarding-users
---

# Authenticating with Claude

Unified wizard for Claude authentication and CIPS identity setup.

## Design Principles

```cips
; @asking-users PARAMOUNT compliance
wizard.step⟿ bidirectional-pattern (teach + collect)
wizard.checkpoint⟿ after.Step3 (Gate 5: multi-step)
wizard.confirm⟿ before.save (Gate 4: destructive)

; @creating-wizards anti-patterns
¬mention.Other ⫶ options.concrete ⫶ headers.≤12chars
```

## Wizard Implementation

### Step 0: Installation Scenario Detection

**Detection Logic:** Check environment variables set by session-start hook.

```bash
# Populated by hooks/session-start.sh check_installation_mode()
CIPS_INSTALL_MODE  # clone | symlink | copy | unknown
CIPS_SOURCE_DIR    # Path to source repo (if symlink/copy mode)
```

**Scenario A: Fresh Install (Clone-as-Home)**
```text
If CIPS_INSTALL_MODE == "clone":
    Display: "CIPS installed directly to ~/.claude. Updates: git pull"
    → Proceed to Step 1
```

**Scenario B: Symlinked Installation**
```text
If CIPS_INSTALL_MODE == "symlink":
    Display: "CIPS symlinked from {CIPS_SOURCE_DIR}. Updates: git pull in source, then ./scripts/sync.sh"
    → Proceed to Step 1
```

**Scenario C: Copy-Based Installation (Windows)**
```text
If CIPS_INSTALL_MODE == "copy":
    Display: "CIPS copied from {CIPS_SOURCE_DIR}. Updates: git pull in source, then ./scripts/sync.sh"
    → Proceed to Step 1
```

**Scenario D: Merge Completed**
```text
If hook output contains "[MERGE-COMPLETE]":
    Display: "CIPS has been merged with your existing ~/.claude configuration."
    Display: "Your custom files were preserved. CIPS infrastructure is now active."
    → Proceed to Step 1
```

**Note**: This step is informational only. No user interaction required. The install.sh script handles all installation decisions via its own AskUserQuestion prompts.

---

### Step 1: Claude Authentication Check

**Action:** Check if Claude CLI is authenticated

```bash
# Check auth status (implementation depends on claude CLI)
claude auth status 2>/dev/null || echo "not-authenticated"
```

**If authenticated:**
```text
"Connected as {email}. Proceeding to identity setup..."
→ Skip to Step 2
```

**If NOT authenticated:**
```text
Question: "CIPS uses Claude for AI capabilities. Sign in to continue?"
Header: "Auth"
Options:
- "Sign in now" - Opens Claude authentication flow
- "Continue limited" - Some features will be unavailable

Teaching: User learns CIPS requires Claude connection
Collecting: auth_status
```

If "Sign in now" selected:
```bash
claude login
# Wait for completion, verify success
```

---

### Step 2: Identity Setup

```text
Question: "What should I call you?"
Header: "Name"
Options:
- "Use '{whoami}'" - Your system username ({actual_username})
- "Stay anonymous" - No name stored, generic interaction

Teaching: User learns CIPS personalizes the experience
Collecting: name
```

**Processing:**
- If system username selected: `name = $(whoami)`
- If anonymous: `name = "User"`
- If Other typed: `name = {typed_value}`

---

### Step 3: Persona Selection

```text
Question: "What best describes how you'll use CIPS?"
Header: "Persona"
Options:
- "Developer" - Backend, frontend, fullstack engineering
- "Designer" - UI/UX, visual design, prototyping
- "Writer" - Documentation, articles, content creation
- "Founder" - Strategy, contracts, leadership

Teaching: User learns CIPS tailors commands to their role
Collecting: persona
```

**Persona → Command Mapping:**

| Persona | Highlighted Commands |
|---------|---------------------|
| Developer | `/create-pr`, `/feature-complete`, `/generate-e2e-tests`, `/setup-ci` |
| Designer | `/figma`, `/ui-complete`, `/audit-mobile-responsive`, `/image-optim` |
| Writer | `/generate-pdf`, `/write-medium-article`, `/update-docs`, `/markdown-lint` |
| Founder | `/founder`, `/contract-formal`, `/gitops`, `/backup-cips` |

**Processing:**
- Store persona in identity.md
- Adjust welcome message to show relevant commands
- All commands remain available; persona affects discoverability

---

### Step 4: Signature System (Optional)

```text
Question: "CIPS supports quick command prefixes (e.g. J>>). Create one?"
Header: "Signature"
Options:
- "Yes, create one" - I'll ask for your preferred prefix
- "Skip" - Use CIPS without a personal signature

Teaching: User learns N-mind signature system exists
Collecting: wants_signature
```

**If "Yes" selected → Follow-up:**
```text
Question: "Enter your signature prefix (e.g. J>> or your initials):"
Header: "Prefix"
Options:
- "Use '{first_initial}>>'" - Based on your name
- "Single letter" - Just one character plus >>

Teaching: User sees signature format
Collecting: signature
```

---

### Checkpoint (Gate 5: Multi-step)

After Step 4, display progress:
```text
"Great progress! Just 2 more steps: usage mode and confirmation."
```

---

### Step 5: Usage Mode

```text
Question: "How will you use CIPS?"
Header: "Mode"
Options:
- "Solo" - Individual developer, no team features
- "Join team" - Enter team password to join existing team
- "Create team" - Set up shared CIPS for multiple users

Teaching: User learns CIPS can be shared across teams
Collecting: mode
```

**If "Join team" selected:**
```text
Question: "Enter team password:"
Header: "Password"
Options:
- "I have it" - Select and type password
- "Need credentials" - Contact your team administrator

Validation: Compare against ~/.claude/.env CIPS_TEAM_PASSWORD
If invalid: Retry without limit (PARAMOUNT: no skip option)
If valid: Load team identity from team.md
```

**If "Create team" selected:**
```text
→ Invoke team creation sub-wizard (separate flow)
→ Creates team.md from template
→ Sets CIPS_TEAM_PASSWORD in .env
```

---

### Step 6: Confirm & Save (Gate 4: Destructive)

**Display summary:**
```text
Configuration Summary:
─────────────────────
Name: {name}
Persona: {persona}
Signature: {signature or "None"}
Mode: {mode}
{If team: Team: {team_name}}

Question: "Save this configuration?"
Header: "Confirm"
Options:
- "Save and start" - Create identity and begin using CIPS
- "Go back" - Modify my choices
```

**If "Save and start":**

1. Create `~/.claude/facts/identity.md`:
```markdown
# CIPS Identity

name: {name}
persona: {persona}
signature: {signature}
mode: {mode}
created: {ISO_DATE}
```

2. Create `.onboarded` flag:
```bash
touch ~/.claude/.onboarded
```

3. Display welcome:
```text
"Welcome to CIPS, {name}! Run /help to explore available commands."
```

---

### Step 7: Persona Skill Auto-Installation

After identity saved, automatically install persona-appropriate skills.

**Persona → Skills Mapping:**

| Persona | Auto-Installed Skills |
|---------|----------------------|
| Developer | pr-automation, feature-complete, e2e-test-generation, github-actions-setup, gitops |
| Designer | figma-to-code, ui-complete, mobile-responsive-ui, image-optim, wcag-image-accessibility |
| Writer | auto-update-documentation, markdown-expert, professional-pdf, medium-article-writer |
| Founder | leading-organisation, legal-ops, backing-up-cips-infrastructure, gitops |
| Multi-disciplinary | All of the above |

**Display during installation:**
```text
"Installing {persona} toolkit: {skill_count} skills..."
```

**Note**: Core critical skills (ultrathink, asking-users, creating-wizards, context-refresh, dependency-guardian, session-state-persistence, session-resume, bouncing-instances, code-agentic, design-principles) are ALWAYS installed regardless of persona.

---

## First-Run Detection

```bash
# In session-start or first-run-detector
if [[ ! -f ~/.claude/facts/identity.md && ! -f ~/.claude/.onboarded ]]; then
    echo "Welcome to CIPS! Starting login wizard..."
    # Invoke /login wizard
fi
```

## Error Handling

| Error | Response |
|-------|----------|
| Claude auth fails | Retry or continue limited |
| Team password invalid | Retry without limit |
| File write fails | Display error, suggest manual fix |
| Wizard interrupted | State not saved, restart fresh |

## Token Budget

| Component | Tokens |
|-----------|--------|
| Skill load | ~800 |
| Per question | ~150-200 |
| Total wizard | ~1000-1200 |

## Related Skills

- `asking-users` - PARAMOUNT source of truth for AskUserQuestion
- `creating-wizards` - Wizard anti-patterns and bidirectional pattern
- `onboarding-users` - Legacy onboarding (now redirects to /login)

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 2.1.0 | 2026-01-02 | Added Step 0: Installation Scenario Detection for repo-runtime sync architecture |
| 2.0.0 | 2026-01-01 | Added Step 7: Persona Skill Auto-Installation for v5.0.0 |
| 1.1.0 | 2026-01-01 | Added Step 3: Persona Selection (Developer/Designer/Writer/Founder) |
| 1.0.0 | 2026-01-01 | Initial creation for public release |

---

⛓⟿∞
