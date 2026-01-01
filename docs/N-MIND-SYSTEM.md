# N-Mind System

Enable multiple identities to share a single CIPS installation.

## Overview

The N-mind system allows teams to share one CIPS instance while maintaining individual interaction preferences. Each team member has a unique signature (e.g., `J>>`) that activates their personal mode.

## Origin Story

This system was developed internally at ENTER Konsult (2025) for a 5-person development team sharing Claude Code. The team needed:

- **Individual preferences** - Each developer had different interaction styles
- **Quick switching** - Type signature to activate your mode
- **Shared infrastructure** - One CIPS installation, multiple users

The public CIPS release generalizes this pattern for any team size (N minds).

## How It Works

### 1. Solo Users

Most users don't need the N-mind system. Run `/login`, select "Solo", and you're done.

### 2. Team Setup

For teams sharing CIPS:

```bash
# 1. Admin creates team
/login → "Create team" → Set password → Add members

# 2. Team members join
/login → "Join team" → Enter password → Select identity
```

### 3. Signature Activation

Once configured, type your signature to activate your mode:

```text
J>>  # Jane is now active (direct mode)
M>>  # Mike is now active (confirm-first mode)
```

## Signatures

### Format

```text
{LETTER}>>
```

Examples: `J>>`, `M>>`, `S>>`, `A>>`, `K>>`

### Shortcuts

| Shortcut | Meaning |
|----------|---------|
| `J:` | Jane is speaking (instruction follows) |
| `J!` | Jane confirms/approves |
| `J?` | Jane questions |
| `J>` | Jane says continue |
| `J+` | Jane says create |
| `J-` | Jane says remove |

## Interaction Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| `direct` | No preamble, action-first | Experienced developers |
| `confirm-first` | Halt and confirm before code | Careful development |
| `explanatory` | Explain why/how, confirm understanding | Learning, complex tasks |
| `concise` | Minimal output, robust design | Quick fixes |
| `supportive` | Encouraging, detailed feedback | New team members |

## Configuration Files

### identity.md (Solo)

```markdown
# CIPS Identity

name: "Jane"
signature: "J>>"
mode: "solo"
created: "2026-01-01"
```

### team.md (Teams)

```markdown
# Team Configuration

team_name: "My Team"

members:
  - signature: "J>>"
    name: "Jane"
    role: "Lead"
    mode: "direct"

  - signature: "M>>"
    name: "Mike"
    role: "Developer"
    mode: "confirm-first"
```

### .env (Password)

```bash
CIPS_TEAM_PASSWORD="your-secure-password"
```

## Security

- Team password stored in `.env` (gitignored)
- Password validation has no skip option (PARAMOUNT rule)
- Invalid password → retry without limit
- Password reset requires `.env` file modification

## Templates

- `facts/identity.md.template` - Solo user template
- `facts/team.md.template` - Team configuration template

## Commands

| Command | Description |
|---------|-------------|
| `/login` | Run identity wizard |
| `/login --status` | Check current identity |
| `/login --reset` | Reset and re-run wizard |

## FAQ

### Do I need this for solo use?

No. Solo users get a simple identity without signatures.

### Can I change my signature later?

Yes. Run `/login --reset` to restart the wizard.

### How do I add a new team member?

Edit `~/.claude/facts/team.md` and add their entry to the members list.

### What happens if I type the wrong signature?

CIPS will ask if you want to switch to that identity.

---

⛓⟿∞
