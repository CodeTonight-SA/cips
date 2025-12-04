#!/bin/bash
# /reverse-engineer-api - Systematically reverse engineer authenticated web API
# Usage: /reverse-engineer-api --platform <name> [--auth-type session|bearer|basic]

cat << 'PROMPT'
# API Reverse Engineering Protocol

You are now in **API Reverse Engineering Mode**.

## Legal & Ethical Gate ⚖️

**CRITICAL**: Before proceeding, confirm with user:

1. ✅ Do you have legitimate account credentials for this platform?
2. ✅ Are you extracting your own data (not scraping others)?
3. ✅ Have you reviewed the platform's Terms of Service?

If ANY answer is "no" or uncertain: **STOP** and explain legal risks.

---

## 7-Step Discovery Protocol

Follow these steps systematically. Use templates from `~/.claude/skills/api-reverse-engineering/templates/` to generate code efficiently.

### Step 1: Platform Information
Ask user:
- Platform name (for file naming)
- Base URL (e.g., https://portal.example.com)
- Estimated entity count (how many data types to export?)

### Step 2: Auth Mechanism Detection
Ask user to paste login request from DevTools Network tab:
- Method (POST/GET)
- URL
- Request body
- Response headers (look for Set-Cookie, Authorization)

Identify pattern:
- **Session-based**: Set-Cookie: PHPSESSID=... → Use auth_session.py.tpl
- **Bearer token**: Authorization: Bearer xxx → Use auth_bearer.py.tpl
- **Basic auth**: Authorization: Basic xxx → Use auth_basic.py.tpl

### Step 3: Endpoint Pattern Analysis
Ask user to paste export/data request:
- URL (e.g., /includes/exportdata.php)
- Method
- Request body (form data or JSON)
- Response headers (Content-Disposition, Content-Type)

Detect pattern:
- **Single endpoint, multiple params**: Form keys discriminate entities (use client_form.py.tpl)
- **RESTful**: /api/v1/users, /api/v1/jobs (use client_rest.py.tpl)
- **GraphQL**: Single /graphql endpoint (use client_graphql.py.tpl)

### Step 4: Entity Mapping (if multi-entity)
For form-based APIs:
Ask: "How many different data types/entities can you export?"
For each: "Paste the POST body when clicking that export button."

Build config/entity_mapping.json:
```json
{
  "entities": [
    {"name": "Users", "form_key": "userexport", "filename": "Users.csv"},
    {"name": "Orders", "form_key": "orderexport", "filename": "Orders.csv"}
  ]
}
```

### Step 5: Response Validation
Extract from first download:
- Get column names (CSV header or JSON keys)
- Detect encoding (UTF-8, Latin1, etc.)
- Count rows for baseline threshold

Create config/expected_schemas.json with key columns and min_rows.

### Step 6: Modular Client Generation
Use templates to create:

1. **lib/{platform}_auth.py** - Authentication only (SRP)
2. **lib/{platform}_client.py** - API calls only (SRP)
3. **scripts/download_{platform}.py** - Orchestration (auth + download + notify)
4. **scripts/validate_{platform}_api.py** - Daily health check (schema + row count)

Replace template variables:
- {{PLATFORM}} → Platform name
- {{BASE_URL}} → API base URL
- {{AUTH_TYPE}} → session/bearer/basic
- {{COMPANY_ID}} → If multi-tenant
- {{LOGIN_ENDPOINT}} → Login path
- {{SESSION_COOKIE_NAME}} → Cookie name

### Step 7: Risk Documentation
Generate confidential assessment using assessment.md.tpl.

Fill in:
- {{CLIENT_NAME}} - Business name
- {{VENDOR_EXPLANATION}} - What vendor told client
- {{TECHNICAL_FINDINGS}} - What you discovered (API design issues)
- {{SIMPLE_ANALOGY}} - ELI5 explanation
- {{MITIGATION_STRATEGY}} - How automated system helps
- {{ROI_CALCULATION}} - Cost savings vs vendor

---

## Reference Implementation

See NannyLogic example in this project:
- Auth: lib/nannylogic_auth.py (session-based, PHPSESSID)
- Client: lib/nannylogic_downloader.py (form POST, entity-specific keys)
- Mapping: config/entity_mapping.json (12 entities)
- Validation: scripts/validate_export_api.py
- Assessment: docs/CONFIDENTIAL_TECHNICAL_ASSESSMENT.md

**When in doubt, copy that structure and adapt to new platform.**

---

## Token Efficiency Rules

✅ Use templates - Don't regenerate boilerplate
✅ Reference existing code - "See lib/nannylogic_auth.py"
✅ Interactive prompts - Guided questions, not walls of text
✅ Batch operations - Create all files in one TodoWrite cycle

❌ Don't explain patterns repeatedly
❌ Don't regenerate same structure
❌ Don't write long documentation

---

## Success Criteria

- Generated client authenticates on first try
- Downloads data without errors
- Validation system detects schema correctly
- Risk assessment provides actionable recommendations
- Total token usage <15k for complete implementation

---

Begin by asking the 3 legal/ethical gate questions.
PROMPT
