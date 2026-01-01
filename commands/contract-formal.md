---
name: contract-formal
description: Generate airtight, senior attorney-level legal contracts for technology services with contra proferentem protection, comprehensive IP indemnification, and professional boilerplate
aliases: [formal-contract, legal-contract]
---

# /contract-formal

Generate formal, court-ready legal contracts at senior attorney/advocate/partner level.

## Usage

```bash
/contract-formal [contract_type] [project_name]
```text

### Arguments:
- `contract_type` (optional): Type of agreement (default: "Independent Service Provider Agreement")
  - Options: "service-provider", "contractor", "consultancy", "software-development", "technology-services"
- `project_name` (optional): Project or client name for context

## What This Command Does

Executes the **legal-ops (Track 1: Formal)** skill workflow:

1. **Gather Requirements**
   - Contract type and scope
   - Parties involved (legal entities)
   - Service description and deliverables
   - Payment structure
   - Special provisions required

2. **Generate Comprehensive Contract**
   - **Title & Parties**: Full legal entity identification
   - **Recitals**: WHEREAS clauses establishing context
   - **Definitions**: Comprehensive terminology (including Legal Latin where appropriate)
   - **Scope of Services**: Detailed specifications with Schedules
   - **Payment Terms**: Precise fee structure with milestones
   - **IP Rights**: Ownership, assignment, licensing, retained rights
   - **Confidentiality**: 5-year post-termination protection
   - **Indemnification**: Uncapped IP indemnity + general indemnity
   - **Limitation of Liability**: Capped (except unlimited categories)
   - **Term & Termination**: For cause, convenience, force majeure
   - **Force Majeure**: Comprehensive event coverage
   - **Boilerplate**: Entire agreement, severability, jurisdiction, notices

3. **Contra Proferentem Compliance**
   - Eliminate ALL ambiguity
   - Define ALL terms
   - Specify ALL procedures
   - Quantify ALL obligations
   - No vague or open-ended language

4. **Security Scan**
   - Replace real amounts with placeholders
   - Replace identifying information with tokens
   - Generate TEMPLATE safe for version control

5. **Output**
   - Formal contract document (court-ready)
   - Separate Schedules (Statement of Work, Timeline, Fees)
   - Checklist for completion (fill placeholders)

## Contract Structure

### Core Sections (Always Included)

1. **Title & Parties**
2. **Recitals** (WHEREAS clauses)
3. **Definitions & Interpretation**
4. **Scope of Services**
5. **Fees & Payment**
6. **Intellectual Property Rights**
7. **Confidentiality**
8. **Indemnification** (including uncapped IP indemnity)
9. **Limitation of Liability**
10. **Term & Termination**
11. **Force Majeure**
12. **General Provisions** (Boilerplate)
13. **Execution** (Signatures)

### Schedules (Appendices)

- **Schedule A**: Statement of Work (detailed specifications)
- **Schedule B**: Project Timeline & Milestones
- **Schedule C**: Fees & Payment Schedule

## Legal Latin Terminology

Used for **precision**, not decoration:

| Term | Usage |
|------|-------|
| **Inter alia** | "Services include, inter alia, software development..." |
| **Mutatis mutandis** | "Clause 5 applies mutatis mutandis to subcontractors" |
| **Ab initio** | "Agreement void ab initio if obtained by fraud" |
| **Bona fide** | "Parties shall act bona fide in all dealings" |
| **Prima facie** | "Prima facie evidence of breach" |
| **Force majeure** | "Performance suspended during force majeure event" |
| **Per se** | "Delay not per se a material breach" |
| **Ipso facto** | "Breach ipso facto terminates rights" |

## Contra Proferentem Protection

**Rule:** Ambiguous terms are construed AGAINST the drafter.

### Protection Strategies

✅ **Specificity**
- ❌ "Developer will deliver soon"
- ✅ "Developer shall deliver by 31 December 2025, 17:00 GMT"

✅ **Quantification**
- ❌ "Reasonable payment"
- ✅ "£10,000.00 (ten thousand pounds sterling)"

✅ **Definition**
- ❌ "Confidential stuff"
- ✅ "Confidential Information means all technical, commercial, financial data marked 'CONFIDENTIAL'"

✅ **Procedure**
- ❌ "Disputes will be resolved"
- ✅ "Disputes shall be resolved through: (a) negotiation (14 days); (b) mediation (28 days); (c) arbitration (binding)"

## Key Features

### 1. IP Indemnification (Uncapped)

```markdown
The Service Provider shall indemnify the Client from and against any claims
arising from infringement of third-party Intellectual Property Rights by the
Deliverables. This IP Indemnity shall be UNCAPPED and NOT subject to the
limitation of liability in Clause [X].
```text

**Why uncapped:** Defence costs for IP claims often exceed general liability caps.

### 2. Limitation of Liability (Strategic)

```markdown
Total aggregate liability: Capped at total Fees paid/payable (12 months)

EXCEPT (unlimited):
- Death/personal injury from negligence
- Fraud/fraudulent misrepresentation
- IP indemnification obligations
- Liabilities that cannot be limited by law
```text

### 3. Comprehensive Definitions

Every term of art defined with precision:
- "Business Day"
- "Confidential Information"
- "Deliverables"
- "Force Majeure Event"
- "Intellectual Property Rights"
- "Services"

### 4. UK 2025 Compliance

- **Governing Law**: England and Wales
- **Jurisdiction**: Courts of England and Wales
- **VAT**: Fees exclusive of VAT (added at prevailing rate)
- **Late Payment**: Interest per Late Payment of Commercial Debts (Interest) Act 1998
- **Third Party Rights**: Contracts (Rights of Third Parties) Act 1999
- **Data Protection**: GDPR/UK GDPR compliance (if personal data involved)

## Examples

### Example 1: Generate Technology Services Agreement

```bash
/contract-formal service-provider "MVP Development Project"
```text

### Output:
- Full Independent Service Provider Agreement
- Comprehensive IP ownership and indemnification clauses
- Payment terms table with milestones
- 3 Schedules (SOW, Timeline, Fees)
- Execution-ready template

**Token usage:** ~7,800
**Time saved:** ~8 hours vs manual drafting

---

### Example 2: Software Development Contract

```bash
/contract-formal software-development "E-commerce Platform"
```text

### Output:
- Software Development Agreement
- Source code ownership and licensing provisions
- Acceptance criteria and testing procedures
- Warranty and support obligations
- Escrow arrangements (if requested)

---

### Example 3: Using Alias

```bash
/formal-contract consultancy "Strategic Technology Advisory"
```text

### Output:
- Consultancy Agreement
- Advisory services scope
- Confidentiality and non-compete provisions
- Success fees or performance bonuses (if applicable)

## Security Protocol

### Automatic Placeholder Replacement

### Command automatically replaces:
- Payment amounts → `£[AMOUNT]` or `£X,XXX`
- Account details → `[ACCOUNT_DETAILS]`
- Company numbers → `[COMPANY_NUMBER]`
- Addresses → `[ADDRESS]`
- Tax IDs → `[TAX_ID]`
- Personal names → `[CLIENT_NAME]`, `[DEVELOPER_NAME]`, `[SIGNATORY_NAME]`

### Safe for Version Control

Generated templates contain NO sensitive data:
- ✅ Commit template to repository
- ❌ DO NOT commit filled client version
- ✅ Add `*_FILLED.*` to `.gitignore`

### Completion Checklist

Command provides checklist for filling template:

```markdown
## Completion Checklist

Before execution, replace all placeholders:

- [ ] `[CLIENT_LEGAL_NAME]` → Full legal entity name
- [ ] `[CLIENT_COMPANY_NUMBER]` → Companies House registration
- [ ] `[CLIENT_ADDRESS]` → Registered office address
- [ ] `[SERVICE_PROVIDER_LEGAL_NAME]` → Full legal entity name
- [ ] `[SERVICE_PROVIDER_COMPANY_NUMBER]` → Companies House registration
- [ ] `[SERVICE_PROVIDER_ADDRESS]` → Registered office address
- [ ] `£[AMOUNT]` → Actual fee amounts
- [ ] `[DATE]` → Commencement and milestone dates
- [ ] `[ACCOUNT_DETAILS]` → Bank account for payments
- [ ] Schedule A: Complete Statement of Work
- [ ] Schedule B: Complete Project Timeline
- [ ] Schedule C: Complete Fees & Payment Schedule

**Security:** DO NOT commit filled version to public repositories.
Add to .gitignore: `*_client_*`, `*_FILLED.*`, `*_EXECUTED.*`
```text

## Output Format

### Primary Document

```markdown
# INDEPENDENT SERVICE PROVIDER AGREEMENT

**File:** `service_provider_agreement_[PROJECT]_TEMPLATE.md`
**Status:** TEMPLATE (placeholders - safe for version control)
**Generated:** [DATE]
**For:** [PROJECT_NAME]

[Full formal contract content with all sections]

---

**Document Version:** 1.0
**Jurisdiction:** England and Wales
**Template Status:** Requires completion per checklist
```text

### Schedule A: Statement of Work

```markdown
# SCHEDULE A - STATEMENT OF WORK

**Project:** [PROJECT_NAME]

## 1. Service Description
[Detailed technical specifications]

## 2. Deliverables
| Deliverable | Description | Acceptance Criteria |
|-------------|-------------|---------------------|
| [Item 1] | [Specification] | [How Client verifies] |

## 3. Technical Requirements
[Development standards, technologies, platforms]

## 4. Assumptions & Dependencies
[Prerequisites for successful delivery]
```text

### Schedule B: Project Timeline

```markdown
# SCHEDULE B - PROJECT TIMELINE

| Phase | Milestone | Deliverable | Due Date | Dependencies |
|-------|-----------|-------------|----------|--------------|
| 1 | Kickoff | Project plan | [DATE] | Contract execution |
| 2 | Design | Technical spec | [DATE] | Client approval |
| 3 | Development | Beta version | [DATE] | Design approval |
| 4 | Testing | Final acceptance | [DATE] | Beta approval |
```text

### Schedule C: Fees & Payment Schedule

```markdown
# SCHEDULE C - FEES & PAYMENT SCHEDULE

| Milestone | Amount (£) | Due Date | Payment Terms |
|-----------|------------|----------|---------------|
| Contract execution | £[AMOUNT] | Within 7 Business Days | Bank transfer |
| Milestone 1 | £[AMOUNT] | Upon acceptance | Within 14 Business Days of invoice |
| Milestone 2 | £[AMOUNT] | Upon acceptance | Within 14 Business Days of invoice |
| Final delivery | £[AMOUNT] | Upon acceptance | Within 14 Business Days of invoice |
| **TOTAL** | **£[TOTAL]** | | |

**Payment Method:** Bank transfer to [ACCOUNT_DETAILS]
**VAT:** All fees exclusive of VAT (charged at prevailing rate)
**Currency:** Pounds sterling (£ GBP)
```text

## Integration with Other Commands

### Generate Formal + Simplified Versions

```bash
/contract-formal service-provider "Platform MVP"
/contract-simplification "Platform MVP"
```

### Result:
- Formal contract (court-ready)
- Simplified explanation (client-facing)
- Both reference same project

### Create PR After Generating Template

```bash
/contract-formal consultancy "Technology Advisory"
/create-pr "Add technology consultancy agreement template"
```text

### Document Contract Drafting Process

```bash
/contract-formal software-development "SaaS Platform"
/write-medium-article "Professional Legal Contract Drafting with Claude Code"
```text

## Best Practices

### Do:
- ✅ Have qualified legal professional review before execution
- ✅ Customise template for specific project requirements
- ✅ Complete ALL schedules with detailed specifications
- ✅ Use version numbers (v1.0, v1.1) as contract evolves
- ✅ Keep formal and simplified versions synchronized
- ✅ Archive executed contracts securely (not in public repos)

### Don't:
- ❌ Execute template without legal review
- ❌ Commit filled versions with client data to repositories
- ❌ Remove essential protective clauses to "simplify"
- ❌ Use Latin terminology for decoration (only precision)
- ❌ Skip contra proferentem checks (avoid ambiguity)
- ❌ Cap IP indemnification (defeats purpose)

## Token Budget

**Typical generation:** ~7,800 tokens

### Breakdown:
- Requirements gathering: ~500
- Core contract sections: ~4,000
- Definitions & boilerplate: ~1,500
- Three schedules: ~1,200
- Checklist & validation: ~600

## Legal Disclaimer

**CRITICAL:** This command generates contract TEMPLATES, not legal advice.

- ✅ Templates provide solid starting point for professional drafting
- ❌ Templates DO NOT replace qualified legal counsel
- ✅ Always have contracts reviewed by solicitor/barrister before execution
- ❌ No warranty of fitness for particular purpose or jurisdiction
- ✅ Appropriate for UK (England & Wales) technology services contracts
- ❌ May require modification for other jurisdictions or industries

**Responsibility:** User assumes all risk and responsibility for contract usage.

## Related Commands

- `/contract-simplification` - Generate explanatory companion document
- `/create-pr` - Commit contract template to repository
- `/remind-yourself` - Search past contract drafting sessions

## Skill Reference

Full documentation: `~/.claude/skills/legal-ops/SKILL.md`

---

**Command Version:** 2.0
**Created:** 2025-11-12
**Maintainer:** LC Scheepers
**Skill:** legal-ops (Track 1: Formal)
**Jurisdiction:** England & Wales
**Compliance:** 2025 UK standards
