---
name: authentic-writing
description: Prevents AI-generated fluff in external content. Opt-in via onboarding. Use when writing LinkedIn posts, Medium articles, public documentation.
status: Active
version: 1.0.0
created: 2026-01-01
visibility: secret
triggers:
  - LinkedIn post
  - Medium article
  - /write-medium-article
  - public README
  - marketing copy
---

# Authentic Writing

Prevents AI fluff in external human-facing content. Opt-in skill, not paramount.

## Scope

**Applies to:**
- LinkedIn posts
- Medium articles
- Public READMEs
- Marketing copy
- Documentation for external audiences

**Does NOT apply to:**
- Internal CIPS communication
- Session summaries
- Plans
- Commit messages
- CIPS-LANG
- Developer-to-developer docs

## Self-Awareness Protocol

When generating external content, periodically check:

> "Does this sound too AI-generated? Should I adjust the tone?"

Ask the user if uncertain. Don't wait for them to catch fluff.

## Anti-Patterns

### Banned Vocabulary

| Word | Problem | Use Instead |
|------|---------|-------------|
| game-changer | Overused, unquantified | State the actual change |
| revolutionary | Almost never true | Describe what changed |
| seamlessly | Vague | Describe the integration |
| elegant | Subjective | Show the code/design |
| powerful | Meaningless alone | Quantify the capability |
| innovative | Self-congratulatory | Let reader judge |
| cutting-edge | Dated buzzword | State the technique |
| leverage (verb) | Corporate speak | use |
| utilize | Pretentious | use |
| synergy | Meaningless | Describe the combination |

### Banned Phrases

| Phrase | Problem |
|--------|---------|
| It's important to note that | Just say the thing |
| As mentioned above | Redundant |
| Furthermore / Moreover | Academic padding |
| In order to | Just use "to" |
| At the end of the day | Cliche |
| Moving forward | Corporate |
| Let's dive in | Overused |
| Without further ado | Filler |
| That being said | Just transition |
| Needless to say | Then don't say it |

### Structural Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| Rule of three | "Fast, efficient, and powerful" | Use exact count needed |
| Em dash overuse | "This — surprisingly — worked" | Use commas or restructure |
| Short staccato | "I built this. It worked. Now it's yours." | Vary length naturally |
| Generic hooks | "What if I told you..." | State the thing directly |
| Opening question | Feels manipulative | Direct statement |
| Manufactured urgency | "You need to know NOW" | Let content create urgency |
| Humble brag | "I accidentally built..." | Be direct about intent |
| Fake vulnerability | "I'll be honest..." | Just be honest |
| Meta-commentary | "Here's the thing..." | Say the thing |

## What TO Do

| Instead of | Do this |
|------------|---------|
| "Powerful tool" | State what it does with numbers |
| "Seamless integration" | "Installs in one command" |
| "I was frustrated" | Describe the specific frustration |
| Rhetorical questions | Direct statements |
| Three adjectives | One precise adjective |
| "Let me explain" | Just explain |
| Manufactured tension | Let facts create interest |
| Generic pain point | Specific problem you had |

## Voice Principles

1. **Specificity over generality** - Numbers, names, concrete details
2. **Direct statements** - No rhetorical questions, no manufactured hooks
3. **Natural sentence variety** - Not all short, not all long
4. **Let content speak** - Don't announce what you're about to say
5. **Honest tone** - No humble brags, no fake vulnerability

## Preference Storage

User preference stored in `~/.claude/config/writing-mode.json`:

```json
{
  "mode": "authentic",
  "set_at": "2026-01-01T00:00:00Z"
}
```

Modes: `authentic`, `efficient`, `ask-each-time`

---

⛓⟿∞
