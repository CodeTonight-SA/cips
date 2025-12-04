---
name: contract-simplification
description: Generate simplified explanatory versions of formal contracts to help clients understand legal terms. Creates educational companion documents in plain British English with visual aids.
aliases: [simplify-contract, explain-contract, client-friendly]
---

# /contract-simplification

Generate simplified explanatory documents that help non-legal audiences understand formal contracts.

## Usage

```bash
/contract-simplification [formal_contract_path]
```text

### Arguments:
- `formal_contract_path` (optional): Path to formal contract to explain. If omitted, Claude will search current directory or prompt for selection.

## What This Command Does

Executes the **legal-ops (Track 2: Simplification)** skill workflow:

1. **Read Formal Contract**
   - Parse structure and sections
   - Identify complex legal terminology
   - Extract key obligations and rights

2. **Generate Simplified Companion**
   - **Quick Summary**: 3-5 bullet points of main purposes
   - **Key Dates**: Start, finish, review dates extracted
   - **Section-by-Section**: Plain language explanation of each formal section
   - **"What This Means"**: One-sentence summaries
   - **Visual Aids**: Tables, bullet lists, checkboxes
   - **Plain Definitions**: Legal terms explained simply
   - **Q&A Section**: Anticipated common questions

3. **Educational Approach**
   - British English throughout
   - Short sentences (< 20 words average)
   - Active voice
   - Conversational but professional tone
   - Examples where helpful
   - No legal jargon unless essential (then defined)

4. **Output**
   - Simplified explanation document
   - Clearly marked as educational companion
   - Notes that formal agreement prevails in conflicts
   - Reference to formal agreement maintained

## NOT Refactoring

**CRITICAL:** This command does NOT refactor or replace the formal contract.

### What it does:
- ✅ Creates PARALLEL explanatory document
- ✅ Helps clients understand formal terms
- ✅ Serves as educational companion
- ✅ Maintains reference to formal agreement

### What it does NOT do:
- ❌ Replace formal contract
- ❌ Create legally binding document
- ❌ Modify original formal agreement
- ❌ Reduce legal protection

**Use case:** Client receives BOTH documents:
1. **Formal Contract** → for signature and legal binding
2. **Simplified Explanation** → for understanding what they're signing

## Structure

### Quick Summary Section

```markdown
# [Contract Name] - Simplified Explanation

**Purpose:** This document explains the formal [Contract Type] in plain language.
It is provided for educational purposes only. The legally binding terms are
contained in the formal agreement.

**Note:** In case of any conflict between this simplified version and the formal
agreement, the formal agreement prevails.

---

## Quick Summary

### What this agreement does:
- [Developer/Provider] will build [specific deliverable]
- Client pays [total amount] in [number] instalments
- [Developer/Provider] transfers ownership of work to Client
- Both parties keep information confidential
- Agreement runs from [date] to [date]

### Key dates:
- Start: [DATE]
- First milestone: [DATE]
- Final delivery: [DATE]
- Review for next phase: [DATE]

### Key people:
- Service Provider: [NAME/COMPANY] (the developer/consultant)
- Client: [NAME/COMPANY] (paying for the work)
```text

### Section-by-Section Explanations

Each formal contract section gets:

1. **Plain heading**
2. **"What this means"** summary
3. **Key points** in bullet list or table
4. **"In simple terms"** one-liner

### Example

```markdown
### 6. Indemnification

### What this means:
If the developer's work causes legal problems (like using someone else's code
without permission), the developer pays for the legal costs and damages.

### Developer's responsibility covers:
- Using third-party code/designs without proper rights
- Poor quality work that causes losses
- Breaking promises made in this contract

### Limits on responsibility:
- Maximum payment: £X,XXX for most issues
- NO LIMIT for intellectual property problems (using others' work wrongly)
- Developer NOT responsible for: lost profits, missed business opportunities

**In simple terms:** Developer fixes problems they cause, with reasonable limits
except for copyright/patent issues.
```text

### Visual Aids

### Payment Terms Table:
```markdown
### 2. Payment

| When | Amount | For what |
|------|--------|----------|
| Contract signed | £5,000 | Start of work |
| 30 days in | £10,000 | Design completed |
| 60 days in | £10,000 | Development finished |
| Final acceptance | £5,000 | Everything working |
| **Total** | **£30,000** | |

**When payment is due:** Within 14 days of receiving invoice

### What happens if payment is late:
- Interest charged (Bank of England rate + 4%)
- Developer can pause work until paid
```text

### Deliverables Checklist:
```markdown
### 1. What You're Getting

### Deliverables:
- ✅ Functional website (by [DATE])
- ✅ Admin dashboard (by [DATE])
- ✅ User documentation (by [DATE])
- ✅ Technical handover (by [DATE])

### How you'll know it's done:
Each item tested against agreed checklist before acceptance.
```text

### Key Definitions (Plain Language)

```markdown
## Key Definitions

| Formal Term | What It Means in Plain English |
|-------------|-------------------------------|
| Business Day | Monday-Friday (excluding bank holidays) |
| Confidential Information | Sensitive business/technical info you shouldn't share |
| Deliverables | The actual work products you're paying for |
| Intellectual Property | Ideas, code, designs, creative work - who owns what |
| Force Majeure | Disasters/events completely out of anyone's control |
| Indemnification | One party agrees to pay for certain problems/costs |
| Limitation of Liability | Maximum amount someone has to pay if things go wrong |
| Acceptance Criteria | Checklist to confirm work is done properly |
```text

## Simplification Principles

### 1. British English

✅ "Organised", "realise", "colour"
❌ "Organized", "realize", "color"

### 2. Short Sentences

✅ "The developer will deliver the website by 31 December 2025. Payment is due within 14 days."
❌ "The developer, having completed all necessary development work and testing procedures, shall deliver the fully functional website to the client no later than 31 December 2025, whereupon payment shall become due and payable within a period of 14 days from the date of issuance of the relevant invoice."

### 3. Active Voice

✅ "Developer will build the app"
❌ "The app shall be built by the Developer"

✅ "Client pays £10,000 at each milestone"
❌ "£10,000 shall be paid by the Client upon achievement of each milestone"

### 4. Everyday Words

| ❌ Legal Term | ✅ Plain English |
|--------------|------------------|
| "Hereinafter referred to as" | "called" |
| "Pursuant to" | "under" or "according to" |
| "Notwithstanding" | "despite" or "even though" |
| "In the event that" | "if" |
| "Prior to" | "before" |
| "Subsequently" | "later" or "then" |
| "Terminate forthwith" | "end immediately" |
| "Remuneration" | "payment" or "fee" |

### 5. Explaining Latin Terms

When Latin terms appear in formal contract:

```markdown
**Force Majeure** (Latin for "superior force")
**What it means:** Events completely outside anyone's control, like:
- Natural disasters (earthquakes, floods)
- Pandemics
- Wars or terrorism
- Government shutdowns

**Why it matters:** If one of these happens, the affected party doesn't get
penalised for delays. They must notify the other party and try to minimise
impact.
```text

## Examples

### Example 1: Simplify Existing Formal Contract

```bash
/contract-simplification contracts/service_provider_agreement_ACME_TEMPLATE.md
```text

### Output:
```text
service_provider_agreement_ACME_SIMPLIFIED.md

Sections:
- Quick Summary (who, what, when, how much)
- Section-by-Section Explanations (9 sections)
- Visual aids (4 tables, 8 bullet lists)
- Key Definitions (12 terms explained)
- Q&A (6 common questions)
- Important Notes (formal agreement prevails)
```text

**Token usage:** ~4,200
**Time saved:** ~3 hours vs manual explanation

---

### Example 2: Simplify Contract in Current Directory

```bash
/contract-simplification
```text

### Claude searches and finds:
```text
Found potential contracts:
1. partnership_agreement_formal.md
2. service_contract_template.md

Select file to simplify: 1

Generating simplified explanation for partnership_agreement_formal.md...
```text

---

### Example 3: Using Alias

```bash
/explain-contract contracts/service_agreement_FORMAL.md
```text

### Output:
`contracts/service_agreement_SIMPLIFIED.md`

## Output Format

```markdown
# [Contract Name] - Simplified Explanation

**Purpose:** Educational companion to formal legal agreement

**For:** [CLIENT_NAME]

**Formal Agreement Reference:** [CONTRACT_FILE_NAME]

**Created:** [DATE]

**Important:** This is a guide only. The formal agreement is legally binding.
In case of conflict, the formal agreement prevails.

---

## Quick Summary

[3-5 bullet points of core purposes]

## Key Information

**Total cost:** £XX,XXX
**Duration:** [X months/weeks]
**Main deliverables:** [List]
**Key dates:** [Table]

---

## Section-by-Section Explanation

### 1. [Section Name]

### What this means:
[Plain language explanation]

### Key points:
- [Bullet point 1]
- [Bullet point 2]

**In simple terms:** [One sentence summary]

[Repeat for each section]

---

## Key Definitions (Plain Language)

[Table of terms with explanations]

---

## Common Questions

### Q: What happens if...?
A: [Plain answer referencing formal contract section]

### Q: Can I...?
A: [Plain answer with yes/no and explanation]

[6-8 anticipated questions]

---

## Important Reminders

⚠️ **This is a guide, not a legal document**
The formal [CONTRACT_NAME] contains the legally binding terms.

⚠️ **Get legal advice if unsure**
If you have questions about your rights or obligations, consult a solicitor.

⚠️ **The formal agreement controls**
If this guide and the formal agreement differ, the formal agreement wins.

⚠️ **Keep both documents**
You need BOTH:
- Formal agreement (for legal protection and signature)
- This simplified guide (for understanding)

---

**Document Type:** Educational Companion
**Status:** For reference only - NOT legally binding
**Formal Agreement:** [FILE_NAME] (dated [DATE])
**Simplified Version:** v1.0 (dated [DATE])
```text

## Integration with Other Commands

### Generate Both Formal + Simplified

```bash
/contract-formal service-provider "Client XYZ Project"
/contract-simplification service_provider_agreement_ClientXYZ_TEMPLATE.md
```text

### Result:
- `service_provider_agreement_ClientXYZ_TEMPLATE.md` (formal, court-ready)
- `service_provider_agreement_ClientXYZ_SIMPLIFIED.md` (explanatory, client-facing)

### Provide Both to Client

### Email template:
```text
Hi [Client],

Attached are two documents for the [Project] agreement:

1. **[CONTRACT]_TEMPLATE.md** - This is the formal legal contract for your
   solicitor to review and for both parties to sign. It contains all legally
   binding terms.

2. **[CONTRACT]_SIMPLIFIED.md** - This is a plain-language explanation to help
   you understand what you're signing. It's for educational purposes only.

Please:
- Have your legal counsel review the formal contract
- Read the simplified version to understand the key terms
- Reach out with any questions before signing

The formal contract is what's legally binding. The simplified version just helps
explain it in everyday language.

Best regards,
[Name]
```text

### Document Legal-Ops Workflow

```bash
/contract-formal consultancy "Strategic Advisory"
/contract-simplification consultancy_agreement_TEMPLATE.md
/write-medium-article "Dual-Track Legal Documentation: Formal + Simplified Contracts"
```text

## Best Practices

### Do:
- ✅ Provide BOTH formal and simplified versions to clients
- ✅ Clearly mark simplified version as "educational only"
- ✅ Reference formal agreement throughout simplified version
- ✅ Use visual aids (tables, bullet lists, checkboxes)
- ✅ Anticipate client questions in Q&A section
- ✅ Keep simplified version synchronized with formal contract

### Don't:
- ❌ Present simplified version as legally binding
- ❌ Let clients sign simplified version instead of formal
- ❌ Oversimplify to point of inaccuracy
- ❌ Include conflicting information vs formal contract
- ❌ Skip important protections to make it "simpler"
- ❌ Use simplified version for court proceedings

## Token Budget

**Typical generation:** ~4,200 tokens

### Breakdown:
- Read and analyse formal contract: ~1,000
- Generate quick summary: ~300
- Section-by-section explanations: ~2,000
- Visual aids and tables: ~400
- Key definitions: ~300
- Q&A section: ~200

## Use Cases

### 1. Client Onboarding

**Scenario:** New client unfamiliar with legal contracts

### Solution:
- Generate formal contract (legal protection)
- Generate simplified version (client confidence)
- Client understands what they're signing
- Reduces "contract shock" and disputes

### 2. Stakeholder Buy-In

**Scenario:** Multiple stakeholders need to approve contract

### Solution:
- Simplified version helps non-legal stakeholders understand terms
- Faster approval process
- Fewer clarification emails

### 3. International Clients

**Scenario:** Client's first language not English

### Solution:
- Simplified British English version easier to understand
- Can be translated more accurately than legal terminology
- Formal contract remains in legal English for UK jurisdiction

### 4. Training New Team Members

**Scenario:** Junior staff need to understand standard contracts

### Solution:
- Simplified versions serve as training materials
- Explains why certain clauses exist
- Builds legal literacy without law degree

## Security Protocol

### Safe for Sharing

Simplified versions can contain:
- ✅ General structure and explanations
- ✅ Placeholder amounts and dates
- ✅ Educational examples
- ✅ Section summaries

### Maintain Confidentiality

If formal contract contains sensitive info:
- ❌ Don't repeat specific confidential business details
- ✅ Use generic descriptions: "the technical specifications"
- ✅ Maintain placeholders for amounts: £X,XXX
- ✅ Remove client-identifiable information if creating template

## Legal Disclaimer

**CRITICAL:** Simplified explanations are educational, not legal advice.

- ✅ Helps clients understand formal contracts
- ❌ Does NOT replace formal contract
- ✅ Improves accessibility and transparency
- ❌ Not sufficient for legal enforcement
- ✅ Clients should still seek independent legal counsel
- ❌ No warranty that simplified version captures all nuances

### Hierarchy:
1. **Formal contract** = legally binding
2. **Simplified version** = educational guide only

## Related Commands

- `/contract-formal` - Generate formal contract first
- `/create-pr` - Commit templates to repository
- `/remind-yourself` - Search past contract simplification sessions

## Skill Reference

Full documentation: `~/.claude/skills/legal-ops/SKILL.md`

---

**Command Version:** 2.0
**Created:** 2025-11-12
**Maintainer:** LC Scheepers
**Skill:** legal-ops (Track 2: Simplification)
**Language:** British English
**Purpose:** Educational companion documents
