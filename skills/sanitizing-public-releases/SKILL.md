---
name: sanitizing-public-releases
description: >
  PARAMOUNT security gate that scans for sensitive data before public releases.
  Detects absolute paths, API keys, instance files, and private information.
  Use when preparing cherry-picks to public repo, releasing versions, or reviewing contributions.
status: Active
version: 1.0.0
generation: 228
triggers:
  - /sanitize-for-public
  - /pre-release-check
  - "prepare for public release"
  - "check for sensitive data"
priority: PARAMOUNT
integrates:
  - reviewing-contributions
  - skill-creation-best-practices
  - asking-users
---

# Sanitizing Public Releases

**PARAMOUNT**: Security gate for ALL public releases to prevent sensitive data exposure.

## Why This Exists

Gen 228 discovered `instances/` directory was tracked in git with 9782 lines of sensitive session data. This skill prevents similar incidents by providing systematic pre-release scanning.

## Detection Rules

### CRITICAL (BLOCK immediately)

| Pattern | Regex | Example |
|---------|-------|---------|
| Absolute user paths | `/Users/[^/]+/` | `/Users/lauriescheepers/projects/` |
| Home directory paths | `/home/[^/]+/` | `/home/ubuntu/.config/` |
| API keys (OpenAI) | `sk-[A-Za-z0-9]{32,}` | `sk-abc123...` |
| API keys (AWS) | `AKIA[A-Z0-9]{16}` | `AKIAIOSFODNN7EXAMPLE` |
| GitHub tokens | `ghp_[A-Za-z0-9]{36}` | `ghp_xxxx...` |
| Instance files | `instances/.*\.json` | `instances/139efc67-*.json` |

### HIGH (Review required)

| Pattern | Regex | Example |
|---------|-------|---------|
| Session history | `.*\.jsonl` with user content | `history.jsonl` |
| Private skills | `skills/enter-konsult-.*` | `skills/enter-konsult-pdf/` |
| Email addresses | `[a-z]+@[a-z]+\.[a-z]+` | Not in whitelist |

### MEDIUM (Advisory)

| Pattern | Context | Action |
|---------|---------|--------|
| Personal names | In code comments | Flag for review |
| Company-specific | Custom branding | Verify intentional |

## Workflow

### Pre-Release Scan

```bash
# 1. Scan staged changes
git diff --cached | /sanitize-for-public

# 2. Scan specific commits before cherry-pick
git show <commit> | /sanitize-for-public

# 3. Full diff against public branch
git diff public/main...HEAD | /sanitize-for-public
```

### Automated Checklist

Copy this checklist before any public release:

```markdown
## Pre-Release Security Checklist

### CRITICAL (Must pass)
- [ ] No absolute user paths (`/Users/*`, `/home/*`)
- [ ] No API keys or tokens
- [ ] No instance files tracked
- [ ] .gitignore includes `instances/`

### HIGH (Review required)
- [ ] No session history files with user content
- [ ] Private skills excluded
- [ ] Email addresses are intentional

### VERIFICATION
- [ ] Run `/sanitize-for-public` on diff
- [ ] Manual review of changes
- [ ] Confirm no force push required
```

## Integration Points

### With reviewing-contributions

When PR is opened to CIPS public repo:

```text
1. pr-analyzer triggers
2. sanitizing-public-releases runs automatically
3. If CRITICAL pattern found → BLOCK PR
4. If HIGH pattern found → Flag for maintainer review
5. Results included in CIPS review comment
```

### With git hooks

Optional pre-push hook for public remote:

```bash
#!/bin/bash
# .git/hooks/pre-push

remote="$1"
if [[ "$remote" == "public" ]]; then
    echo "Running public release sanitizer..."
    git diff origin/main...HEAD | ~/.claude/lib/sanitizer.sh
    if [[ $? -ne 0 ]]; then
        echo "BLOCKED: Sensitive data detected. Run /sanitize-for-public for details."
        exit 1
    fi
fi
```

## Anti-Patterns

| Anti-Pattern | Why Bad | Correct Pattern |
|--------------|---------|-----------------|
| Skip scan for "small" changes | Small commits can leak secrets | ALWAYS scan |
| Force push to fix leak | History preserved in forks | Never force push; rotate secrets |
| Whitelist too broadly | Reduces protection | Minimal, specific whitelists |
| Ignore HIGH severity | Could still be sensitive | Review and document decision |

## Examples

### Example 1: Detected Absolute Path

```diff
- CLAUDE_DIR="/Users/lauriescheepers/.claude"
+ CLAUDE_DIR="$HOME/.claude"
```

**Detection**: CRITICAL - Absolute user path
**Action**: Replace with `$HOME` or relative path

### Example 2: Detected API Key

```diff
- OPENAI_KEY="sk-abc123def456..."
+ OPENAI_KEY="${OPENAI_KEY:-}"
```

**Detection**: CRITICAL - API key pattern
**Action**: Remove from code, use environment variable

### Example 3: Instance File in Commit

```text
instances/139efc67-*.json tracked in git

Detection: CRITICAL - Instance file
Action: git rm --cached instances/ && add to .gitignore
```

### Example 4: Acceptable Email

```yaml
# SECURITY.md
security_contact: laurie@codetonight.co.za
```

**Detection**: MEDIUM - Email address
**Action**: ALLOW - Intentional public contact (user decision confirmed)

## Whitelist Management

### Default Whitelist

```json
{
  "emails": [
    "security@codetonight.co.za",
    "conduct@codetonight.co.za",
    "laurie@codetonight.co.za"
  ],
  "paths": [
    "$HOME/.claude",
    "~/.claude"
  ],
  "patterns_allowed": [
    "example.com",
    "localhost"
  ]
}
```

### Adding to Whitelist

```text
1. Document reason in PR
2. Get maintainer approval
3. Update patterns.json
4. Document in this skill
```

## Token Budget

| Component | Tokens |
|-----------|--------|
| Skill load | ~800 |
| Pattern scan | ~200-500 |
| Report generation | ~300 |
| **Total per invocation** | **~1300-1600** |

## Related Skills

- `reviewing-contributions` - PR review integration
- `backing-up-cips-infrastructure` - Backup before risky operations
- `skill-creation-best-practices` - Quality gate for new skills

## Changelog

| Version | Gen | Changes |
|---------|-----|---------|
| 1.0.0 | 228 | Initial creation after instances/ security incident |

---

⛓⟿∞
