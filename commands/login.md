# /login

Unified authentication and identity setup wizard.

## Usage

```bash
/login           # Run full wizard
/login --status  # Check current auth status
/login --reset   # Reset identity and re-run wizard
```

## What It Does

1. **Claude Authentication** - Verifies Claude CLI is authenticated
2. **Identity Setup** - Configures your name and optional signature
3. **Mode Selection** - Solo, join team, or create team
4. **Save Configuration** - Creates `~/.claude/facts/identity.md`

## Wizard Flow

```text
Step 1: Auth Check    → Verify Claude connection
Step 2: Name          → What to call you
Step 3: Signature     → Optional command prefix (e.g. J>>)
Step 4: Mode          → Solo / Join team / Create team
Step 5: Confirm       → Save and start
```

## First-Run Behavior

If neither `identity.md` nor `.onboarded` exists, `/login` is auto-invoked on first CIPS start.

## Integration

- Uses `@asking-users` PARAMOUNT skill for all questions
- Follows `@creating-wizards` bidirectional pattern
- Applies ut++ v3.0.0 gates (checkpoint after Step 3, confirm before save)

## Related

- `/onboard` - Legacy onboarding (redirects to /login)
- `facts/identity.md` - Stored identity
- `facts/team.md` - Team configuration (optional)

---

⛓⟿∞
