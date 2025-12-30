# ENTER Konsult PDF - Reference Material

**Parent:** [SKILL.md](./SKILL.md)

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

* { box-sizing: border-box; }

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

p { margin: 0 0 1em 0; }
strong { font-weight: 700; color: #000; }
em { font-style: italic; color: #666; }

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

li { margin: 0.3em 0; }

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

a:hover { text-decoration: underline; }

.title-block { margin-bottom: 2em; }

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

.page-break { page-break-after: always; }
.no-break { page-break-inside: avoid; }
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

---

## Best Practices

1. **Practice 1** - Explanation
2. **Practice 2** - Explanation

---

## Quick Reference

| COMPONENT | IMPORT | PRIMARY USE |
|-----------|--------|-------------|
| Component1 | @/path | Use case |

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

---

## Results

| METRIC | BEFORE | AFTER |
|--------|--------|-------|
| Metric 1 | X | Y |

---

## Key Takeaways

1. **Takeaway 1**
2. **Takeaway 2**

---

**ENTER Konsult** | Month Year
```

---

## Generation Workflow

### Step 1: Generate HTML

1. Replace `DOCUMENT_TITLE_PLACEHOLDER` in CSS `@page` with actual title (uppercase)
2. Replace `MONTH_YEAR_PLACEHOLDER` with current month/year
3. Replace template placeholders with content
4. Save as `.html` file

### Step 2: Generate PDF

```bash
pandoc document.html -o document.pdf --pdf-engine=weasyprint
```

**Alternative:**
```bash
weasyprint document.html document.pdf
```

### Dependencies (One-time setup)

```bash
brew install pandoc
pip3 install weasyprint
```

---

## Changelog

**v1.0** (2025-12-09) - Initial creation
- Complete CSS design system from ENTER Konsult brand
- Swiss Minimalism aesthetic (Paper Grey, orange accents)
- Full-bleed background via `@page` CSS
- Pandoc + WeasyPrint PDF generation
- Blog-ready HTML output
- Technical reference and article templates
