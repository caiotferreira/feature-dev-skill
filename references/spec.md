# /spec — Spec Writer Agent

## Goal

Transform a feature description in natural language into a structured specification document
that defines everything the application needs to do before a single line of code is written.
This document becomes the single source of truth for all subsequent steps.

---

## Inputs

- Feature description: provided by the user as the command argument

---

## Step-by-Step Process

### Step 1: Determine the feature folder

Before creating any file, resolve the correct folder name.

**Scan `docs/features/`** for existing folders matching the pattern `feature-<N>-*`.
- Extract all N values (they are integers in the folder name prefix).
- Take the maximum N found and use N+1 for the new folder.
- If `docs/features/` does not exist or has no matching folders, start at N=1.

**If the user explicitly mentioned a number** (e.g. "isso é a feature 5", "feature 5", "#5"), use that number
directly, regardless of what already exists.

Derive the slug from the feature description: short, lowercase, kebab-case.
Examples: "gestão de clientes pós-venda" → `pos-venda-clientes`; "checkout flow" → `checkout-flow`.

Construct the folder path: `docs/features/feature-<N>-<slug>/`

Create the folder (and `docs/features/` if it doesn't exist yet).

Announce to the user:
```
Creating feature folder: docs/features/feature-<N>-<slug>/
```

### Step 2: Ask clarifying questions if needed

Before writing the spec, evaluate whether the description has enough detail to answer all four layers
(Overview, Pages, Components, Behaviors). If any layer is genuinely ambiguous, ask targeted questions.

Rules for asking questions:
- Ask only what you cannot reasonably infer from the description.
- Group all questions into a single message — never ask in multiple rounds.
- If the description is detailed enough, skip this step entirely and proceed.

Examples of good clarifying questions:
- "Essa tela já existe no app ou é completamente nova?"
- "Quem acessa essa funcionalidade: o dono da loja, o cliente final, ou ambos?"
- "Quando o usuário submete o form e dá erro, ele perde os dados preenchidos ou mantém?"

### Step 3: Write spec.md

Write `docs/features/feature-<N>-<slug>/spec.md` with this structure:

```markdown
# Spec: <Feature Name>

**Date**: YYYY-MM-DD
**Feature**: feature-<N>-<slug>
**Status**: draft

---

## Overview

[2–4 sentences describing what this feature is, why it exists, and who uses it.
Be specific: avoid generic phrases like "improve user experience".]

---

## Pages

List every screen that is part of this feature. For each page:

### Page: <Page Name>

**Route**: `/path/to/page` (or "modal", "drawer", "inline" if not a full page)
**Who sees it**: [user role or condition]
**Purpose**: [one sentence — what does this page allow the user to accomplish]

---

## Components

For each page listed above, list every visible element the user interacts with or sees.
Group components under their page.

### Page: <Page Name>

#### Component: <Component Name>

**Type**: form | button | table | card | list | modal | input | chart | badge | other
**Description**: [what this component shows or contains]
**States**: [visible states — empty, loading, filled, error, disabled, etc.]

---

## Behaviors

For each component, describe every action the user can take and what happens as a result.
Group behaviors under their component.

### Page: <Page Name> › Component: <Component Name>

#### Behavior: <Behavior Name>

**Trigger**: [what the user does — clicks button, submits form, types in field, etc.]

**Happy path**:
- GIVEN [precondition]
- WHEN [user action]
- THEN [expected result]

**Edge cases**:
- GIVEN [precondition]
- WHEN [user action]
- THEN [expected result]

**Error states**:
- GIVEN [precondition]
- WHEN [user action]
- THEN [expected result — error message, fallback, etc.]

---

## Out of Scope

[List what this feature explicitly does NOT include. This prevents scope creep in subsequent steps.]

- [item]
- [item]
```

Rules for writing the spec:
- Every page must have at least one component.
- Every component must have at least one behavior.
- Every behavior must have a happy path. Edge cases and error states are required when applicable.
- Do not describe implementation details (no database tables, no API endpoints, no code patterns).
- The spec describes WHAT the user experiences, not HOW the system works internally.
- Use present tense: "The user sees...", "The system shows...", "The form submits...".

### Step 4: Confirm and close

After writing `spec.md`, respond:

```
Spec complete. Artifact saved to:
  docs/features/feature-<N>-<slug>/spec.md

Pages documented: [N]
Components documented: [N]
Behaviors documented: [N]

Next step:
  /clear
  /break <slug>
```

---

## Important Rules

- Never write research, code, or implementation details during this step.
- The spec is a product document, not a technical document. Write it so a designer or product manager can read and validate it.
- If the user's description implies behaviors that contradict each other, flag them explicitly in the spec under a "⚠️ Open Questions" section before "Out of Scope".
- Slugs are lowercase kebab-case derived from the feature description.
