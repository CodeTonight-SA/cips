---
name: enter-konsult-pdf
description: Generate professional PDF documents and blog-ready HTML in ENTER Konsult brand style (Swiss Minimalism). Outputs self-contained HTML + PDF via pandoc/weasyprint.
commands: [/generate-pdf]
---

# ENTER Konsult PDF Generator

**Purpose:** Generate professional technical documents, articles, and guides in ENTER Konsult brand style with consistent Swiss Minimalism aesthetic. Outputs both blog-ready HTML and print-ready PDF.

**Activation:** When user invokes `/generate-pdf "<Title>"` or requests document generation in ENTER Konsult style.

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
| Light Grey | `#f3f4f6` | Inline code background |
| White | `#ffffff` | Blockquote background, table cells |

### Typography

| Element | Font | Size | Weight | Notes |
|---------|------|------|--------|-------|
| Body | System stack | 11pt | 400 | Line-height 1.6 |
| H1 | System stack | 28pt | 800 | Orange underline, letter-spacing -0.03em |
| H2 | System stack | 16pt | 700 | Grey underline |
| H3 | System stack | 12pt | 700 | Orange colour |
| H4 | SF Mono/Consolas | 10pt | 600 | Uppercase, letter-spacing 0.1em |
| Code | SF Mono/Consolas | 9pt | 400 | Orange inline, light on dark for blocks |
| Header/Footer | SF Mono/Consolas | 8pt | 400 | Uppercase, letter-spacing 0.2em |

### Page Layout

- **Size:** A4 (210mm x 297mm)
- **Margins:** 2cm top/bottom, 2.5cm left/right
- **Background:** Paper Grey `#EAEAEA` (full page via `@page`)
- **Header:** Document title in spaced uppercase monospace
- **Footer:** Page number (centred) + "ENTER Konsult | Month Year"

---

## Complete CSS Template

```css
@page {
  size: A4;
  margin: 2cm 2.5cm;
  background-color: #EAEAEA;
  @top-center {
    content: "DOCUMENT_TITLE_PLACEHOLDER";
    font-family: "SF Mono", "Consolas", monospace;
    font-size: 8pt;
    color: #666;
    letter-spacing: 0.2em;
    text-transform: uppercase;
  }
  @bottom-center {
    content: counter(page);
    font-family: "SF Mono", "Consolas", monospace;
    font-size: 8pt;
    color: #666;
  }
}

@page:last {
  @bottom-center {
    content: "ENTER Konsult | MONTH_YEAR_PLACEHOLDER";
    font-family: "SF Mono", "Consolas", monospace;
    font-size: 8pt;
    color: #666;
    letter-spacing: 0.1em;
  }
}

* {
  box-sizing: border-box;
}

html, body {
  background-color: #EAEAEA;
  min-height: 100%;
  margin: 0;
  padding: 0;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  font-size: 11pt;
  line-height: 1.6;
  color: #1a1a1a;
  max-width: 100%;
}

h1 {
  font-size: 28pt;
  font-weight: 800;
  letter-spacing: -0.03em;
  line-height: 1.1;
  margin: 0 0 0.5em 0;
  padding-bottom: 0.3em;
  border-bottom: 3px solid #ea580c;
  color: #000;
}

h2 {
  font-size: 16pt;
  font-weight: 700;
  letter-spacing: -0.02em;
  margin: 2em 0 0.5em 0;
  padding-bottom: 0.3em;
  border-bottom: 1px solid #d1d5db;
  color: #000;
}

h3 {
  font-size: 12pt;
  font-weight: 700;
  margin: 1.5em 0 0.5em 0;
  color: #ea580c;
}

h4 {
  font-family: "SF Mono", "Consolas", monospace;
  font-size: 10pt;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  margin: 1em 0 0.5em 0;
  color: #666;
}

p {
  margin: 0 0 1em 0;
}

strong {
  font-weight: 700;
  color: #000;
}

em {
  font-style: italic;
  color: #666;
}

hr {
  border: none;
  border-top: 1px solid #d1d5db;
  margin: 2em 0;
}

code {
  font-family: "SF Mono", "Consolas", "Monaco", monospace;
  font-size: 9pt;
  background-color: #f3f4f6;
  padding: 0.15em 0.4em;
  border-radius: 3px;
  color: #ea580c;
}

pre {
  font-family: "SF Mono", "Consolas", "Monaco", monospace;
  font-size: 9pt;
  background-color: #1a1a1a;
  color: #f3f4f6;
  padding: 1em 1.2em;
  border-radius: 0;
  border-left: 3px solid #ea580c;
  overflow-x: auto;
  margin: 1em 0;
  line-height: 1.5;
  page-break-inside: avoid;
}

pre code {
  background: none;
  padding: 0;
  color: #f3f4f6;
}

table {
  width: 100%;
  border-collapse: collapse;
  margin: 1em 0;
  font-size: 10pt;
  page-break-inside: avoid;
}

th {
  font-family: "SF Mono", "Consolas", monospace;
  font-size: 8pt;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  text-align: left;
  padding: 0.8em 1em;
  background-color: #1a1a1a;
  color: #fff;
  border: none;
}

td {
  padding: 0.8em 1em;
  border-bottom: 1px solid #d1d5db;
  vertical-align: top;
  background-color: #fff;
}

tr:last-child td {
  border-bottom: 2px solid #1a1a1a;
}

ul, ol {
  margin: 0.5em 0 1em 0;
  padding-left: 1.5em;
}

li {
  margin: 0.3em 0;
}

blockquote {
  margin: 1em 0;
  padding: 0.5em 1em;
  border-left: 3px solid #ea580c;
  background-color: #fff;
  font-style: italic;
  color: #666;
  page-break-inside: avoid;
}

a {
  color: #ea580c;
  text-decoration: none;
}

a:hover {
  text-decoration: underline;
}

.title-block {
  margin-bottom: 2em;
}

.subtitle {
  font-family: "SF Mono", "Consolas", monospace;
  font-size: 9pt;
  text-transform: uppercase;
  letter-spacing: 0.15em;
  color: #666;
  margin-top: 0.5em;
}

.meta {
  font-family: "SF Mono", "Consolas", monospace;
  font-size: 9pt;
  color: #666;
  margin-bottom: 2em;
}

.page-break {
  page-break-after: always;
}

.no-break {
  page-break-inside: avoid;
}
```

---

## HTML Template

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>DOCUMENT_TITLE</title>
  <style>
    /* INSERT COMPLETE CSS HERE */
  </style>
</head>
<body>
  <div class="title-block">
    <h1>DOCUMENT_TITLE</h1>
    <p class="subtitle">DOCUMENT_SUBTITLE</p>
    <p class="meta"><strong>Document Type</strong> Version X.X | MONTH YEAR</p>
  </div>

  <!-- CONTENT SECTIONS -->

  <h2>Section Title</h2>
  <p>Content paragraph...</p>

  <h3>Subsection</h3>
  <p>More content...</p>

  <pre><code>code example here</code></pre>

  <table>
    <thead>
      <tr>
        <th>Column 1</th>
        <th>Column 2</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Data</td>
        <td>Data</td>
      </tr>
    </tbody>
  </table>

</body>
</html>
```

---

## Generation Workflow

### Step 1: Generate HTML

Create self-contained HTML file with embedded CSS:

1. Replace `DOCUMENT_TITLE_PLACEHOLDER` in CSS `@page` with actual title (uppercase)
2. Replace `MONTH_YEAR_PLACEHOLDER` with current month/year
3. Replace template placeholders with content
4. Save as `.html` file

### Step 2: Generate PDF

```bash
pandoc document.html -o document.pdf --pdf-engine=weasyprint
```

**Alternative (direct weasyprint):**

```bash
weasyprint document.html document.pdf
```

### Dependencies

One-time setup:

```bash
brew install pandoc
pip3 install weasyprint
```

---

## Content Structure Templates

### Technical Reference Document

```markdown
# [Product/Feature]: [Topic]

**Technical Reference Document** Version X.X | Month Year

---

## Overview

[2-3 paragraphs explaining what this is and why it matters]

### Key Benefits
| BENEFIT | DESCRIPTION |
|---------|-------------|
| Benefit 1 | Description |
| Benefit 2 | Description |

---

## Component Location

`path/to/component.tsx`

---

## Component Inventory

### [Category Name]

#### ComponentName

[Description of what it does]

```language
import { Component } from "@/path"

<Component prop="value" />
```

---

## Usage Patterns

### Pattern 1: [Name]

[Description and code example]

### Pattern 2: [Name]

[Description and code example]

---

## Best Practices

1. **Practice 1** - Explanation
2. **Practice 2** - Explanation
3. **Practice 3** - Explanation

---

## Quick Reference

| COMPONENT | IMPORT | PRIMARY USE |
|-----------|--------|-------------|
| Component1 | @/path | Use case |
| Component2 | @/path | Use case |

---

**Document Title** | ENTER Konsult | Month Year

```

### Blog Article

```markdown
# [Engaging Title]

**[Subtitle/Hook]**

---

## The Problem

[Set up the pain point]

---

## The Solution

[Introduce your approach]

### Step 1: [Action]

[Explanation with code]

### Step 2: [Action]

[Explanation with code]

---

## Results

| METRIC | BEFORE | AFTER |
|--------|--------|-------|
| Metric 1 | X | Y |

---

## Key Takeaways

1. **Takeaway 1**
2. **Takeaway 2**
3. **Takeaway 3**

---

**ENTER Konsult** | Month Year
```

---

## Slash Command Usage

```bash
/generate-pdf "Skeleton Loaders Technical Reference"
/generate-pdf "Authentication Flow Guide" --output ~/Documents/
/generate-pdf "API Integration" --type article
```

### Parameters

- `title` (required): Document title
- `--output`: Output directory (default: current directory)
- `--type`: Template type (`reference`, `article`, `guide`)

---

## Integration with Other Skills

### With `/remind-yourself`

Search history for content to document:

```bash
/remind-yourself "skeleton loaders implementation"
/generate-pdf "Skeleton Loaders" --from-history
```

### With `/write-medium-article`

Generate both formats:

```bash
/write-medium-article "topic"
/generate-pdf "topic" --type article
```

---

## Output Files

| Type | Location | Purpose |
|------|----------|---------|
| HTML | `{output}/{slug}.html` | Blog-ready, self-contained |
| PDF | `{output}/{slug}.pdf` | Print-ready, A4 format |

---

## Anti-Patterns

- **Do not** use external CSS links (breaks self-containment)
- **Do not** use browser print (use weasyprint for proper `@page`)
- **Do not** forget the Paper Grey background in both `@page` and `body`
- **Do not** use CodeTonight branding (use ENTER Konsult)

---

## Token Budget

~3,000 tokens per generation:

- Template selection: ~200
- Content generation: ~2,000
- HTML assembly: ~500
- PDF command: ~100
- Verification: ~200

---

## Changelog

**v1.0** (2025-12-09) - Initial creation

- Complete CSS design system from ENTER Konsult brand
- Swiss Minimalism aesthetic (Paper Grey, orange accents)
- Full-bleed background via `@page` CSS
- Pandoc + WeasyPrint PDF generation
- Blog-ready HTML output
- Technical reference and article templates

---

**Skill Status:** Active
**Maintainer:** LC Scheepers
**Last Updated:** 2025-12-09
**Brand:** ENTER Konsult (Swiss Minimalism)
