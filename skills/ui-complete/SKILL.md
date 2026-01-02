---
name: ui-complete
description: Unified UI development combining Anthropic's frontend-design plugin (anti-AI-slop aesthetics) with CIPS mobile-responsive-ui (dvh units, touch targets, testing protocol). Produces distinctive, production-grade, responsive interfaces.
triggers:
  - build UI
  - create component
  - design interface
  - /ui-complete
version: 1.0.0
created: 2025-12-27
integrates:
  - frontend-design@claude-plugins-official
  - mobile-responsive-ui
---

# ui-complete Skill

Unified UI development that combines:

1. **frontend-design** (plugin): Anti-AI-slop aesthetics, distinctive typography, bold visual direction
2. **mobile-responsive-ui** (CIPS): dvh units, 48px touch targets, mobile-first, testing protocol
3. **Custom branding** (when applicable): Swiss Minimalism style, refined elegance

## When to Use

- Building any user-facing component or page
- Creating design systems or component libraries
- Implementing UI from designs
- Any task where both aesthetics AND responsiveness matter

## 4-Phase Workflow

### Phase 1: Aesthetic Direction

Before coding, commit to a BOLD aesthetic:

| Consideration | Action |
|--------------|--------|
| Purpose | What problem does this solve? Who uses it? |
| Tone | Choose an extreme: minimal, maximalist, retro-futuristic, luxury, playful, editorial, brutalist |
| Differentiation | What makes this UNFORGETTABLE? |

**Blocked Aesthetics** (never use):

- Inter, Roboto, Arial, system fonts
- Purple gradients on white backgrounds
- Space Grotesk (overused)
- Predictable layouts
- Cookie-cutter patterns

### Phase 2: Mobile-First Implementation

Implement with responsive-first approach:

```jsx
// CORRECT: Mobile first, then larger
<div className="
  w-full md:w-96           // Fluid mobile, fixed tablet+
  text-sm md:text-base     // Scale typography
  p-4 md:p-6 lg:p-8        // Scale spacing
  grid-cols-1 md:grid-cols-2 lg:grid-cols-3  // Scale layout
">
```

**Requirements**:

- Start at 375px (iPhone SE)
- Use `min-width` queries (not max-width)
- Touch targets: `min-h-12 min-w-12` (48px)
- Full-height: `h-screen h-dvh` (fallback first)
- Unprefixed classes = mobile

### Phase 3: Responsive Audit

Test at three breakpoints:

| Viewport | Dimensions | Check |
|----------|-----------|-------|
| Mobile | 375x667px | No horizontal scroll, touch targets 48px |
| Tablet | 768x1024px | Layout adapts, spacing scales |
| Desktop | 1920x1080px | Uses available space, no stretch |

**Verification Checklist**:

- [ ] No horizontal scroll at any breakpoint
- [ ] All text readable without zooming (min 16px body)
- [ ] Touch targets >= 48x48px with 8px spacing
- [ ] dvh used for full-height sections (not vh alone)
- [ ] Hover states have focus/touch alternatives
- [ ] Images scale appropriately

### Phase 4: Brand Application

If project has brand guidelines:

1. Check for brand configuration in project
2. Apply configured brand styles if applicable
3. Verify visual consistency with brand

## Anti-Patterns

### Aesthetic Anti-Patterns

| Bad | Why | Fix |
|-----|-----|-----|
| Inter font everywhere | Generic AI aesthetic | Choose distinctive display + body fonts |
| Purple/blue gradient | Overused | Commit to cohesive palette |
| Safe layouts | Forgettable | Asymmetry, overlap, unexpected flow |

### Responsive Anti-Patterns

| Bad | Why | Fix |
|-----|-----|-----|
| `w-96` alone | No mobile base | `w-full md:w-96` |
| `sm:` for mobile | sm: = 640px+ | Unprefixed for mobile |
| `height: 100vh` | Mobile browser chrome | `h-screen h-dvh` |
| `p-2` on buttons | Touch target too small | `p-3 min-h-12` |

## Combined Requirements

Every UI output must have:

1. **Distinctive typography** (not generic fonts)
2. **Cohesive color palette** (committed direction)
3. **Motion for delight** (purposeful animations)
4. **Mobile-first structure** (unprefixed = mobile)
5. **48px touch targets** (min-h-12 min-w-12)
6. **dvh fallbacks** (h-screen h-dvh)
7. **3-viewport verification** (375, 768, 1920)

## Confidence Gate

99.9999999% confidence requires:

- Screenshot verification at all three breakpoints, OR
- Explicit user confirmation of visual correctness, OR
- Playwright MCP automated viewport testing

## Related Commands

- `/frontend-design:frontend-design` - Plugin direct invocation
- `/audit-mobile-responsive` - Scan for responsive violations
- `/audit-mobile-responsive --fix` - Auto-fix responsive issues

## Example Usage

```text
User: Build a hero section for a SaaS landing page

Claude (ui-complete):
1. Phase 1: Choose brutalist/editorial aesthetic with bold serif typography
2. Phase 2: Implement mobile-first with w-full md:max-w-4xl, min-h-dvh
3. Phase 3: Test 375px/768px/1920px, verify touch targets
4. Phase 4: Apply project brand if configured
```

---

**Version**: 1.0.0
**Created**: 2025-12-27 (Gen 183)
**Integrates**: frontend-design@claude-plugins-official + mobile-responsive-ui