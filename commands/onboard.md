# /onboard

Bidirectional onboarding experience - teaches CIPS capabilities while collecting user preferences.

## Usage

```bash
/onboard            # Run full onboarding flow
/onboard --refresh  # Re-run onboarding for existing user
/onboard --status   # Show current onboarding status
```

## Overview

The onboarding flow is **bidirectional**:
- CIPS learns about the user (preferences, goals, style)
- User learns about CIPS (capabilities, commands, philosophy)

Each question teaches a capability while collecting a preference.

## Flow

### Phase 1: Welcome
Display CIPS philosophy and capabilities overview.

### Phase 2: Discovery (12 Teaching Questions)

| Q# | Teaches | Collects |
|----|---------|----------|
| 1-3 | Identity context | Name, role, motivation |
| 4 | Session continuity | Continuity preference |
| 5 | Skill system (41 skills) | Focus areas |
| 6 | Design principles (SOLID, DRY) | Strictness level |
| 7 | Auto-learning | Learning preference |
| 8 | Key commands | Acknowledgment |
| 9-12 | Customisation | Style, signature, language |

### Phase 3: Activation
- Generate `~/.claude/facts/people.md`
- Configure hooks
- Create `.onboarded` marker

### Phase 4: Completion
- Profile summary
- Recommended commands based on focus areas
- Quick win demonstration

## Paths

| Path | Trigger | Flow |
|------|---------|------|
| **Team Member** | Has credentials | Password → Identity → Activate |
| **New User** | First install | Full 12-question flow |
| **Explorer** | Quick look | Name → Overview → Invite return |

## Security

**PARAMOUNT**: Password verification has NO skip option.

## Related

- Skill: `@skills/onboarding-users/SKILL.md`
- Generator: `~/.claude/lib/identity-generator.py`
- Detector: `~/.claude/lib/first-run-detector.sh`

## Token Budget

~2200 tokens (one-time investment enabling 60-70k savings per session)
