# Team Configuration

Configure team signatures for multi-user CIPS environments.

## Quick Start

Run the team wizard during onboarding:

```bash
cips onboard --team
```

Or create `~/.claude/facts/team.md` manually.

## Team Signatures

CIPS uses signatures (`SIG>>`) for identity-aware interactions:

| Field | Description | Example |
|-------|-------------|---------|
| Signature | Short identifier | `L>>`, `J>>`, `M>>` |
| Name | Full name | Laurie, John, Maria |
| Role | Team role | Technical Director, Developer |
| Mode | Interaction style | direct, confirm-first, explanatory |

## Configuration File

Create `~/.claude/facts/team.md`:

```markdown
# Team Configuration

## Primary User

| Field | Value |
|-------|-------|
| Name | Your Name |
| Signature | Y>> |
| Role | Technical Director |
| Mode | direct |

## Team Members (Optional)

| Sig | Name | Role | Mode |
|-----|------|------|------|
| J>> | John | Developer | confirm-first |
| M>> | Maria | Designer | explanatory |
```

## Interaction Modes

| Mode | Behaviour |
|------|-----------|
| `direct` | No preamble, action-first, minimal explanation |
| `confirm-first` | Halt and confirm strategy before writing code |
| `explanatory` | Explain why/how, confirm understanding |
| `concise` | Minimal output, robust design focus |
| `supportive` | Encouraging, detailed feedback, gentle corrections |

## Using Signatures

Type your signature to activate your mode:

```text
L>>: refactor the auth module
```

CIPS adjusts its interaction style based on the signature.

## Machine-Level Defaults

Set a default signature per machine in `~/.claude/rules/local-identity.md`:

```markdown
# Local Identity

Default operator on this machine: M>>
```

## Integration with CLAUDE.md

CIPS loads team configuration from:

1. `facts/team.md` (team definitions)
2. `rules/local-identity.md` (machine default)
3. Explicit signature in message (override)

## Creating Your Team

The onboarding wizard asks:

1. "What's your signature shorthand?" → `L` for Laurie
2. "What's your role?" → Technical Director
3. "How should CIPS interact with you?" → direct
4. "Add team member?" → Loop until done

Results saved to `facts/team.md`.
