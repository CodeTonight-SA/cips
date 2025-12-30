---
name: generating-brand-pdfs
description: Generate professional PDF documents and blog-ready HTML in ENTER Konsult brand style (Swiss Minimalism). Use when user invokes /generate-pdf or requests document generation.
status: Active
version: 1.1.0
triggers:
  - /generate-pdf
  - "generate PDF"
  - "ENTER Konsult style"
---

# ENTER Konsult PDF Generator

**Purpose:** Generate professional technical documents, articles, and guides in ENTER Konsult brand style with consistent Swiss Minimalism aesthetic. Outputs both blog-ready HTML and print-ready PDF.

**Token Budget:** ~3,000 tokens per generation

**Reference:** See [reference.md](./reference.md) for complete CSS template, HTML template, and content structure templates.

---

## Design System

### Colour Palette

| Name | Hex | Usage |
|------|-----|-------|
| Paper Grey | `#EAEAEA` | Page background (full bleed) |
| Black | `#000000` | Headings, strong text |
| Dark | `#1a1a1a` | Body text, code block backgrounds |
| Orange Accent | `#ea580c` | H1 underline, H3 colour, links, inline code |
| Grey | `#666666` | Muted text, H4, subtitles |
| Border Grey | `#d1d5db` | Table borders, HR, H2 underline |

### Typography

| Element | Font | Size | Weight |
|---------|------|------|--------|
| Body | System stack | 11pt | 400 |
| H1 | System stack | 28pt | 800 |
| H2 | System stack | 16pt | 700 |
| H3 | System stack | 12pt | 700 |
| H4 | SF Mono/Consolas | 10pt | 600 |
| Code | SF Mono/Consolas | 9pt | 400 |

### Page Layout

- **Size:** A4 (210mm x 297mm)
- **Margins:** 2cm top/bottom, 2.5cm left/right
- **Background:** Paper Grey `#EAEAEA` (full page via `@page`)
- **Header:** Document title in spaced uppercase monospace
- **Footer:** Page number + "ENTER Konsult | Month Year"

---

## Generation Workflow

### Step 1: Generate HTML

1. Load CSS template from reference.md
2. Replace `DOCUMENT_TITLE_PLACEHOLDER` with actual title (uppercase)
3. Replace `MONTH_YEAR_PLACEHOLDER` with current month/year
4. Insert content using appropriate structure template
5. Save as `.html` file

### Step 2: Generate PDF

```bash
pandoc document.html -o document.pdf --pdf-engine=weasyprint
```

**Alternative:**

```bash
weasyprint document.html document.pdf
```

### Dependencies (One-time)

```bash
brew install pandoc
pip3 install weasyprint
```

---

## Document Types

### Technical Reference

Best for: API documentation, component libraries, design systems

Structure:
- Overview with key benefits table
- Component inventory
- Usage patterns with code examples
- Best practices
- Quick reference table

### Blog Article

Best for: Tutorials, case studies, technical writing

Structure:
- Problem statement
- Solution with step-by-step guide
- Results table (before/after metrics)
- Key takeaways

---

## Slash Command

```bash
/generate-pdf "Document Title"
/generate-pdf "Title" --output ~/Documents/
/generate-pdf "Title" --type article
```

### Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| title | Document title (required) | - |
| --output | Output directory | Current directory |
| --type | Template type | reference |

---

## Token Budget Breakdown

| Step | Tokens |
|------|--------|
| Template selection | ~200 |
| Content generation | ~2,000 |
| HTML assembly | ~500 |
| PDF command | ~100 |
| Verification | ~200 |
| **Total** | **~3,000** |

---

## Anti-Patterns

| Don't | Why |
|-------|-----|
| Use external CSS links | Breaks self-containment |
| Use browser print | Doesn't support `@page` properly |
| Forget Paper Grey background | Must be in both `@page` and `body` |
| Use CodeTonight branding | Use ENTER Konsult |
| Skip weasyprint | Required for proper page layout |

---

## Integration

| Skill | Usage |
|-------|-------|
| `chat-history-search` | Search history for content to document |
| `medium-article-writer` | Generate both formats |

---

**Skill Status:** ✅ Active
**Maintainer:** LC Scheepers
**Last Updated:** 2025-12-30
**Brand:** ENTER Konsult (Swiss Minimalism)

⛓⟿∞
