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

**Scan `.docs/features/`** for existing folders matching the pattern `feature-<N>-*`.
- Extract all N values (they are integers in the folder name prefix).
- Take the maximum N found and use N+1 for the new folder.
- If `.docs/features/` does not exist or has no matching folders, start at N=1.

**If the user explicitly mentioned a number** (e.g. "isso é a feature 5", "feature 5", "#5"), use that number
directly, regardless of what already exists.

Derive the slug from the feature description: short, lowercase, kebab-case.
Examples: "gestão de clientes pós-venda" → `pos-venda-clientes`; "checkout flow" → `checkout-flow`.

Construct the folder path: `.docs/features/feature-<N>-<slug>/`

Create the folder (and `.docs/features/` if it doesn't exist yet).

Announce to the user:
```
Creating feature folder: .docs/features/feature-<N>-<slug>/
```

### Step 2: Brainstorm — gather all inputs before writing

**Before writing the spec, evaluate whether the description has enough detail to answer all five layers**

**This step is mandatory when the description is incomplete.** Before writing a single line of the
spec, evaluate whether you have enough information to define — without guessing — every layer:
Overview, Pages, Components, Behaviors, and User Flows.

**Never invent or assume behaviors and user flows.** If you do not have explicit information about
what happens when the user performs an action, what screen comes next, or what the system response
is, you must ask. Fabricating plausible-sounding behaviors leads to specs that do not reflect the
real product intent and pollutes all downstream steps (break, research, plan, implement).

**How to assess completeness** — for each layer, ask yourself:

| Layer | You need to know |
|---|---|
| Overview | What problem this solves and who it's for |
| Pages | Every distinct screen or surface involved |
| Components | Every interactive or informational element on each page |
| Behaviors | The exact system response for every user action — including errors |
| User Flows | How the user navigates from start to end state, including branching paths |

If any of these cannot be answered from the description alone, **stop and ask**.

**How to ask:**
Use the `AskUserQuestion` tool to present all questions in a single, structured message.
Do not open multiple rounds of questions — batch everything into one call.
Format questions as a numbered list, grouped by layer when there are several.

**When to skip this step:**
Only if the description is detailed enough that every layer above can be filled without any
inference beyond common sense (e.g. a button that says "Save" saves the form). If in doubt, ask.

Examples of good clarifying questions:
- "Essa tela já existe no app ou é completamente nova?"
- "Quem acessa essa funcionalidade: o dono da loja, o cliente final, ou ambos?"
- "Quando o usuário submete o form e dá erro, ele perde os dados preenchidos ou mantém?"
- "Existe algum estado intermediário entre essas duas telas, como um loading ou confirmação?"
- "Após confirmar a ação, o usuário é redirecionado para alguma tela específica?"
- "Quais campos são obrigatórios nesse formulário? Existe validação em tempo real ou só ao submeter?"

### Step 3: Write spec.md

Write `.docs/features/feature-<N>-<slug>/spec.md` with this structure:

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
Group components under their page. Include only components that enable a user action or
carry information the user needs — do not list purely decorative elements.

### Page: <Page Name>

#### Component: <Component Name>

**Type**: form | button | table | card | list | modal | input | chart | badge | other
**Description**: [what this component shows or contains]
**States**: [visible states — empty, loading, filled, error, disabled, etc.]

---

## Behaviors

For each component that triggers a system response, describe every interaction the user
can perform and what the system does as a result. Behaviors are atomic: one trigger, one outcome.

Group behaviors under their component. Do not describe navigation between pages here —
that belongs in User Flows.

### Page: <Page Name> › Component: <Component Name>

#### Behavior: <Behavior Name>

**Trigger**: [what the user does — clicks button, submits form, types in field, etc.]

**Happy path**:
- GIVEN [precondition — state of the system before the action]
- WHEN [the specific user action]
- THEN [the observable result — what changes on screen, what the system does]

**Edge cases** (include only when applicable):
- GIVEN [precondition]
- WHEN [user action]
- THEN [expected result]

**Error states** (include only when applicable):
- GIVEN [precondition]
- WHEN [user action]
- THEN [expected result — error message, fallback, recovery path]

---

## User Flows

Describe the navigation paths a user can take through this feature. Each flow is a named
sequence of steps that connects a starting point to an end state. Flows describe WHERE
the user goes and HOW screens connect — not what happens inside each screen.

Reference pages and components by their exact names as defined in the Pages and Components
sections above.

### Flow: <Flow Name>

**Actor**: [who executes this flow — user role or condition]
**Entry point**: [where the flow starts — route, external link, prior action]
**End state**: [what the user has accomplished when the flow is complete]

**Steps**:
1. User is at [Page Name] via [route or prior action]
2. User [action that causes navigation — clicks X, completes Y, etc.]
3. System navigates to [Page Name] (or opens [modal/drawer name])
4. [Continue until end state is reached]

**Alternate paths** (include only when applicable):
- At step [N], if [condition], the flow branches to [Page Name or step]

---

## Out of Scope

[List what this feature explicitly does NOT include. This prevents scope creep in subsequent steps.]

- [item]
- [item]
```

Rules for writing the spec:
- Every page must have at least one component.
- Every component that enables a user action must have at least one behavior.
- Every behavior must have a happy path. Edge cases and error states are required only when they
  produce a meaningfully different system response.
- Every user flow must reference only pages and components already defined in their respective sections.
- Behaviors must never describe navigation. Navigation belongs exclusively in User Flows.
- User Flows must never describe what happens inside a component. Internal logic belongs in Behaviors.
- Do not describe implementation details (no database tables, no API endpoints, no code patterns).
- The spec describes WHAT the user experiences, not HOW the system works internally.
- Use present tense: "The user sees...", "The system shows...", "The form submits...".

### Step 4: Confirm and close

After writing `spec.md`, respond:

```
Spec complete. Artifact saved to:
  .docs/features/feature-<N>-<slug>/spec.md

Pages documented: [N]
Components documented: [N]
Behaviors documented: [N]
User Flows documented: [N]

Next step:
  /clear
  /break <slug>
```

---

## Important Rules

- Never write research, code, or implementation details during this step.
- The spec is a product document, not a technical document. Write it so a designer or
  product manager can read and validate it.
- **Never invent behaviors or user flows.** Every behavior (trigger → system response) and every
  navigation step in a user flow must come from information the user explicitly provided or confirmed.
  If the information is not there, ask before writing. A spec that guesses is worse than no spec.
- **Ask, don't assume.** When in doubt about what the system should do, what screen follows an action,
  or how an error should be handled — stop and use `AskUserQuestion` to clarify. The cost of one
  question is far lower than the cost of a spec that misrepresents the product.
- If the user's description implies behaviors that contradict each other, or flows that
  lead to undefined pages, flag them explicitly under a "⚠️ Open Questions" section
  inserted before "Out of Scope".
- Slugs are lowercase kebab-case derived from the feature description.
- The separation between Behaviors and User Flows is strict and non-negotiable:
  Behaviors = what happens inside a screen; User Flows = how the user moves between screens.
