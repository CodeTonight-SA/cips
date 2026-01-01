---
name: generating-legal-documents
description: Multi-faceted legal operations - generate formal court-ready contracts (senior attorney level) OR simplified explanatory versions. Use when user references contracts or invokes /contract-formal or /contract-simplification.
status: Active
version: 2.0.0
triggers:
  - /contract-formal
  - /contract-simplification
  - "legal contract"
  - "service agreement"
---

# Legal Operations (Legal-Ops)

**Purpose:** Dual-track approach to legal document generation for technology services.

**Reference:** See [reference.md](./reference.md) for full contract templates, Latin terminology, and security protocols.

---

## Core Philosophy

**Professional legal work requires appropriate register for context.**

Two distinct approaches:

### Track 1: Formal Legal Contracts (`/contract-formal`)

| Aspect | Description |
|--------|-------------|
| **Audience** | Courts, legal professionals, formal execution |
| **Style** | Senior attorney/advocate/partner level |
| **Protection** | Airtight drafting with contra proferentem compliance |
| **Language** | Legal Latin where appropriate for precision |
| **Purpose** | Legally binding, court-ready documentation |

### Track 2: Simplified Documents (`/contract-simplification`)

| Aspect | Description |
|--------|-------------|
| **Audience** | Clients, stakeholders, non-legal professionals |
| **Style** | Plain British English with visual aids |
| **Protection** | Maintains legal accuracy whilst improving accessibility |
| **Language** | Contemporary, clear terminology |
| **Purpose** | Educational companion to formal contracts |

**CRITICAL:** These are NOT refactoring tools. They generate NEW documents fit for purpose.

---

## Trigger Conditions

### /contract-formal

Activates when user:
- Requests "formal contract", "legal agreement", "service provider agreement"
- Needs "court-ready" or "legally binding" documentation
- References "airtight protection" or "contra proferentem"

### /contract-simplification

Activates when user:
- Requests "simplified version", "plain language explanation"
- Needs to "explain contract terms" to stakeholders
- References "make this understandable"

---

## Contra Proferentem Rule Compliance

**Rule:** Ambiguous contract terms are construed AGAINST the drafter.

### Protection Strategy

1. **Eliminate ALL ambiguity** - every clause must have ONE interpretation only
2. **Define ALL terms** - no undefined concepts or vague references
3. **Specify ALL procedures** - concrete steps, timelines, methods
4. **Quantify ALL obligations** - measurable deliverables and standards
5. **Anticipate ALL scenarios** - address edge cases and contingencies

### Drafting Standards

| Good | Bad |
|------|-----|
| "Developer shall deliver functional MVP by 31 December 2025, 17:00 GMT" | "Developer will deliver the project soon" |
| "Payment of £10,000.00 within 7 business days" | "Reasonable payment in due course" |
| "Information marked 'CONFIDENTIAL'" | "Confidential stuff and similar things" |

---

## Essential Contract Structure (Track 1)

### 11 Required Sections

1. **Title & Parties** - Legal names, registration, addresses
2. **Recitals** - WHEREAS clauses, NOW THEREFORE
3. **Definitions & Interpretation** - All terms defined
4. **Scope of Services** - What, when, how
5. **Fees & Payment** - Amounts, schedule, late payment
6. **Intellectual Property** - Background IP, Deliverables IP, licences
7. **Confidentiality** - Obligations, exceptions, duration (5 years)
8. **Indemnification** - IP indemnity UNCAPPED
9. **Limitation of Liability** - Cap at 12 months fees (except IP)
10. **Term & Termination** - For convenience (90 days), for cause
11. **General Provisions** - Entire agreement, governing law, jurisdiction

### Critical Clauses

**IP Indemnification** (UNCAPPED):
- Developer indemnifies against third-party IP claims
- No cap on liability for IP infringement
- Options: procure rights, modify, or replace

**Governing Law**: England and Wales

**Jurisdiction**: Courts of England and Wales

---

## Simplified Document Structure (Track 2)

### Required Components

1. **Quick Summary** - 3-5 bullet points, key dates, key people
2. **Section-by-Section Explanation** - Plain language per section
3. **Key Definitions** - Business Day, IP, Force Majeure
4. **Important Notes** - This is a guide, formal controls, get legal advice

### Simplification Principles

- British English throughout
- Short sentences (< 20 words average)
- Active voice ("Developer will deliver")
- Visual aids: tables, checkboxes, bullet lists
- "What this means" sections after each formal section
- No legal jargon unless essential (then defined)

---

## Security Protocol

**CRITICAL:** Never commit sensitive contract data to repositories.

### Prohibited in Version Control

- Actual payment amounts → use `£[AMOUNT]`
- Bank account numbers → `[ACCOUNT_DETAILS]`
- Company registration numbers → `[COMPANY_NUMBER]`
- Personal addresses → `[ADDRESS]`
- Personal names → use roles: `[CLIENT_NAME]`

### Safe for Version Control

- Contract templates with placeholders
- Clause structure and legal language
- Standard definitions
- Boilerplate provisions

---

## Integration with Other Skills

| Skill | Usage |
|-------|-------|
| `/create-pr` | Commit contract templates |
| `/remind-yourself` | Search previous contract drafting |
| `/write-medium-article` | Write about legal drafting process |

---

## Anti-Patterns

### Don't

- ❌ Use Latin to sound impressive - use ONLY for precision
- ❌ Create simplified version as only document - need BOTH
- ❌ Ignore contra proferentem - every ambiguity hurts drafter
- ❌ Use outdated boilerplate - update for 2025 compliance
- ❌ Skip IP indemnification - technology = IP risk

### Do

- ✅ Draft with contra proferentem in mind
- ✅ Provide both formal and simplified versions
- ✅ Use Latin where it enhances precision
- ✅ Update boilerplate for current law
- ✅ Uncap IP indemnification

---

## Token Budget

| Component | Tokens |
|-----------|--------|
| Formal contract generation | ~8,000 |
| - Template structure | ~2,000 |
| - Definitions & clauses | ~3,000 |
| - Schedules & execution | ~2,000 |
| - Review & validation | ~1,000 |
| Simplified version | ~5,000 |
| - Section explanations | ~3,000 |
| - Visual aids | ~1,000 |
| - Q&A and notes | ~1,000 |
| **Total per dual-track** | **~13,000** |

---

## Reference Material

For detailed implementations, see [reference.md](./reference.md):

- Full Independent Service Provider Agreement template (11 sections)
- Legal Latin terminology table (12 terms)
- Simplified contract template
- Security scanning checklist
- Metrics tracking format
- Full changelog

---

**Skill Status:** ✅ Active (Multi-Faceted)
**Maintainer:** LC Scheepers
**Last Updated:** 2025-11-12
**UK Compliance:** 2025 standards

⛓⟿∞
