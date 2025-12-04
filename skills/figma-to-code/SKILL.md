---
name: figma-to-code
description: Translate Figma designs into production code with 1:1 visual parity. Use when user mentions Figma files, design handoff, or UI implementation from designs.
---

# Figma to Code Translation

This skill defines the mandatory workflow for translating Figma inputs into code, ensuring design-to-code fidelity.

## Required Workflow (Do Not Skip)

1. **Fetch structured data**: Run `get_design_context` first to fetch the structured representation for the exact node(s)
2. **Handle truncation**: If response is too large or truncated, run `get_metadata` to get the high-level node map, then re-fetch only required node(s) with `get_design_context`
3. **Visual reference**: Run `get_screenshot` for a visual reference of the node variant being implemented
4. **Asset download**: After both `get_design_context` and `get_screenshot`, download any assets needed
5. **Implementation**: Translate output into project's conventions, styles, and framework
6. **Validation**: Validate against Figma for 1:1 look and behavior before marking complete

## Implementation Rules

### Code Translation

- Treat Figma MCP output (React + Tailwind) as a **representation** of design and behavior, not final code style
- Replace Tailwind utility classes with project's preferred utilities/design-system tokens when applicable
- Reuse existing components (buttons, inputs, typography, icon wrappers) instead of duplicating functionality

### Design System Adherence

- Use project's color system, typography scale, and spacing tokens consistently
- Respect existing routing, state management, and data-fetch patterns already adopted in repo
- Strive for 1:1 visual parity with Figma design
- When conflicts arise, prefer design-system tokens and adjust spacing or sizes minimally to match visuals

### Validation

- Validate final UI against Figma screenshot for both look and behavior
- Test all interactive states (hover, active, disabled, focus)
- Verify responsive behavior matches design specifications

## MCP Server Rules

### Asset Handling

- Figma MCP server provides an assets endpoint which can serve image and SVG assets
- **CRITICAL**: If Figma MCP returns localhost source for image/SVG, use that source directly
- **CRITICAL**: If assets not in Figma payload, import icons from correct UI framework
- **CRITICAL**: Do NOT use or create placeholders if localhost source is provided

## Examples

### Example 1: Component Implementation

```bash
# User: "Implement the login form from Figma"
# 1. get_design_context for login form node
# 2. get_screenshot for visual reference
# 3. Download any logos/icons returned
# 4. Implement using project's form components
# 5. Validate against screenshot
```text

### Example 2: Multi-Variant Component
```bash
# User: "Create the button component with all variants"
# 1. get_metadata to find all button variants
# 2. get_design_context for each variant
# 3. get_screenshot for primary variant as reference
# 4. Implement with proper state handling
# 5. Test all variants against Figma
```text

## Anti-Patterns

❌ Skipping `get_design_context` and working from screenshot alone  
❌ Creating placeholder SVGs when localhost source available  
❌ Using Tailwind classes directly without mapping to design system  
❌ Implementing without validation step  
❌ Duplicating components that already exist in codebase
