---
name: legal-ops
description: Multi-faceted legal operations - generate formal court-ready contracts (senior attorney level) OR simplified explanatory versions. Extends Claude Code beyond coding to professional legal document generation.
commands: [/contract-formal, /contract-simplification]
---

# Legal Operations (Legal-Ops) - Multi-Faceted Skill

**Purpose:** Dual-track approach to legal document generation for technology services, serving different audiences and purposes with appropriate formality levels.

**Activation:** When user references contracts, legal agreements, service provider terms, or explicitly invokes `/contract-formal` or `/contract-simplification`.

---

## Core Philosophy

**Professional legal work requires appropriate register for context.**

Two distinct approaches:

### Track 1: Formal Legal Contracts (`/contract-formal`)

**Audience:** Courts, legal professionals, formal execution
**Style:** Senior attorney/advocate/partner level
**Protection:** Airtight drafting with contra proferentem rule compliance
**Language:** Legal Latin where appropriate for precision
**Purpose:** Legally binding, court-ready documentation

### Track 2: Simplified Explanatory Documents (`/contract-simplification`)

**Audience:** Clients, stakeholders, non-legal professionals
**Style:** Plain British English with visual aids
**Protection:** Maintains legal accuracy whilst improving accessibility
**Language:** Contemporary, clear terminology
**Purpose:** Educational companion to formal contracts

**CRITICAL:** These are NOT refactoring tools. They generate NEW documents fit for purpose.

---

## Track 1: /contract-formal

### Purpose

Generate comprehensive, airtight legal contracts at senior attorney/advocate/partner level for technology services, with particular focus on Independent Service Provider Agreements.

### Trigger Conditions

Activates when user:

- Requests "formal contract", "legal agreement", "service provider agreement"
- Needs "court-ready" or "legally binding" documentation
- Explicitly invokes `/contract-formal`
- References "Independent Service Provider", "contractor agreement", "technology services"
- Requires "airtight protection" or mentions "contra proferentem"

### Contra Proferentem Rule Compliance

**Rule:** Ambiguous contract terms are construed AGAINST the drafter.

### Protection Strategy:

1. **Eliminate ALL ambiguity** - every clause must have ONE interpretation only
2. **Define ALL terms** - no undefined concepts or vague references
3. **Specify ALL procedures** - concrete steps, timelines, methods
4. **Quantify ALL obligations** - measurable deliverables and standards
5. **Anticipate ALL scenarios** - address edge cases and contingencies

### Drafting Standards:

- ✅ "Developer shall deliver functional MVP by 31 December 2025, 17:00 GMT"
- ❌ "Developer will deliver the project soon"

- ✅ "Payment of £10,000.00 (ten thousand pounds sterling) within 7 business days"
- ❌ "Reasonable payment in due course"

- ✅ "Confidential Information means all technical, commercial, financial data marked 'CONFIDENTIAL'"
- ❌ "Confidential stuff and similar things"

### Essential Contract Structure

#### 1. Title & Parties

```markdown
# [TYPE] AGREEMENT

**This Agreement** is made on [DATE]

### BETWEEN

(1) [PARTY A LEGAL NAME], a [company/individual] registered in [jurisdiction]
    under company number [NUMBER] whose registered office is at [ADDRESS]
    ("**Service Provider**" or "**Developer**"); and

(2) [PARTY B LEGAL NAME], a [company/individual] registered in [jurisdiction]
    under company number [NUMBER] whose registered office is at [ADDRESS]
    ("**Client**" or "**Company**").

(each a "**Party**" and together the "**Parties**")
```text

#### 2. Recitals (WHEREAS Clauses)

```markdown
### WHEREAS

(A) The Service Provider is engaged in the business of [technology services description]
    and possesses expertise in [specific technical domains];

(B) The Client desires to engage the Service Provider to [specific purpose/project];

(C) The Service Provider has agreed to provide such services upon the terms and
    conditions hereinafter set forth;

**NOW, THEREFORE**, in consideration of the mutual covenants and agreements
hereinafter set forth and for other good and valuable consideration, the receipt
and sufficiency of which are hereby acknowledged, the Parties agree as follows:
```text

#### 3. Definitions & Interpretation

```markdown
## 1. DEFINITIONS AND INTERPRETATION

### 1.1 Definitions

In this Agreement, unless the context otherwise requires, the following terms
shall have the meanings set forth below:

**"Acceptance"** means the Client's written approval that the Deliverables
conform to the Acceptance Criteria;

**"Acceptance Criteria"** means the specifications set forth in Schedule A
against which Deliverables shall be tested;

**"Business Day"** means any day other than Saturday, Sunday or public holiday
in England and Wales;

**"Commencement Date"** means [DATE] or such other date as the Parties may
agree in writing;

**"Confidential Information"** means all information (whether written, oral,
visual or electronic) disclosed by or on behalf of one Party to the other,
including but not limited to:
    (a) technical data, trade secrets, know-how, research, product plans;
    (b) business operations, financial information, customer lists;
    (c) any information marked "CONFIDENTIAL" or communicated as confidential;

**"Deliverables"** means the work product described in Schedule A to be
delivered by the Service Provider to the Client;

**"Force Majeure Event"** means any event or circumstance beyond a Party's
reasonable control, including but not limited to acts of God, war, terrorism,
epidemic, pandemic, government restrictions, labour disputes, or failure of
telecommunications or internet infrastructure;

**"Intellectual Property Rights"** or "**IPR**" means all patents, rights to
inventions, utility models, copyright and related rights, trademarks, service
marks, trade, business and domain names, rights in trade dress or get-up, rights
in goodwill or to sue for passing off, unfair competition rights, rights in
designs, rights in computer software, database rights, topography rights, moral
rights, rights in confidential information (including know-how and trade secrets)
and any other intellectual property rights, in each case whether registered or
unregistered and including all applications for and renewals or extensions of
such rights, and all similar or equivalent rights or forms of protection in any
part of the world;

**"Services"** means the services to be provided by the Service Provider as
described in Schedule A;

### 1.2 Interpretation

In this Agreement, unless the context otherwise requires:

(a) references to Clauses and Schedules are to clauses of and schedules to
    this Agreement;
(b) headings are for convenience only and shall not affect interpretation;
(c) references to any statute or statutory provision include any modification,
    amendment, or re-enactment thereof;
(d) words importing the singular include the plural and vice versa;
(e) references to "writing" or "written" include email;
(f) the words "include", "includes" and "including" shall be deemed to be
    followed by the phrase "without limitation";
(g) references to "£" or "pounds" are to pounds sterling.
```text

#### 4. Scope of Services

```markdown
## 2. SCOPE OF SERVICES

### 2.1 Services to be Provided

The Service Provider shall provide the Services to the Client in accordance with:

(a) the specifications set forth in **Schedule A** (Statement of Work);
(b) the timelines and milestones set forth in **Schedule B** (Project Timeline);
(c) the standards of a reasonably competent service provider experienced in
    providing services similar to the Services;
(d) all applicable laws, regulations, and industry standards.

### 2.2 Deliverables

The Service Provider shall deliver the Deliverables to the Client by the dates
specified in Schedule B, each Deliverable to be subject to the Acceptance
Criteria defined in Schedule A.

### 2.3 Service Provider Obligations

The Service Provider warrants and undertakes that:

(a) it possesses the necessary skills, experience, and resources to perform
    the Services;
(b) the Services shall be performed with reasonable skill and care;
(c) the Deliverables shall be of satisfactory quality and fit for purpose;
(d) it shall comply with all applicable laws and regulations;
(e) it shall not, in providing the Services, infringe any third party
    Intellectual Property Rights.
```text

#### 5. Payment Terms

```markdown
## 3. FEES AND PAYMENT

### 3.1 Fees

In consideration for the Services, the Client shall pay the Service Provider
the fees set out in **Schedule C** (Fees and Payment Schedule).

### 3.2 Payment Schedule

| Milestone | Fee (£) | Due Date | Payment Terms |
|-----------|---------|----------|---------------|
| Contract execution | £[AMOUNT] | Within 7 Business Days of execution | Bank transfer |
| [Milestone 1] | £[AMOUNT] | Upon acceptance of Deliverable 1 | Within 14 Business Days of invoice |
| [Milestone 2] | £[AMOUNT] | Upon acceptance of Deliverable 2 | Within 14 Business Days of invoice |
| Final delivery | £[AMOUNT] | Upon final Acceptance | Within 14 Business Days of invoice |
| **TOTAL** | **£[TOTAL]** | | |

### 3.3 Invoicing

(a) The Service Provider shall submit invoices to the Client following completion
    of each Milestone;
(b) Each invoice shall contain sufficient detail to enable the Client to verify
    the Services rendered;
(c) All fees are exclusive of Value Added Tax (VAT), which shall be added at
    the prevailing rate.

### 3.4 Late Payment

If the Client fails to pay any undisputed invoice within the specified time,
the Service Provider shall be entitled to:

(a) charge interest on the overdue amount at the rate of 4% per annum above
    the Bank of England base rate from time to time pursuant to the Late
    Payment of Commercial Debts (Interest) Act 1998; and
(b) suspend performance of Services until payment is received.

### 3.5 Expenses

Unless otherwise agreed in writing, all expenses reasonably incurred by the
Service Provider in connection with the Services (including travel, accommodation,
and materials) shall be reimbursed by the Client upon presentation of appropriate
receipts.
```text

#### 6. Intellectual Property Rights

```markdown
## 4. INTELLECTUAL PROPERTY RIGHTS

### 4.1 Background IP

Each Party shall retain all right, title, and interest in and to its Background
IP (being Intellectual Property Rights owned by or licensed to a Party prior to
the Commencement Date or developed independently of this Agreement).

### 4.2 IP in Deliverables

Subject to Clause 4.3 and full payment of all Fees:

(a) All Intellectual Property Rights in the Deliverables created by the Service
    Provider specifically for the Client pursuant to this Agreement shall, upon
    creation, vest in and belong absolutely to the Client;
(b) The Service Provider hereby assigns (by way of present assignment of future
    rights) to the Client, with full title guarantee, all such Intellectual
    Property Rights;
(c) The Service Provider shall execute all documents and do all things necessary
    to give effect to such assignment.

### 4.3 Service Provider Retained IP

Notwithstanding Clause 4.2, the Service Provider retains all Intellectual Property
Rights in:

(a) pre-existing tools, libraries, frameworks, or methodologies owned by the
    Service Provider ("**Service Provider Tools**");
(b) general skills, knowledge, or experience acquired during performance of
    the Services.

The Client is hereby granted a perpetual, irrevocable, worldwide, non-exclusive,
royalty-free licence to use the Service Provider Tools to the extent incorporated
into the Deliverables, solely for the purpose of using the Deliverables.

### 4.4 Third-Party IP

(a) The Service Provider warrants that it has obtained all necessary licences
    for any third-party Intellectual Property Rights incorporated into the
    Deliverables;
(b) The Service Provider shall indemnify the Client against any third-party
    claims arising from infringement of Intellectual Property Rights (see Clause 8).

### 4.5 Moral Rights

The Service Provider hereby irrevocably and unconditionally waives all moral
rights under the Copyright, Designs and Patents Act 1988 (and any similar rights
in any jurisdiction) in relation to the Deliverables, to the extent permitted
by law.
```text

#### 7. Confidentiality

```markdown
## 5. CONFIDENTIALITY

### 5.1 Confidentiality Obligations

Each Party (the "**Receiving Party**") shall:

(a) keep confidential all Confidential Information disclosed by the other Party
    (the "**Disclosing Party**");
(b) not disclose such Confidential Information to any third party without the
    prior written consent of the Disclosing Party;
(c) not use such Confidential Information for any purpose other than performance
    of this Agreement;
(d) protect such Confidential Information using the same degree of care (but no
    less than reasonable care) as it uses to protect its own confidential information;
(e) restrict disclosure of Confidential Information to employees, contractors,
    or advisers who need to know and who are bound by confidentiality obligations
    at least as restrictive as those contained herein.

### 5.2 Exceptions

Clause 5.1 shall not apply to information that:

(a) is or becomes publicly available through no breach of this Agreement;
(b) was lawfully in the Receiving Party's possession before disclosure;
(c) is lawfully obtained from a third party without breach of confidentiality;
(d) is independently developed by the Receiving Party without use of Confidential
    Information;
(e) is required to be disclosed by law, regulation, or court order (provided
    the Receiving Party gives prompt notice to the Disclosing Party and cooperates
    in any effort to seek protective measures).

### 5.3 Return of Confidential Information

Upon termination of this Agreement or upon request by the Disclosing Party, the
Receiving Party shall promptly return or destroy (at the Disclosing Party's
election) all Confidential Information and certify in writing compliance with
this obligation.

### 5.4 Duration

The obligations under this Clause 5 shall survive termination of this Agreement
and continue for a period of five (5) years from the date of disclosure of the
relevant Confidential Information.
```text

#### 8. Indemnification

```markdown
## 6. INDEMNIFICATION

### 6.1 Service Provider Indemnity

The Service Provider shall indemnify, defend, and hold harmless the Client, its
officers, directors, employees, and agents (the "**Indemnified Parties**") from
and against any and all claims, demands, actions, losses, damages, liabilities,
costs, and expenses (including reasonable legal fees) ("**Losses**") arising from
or relating to:

(a) any breach of the Service Provider's representations, warranties, or obligations
    under this Agreement;
(b) any negligence or wilful misconduct of the Service Provider or its personnel;
(c) any infringement or alleged infringement of third-party Intellectual Property
    Rights by the Deliverables, Services, or Service Provider Tools
    ("**IP Indemnity**").

### 6.2 IP Indemnity - Enhanced Protection

With respect to the IP Indemnity under Clause 6.1(c):

(a) The Service Provider's obligation to indemnify shall be uncapped and shall
    not be subject to the limitations set forth in Clause 7 (Limitation of Liability);
(b) In the event of any IP infringement claim, the Service Provider shall, at
    its own expense and the Client's election:
    (i) procure for the Client the right to continue using the Deliverables;
    (ii) modify the Deliverables to make them non-infringing whilst maintaining
         equivalent functionality; or
    (iii) replace the Deliverables with non-infringing equivalents.

### 6.3 Indemnification Procedure

(a) The Indemnified Party shall promptly notify the indemnifying party in writing
    of any claim for which indemnification is sought;
(b) The indemnifying party shall have the right to control the defence and
    settlement of such claim, provided that:
    (i) the Indemnified Party shall have the right to participate in the defence
        at its own expense;
    (ii) no settlement shall be made without the Indemnified Party's prior written
         consent (not to be unreasonably withheld);
(c) The Indemnified Party shall reasonably cooperate with the indemnifying party
    in the defence of the claim.

### 6.4 Exclusions from Indemnity

The Service Provider shall have no obligation to indemnify to the extent Losses
arise from:

(a) modifications to the Deliverables made by persons other than the Service
    Provider without the Service Provider's written approval;
(b) use of the Deliverables in combination with products, services, or data not
    supplied or approved by the Service Provider, where infringement would not
    have occurred but for such combination;
(c) failure to implement updates or modifications provided by the Service Provider
    to avoid infringement.
```text

#### 9. Limitation of Liability

```markdown
## 7. LIMITATION OF LIABILITY

### 7.1 Unlimited Liabilities

Nothing in this Agreement shall limit or exclude either Party's liability for:

(a) death or personal injury caused by its negligence;
(b) fraud or fraudulent misrepresentation;
(c) any liability which cannot be limited or excluded by applicable law;
(d) indemnification obligations under Clause 6.1(c) (IP Indemnity).

### 7.2 Cap on Liability

Subject to Clause 7.1, each Party's total aggregate liability to the other Party
for all claims arising out of or in connection with this Agreement, whether in
contract, tort (including negligence), breach of statutory duty, or otherwise,
shall not exceed the total Fees paid or payable under this Agreement in the
twelve (12) months preceding the event giving rise to liability.

### 7.3 Consequential Losses

Subject to Clause 7.1, neither Party shall be liable to the other for:

(a) loss of profits, revenue, or anticipated savings;
(b) loss of business opportunity or goodwill;
(c) loss of or corruption to data;
(d) any indirect, special, incidental, punitive, or consequential losses or damages;

even if such Party has been advised of the possibility of such losses.

### 7.4 Reasonable and Proportionate

The Parties acknowledge that the limitations and exclusions set forth in this
Clause 7 are reasonable and proportionate, taking into account:

(a) the Fees payable under this Agreement;
(b) the allocation of risk between the Parties;
(c) the ability of each Party to obtain insurance coverage;
(d) the nature of the Services provided.
```text

#### 10. Term & Termination

```markdown
## 8. TERM AND TERMINATION

### 8.1 Term

This Agreement shall commence on the Commencement Date and, unless terminated
earlier in accordance with its terms, shall continue until completion of all
Services and Deliverables or until [FIXED END DATE], whichever occurs first.

### 8.2 Termination for Convenience

Either Party may terminate this Agreement for convenience upon ninety (90) days'
prior written notice to the other Party.

### 8.3 Termination for Cause

Either Party (the "**Non-Defaulting Party**") may terminate this Agreement
immediately by written notice if:

(a) the other Party (the "**Defaulting Party**") commits a material breach of
    this Agreement and:
    (i) such breach is incapable of remedy; or
    (ii) the Defaulting Party fails to remedy such breach within thirty (30)
         days of receiving written notice specifying the breach and requiring
         its remedy;

(b) the Defaulting Party becomes insolvent, enters administration or receivership,
    makes an arrangement with creditors, or ceases to carry on business;

(c) a Force Majeure Event affecting the Defaulting Party continues for more than
    sixty (60) consecutive days.

### 8.4 Effect of Termination

Upon termination of this Agreement for any reason:

(a) **Payment for Work Performed**: The Client shall pay the Service Provider
    for all Services satisfactorily performed and Deliverables accepted up to
    the date of termination;

(b) **Return of Materials**: Each Party shall return or destroy (at the other
    Party's election) all Confidential Information and materials belonging to
    the other Party;

(c) **Survival**: Clauses 1 (Definitions), 4 (Intellectual Property Rights),
    5 (Confidentiality), 6 (Indemnification), 7 (Limitation of Liability),
    and 11 (General Provisions) shall survive termination.

### 8.5 Termination Not Exclusive Remedy

Termination of this Agreement shall be without prejudice to any other rights or
remedies a Party may be entitled to under this Agreement or at law and shall not
affect any accrued rights or liabilities of either Party.
```text

#### 11. Force Majeure

```markdown
## 9. FORCE MAJEURE

### 9.1 Suspension of Obligations

Neither Party shall be liable for any failure or delay in performing its obligations
under this Agreement to the extent that such failure or delay is caused by a Force
Majeure Event.

### 9.2 Notice and Mitigation

(a) A Party affected by a Force Majeure Event ("**Affected Party**") shall:
    (i) promptly notify the other Party in writing of the nature, extent, and
        expected duration of the Force Majeure Event;
    (ii) use all reasonable endeavours to mitigate the effects of the Force
         Majeure Event;
    (iii) resume performance of its obligations as soon as reasonably practicable.

(b) The Affected Party shall keep the other Party regularly informed of developments.

### 9.3 Prolonged Force Majeure

If a Force Majeure Event continues for more than sixty (60) consecutive days,
either Party may terminate this Agreement immediately by written notice to the
other Party without liability (save for obligations accrued prior to termination).

### 9.4 Payment Obligations

For the avoidance of doubt, the Client's obligation to pay Fees for Services
performed and Deliverables accepted prior to a Force Majeure Event shall not be
suspended or excused.
```text

#### 12. General Provisions (Boilerplate)

```markdown
## 10. GENERAL PROVISIONS

### 10.1 Entire Agreement

(a) This Agreement constitutes the entire agreement between the Parties and
    supersedes all prior agreements, arrangements, understandings, and representations,
    whether written or oral, relating to the subject matter hereof.

(b) Each Party acknowledges that it has not relied on any statement, representation,
    warranty, or understanding not expressly set out in this Agreement.

(c) Nothing in this Clause shall exclude liability for fraudulent misrepresentation.

### 10.2 Variation

No variation or amendment of this Agreement shall be effective unless made in
writing and signed by authorised representatives of both Parties.

### 10.3 Severability

(a) If any provision of this Agreement is or becomes invalid, illegal, or
    unenforceable under any applicable law, it shall be deemed modified to the
    minimum extent necessary to make it valid, legal, and enforceable.

(b) If such modification is not possible, the provision shall be deemed severed
    from this Agreement.

(c) The invalidity, illegality, or unenforceability of any provision shall not
    affect the validity, legality, or enforceability of the remaining provisions.

### 10.4 Waiver

(a) No waiver of any breach of this Agreement shall constitute a waiver of any
    subsequent breach.

(b) No waiver shall be effective unless made in writing and signed by the waiving
    Party.

(c) Failure or delay by either Party to enforce any provision shall not constitute
    a waiver of that provision or any other provision.

### 10.5 Assignment and Subcontracting

(a) Neither Party may assign, transfer, sub-license, or otherwise dispose of its
    rights or obligations under this Agreement without the prior written consent
    of the other Party (such consent not to be unreasonably withheld or delayed).

(b) The Service Provider may engage subcontractors to perform Services, provided:
    (i) the Service Provider obtains the Client's prior written approval;
    (ii) the Service Provider remains fully responsible for the acts and omissions
         of its subcontractors;
    (iii) subcontractors are bound by obligations at least as restrictive as
          those in this Agreement.

### 10.6 Third Party Rights

No person who is not a party to this Agreement shall have any right under the
Contracts (Rights of Third Parties) Act 1999 to enforce any term of this Agreement,
provided that this shall not affect any right or remedy of a third party which
exists or is available apart from that Act.

### 10.7 Notices

(a) Any notice required to be given under this Agreement shall be in writing and
    delivered by:
    (i) personal delivery;
    (ii) registered post or recorded delivery to the address set out in this
         Agreement (or such other address as notified in writing); or
    (iii) email to the addresses specified below (with confirmation of receipt).

(b) Notice shall be deemed received:
    (i) if personally delivered, at the time of delivery;
    (ii) if sent by registered post, two (2) Business Days after posting;
    (iii) if sent by email, upon confirmation of receipt by the recipient.

(c) Notice addresses:
    **Service Provider**: [Email address]
    **Client**: [Email address]

### 10.8 Governing Law

This Agreement and any dispute or claim arising out of or in connection with it
or its subject matter (including non-contractual disputes or claims) shall be
governed by and construed in accordance with the laws of England and Wales.

### 10.9 Jurisdiction

The Parties irrevocably agree that the courts of England and Wales shall have
exclusive jurisdiction to settle any dispute or claim arising out of or in
connection with this Agreement or its subject matter (including non-contractual
disputes or claims).

### 10.10 Counterparts

This Agreement may be executed in any number of counterparts, each of which when
executed shall constitute a duplicate original, but all of which together shall
constitute a single agreement.
```text

#### 13. Execution

```markdown
## 11. EXECUTION

**IN WITNESS WHEREOF**, the Parties have executed this Agreement as of the date
first written above.

---

**SIGNED** by [NAME]
for and on behalf of
**[SERVICE PROVIDER LEGAL NAME]**

Signature: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Name: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Title: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Date: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

---

**SIGNED** by [NAME]
for and on behalf of
**[CLIENT LEGAL NAME]**

Signature: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Name: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Title: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Date: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_
```text

### Legal Latin Terminology (Appropriate Use)

### Use these terms for PRECISION, not decoration

| Latin Term | Meaning | Usage Context |
|------------|---------|---------------|
| **Inter alia** | Among other things | "Services include, inter alia, software development..." |
| **Mutatis mutandis** | With necessary changes | "Clause 5 applies mutatis mutandis to subcontractors" |
| **Ab initio** | From the beginning | "Agreement void ab initio if obtained by fraud" |
| **Bona fide** | In good faith | "Parties shall act bona fide in performance" |
| **Prima facie** | On first appearance | "Prima facie evidence of breach" |
| **Force majeure** | Superior force | "Performance suspended during force majeure event" |
| **In limine** | At the outset | "Objection raised in limine before proceedings" |
| **Ex gratia** | As a favour | "Ex gratia payment without admitting liability" |
| **Sine die** | Without day/indefinitely | "Meeting adjourned sine die" |
| **Per se** | By itself | "Delay is not per se a breach" |
| **De facto** | In fact | "De facto control of the company" |
| **Ipso facto** | By that very fact | "Breach ipso facto terminates the agreement" |

**Principle:** Use Latin where it provides precision unavailable in English. Avoid Latin that simply duplicates common English terms.

---

## Track 2: /contract-simplification

### Purpose

Generate simplified explanatory documents that help non-legal audiences understand formal contracts, serving as educational companions rather than replacements.

### Trigger Conditions

Activates when user:
- Requests "simplified version", "plain language explanation", "client-friendly contract"
- Needs to "explain contract terms" to stakeholders
- Explicitly invokes `/contract-simplification`
- References "make this understandable" or "help client understand terms"
- Requires "educational document" or "companion guide"

### Approach

**NOT refactoring** - creates PARALLEL document:
- Formal contract → remains unchanged (court-ready)
- Simplified version → explains formal contract in accessible language

### Structure

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
- [3-5 bullet points of main purposes]

### Key dates:
- Start: [DATE]
- Finish: [DATE]
- Review: [DATE]

### Key people:
- Service Provider: [NAME/COMPANY]
- Client: [NAME/COMPANY]

---

## Section-by-Section Explanation

### 1. Services & Deliverables

### What this means:
[Developer/Provider] will [plain description of work].

### Deliverables:
| What | When | How you'll know it's done |
|------|------|---------------------------|
| [Item 1] | [Date] | [Acceptance criteria in plain language] |
| [Item 2] | [Date] | [Acceptance criteria in plain language] |

**In simple terms:** [One sentence summary]

### 2. Payment

### What you pay:
| When | Amount | For what |
|------|--------|----------|
| [Trigger] | £X,XXX | [Milestone description] |

**Total:** £XX,XXX

**When payment is due:** [Plain explanation]

**What happens if payment is late:** [Plain explanation of consequences]

### 3. Who Owns What (Intellectual Property)

### What this means:
Intellectual property = the ideas, code, designs, and creative work.

### Who owns what:
- ✅ Client owns: [List what client owns after project]
- ✅ Developer keeps: [List what developer retains]
- ℹ️ Client can use: [List what client has licence to use]

**In simple terms:** [One-sentence summary]

### 4. Keeping Things Confidential

### What this means:
Both parties agree not to share sensitive information.

### What's confidential:
- [Plain list of confidential info types]

**How long:** [X years after the contract ends]

**Exceptions:** [Plain list of when you CAN share]

### 5. What Happens If Something Goes Wrong

### Developer's responsibility:
If [developer/provider] causes problems through:
- Poor work quality
- Breaking promises in the contract
- Using someone else's intellectual property without permission

Then they pay for the costs.

### Limits:
- Maximum the developer pays: £X,XXX (except for IP issues - no limit)
- Developer NOT responsible for: lost profits, lost business opportunities

**What this protects:** [Plain explanation]

### 6. Ending the Agreement

### How to end it:
- ✅ Mutual agreement: Both parties agree to stop
- ✅ For convenience: Either party gives 90 days' notice
- ❌ For serious breach: If one party breaks important terms and doesn't fix it within 30 days

### What happens when it ends:
1. Client pays for work done up to that point
2. Both parties return confidential information
3. Some obligations continue (like confidentiality)

### 7. Unexpected Events (Force Majeure)

### What this means:
If something completely out of control happens (pandemic, war, natural disaster),
the affected party doesn't get penalised for delays.

### Requirements:
- Must notify the other party immediately
- Must try to minimise the impact
- Must resume work as soon as possible

**If it lasts more than 60 days:** Either party can end the agreement without penalty.

### 8. Legal Stuff

**What law applies:** English law

**Where disputes are resolved:** Courts of England and Wales

**Entire agreement:** This written contract is everything - no verbal side agreements count

**Changes:** Must be in writing and signed by both parties

---

## Key Definitions (Plain Language)

| Term | What It Means |
|------|---------------|
| Business Day | Monday-Friday (not holidays) |
| Confidential Information | Sensitive business/technical information |
| Deliverables | The work products you're paying for |
| Intellectual Property | Ideas, code, designs, creative work |
| Force Majeure | Events completely out of anyone's control |

---

## Important Notes

⚠️ **This is a simplified guide** - the formal agreement has full legal details

⚠️ **Get legal advice** if you have questions about your rights/obligations

⚠️ **The formal agreement controls** - if this guide and the formal agreement differ,
the formal agreement wins

---

## Questions?

Common questions about this agreement:

### Q: What happens if...?
A: [Plain answer]

### Q: Can I...?
A: [Plain answer]

### Q: When do I need to...?
A: [Plain answer]

---

**Document Type:** Educational companion to formal agreement
**Created:** [DATE]
**For:** [CLIENT NAME]
**Formal Agreement Reference:** [CONTRACT TITLE AND DATE]
```text

### Simplification Principles

1. **British English** throughout
2. **Short sentences** (< 20 words average)
3. **Active voice** ("Developer will deliver" not "shall be delivered by")
4. **Visual aids**: tables, checkboxes, bullet lists
5. **"What this means"** sections after each formal section
6. **Examples** where helpful
7. **No legal jargon** unless essential (then defined)
8. **Conversational tone** whilst maintaining professionalism

---

## Security Protocol (Both Tracks)

**CRITICAL:** Never commit sensitive contract data to repositories.

### Scanning Checklist

Before saving ANY contract file, scan for:

❌ **Prohibited in version control:**
- Actual payment amounts → use placeholders `£[AMOUNT]`
- Bank account numbers → `[ACCOUNT_DETAILS]`
- Company registration numbers → `[COMPANY_NUMBER]`
- Personal addresses → `[ADDRESS]`
- Tax IDs / VAT numbers → `[TAX_ID]`
- Personal names → use roles: `[CLIENT_NAME]`, `[DEVELOPER_NAME]`
- Confidential business information
- Trade secrets
- Passwords, API keys, credentials

✅ **Safe for version control:**
- Contract templates with placeholders
- Clause structure and legal language
- General timelines and processes
- Standard definitions
- Boilerplate provisions

### .gitignore Additions

```bash
# Legal contract security
*_SIGNED.*
*_EXECUTED.*
*_FINAL_CLIENT.*
contracts/*_filled_*
*_with_amounts.*
*.contract_client_version.*
```text

### Version Control Best Practices

```bash
# Good commit messages
git commit -m "Add Independent Service Provider Agreement template (no sensitive data)"
git commit -m "Update IP indemnification clause to uncapped standard"
git commit -m "Add contra proferentem compliance to definitions section"

# Bad commit messages (indicate sensitive data)
git commit -m "Add Acme Corp contract with payment terms"
git commit -m "Client agreement for Project X"
```text

---

## Integration with Other Skills

### Works with `/create-pr`
```bash
/contract-formal "technology services agreement"
/create-pr "Add technology services agreement template with IP indemnity"
```text

### Works with `/remind-yourself`
```bash
/remind-yourself "contract drafting" "Independent Service Provider"
```text

### Works with `/write-medium-article`
```bash
/write-medium-article "How I Use Claude Code for Professional Legal Drafting"
```text

---

## Anti-Patterns (What NOT to Do)

❌ **Don't use Latin to sound impressive**
   - Use Latin ONLY where it adds precision unavailable in English
   - "Prior to" (English) is clearer than "ante" (Latin) for most audiences

❌ **Don't create simplified version as only document**
   - Clients need BOTH: formal (for court) AND simplified (for understanding)
   - Simplified alone lacks legal precision for disputes

❌ **Don't ignore contra proferentem**
   - Every ambiguity favours the non-drafter
   - Be paranoid about precision

❌ **Don't use outdated boilerplate**
   - UK law evolves (GDPR, IR35, etc.)
   - Update templates for 2025 compliance

❌ **Don't skip IP indemnification**
   - Technology services = IP infringement risk
   - Uncapped or super-cap essential

✅ **Do draft with contra proferentem in mind**
✅ **Do provide both formal and simplified versions**
✅ **Do use Latin where it enhances precision**
✅ **Do update boilerplate for current law**
✅ **Do uncap IP indemnification**

---

## Token Budget

**Formal contract generation:** <8,000 tokens
- Template structure: ~2,000
- Definitions & bespoke clauses: ~3,000
- Schedules & execution: ~2,000
- Review & validation: ~1,000

**Simplified version generation:** <5,000 tokens
- Section-by-section explanation: ~3,000
- Visual aids (tables, lists): ~1,000
- Q&A and notes: ~1,000

**Total per dual-track contract:** <13,000 tokens

---

## Metrics Tracking

```json
{
  "session_type": "legal-ops-formal",
  "contract_type": "Independent Service Provider Agreement",
  "track": "formal",
  "sections_included": 11,
  "latin_terms_used": 12,
  "contra_proferentem_checks": "passed",
  "ip_indemnity": "uncapped",
  "boilerplate_current": true,
  "tokens_used": 7800,
  "time_saved_vs_manual": "8 hours"
}
```text

---

## Changelog

**v2.0** (2025-11-12) - Multi-faceted redesign
- Split into two tracks: /contract-formal and /contract-simplification
- Added contra proferentem rule compliance protocols
- Enhanced IP indemnification (uncapped/super-cap)
- Comprehensive Independent Service Provider Agreement template
- Legal Latin terminology guidance (precision over decoration)
- UK 2025 compliance (boilerplate, VAT threshold, etc.)
- Security protocols for sensitive data
- Anti-patterns and best practices

**v1.0** (2025-11-12) - Initial creation
- Plain language refactoring approach
- Visual structure guidelines
- Deferred equity templates
- Basic security scanning

---

**Skill Status:** ✅ Active (Multi-Faceted)
**Maintainer:** LC Scheepers
**Last Updated:** 2025-11-12
**Token Budget:** <13,000 per dual-track contract
**Demonstrated:** Production contracts (formal + simplified versions)
**UK Compliance:** 2025 standards
