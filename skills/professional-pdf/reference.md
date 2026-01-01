# Professional PDF - Reference Material

**Parent:** [SKILL.md](./SKILL.md)

---

## Configuration Placeholders

Replace these placeholders with values from `~/.claude/config/pdf-branding.json`:

| Placeholder | Config Key | Default |
|-------------|-----------|---------|
| `{{COMPANY_NAME}}` | company_name | "Your Company" |
| `{{ACCENT_COLOUR}}` | colours.accent | #ea580c |
| `{{TEXT_COLOUR}}` | colours.text | #1a1a1a |
| `{{BG_COLOUR}}` | colours.background | #EAEAEA |
| `{{BORDER_COLOUR}}` | colours.border | #d1d5db |
| `{{FOOTER_TEXT}}` | footer | "{{COMPANY_NAME}}" |

---

## Complete CSS Template

```css
@page {
  size: A4;
  margin: 2cm 2.5cm;
  background-color: {{BG_COLOUR}};
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
    content: "{{FOOTER_TEXT}} | MONTH_YEAR_PLACEHOLDER";
    font-family: "SF Mono", "Consolas", monospace;
    font-size: 8pt;
    color: #666;
    letter-spacing: 0.1em;
  }
}

* { box-sizing: border-box; }

html, body {
  background-color: {{BG_COLOUR}};
  min-height: 100%;
  margin: 0;
  padding: 0;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  font-size: 11pt;
  line-height: 1.6;
  color: {{TEXT_COLOUR}};
  max-width: 100%;
}

h1 {
  font-size: 28pt;
  font-weight: 800;
  letter-spacing: -0.03em;
  line-height: 1.1;
  margin: 0 0 0.5em 0;
  padding-bottom: 0.3em;
  border-bottom: 3px solid {{ACCENT_COLOUR}};
  color: #000;
}

h2 {
  font-size: 16pt;
  font-weight: 700;
  letter-spacing: -0.02em;
  margin: 2em 0 0.5em 0;
  padding-bottom: 0.3em;
  border-bottom: 1px solid {{BORDER_COLOUR}};
  color: #000;
}

h3 {
  font-size: 12pt;
  font-weight: 700;
  margin: 1.5em 0 0.5em 0;
  color: {{ACCENT_COLOUR}};
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
  border-top: 1px solid {{BORDER_COLOUR}};
  margin: 2em 0;
}

code {
  font-family: "SF Mono", "Consolas", "Monaco", monospace;
  font-size: 9pt;
  background-color: #f3f4f6;
  padding: 0.15em 0.4em;
  border-radius: 3px;
  color: {{ACCENT_COLOUR}};
}

pre {
  font-family: "SF Mono", "Consolas", "Monaco", monospace;
  font-size: 9pt;
  background-color: {{TEXT_COLOUR}};
  color: #f3f4f6;
  padding: 1em 1.2em;
  border-radius: 0;
  border-left: 3px solid {{ACCENT_COLOUR}};
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
  background-color: {{TEXT_COLOUR}};
  color: #fff;
  border: none;
}

td {
  padding: 0.8em 1em;
  border-bottom: 1px solid {{BORDER_COLOUR}};
  vertical-align: top;
  background-color: #fff;
}

tr:last-child td {
  border-bottom: 2px solid {{TEXT_COLOUR}};
}

ul, ol {
  margin: 0.5em 0 1em 0;
  padding-left: 1.5em;
}

li { margin: 0.3em 0; }

blockquote {
  margin: 1em 0;
  padding: 0.5em 1em;
  border-left: 3px solid {{ACCENT_COLOUR}};
  background-color: #fff;
  font-style: italic;
  color: #666;
  page-break-inside: avoid;
}

a {
  color: {{ACCENT_COLOUR}};
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
    /* INSERT CSS WITH PLACEHOLDERS REPLACED */
  </style>
</head>
<body>
  <div class="title-block">
    <h1>DOCUMENT_TITLE</h1>
    <p class="subtitle">DOCUMENT_SUBTITLE</p>
    <p class="meta"><strong>Document Type</strong> Version X.X | MONTH YEAR</p>
  </div>

  <!-- CONTENT SECTIONS -->

</body>
</html>
```

---

## Content Structure Templates

### Technical Reference

```markdown
# [Product/Feature]: [Topic]

**Technical Reference** Version X.X | Month Year

---

## Overview

[2-3 paragraphs explaining what this is and why it matters]

### Key Benefits

| BENEFIT | DESCRIPTION |
|---------|-------------|
| Benefit 1 | Description |
| Benefit 2 | Description |

---

## Components

### [Category]

#### ComponentName

[Description]

```language
// Code example
```

---

## Best Practices

1. **Practice 1** - Explanation
2. **Practice 2** - Explanation

---

**Document Title** | {{COMPANY_NAME}} | Month Year
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

[Introduce approach]

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

**{{COMPANY_NAME}}** | Month Year
```

---

## Generation Workflow

### Step 1: Load Config

```python
import json
from pathlib import Path

config_path = Path.home() / ".claude/config/pdf-branding.json"
if config_path.exists():
    config = json.loads(config_path.read_text())
else:
    config = {
        "company_name": "Your Company",
        "colours": {
            "accent": "#ea580c",
            "text": "#1a1a1a",
            "background": "#EAEAEA",
            "border": "#d1d5db"
        },
        "typography": "swiss",
        "logo_path": None,
        "footer": "Your Company"
    }
```

### Step 2: Replace Placeholders

```python
css = css_template.replace("{{COMPANY_NAME}}", config["company_name"])
css = css.replace("{{ACCENT_COLOUR}}", config["colours"]["accent"])
css = css.replace("{{TEXT_COLOUR}}", config["colours"]["text"])
css = css.replace("{{BG_COLOUR}}", config["colours"]["background"])
css = css.replace("{{BORDER_COLOUR}}", config["colours"]["border"])
css = css.replace("{{FOOTER_TEXT}}", config["footer"])
```

### Step 3: Generate PDF

```bash
weasyprint document.html document.pdf
```

---

## Default Colour Schemes

### Warm Orange (Recommended)

```json
{
  "accent": "#ea580c",
  "text": "#1a1a1a",
  "background": "#EAEAEA",
  "border": "#d1d5db"
}
```

### Professional Blue

```json
{
  "accent": "#0066CC",
  "text": "#333333",
  "background": "#F5F5F5",
  "border": "#CCCCCC"
}
```

### Minimal Grayscale

```json
{
  "accent": "#666666",
  "text": "#333333",
  "background": "#FFFFFF",
  "border": "#DDDDDD"
}
```

---

## Changelog

**v1.0** (2025-12-30) - Initial creation
- Bespoke configuration system
- Configurable company branding
- Multiple colour schemes
- Placeholder-based CSS templates
