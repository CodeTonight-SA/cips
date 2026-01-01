---
description: Run thorough mobile responsive audit on codebase, detecting anti-patterns across TailwindCSS, vanilla CSS, and framework components
disable-model-invocation: false
---

# Audit Mobile Responsive

Runs a comprehensive mobile responsive audit detecting anti-patterns and providing actionable fixes with file:line references.

## What It Does

1. Scans codebase for 15+ mobile responsive anti-patterns
2. Detects TailwindCSS, vanilla CSS, and framework-specific issues
3. Reports severity-scored violations with exact locations
4. Provides specific remediation for each violation
5. Calculates overall mobile-readiness score (0-100)

## Usage

```bash
/audit-mobile-responsive [path]
```

### Parameters

- `path` (optional): Directory to audit (default: current directory)

### Examples

- `/audit-mobile-responsive` - Audit current project
- `/audit-mobile-responsive src/components` - Audit specific directory

## Detection Patterns

### Critical (10 points each)

| Pattern | Detection | Remediation |
|---------|-----------|-------------|
| Missing viewport meta | No `<meta name="viewport"` in HTML | Add `<meta name="viewport" content="width=device-width, initial-scale=1.0">` |
| Fixed container widths | `width: \d+px` on containers | Use `max-width` or responsive classes |
| vh without dvh fallback | `height: 100vh` without dvh | Add `height: 100dvh` with `height: 100vh` fallback |

### Major (5 points each)

| Pattern | Detection | Remediation |
|---------|-----------|-------------|
| Desktop-first media queries | `max-width` before `min-width` | Refactor to mobile-first with `min-width` |
| Small touch targets | `min-height` or `padding` < 48px on buttons | Use `min-h-12 min-w-12` (TailwindCSS) or `min-height: 48px` |
| Hover-only interactions | `:hover` without `:focus` alternative | Add `:focus` and `@media (hover: hover)` |
| Hardcoded Tailwind widths | `w-[500px]` without responsive variant | Use `w-full md:w-[500px]` |

### Minor (2 points each)

| Pattern | Detection | Remediation |
|---------|-----------|-------------|
| Missing responsive prefixes | Single breakpoint Tailwind classes | Add `sm:`, `md:`, `lg:` variants |
| Non-fluid typography | Fixed `font-size` values | Use `clamp()` or Tailwind responsive text |
| Fixed image dimensions | `<img width="500">` | Use `max-width: 100%` or responsive classes |

## Detection Commands

The audit uses these rg patterns:

```bash
rg -n "width:\s*\d+px" --glob '*.css' --glob '*.scss'
rg -n "height:\s*100vh" --glob '*.css' --glob '*.tsx' --glob '*.jsx'
rg -n "@media.*max-width" --glob '*.css'
rg -n "w-\[\d+px\]" --glob '*.tsx' --glob '*.jsx' --glob '*.html'
rg -n "min-height:\s*[0-3][0-9]px" --glob '*.css'
rg -n ":hover\s*{" --glob '*.css' | grep -v ":focus"
```

## Output Format

```text
MOBILE RESPONSIVE AUDIT REPORT

Project: /path/to/project
Files Scanned: 127
Violations Found: 8

CRITICAL (10 pts each):
  src/styles/global.css:45 - vh without dvh fallback
    Found: height: 100vh
    Fix: height: 100dvh; /* with fallback */ height: 100vh;

MAJOR (5 pts each):
  src/components/Button.tsx:12 - Touch target too small
    Found: className="p-2" (32px)
    Fix: className="p-3 min-h-12 min-w-12"

MINOR (2 pts each):
  src/components/Card.tsx:8 - Missing responsive prefix
    Found: className="w-96"
    Fix: className="w-full md:w-96"

SCORE: 73/100 (Needs Improvement)
  - Critical: 1 (10 pts)
  - Major: 2 (10 pts)
  - Minor: 3 (6 pts)

RECOMMENDATIONS:
1. Add dvh fallbacks to all vh usages (1 file)
2. Increase touch target sizes on interactive elements (2 files)
3. Add responsive prefixes to fixed-width classes (3 files)
```

## Scoring

| Score | Grade | Action |
|-------|-------|--------|
| 90-100 | Excellent | Production ready |
| 70-89 | Good | Minor fixes recommended |
| 50-69 | Needs Work | Address major issues |
| 0-49 | Critical | Do not deploy |

## Integration

This command triggers the `mobile-responsive-fixer-agent` for automated fixes when:
- User runs `/audit-mobile-responsive --fix`
- Violations exceed threshold (score < 70)

## Related

- `/fix-mobile-responsive` - Auto-fix detected issues
- `mobile-responsive-ui` skill - Full protocol reference
- `mobile-responsive-fixer-agent` - Background fixing agent

## Tech Stack Coverage

- **TailwindCSS**: Responsive utilities, arbitrary values, container queries
- **Vanilla CSS**: Media queries, viewport units, touch targets
- **React/Vue/Svelte**: Component-level responsiveness patterns
- **HTML**: Viewport meta, responsive images, semantic structure
