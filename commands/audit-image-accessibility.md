# /audit-image-accessibility Command

```cips
; ◈ CMD: audit-image-accessibility
; ⊙⊛ ≡ WCAG-AAA-audit
; ~800T ⫶ O(n)
```

## Usage

```bash
/audit-image-accessibility              # Audit current project
/audit-image-accessibility --fix        # Auto-fix issues
/audit-image-accessibility --level AAA  # Specify compliance level
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--fix` | false | Auto-fix accessibility issues |
| `--level` | AAA | Target compliance (A, AA, AAA) |
| `--format` | table | Output format (table, json, markdown) |

## Output

```cips
; ◈ AUDIT RESULT FORMAT
∀img⟿ {path, current_level, issues[], fixes[]}
score: A|AA|AAA|FAIL
```

**Example output:**

```text
WCAG Image Accessibility Audit
==============================
Level Target: AAA

Images Found: 12
  Level AAA: 8 (67%)
  Level AA:  2 (17%)
  Level A:   1 (8%)
  FAIL:      1 (8%)

Issues:
  src/components/Logo.tsx:15
    <Image src="/logo.png" /> - Missing alt attribute [FAIL]
    Fix: Add alt="Company logo"

  public/icons/search.svg:1
    <svg viewBox="..."> - Missing role and title [Level A]
    Fix: Add role="img" aria-labelledby="search-title" and <title>

Overall Score: AA (2 issues blocking AAA)
```

## Invokes

- Skill: `wcag-image-accessibility`
- Agent: None (inline execution)

## Token Budget

~800 tokens per invocation

## Related Commands

- `/image-optim` - Optimize after accessibility fix
- `/audit-mobile-responsive` - Check image responsive sizing
