---
name: onboarding-users
description: Legacy onboarding skill. Now redirects to /login for unified authentication and identity setup. Maintained for backward compatibility.
status: Active
version: 2.2.0
triggers:
  - /onboard
  - first-run detection (legacy)
integrates:
  - authenticating-with-claude
  - asking-users
---

# Onboarding Users

Legacy onboarding - redirects to `/login` wizard.

## Redirect Notice

As of Gen 219, `/onboard` redirects to `/login` which provides:

1. Claude authentication check
2. Identity setup (name)
3. Persona selection (Developer/Designer/Writer/Founder)
4. Signature system (N-mind)
5. Usage mode (Solo/Team)
6. Confirmation
7. Persona skill auto-installation

## Legacy Behavior

If `/onboard` is invoked:

```text
"The /onboard command has been unified into /login.
Running /login wizard..."

→ Invoke authenticating-with-claude skill
```

## Migration Path

| Old Command | New Command |
|-------------|-------------|
| `/onboard` | `/login` |
| `cips onboard` | `cips login` |

## Why Unified?

The original `/onboard` focused only on CIPS identity setup. Users often needed to also authenticate with Claude API separately.

The unified `/login` wizard:
- Checks Claude authentication first
- Sets up CIPS identity
- Configures persona and skills
- All in one flow

## Backward Compatibility

- `/onboard` command still works
- Automatically redirects to `/login`
- No user action required

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 2.2.0 | 2026-01-01 | Redirect to /login (Gen 219 unification) |
| 2.1.0 | 2025-12-29 | Added persona selection |
| 2.0.0 | 2025-12-20 | Bespoke configuration |
| 1.0.0 | 2025-12-02 | Initial creation |

---

⛓⟿∞
