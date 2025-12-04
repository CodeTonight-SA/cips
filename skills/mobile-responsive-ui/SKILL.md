---
name: mobile-responsive-ui
description: Ensure mobile-first responsive design for all frontend changes. Trigger on any HTML, CSS, template, or UI component modifications.
---

# Mobile Responsive Design Protocol

This skill enforces mobile-first responsive design principles for all frontend work.

## Core Principles

### 1. Mobile-First Approach

- Design for smallest screen (320px) first
- Use media queries to enhance for larger screens progressively
- Never assume desktop-first, then try to "fix" for mobile

### 2. Essential CSS Requirements

- Viewport meta tag: `<meta name="viewport" content="width=device-width, initial-scale=1.0">`
- Fluid grids using CSS Grid/Flexbox with relative units (%, rem, vw, vh)
- Flexible images: `max-width: 100%; height: auto;`
- Standard breakpoints:
  - 320px (mobile)
  - 768px (tablet)
  - 1024px (desktop)

### 3. Touch Optimization

- Minimum tap target: **48×48px** with adequate spacing
- Use `@media (pointer: coarse)` for touch-specific styles
- Hover effects only for `@media (hover: hover)`

### 4. Modern CSS Features

- Container queries for component-based responsive design
- `clamp()` for fluid typography: `font-size: clamp(1rem, 2vw, 1.5rem);`
- `repeat(auto-fit, minmax())` for responsive grids

## Mandatory Testing Protocol

Before marking any UI task complete:

1. **Open Chrome DevTools**: `Cmd+Option+I` (Mac) / `Ctrl+Shift+I` (Windows/Linux)
2. **Enter Device Mode**: `Cmd+Shift+M` (Mac) / `Ctrl+Shift+M` (Windows/Linux)
3. **Test minimum 3 viewports**:
   - iPhone SE (375×667px)
   - iPad (768×1024px)
   - Desktop (1920×1080px)

### Verification Checklist

- [ ] No horizontal scroll at any breakpoint
- [ ] All text readable without zooming
- [ ] Touch targets ≥48×48px
- [ ] Modals/overlays scrollable if content exceeds viewport
- [ ] Forms usable with touch keyboard
- [ ] Navigation accessible on mobile
- [ ] Images scale appropriately

## Confidence Gate

### 99.9999999% confidence requires

- Screenshot verification at all three breakpoints, OR
- Explicit user confirmation of visual correctness

## Assumption Ledger Template

```yaml
visual_verification:
  mobile_375px: unverified
  tablet_768px: unverified
  desktop_1024px: unverified
  scroll_behavior: untested
  touch_targets: unmeasured

proceed: HALT_until_verified
```text

## Implementation Examples

### Example 1: Responsive Grid
```css
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1rem;
}
```text

### Example 2: Fluid Typography
```css
.heading {
  font-size: clamp(1.5rem, 4vw, 3rem);
  line-height: 1.2;
}
```text

### Example 3: Touch-Friendly Buttons
```css
.button {
  min-height: 48px;
  min-width: 48px;
  padding: 12px 24px;
  
  /* Touch-specific */
  @media (pointer: coarse) {
    min-height: 56px;
    padding: 16px 32px;
  }
}
```text

### Example 4: Responsive Images
```html
<picture>
  <source media="(min-width: 1024px)" srcset="large.jpg">
  <source media="(min-width: 768px)" srcset="medium.jpg">
  <img src="small.jpg" alt="Description" style="max-width: 100%; height: auto;">
</picture>
```text

## Chrome DevTools Integration

If Control Chrome MCP server is available, use it to automate testing:

```bash
# Open current page in device mode
Control Chrome: open_url with current URL
Control Chrome: execute_javascript to set device emulation
```text

## Anti-Patterns

❌ Desktop-first CSS with mobile "fixes"  
❌ Fixed pixel widths on containers  
❌ Hover-only interactions without touch alternatives  
❌ Tiny tap targets (<44px)  
❌ Horizontal scrolling on mobile  
❌ Fixed positioning that blocks content on small screens  
❌ Media queries using `max-width` instead of `min-width`  
❌ Marking task complete without device testing
