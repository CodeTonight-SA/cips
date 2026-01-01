---
name: generating-professional-pdfs
description: Generate professional PDF documents with configurable branding (Swiss Minimalism style). Use when user invokes /generate-pdf or requests document generation.
status: Active
version: 1.0.0
bespoke: true
triggers:
  - /generate-pdf
  - /configure-pdf
  - "generate PDF"
  - "create document"
---

# Professional PDF Generator

Generate branded PDF documents using your company's visual identity.

**Token Budget:** ~3,000 tokens per generation

**Reference:** See [reference.md](./reference.md) for CSS/HTML templates.

---

## Bespoke Configuration

On first use (or via `/configure-pdf`), CIPS prompts for brand settings.

### Brand Configuration Wizard

```text
Q1: "What's your company name?"
    → Free text input

Q2: "What's your brand colour scheme?"
    Options:
    - "Minimal (grayscale)" → #EAEAEA, #333333
    - "Professional blue" → #0066CC, #333333
    - "Warm orange" → #ea580c, #1a1a1a (Recommended)
    - "Custom colours" → Prompts for hex codes

Q3: "What typography style?"
    Options:
    - "Swiss Minimalism (system fonts)" (Recommended)
    - "Corporate (Arial + Times)"
    - "Modern (Inter + Georgia)"

Q4: "Include logo in header?"
    Options:
    - "Yes" → Prompts for logo path
    - "No"

Q5: "Footer text?"
    → Free text (e.g., "Confidential - {COMPANY_NAME}")
```

### Configuration Storage

Saves to: `~/.claude/config/pdf-branding.json`

```json
{
  "company_name": "Your Company",
  "colours": {
    "accent": "#ea580c",
    "text": "#1a1a1a",
    "background": "#EAEAEA",
    "border": "#d1d5db"
  },
  "typography": "swiss",
  "logo_path": null,
  "footer": "Confidential - Your Company"
}
```

---

## Design System

### Colour Palette (Defaults)

| Name | Hex | Usage |
|------|-----|-------|
| Background | `#EAEAEA` | Page background |
| Text | `#1a1a1a` | Body text |
| Accent | `#ea580c` | H1 underline, H3, links |
| Border | `#d1d5db` | Table borders, HR |

### Typography

| Element | Font | Size | Weight |
|---------|------|------|--------|
| Body | System stack | 11pt | 400 |
| H1 | System stack | 28pt | 800 |
| H2 | System stack | 16pt | 700 |
| H3 | System stack | 12pt | 700 |
| Code | SF Mono/Consolas | 9pt | 400 |

### Page Layout

- **Size:** A4 (210mm x 297mm)
- **Margins:** 2cm top/bottom, 2.5cm left/right
- **Header:** Document title (uppercase monospace)
- **Footer:** Page number + company name

---

## Generation Workflow

### Step 1: Check Configuration

```python
config_path = "~/.claude/config/pdf-branding.json"
if not exists(config_path):
    run_brand_wizard()  # AskUserQuestion flow
```

### Step 2: Generate HTML

1. Load CSS template from reference.md
2. Replace placeholders with config values
3. Insert content using structure template
4. Save as `.html` file

### Step 3: Generate PDF

```bash
weasyprint document.html document.pdf
```

**Alternative:**
```bash
pandoc document.html -o document.pdf --pdf-engine=weasyprint
```

### Dependencies (One-time)

```bash
brew install pandoc
pip3 install weasyprint
```

---

## Document Types

### Technical Reference

Structure:
- Overview with benefits table
- Component inventory
- Usage patterns with code
- Best practices
- Quick reference table

### Blog Article

Structure:
- Problem statement
- Solution with steps
- Results table
- Key takeaways

---

## Slash Commands

```bash
/generate-pdf "Title"              # Generate with current config
/generate-pdf "Title" --output ~/  # Specify output directory
/configure-pdf                     # Re-run brand wizard
```

---

## Implementation (AskUserQuestion)

When config missing, use this flow:

```typescript
// Q1: Company name
AskUserQuestion({
  questions: [{
    question: "What's your company name for PDF branding?",
    header: "Company",
    options: [
      { label: "Personal/Individual", description: "No company branding" },
      { label: "Enter company name", description: "Provide custom name" }
    ],
    multiSelect: false
  }]
});

// Q2: Colour scheme
AskUserQuestion({
  questions: [{
    question: "What colour scheme for your documents?",
    header: "Colours",
    options: [
      { label: "Warm orange", description: "#ea580c accent - Swiss Minimalism (Recommended)" },
      { label: "Professional blue", description: "#0066CC accent - Corporate feel" },
      { label: "Minimal grayscale", description: "#666666 accent - Clean and neutral" },
      { label: "Custom colours", description: "Provide your own hex codes" }
    ],
    multiSelect: false
  }]
});

// Q3: Typography
AskUserQuestion({
  questions: [{
    question: "What typography style?",
    header: "Fonts",
    options: [
      { label: "Swiss Minimalism", description: "System fonts, clean and modern (Recommended)" },
      { label: "Corporate", description: "Arial headings, Times body" },
      { label: "Modern", description: "Inter headings, Georgia body" }
    ],
    multiSelect: false
  }]
});
```

---

## Token Budget

| Step | Tokens |
|------|--------|
| Config check | ~100 |
| Template load | ~200 |
| Content generation | ~2,000 |
| HTML assembly | ~500 |
| PDF command | ~100 |
| **Total** | **~3,000** |

---

## Migration from enter-konsult-pdf

If migrating from the old skill:
1. Your existing documents remain unchanged
2. Run `/configure-pdf` to set up your branding
3. New documents use your config

---

**Skill Status:** Active
**Version:** 1.0.0
**Bespoke:** Yes (configurable branding)
