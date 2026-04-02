# /break — Issue Breakdown Agent

## Goal

Read `spec.md` and transform it into a set of small, well-defined issues organized in two batches:
first prototype issues (visual only, no functionality), then functional issues (wiring each prototype
to real data, APIs, and backend logic). Each issue becomes the input unit for `/plan`.

---

## Inputs

- `<slug>`: provided as the command argument (partial name, without the `feature-<N>-` prefix)
- `docs/features/feature-<N>-<slug>/spec.md`: must exist before this command runs

---

## Step-by-Step Process

### Step 1: Resolve the feature folder

Scan `docs/features/` for a folder whose name contains the provided slug.
- Match is case-insensitive and partial: `/break pos-venda` should find `feature-3-pos-venda-clientes`.
- If exactly one match is found, use it. Announce: `Resolved to: docs/features/feature-<N>-<slug>/`
- If multiple folders match, list them and ask the user to clarify.
- If no folder matches, report the error and list all existing feature folders.

If no slug was provided, list all folders under `docs/features/` and ask the user to pick one.

### Step 2: Read spec.md fully

Read `docs/features/feature-<N>-<slug>/spec.md` completely before doing anything else.

If the file doesn't exist, respond:
```
spec.md not found in docs/features/feature-<N>-<slug>/.
Run /spec first, then /clear, then /break <slug>.
```

### Step 3: Create the issues folder

Create `docs/features/feature-<N>-<slug>/issues/` if it does not exist.

### Step 4: Generate Batch 1 — Prototype Issues

Prototype issues cover the visual layer only. No API calls, no database writes, no business logic.
Static data and placeholder values are acceptable.

**Scope rule**: one prototype issue per page defined in the spec.

**Naming convention**: `proto-<NN>-<page-slug>.md` where NN is zero-padded (01, 02, 03...).

For each page in the spec, write one file with this structure:

```markdown
# Proto Issue: <Page Name>

**Issue ID**: proto-<NN>
**Feature**: feature-<N>-<slug>
**Type**: prototype
**Page**: <page name from spec>
**Status**: pending

---

## Goal

Build the visual shell of <Page Name>. No real data, no API calls, no form submission logic.
The output is a pixel-accurate screen that matches the spec components and states.

---

## Components to Build

For each component listed in the spec for this page:

### <Component Name>

**Type**: [form | button | table | card | list | modal | input | chart | badge | other]
**States to implement**: [list all states from the spec — empty, loading, filled, error, disabled, etc.]
**Static data**: [describe placeholder content to use — e.g. "3 hardcoded rows", "lorem ipsum", "a fixed price value"]

---

## Acceptance Criteria

- [ ] Page renders without errors
- [ ] All components listed above are present and visible
- [ ] All states listed per component are implementable via props or local toggle (no real data needed)
- [ ] No real API calls or database writes are made
- [ ] Matches the layout described in the spec
```

### Step 5: Generate Batch 2 — Functional Issues

Functional issues wire each prototype to real behavior: data fetching, form submission, database writes,
API integrations, error handling, and all behaviors defined in the spec.

**Scope rule**: one functional issue per page, derived from the behaviors defined in the spec for that page.
If a page has many independent behaviors (e.g. a page with a list AND a creation form with distinct logic),
split into two functional issues and note the dependency between them.

**Naming convention**: `func-<NN>-<page-slug>.md` where NN mirrors the prototype number for the same page.

For each page in the spec, write one file with this structure:

```markdown
# Functional Issue: <Page Name>

**Issue ID**: func-<NN>
**Feature**: feature-<N>-<slug>
**Type**: functional
**Page**: <page name from spec>
**Depends on**: proto-<NN> (must be complete before this issue starts)
**Status**: pending

---

## Goal

Wire the visual shell of <Page Name> to real data and backend logic.
Replace all static placeholders with live behavior as described in the spec.

---

## Behaviors to Implement

For each behavior defined in the spec for this page's components:

### <Component Name> › <Behavior Name>

**Trigger**: [what the user does]

**Implementation scope**:
- [ ] Happy path: [what must work end-to-end]
- [ ] Edge case: [specific edge case from spec]
- [ ] Error state: [error handling from spec]

**External dependencies**: [API endpoint, database table, third-party service — or "none"]

---

## Acceptance Criteria

- [ ] All behaviors listed above are functional with real data
- [ ] No hardcoded or static placeholder data remains
- [ ] All error states show the correct feedback to the user
- [ ] All happy path scenarios complete without console errors
```

### Step 6: Present summary and confirm

After generating all files, show the user:

```
Issues created for feature-<N>-<slug>:

Batch 1 — Prototypes (visual only)
  proto-01-<page-slug>.md — <Page Name>
  proto-02-<page-slug>.md — <Page Name>
  ...

Batch 2 — Functional (wiring + logic)
  func-01-<page-slug>.md — <Page Name>
  func-02-<page-slug>.md — <Page Name>
  ...

Total: [N] prototype issues + [N] functional issues = [total] issues

Recommended execution order:
  Implement all proto issues first (left to right), then all func issues.
  Each func issue depends on its corresponding proto being complete.

Next step:
  /clear
  /plan <slug> proto-01
```

---

## Important Rules

- Prototype issues contain zero functional logic. If a component has an "empty state" that requires a real API call to detect, the prototype shows the empty state statically via a prop or toggle.
- Functional issues assume the prototype is done. They never re-describe layout or visual details.
- If a page has no behaviors in the spec (pure display, no interactions), it gets a prototype issue but NO functional issue. Note this explicitly in the summary.
- If two behaviors on the same page share the same backend resource (e.g. both read from the same table), they belong in the same functional issue, not separate ones.
- Never merge a prototype and a functional concern into the same issue.
- Issue files are not modified by `/plan` or `/implement`. They are the source of truth for what must be built.
