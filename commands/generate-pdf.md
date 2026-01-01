---
name: generate-pdf
description: Generate professional PDF documents in ENTER Konsult brand style (Swiss Minimalism). Outputs HTML + PDF.
---

# /generate-pdf

Generate professional technical documents in ENTER Konsult brand style.

## Usage

```bash
/generate-pdf "<Document Title>"
/generate-pdf "<Title>" --output ~/Documents/
/generate-pdf "<Title>" --type reference|article|guide
```

## Process

1. Load `enter-konsult-pdf` skill from `~/.claude/skills/enter-konsult-pdf/SKILL.md`
2. Generate content based on user request or provided markdown
3. Create self-contained HTML with embedded CSS
4. Generate PDF via `pandoc --pdf-engine=weasyprint`
5. Return paths to both files

## Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| title | Yes | - | Document title |
| --output | No | Current dir | Output directory |
| --type | No | reference | Template: reference, article, guide |

## Dependencies

```bash
brew install pandoc
pip3 install weasyprint
```

## Output

- `{slug}.html` - Blog-ready, self-contained
- `{slug}.pdf` - Print-ready, A4 format

## Brand

- Background: Paper Grey (#EAEAEA)
- Accent: Orange (#ea580c)
- Footer: "ENTER Konsult | Month Year"
