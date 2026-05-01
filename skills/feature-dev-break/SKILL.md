---
name: feature-dev-break
description: Use when the user invokes /break, says "quebrar em issues", "criar issues", "decompor spec", or wants to convert a spec.md into prototype and functional issue files.
---

# /break — Issue Breakdown Architect

## Goal

Read `spec.md`, perform a critical analysis of the feature, verify UI and data coverage, detect
redundancies and ambiguities, ask when critical information is missing, and only then create
prototype and functional issue files. Every issue created must have a clear owner: a visual
component, a user behavior, or a data responsibility.

---

## Inputs

- `<slug>`: provided as the command argument (partial name, without the `feature-<N>-` prefix)
- `.docs/features/feature-<N>-<slug>/spec.md`: must exist before this command runs

---

## Step-by-Step Process

### Step 1: Resolve the feature folder

Scan `.docs/features/` for a folder whose name contains the provided slug.
- Match is case-insensitive and partial: `/break pos-venda` should find `feature-3-pos-venda-clientes`.
- If exactly one match is found, use it. Announce: `Resolved to: .docs/features/feature-<N>-<slug>/`
- If multiple folders match, list them and ask the user to clarify.
- If no folder matches, report the error and list all existing feature folders.

If no slug was provided, list all folders under `.docs/features/` and ask the user to pick one.

### Step 2: Read spec.md fully

Read `.docs/features/feature-<N>-<slug>/spec.md` completely before doing anything else.

If the file doesn't exist, respond:
```
spec.md not found in .docs/features/feature-<N>-<slug>/.
Run /spec first, then /clear, then /break <slug>.
```

Also read `.docs/features/feature-<N>-<slug>/research.md` if it exists — it provides codebase
context that informs component existence checks.

---

### Step 3: Breakdown Review (mandatory before writing any files)

This step is not skippable. Do not write any files until Step 3 is complete and confirmed.

#### 3a. Extract from spec

Pull these elements explicitly from the spec:

- **Pages**: every distinct view or route
- **Components**: every UI component per page
- **Component states**: loading, populated, empty, error, disabled — per component
- **User behaviors**: human-triggered interactions (click, submit, select, navigate, filter)
- **Data behaviors**: lifecycle-triggered data needs (page load, tab switch, filter change, entity
  selection, component mount)
- **User flows**: end-to-end sequences crossing components or pages
- **Out of scope**: anything the spec explicitly excludes

#### 3b. Light codebase scan

For each page and component identified in 3a, perform a targeted search:

- Does the page/route already exist?
- Does each component already exist?
- Is any component partially implemented (some states missing, using mock data)?
- Are there hardcoded values, mock data, placeholder adapters, or local stubs related to this
  feature in the existing code?

Use `grep`, `find`, and directory listings. Do not read entire files — scan for file names and
key identifiers.

#### 3c. Classify each component

Assign one primary classification:

| Class | Definition |
|---|---|
| `visual-only` | Purely presentational, no data from backend, no user mutations |
| `data-display` | Renders real business data (KPIs, tables, lists, charts, summaries) |
| `interactive-input` | Forms, filters, date pickers, search inputs that mutate state or query params |
| `navigation` | Links, breadcrumbs, tabs that drive routing or view transitions |
| `modal/drawer` | Overlay containers; classify inner components separately |
| `backend-only` | Infrastructure, services, API layers — no UI |

#### 3d. Validate data coverage

For every `data-display` component:
- Is there an existing or planned functional/data issue that loads real data into it?
- Does the spec or research identify the data source (endpoint, model, table, external service)?
- Are loading, empty, and error states covered?

If any `data-display` component lacks a clear data issue and the answer cannot be inferred from
the spec or research, add it to the **questions list**.

#### 3e. Normalize and deduplicate behaviors

For each user behavior and data behavior, compute a normalized signature:

```
signature = trigger + target + outcome + affected_data
```

Rules:
- **Consolidate** when two behaviors share the same signature and differ only in context (e.g.,
  "Close Ranking Modal" + "Close City Detail Modal" → "Close Modals").
- **Consolidate** when the difference is only metric/endpoint/unit and the flow is identical
  (e.g., "Expand Ranking by Value" + "Expand Ranking by Quantity" → "Expand Customer Rankings").
- **Keep separate** when data sources, permissions, UX states, error paths, or business risk
  differ meaningfully.
- **Keep separate** when one issue controls state/params and another loads data
  (e.g., "Select Period" ≠ "Load Indicators for Selected Period").

#### 3f. Detect issues that are too broad

Flag any behavior that, if implemented as one issue, would require:
- Multiple unrelated endpoints
- Changes to multiple unrelated components
- Both filter state management AND data fetching

Split these before proceeding.

#### 3g. Detect coverage gaps

Report any of the following as errors or questions:

| Gap | Action |
|---|---|
| Visual component is new and has no proto issue | Create proto or ask |
| `data-display` component has no functional/data issue | Create data issue or ask |
| Explicit spec behavior has no functional issue | Error — must be created |
| Issue references no clear component, behavior, or data responsibility | Revise before creating |
| Two issues share the same normalized signature | Consolidate or ask |
| Issue mixes prototype visuals with real API integration | Split before creating |
| Filter issue begins loading data from all tabs/endpoints | Reduce scope: filter manages params only |

#### 3h. Build coverage matrix

Before writing any files, output this matrix:

```
Component | Class | Exists? | Partial? | Proto issue | Data source | Func/Data issue | Notes
```

Every row must be complete. Gaps are surfaced here before any file is written.

---

### Step 4: Open Questions

After building the matrix, collect all unanswered questions. Use these as templates:

- "Should `<Component>` use real data in this feature or remain a prototype?"
- "What data source feeds `<Component>`? (table, model, external API, service)"
- "Which components does the `<filter>` filter affect?"
- "Should `<repeated behavior>` across multiple modals become one issue or stay separate?"
- "Is mock data in `<file>` meant to persist for demo/story or be removed from the app?"
- "Does `<integration>` depend on a new backend endpoint, an existing one, or is it frontend-only?"

**If an obvious answer can be inferred from spec/research/code, do not ask — create the correct
issue.** Only ask when the answer could meaningfully change scope, architecture, or product behavior.

---

### Step 5: Confirmation Before Writing

Show the user a pre-write confirmation summary:

```
Breakdown Review — <feature-N-slug>

Proto issues proposed:
  proto-01: <Page/Component> — [new / adaptation]
  ...

Functional issues proposed:
  func-01: <Behavior> — trigger: <X> → outcome: <Y>
  ...

Data issues added (implicit, not in spec):
  data-01: Load <Component> data — source: <origin>
  ...

Consolidated issues:
  func-03 replaces: "Close Ranking Modal" + "Close City Detail Modal"
  ...

Skipped (component already exists, no visual change needed):
  <Component> on <Page> — already implemented, no proto required
  ...

Coverage matrix:
  [matrix from 3h]

Open questions:
  1. <question>
  2. <question>

```

**If there are open questions, stop here and wait for answers before writing files.**

If there are no open questions (or all questions were resolved by inference), proceed to Step 6.

---

### Step 6: Create issues folder

Create `.docs/features/feature-<N>-<slug>/issues/` if it does not exist.

---

### Step 7: Generate Prototype Issues

Prototype issues cover the visual layer only. No API calls, no database writes, no business logic.
Static data and placeholder values are acceptable but must be clearly marked as temporary.

**Scope rules**:
- One prototype issue per new page or new visual component.
- Group small visual components of the same page when they are part of the same initial layout.
- Do not create a proto for a component that already fully exists, unless the feature requires
  a relevant visual adaptation.
- If a page exists but one component is missing, create a proto scoped to that component only.
- Prototype issues must never contain real API calls, database writes, mutations, or business logic.

**Naming**: `proto-<NN>-<page-or-component-slug>.md` (NN zero-padded: 01, 02…)

```markdown
# Proto: <Page or Component Name>

**Issue ID**: proto-<NN>
**Feature**: feature-<N>-<slug>
**Type**: prototype
**Scope**: <page name> [/ <component name if scoped to a single component>]
**Status**: pending

---

## Description

[Detailed description. Cover:
- What page or component this is and its purpose in the feature
- All components to build, with their types and visual states (empty, loading, populated, error,
  disabled) rendered with static/placeholder data
- Layout and structural requirements implied by the spec
- Local-state-only visual behaviors (e.g., a toggle to switch between states for development)
- Explicit note: "All data shown here is static/placeholder and will be replaced by func/data issues"

Do not describe real API calls, database access, or business logic.]
```

---

### Step 8: Generate Functional and Data Issues

Functional issues wire behaviors to real data, API calls, form submissions, and backend logic.

**Two issue subtypes**:

- **User behavior issue**: triggered by a human action (click, submit, select, navigate).
- **Data behavior issue**: triggered by a lifecycle event (page load, tab switch, filter change,
  entity selection, component mount). Create these whenever a `data-display` component needs real
  data and no explicit behavior in the spec covers it.

**Scope rules**:
- One issue per behavior (user or data).
- Consolidate only when signatures match (see Step 3e).
- A filter issue manages state and query params only — it does not load data. Data loading is a
  separate data behavior issue.
- Functional issues assume the prototype is done. Do not re-describe layout or visual details.

**Naming**: `func-<NN>-<behavior-slug>.md` (NN increments globally across all func/data issues)

```markdown
# Func: <Behavior Name>

**Issue ID**: func-<NN>
**Feature**: feature-<N>-<slug>
**Type**: functional | data
**Subtype**: user-behavior | data-behavior
**Page**: <page name>
**Component**: <component name>
**Behavior**: <behavior name from spec or inferred>
**Depends on**: proto-<NN> (<Page or Component Name>)
**Status**: pending

---

## Description

[Detailed description. Cover:
- What behavior this is, which component, which page
- Trigger (human action or lifecycle event)
- Happy path end-to-end: user action → system response
- For data behaviors: endpoint/API/service expected (if known), data source (table, model, external
  API, service), loading state, empty state, error state, rule for replacing/removing mocks
- Dependency on filters: which filter params affect this component's query
- Query/mutation parameters
- All edge cases from the spec
- All error states and required user feedback
- Relevant external dependencies

Do not describe layout or visual details — those belong in the proto issue.]
```

---

### Step 9: Generate issues/README.md

Always generate `.docs/features/feature-<N>-<slug>/issues/README.md`:

```markdown
# Issues — <feature-N-slug>

## Issue Map

### Prototype Issues
| ID | File | Scope | Status |
|---|---|---|---|
| proto-01 | proto-01-<slug>.md | <Page/Component> | pending |
...

### Functional Issues
| ID | File | Behavior | Subtype | Depends on | Status |
|---|---|---|---|---|---|
| func-01 | func-01-<slug>.md | <Behavior> | user-behavior | proto-01 | pending |
...

## Suggested Execution Order

1. All proto issues (implement in parallel if independent)
2. Data behavior issues (can start once proto is done)
3. User behavior issues (depend on data being wired)

## Consolidated Issues

| New issue | Replaced | Reason |
|---|---|---|
| func-03 | "Close Ranking Modal" + "Close City Detail Modal" | Same trigger/outcome |
...

## Components Covered

| Component | Class | Proto | Func/Data issue |
|---|---|---|---|
| <Component> | data-display | proto-01 | func-03 |
...

## Skipped Components

| Component | Reason |
|---|---|
| <Component> | Already fully implemented, no visual change needed |
...

## Coverage Gaps Resolved

- <gap description> → resolved by <issue ID>

## Coverage Gaps Pending

- <gap description> → awaiting: <question or dependency>

## Notes for /research and /plan

- <observation about codebase state relevant to planning>
- <mock or hardcoded data to be removed in: func-XX>
```

---

### Step 10: Present Final Summary

```
Issues created for feature-<N>-<slug>:

Prototype issues: [N]
  proto-01: <Page/Component>
  ...

Functional issues (user behavior): [N]
  func-01: <Behavior> — <Page> › <Component>
  ...

Data issues (implicit, added by breakdown): [N]
  func-0N: Load <Component> data — source: <origin>
  ...

Consolidated: [N]
  func-0N replaces: <list of merged behaviors>

Skipped (already exist, no change needed): [N]
  <Component> on <Page>

Alerts / gaps:
  [any remaining open questions or unresolved gaps]

Coverage matrix:
  [abbreviated matrix]

Next step:
  /clear
  /research <slug>
```

---

## Important Rules

- Issue files contain only a detailed description. No implementation phases, no code blocks, no
  acceptance criteria checklists. `/plan` will append the implementation plan to the same file.
- Prototype issues contain zero functional logic. If a component has an "empty state" that requires
  a real API call to detect, the prototype shows it statically via a prop or toggle.
- Functional issues assume the prototype is done. They never re-describe layout or visual details.
- Functional issues are atomic: one behavior or one data responsibility, one trigger, one outcome.
- If a page has no behaviors and no data to load (pure static display), it gets a proto issue but
  no functional issue. Note this explicitly.
- Never merge a prototype and a functional concern into the same issue.
- Never create an issue without a clear owner: a visual component, a user behavior, or a data
  responsibility.
- Do not skip the Breakdown Review (Step 3) or the Confirmation step (Step 5) under any
  circumstances.
