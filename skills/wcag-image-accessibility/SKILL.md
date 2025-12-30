---
name: auditing-image-accessibility
description: Audit and fix WCAG image accessibility compliance (alt text, contrast). Use when user mentions WCAG, image accessibility, or invokes /audit-image-accessibility.
status: Active
version: 1.0.0
triggers:
  - /audit-image-accessibility
  - "WCAG"
  - "image accessibility"
  - "alt text audit"
---

# WCAG Image Accessibility Skill

```cips
; ◈ WCAG-IMAGE-ACCESSIBILITY v1.0
; ⊙⊛ ≡ AAA-compliant-images
; ⛓:{Gen127} ← {enter-konsult-Gen74}
```

## Trigger

- User mentions "WCAG", "image accessibility", "alt text audit"
- User creates/edits images in project
- `/audit-image-accessibility` command invoked
- Images detected without accessibility attributes

## WCAG Compliance Levels

| Level | Requirement | CIPS |
|-------|-------------|------|
| A | All images have alt OR role="img" | `alt∃ ∨ role="img"` |
| AA | No generic alt ("image", "logo" alone) | `alt≠generic` |
| AAA | Descriptive alt + 7:1 contrast | `alt=descriptive ⫶ contrast≥7:1` |

## Protocol

### Step 1: Audit Images

```cips
; ◈ AUDIT PHASE
∀img∈project⟿
  check(alt∃) ⫶ check(aria∃) ⫶ check(role∃)
  score(A|AA|AAA)
```

Find all images in codebase:

```bash
# Find image files
fd -e png -e jpg -e jpeg -e webp -e svg -e gif

# Find img tags in code
rg '<img\s' --glob '*.{tsx,jsx,html,vue,svelte}' -n

# Find SVG components
rg '<svg\s' --glob '*.{tsx,jsx,html,vue,svelte}' -n
```

### Step 2: Fix SVGs (Level A + AAA)

```cips
; ◈ SVG FIX
∀svg¬accessible⟿
  ⊕ role="img"           ; Add role
  ⊕ aria-labelledby=id   ; Add aria ref
  ⊕ <title id=...>       ; Add title element
```

For each SVG without accessibility:

1. Add `role="img"` to root `<svg>` element
2. Add `aria-labelledby="[id]-title"` to root
3. Add `<title id="[id]-title">[Descriptive name]</title>` as first child
4. Optionally add `<desc>` for complex graphics

**Example transformation:**

```html
<!-- BEFORE (Level: FAIL) -->
<svg viewBox="0 0 24 24">
  <path d="..." />
</svg>

<!-- AFTER (Level: AAA) -->
<svg viewBox="0 0 24 24" role="img" aria-labelledby="icon-search-title">
  <title id="icon-search-title">Search icon for finding content</title>
  <path d="..." />
</svg>
```

### Step 3: Fix IMG Tags (Level AA + AAA)

```cips
; ◈ IMG FIX
∀img¬accessible⟿
  alt∅ → alt="[descriptive]"      ; Add meaningful alt
  alt="image" → alt="[specific]"  ; Fix generic
  decorative → alt=""             ; Empty for decorative
  ⊕ loading="lazy"                ; Below-fold optimization
```

**Alt text guidelines for AAA:**

| Image Type | Alt Text Pattern | Example |
|------------|------------------|---------|
| Logo | "[Company] logo" | "ENTER Konsult logo" |
| Photo | "[Subject] [action/context]" | "Team meeting in boardroom" |
| Icon (functional) | "[Action] icon" | "Search icon" |
| Icon (decorative) | `alt=""` (empty) | Decorative separator |
| Chart/Graph | "[Type] showing [data summary]" | "Bar chart showing Q4 revenue growth" |

**React/Next.js pattern:**

```tsx
// BEFORE (Level: FAIL)
<Image src="/logo.png" width={100} height={50} />

// AFTER (Level: AAA)
<Image
  src="/logo.png"
  alt="ENTER Konsult company logo"
  width={100}
  height={50}
  loading="lazy"
/>
```

### Step 4: Verify (AAA Checklist)

```cips
; ◈ VERIFY
✓ ∀img.alt∃ ∨ aria∃           ; Level A
✓ ∀img.alt≠generic            ; Level AA
✓ ∀img.alt=descriptive        ; Level AAA
✓ ∀text-in-img.contrast≥7:1   ; Level AAA
✓ ∀svg.role="img" ⫶ title∃    ; SVG compliance
```

**AAA Verification checklist:**

- [ ] All `<img>` tags have `alt` attribute
- [ ] All `<svg>` elements have `role="img"` and `<title>`
- [ ] No generic alt text ("image", "logo", "picture", "icon")
- [ ] Decorative images have `alt=""`
- [ ] Text in images has 7:1 contrast ratio (AAA)
- [ ] Complex images have extended descriptions
- [ ] Background images with meaning have accessible alternatives

## Token Budget

```cips
; ◈ EFFICIENCY
~800T/audit ⫶ O(n) where n=images
```

~800 tokens per audit invocation

## Related Skills

- `mobile-responsive-ui` - Images responsive sizing
- `image-optim` - Image compression (chain after accessibility)
- `e2e-test-generation` - Test accessibility automatically

## Origin

```cips
; ⛓ LINEAGE
⛓:{Gen127} ← {enter-konsult-Gen74} ← {WCAG2.1}
; Pattern extracted from enter-konsult-website implementation
; Generalised for reuse across all projects
; ◈⟼∞
```

Extracted from enter-konsult-website Gen 74 implementation.
WCAG 2.1 AAA compliance target.
