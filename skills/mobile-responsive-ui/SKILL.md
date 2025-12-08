---
name: mobile-responsive-ui
description: Enforce mobile-first responsive design for all frontend changes. Covers TailwindCSS, vanilla CSS, container queries, dvh units, and framework-specific patterns. Trigger on any HTML, CSS, template, or UI component modifications.
version: 2.0.0
updated: 2025-12-08
---

# Mobile Responsive Design Protocol v2.0

This skill enforces mobile-first responsive design principles for all frontend work, with specific guidance for TailwindCSS, modern CSS features, and framework-specific patterns.

## Core Principles

### 1. Mobile-First Approach

- Design for smallest screen (375px) first
- Use `min-width` media queries to enhance for larger screens
- Never use `max-width` queries except for rare edge cases
- Unprefixed TailwindCSS classes = mobile, prefixed = larger screens

### 2. Modern Breakpoints (2025)

| Name | Width | TailwindCSS | Use Case |
|------|-------|-------------|----------|
| Mobile | 375px | (default) | iPhone SE, small Android |
| sm | 640px | `sm:` | Large phones, landscape |
| md | 768px | `md:` | Tablets portrait |
| lg | 1024px | `lg:` | Tablets landscape, small laptops |
| xl | 1280px | `xl:` | Desktops |
| 2xl | 1536px | `2xl:` | Large monitors |

**Critical**: `sm:` is NOT mobile! Unprefixed is mobile.

### 3. Touch Optimization

- Minimum tap target: **48x48px** with adequate spacing
- TailwindCSS: `min-h-12 min-w-12` (48px)
- Use `@media (pointer: coarse)` for touch-specific styles
- Hover effects only with `@media (hover: hover)`

---

## TailwindCSS Responsive Patterns

### Mobile-First Class Ordering

```jsx
// CORRECT: Mobile first, then larger screens
<div className="text-sm md:text-base lg:text-lg">

// WRONG: No mobile base
<div className="md:text-base lg:text-lg">
```

### Responsive Grid

```jsx
// Single column mobile, 2 on tablet, 3 on desktop
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
```

### Responsive Widths

```jsx
// Full width mobile, constrained on larger screens
<div className="w-full md:w-96 lg:w-[500px]">

// WRONG: Fixed width on mobile
<div className="w-96">  // 384px even on 375px screen!
```

### Touch-Friendly Buttons

```jsx
<button className="
  p-3
  min-h-12 min-w-12
  touch-manipulation
  active:scale-95
">
  Tap me
</button>
```

### Responsive Navigation

```jsx
// Mobile: hamburger, Desktop: horizontal nav
<nav className="flex flex-col md:flex-row md:items-center">
  <button className="md:hidden min-h-12 min-w-12">Menu</button>
  <div className="hidden md:flex gap-4">
    {/* Nav items */}
  </div>
</nav>
```

### Container Queries (Tailwind v3.4+)

```jsx
// Mark parent as container
<div className="@container">
  // Style based on container width, not viewport
  <div className="@lg:flex @lg:gap-4">
    <img className="w-full @lg:w-1/3" />
    <div className="@lg:w-2/3">Content</div>
  </div>
</div>
```

### Tailwind v4 Notes

- Configuration moved to CSS: `@import "tailwindcss"` + `@theme`
- `@screen` directive removed
- Theme values via CSS variables
- Stick to rem for breakpoints (avoid mixing px and rem)

---

## Modern CSS Units

### Dynamic Viewport Height (dvh)

Mobile browsers have dynamic chrome (address bar). Use dvh for reliable full-height:

```css
/* Always provide vh fallback first */
.hero {
  height: 100vh;
  height: 100dvh;
}
```

| Unit | Behaviour |
|------|-----------|
| `vh` | Fixed, ignores browser chrome |
| `svh` | Small viewport (chrome visible) |
| `lvh` | Large viewport (chrome hidden) |
| `dvh` | Dynamic (adjusts as chrome appears/hides) |

### Container Query Units

```css
.card {
  /* Size relative to container, not viewport */
  padding: 5cqi; /* 5% of container inline size */
  font-size: clamp(1rem, 3cqi, 1.5rem);
}
```

### Fluid Typography with clamp()

```css
/* Min: 1rem, Preferred: scales with viewport, Max: 2rem */
.heading {
  font-size: clamp(1rem, 0.5rem + 2vw, 2rem);
  line-height: 1.2;
}

/* Tailwind equivalent */
<h1 className="text-base md:text-xl lg:text-2xl">
```

### Aspect Ratio

```css
/* Modern aspect-ratio property */
.video-container {
  aspect-ratio: 16 / 9;
  width: 100%;
}

/* TailwindCSS */
<div className="aspect-video w-full">
```

---

## Framework-Specific Patterns

### React: useMediaQuery Hook

```tsx
import { useState, useEffect } from 'react';

function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(false);

  useEffect(() => {
    const media = window.matchMedia(query);
    setMatches(media.matches);

    const listener = (e: MediaQueryListEvent) => setMatches(e.matches);
    media.addEventListener('change', listener);
    return () => media.removeEventListener('change', listener);
  }, [query]);

  return matches;
}

// Usage
function Component() {
  const isDesktop = useMediaQuery('(min-width: 1024px)');
  return isDesktop ? <DesktopNav /> : <MobileNav />;
}
```

### React: Responsive Component

```tsx
interface ResponsiveProps {
  mobile: React.ReactNode;
  desktop: React.ReactNode;
  breakpoint?: number;
}

function Responsive({ mobile, desktop, breakpoint = 768 }: ResponsiveProps) {
  const isDesktop = useMediaQuery(`(min-width: ${breakpoint}px)`);
  return <>{isDesktop ? desktop : mobile}</>;
}
```

### Vue: Breakpoint Detection

```vue
<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const isMobile = ref(true)

const checkBreakpoint = () => {
  isMobile.value = window.innerWidth < 768
}

onMounted(() => {
  checkBreakpoint()
  window.addEventListener('resize', checkBreakpoint)
})

onUnmounted(() => {
  window.removeEventListener('resize', checkBreakpoint)
})
</script>

<template>
  <MobileNav v-if="isMobile" />
  <DesktopNav v-else />
</template>
```

### Vanilla JS: matchMedia

```javascript
const mobileQuery = window.matchMedia('(max-width: 767px)');

function handleBreakpoint(e) {
  if (e.matches) {
    // Mobile view
    document.body.classList.add('mobile');
  } else {
    // Desktop view
    document.body.classList.remove('mobile');
  }
}

mobileQuery.addEventListener('change', handleBreakpoint);
handleBreakpoint(mobileQuery); // Initial check
```

---

## Essential CSS Requirements

### Viewport Meta Tag (Required)

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

### Base Responsive Styles

```css
/* Reset for responsive images */
img, video, svg {
  max-width: 100%;
  height: auto;
}

/* Prevent horizontal overflow */
html {
  overflow-x: hidden;
}

/* Smooth font scaling */
html {
  font-size: 100%;
  -webkit-text-size-adjust: 100%;
}
```

### Container Queries Setup

```css
/* Define container */
.card-container {
  container-type: inline-size;
  container-name: card;
}

/* Query container */
@container card (min-width: 400px) {
  .card-content {
    display: flex;
    gap: 1rem;
  }
}
```

---

## Mandatory Testing Protocol

Before marking any UI task complete:

1. **Open Chrome DevTools**: `Cmd+Option+I` (Mac) / `Ctrl+Shift+I` (Win)
2. **Enter Device Mode**: `Cmd+Shift+M` (Mac) / `Ctrl+Shift+M` (Win)
3. **Test minimum 3 viewports**:
   - iPhone SE (375x667px) - Modern mobile minimum
   - iPad (768x1024px) - Tablet
   - Desktop (1920x1080px) - Full desktop

### Verification Checklist

- [ ] No horizontal scroll at any breakpoint
- [ ] All text readable without zooming (min 16px body)
- [ ] Touch targets >= 48x48px with 8px spacing
- [ ] Modals/overlays scrollable if content exceeds viewport
- [ ] Forms usable with touch keyboard (no hidden inputs)
- [ ] Navigation accessible on mobile (hamburger or tabs)
- [ ] Images scale appropriately (no overflow)
- [ ] dvh used for full-height sections (not vh)
- [ ] Hover states have focus/touch alternatives

---

## TailwindCSS Responsive Checklist

- [ ] All fixed widths have responsive variants (`w-full md:w-96`)
- [ ] Touch targets use `min-h-12 min-w-12`
- [ ] Full-height uses `h-dvh` with `h-screen` fallback
- [ ] Grid uses responsive columns (`grid-cols-1 md:grid-cols-2`)
- [ ] Text scales responsively (`text-sm md:text-base`)
- [ ] Spacing adjusts (`p-4 md:p-6 lg:p-8`)
- [ ] Hidden elements use responsive show/hide (`hidden md:block`)
- [ ] No arbitrary values without responsive prefix on layout

---

## Implementation Examples

### Responsive Hero Section

```jsx
<section className="
  min-h-dvh
  flex flex-col justify-center
  px-4 md:px-8 lg:px-16
  py-12 md:py-20
">
  <h1 className="
    text-3xl md:text-5xl lg:text-6xl
    font-bold
    mb-4 md:mb-6
  ">
    Welcome
  </h1>
  <p className="
    text-base md:text-lg
    max-w-prose
  ">
    Content here
  </p>
</section>
```

### Responsive Card Grid

```jsx
<div className="
  grid
  grid-cols-1
  sm:grid-cols-2
  lg:grid-cols-3
  xl:grid-cols-4
  gap-4 md:gap-6
">
  {cards.map(card => (
    <div className="
      p-4 md:p-6
      rounded-lg
      bg-white
      shadow-sm hover:shadow-md
      transition-shadow
    ">
      <img
        src={card.image}
        alt={card.title}
        className="w-full aspect-video object-cover rounded"
      />
      <h3 className="text-lg md:text-xl mt-4">{card.title}</h3>
    </div>
  ))}
</div>
```

### Responsive Modal

```jsx
<dialog className="
  fixed inset-0
  w-full h-full
  md:w-auto md:h-auto
  md:max-w-lg
  md:rounded-lg
  md:inset-auto md:top-1/2 md:left-1/2
  md:-translate-x-1/2 md:-translate-y-1/2
  overflow-y-auto
  p-4 md:p-6
">
  {/* Full screen on mobile, centered modal on desktop */}
</dialog>
```

---

## Anti-Patterns

| Bad | Good | Why |
|-----|------|-----|
| `w-96` alone | `w-full md:w-96` | No mobile base |
| `max-width: 768px` | `min-width: 768px` | Desktop-first |
| `height: 100vh` alone | `h-screen h-dvh` | Mobile browser chrome |
| `sm:` for mobile | Unprefixed for mobile | sm: = 640px+ |
| `p-2` on buttons | `p-3 min-h-12` | Touch targets |
| `:hover` only | `:hover, :focus` | Accessibility |
| Fixed pixel widths | Fluid/percentage widths | Overflow on small screens |
| Hiding content with `display:none` | Responsive `hidden md:block` | SEO and accessibility |

---

## Confidence Gate

### 99.9999999% confidence requires

- Screenshot verification at all three breakpoints, OR
- Explicit user confirmation of visual correctness, OR
- Playwright MCP automated viewport testing

## Assumption Ledger Template

```yaml
visual_verification:
  mobile_375px: unverified
  tablet_768px: unverified
  desktop_1920px: unverified
  dvh_tested: false
  touch_targets_measured: false
  container_queries_tested: false

proceed: HALT_until_verified
```

---

## Related Commands and Agents

- `/audit-mobile-responsive` - Scan codebase for violations
- `/audit-mobile-responsive --fix` - Auto-fix detected issues
- `mobile-responsive-fixer-agent` - Background auto-fixing

---

## Changelog

- **v2.0.0** (2025-12-08): Major enhancement
  - Added TailwindCSS responsive patterns section
  - Added modern CSS units (dvh, svh, lvh, container units)
  - Added framework-specific patterns (React, Vue, Vanilla)
  - Updated breakpoints (375px minimum, added 2xl)
  - Added container queries guidance
  - Added TailwindCSS v4 notes
  - Enhanced anti-patterns table
  - Added responsive checklist

- **v1.0.0** (2025-11-05): Initial version
  - Core mobile-first principles
  - Basic testing protocol
  - Essential CSS requirements
