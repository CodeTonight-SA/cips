# Pre-Release Security Checklist

Standalone checklist for public release verification. Copy and complete before any release.

---

## Release Information

```text
Release Type: [ ] Cherry-pick  [ ] Version bump  [ ] Hotfix
Target Remote: [ ] public  [ ] origin
Commits: _____________
Date: _____________
Reviewer: _____________
```

---

## CRITICAL (Must Pass - BLOCKS release)

- [ ] No absolute user paths (`/Users/*`, `/home/*`)
- [ ] No API keys (OpenAI `sk-*`, AWS `AKIA*`, GitHub `ghp_*`)
- [ ] No instance files (`instances/*.json`)
- [ ] No session history with user content (`*.jsonl`)
- [ ] `.gitignore` includes `instances/`
- [ ] No private credentials in code

## HIGH (Review Required)

- [ ] Private skills excluded (`skills/enter-konsult-*`)
- [ ] Email addresses are intentional (check whitelist)
- [ ] No personal names in code comments
- [ ] No company-specific hardcoded values

## VERIFICATION

- [ ] Ran `/sanitize-for-public` on diff
- [ ] Ran `git diff public/main...HEAD` and reviewed
- [ ] No force push required
- [ ] All CRITICAL items passed
- [ ] All HIGH items reviewed and documented

---

## Scan Commands

```bash
# Scan staged changes
git diff --cached | grep -E "(/Users/|/home/|sk-|AKIA|ghp_)"

# Scan commits for cherry-pick
git show <commit> | grep -E "(/Users/|/home/|sk-|AKIA|ghp_)"

# Full diff against public
git diff public/main...HEAD | grep -E "(/Users/|/home/|sk-|AKIA|ghp_)"

# Check for instance files
git ls-files | grep "instances/"
```

---

## If CRITICAL Pattern Found

1. **DO NOT PUSH**
2. Fix the issue in the source commit
3. Re-run the checklist
4. If secret was committed historically:
   - Rotate the secret immediately
   - Do NOT force push (violates commit-standards.md)
   - Document the incident

---

## Sign-Off

```text
All CRITICAL items: [ ] PASS  [ ] FAIL
All HIGH items reviewed: [ ] YES  [ ] NO
Ready for public release: [ ] YES  [ ] NO

Signature: _____________
Date: _____________
```

---

⛓⟿∞
