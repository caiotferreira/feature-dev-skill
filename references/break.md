# /break — Issue Breakdown Agent

## Goal

Read `spec.md` and transform it into a set of small, well-defined issues organized in two batches:
first prototype issues (visual only, one per page), then functional issues (one per behavior defined
in the spec). Each issue file contains a detailed description and becomes the input unit for `/plan`.

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

### Step 3: Create the issues folder

Create `.docs/features/feature-<N>-<slug>/issues/` if it does not exist.

### Step 4: Generate Batch 1 — Prototype Issues

Prototype issues cover the visual layer only. No API calls, no database writes, no business logic.
Static data and placeholder values are acceptable.

**Scope rule**: one prototype issue per page defined in the spec.

**Naming convention**: `proto-<NN>-<page-slug>.md` where NN is zero-padded (01, 02, 03...).

For each page in the spec, write one file with this structure:

```markdown
# Proto: <Page Name>

**Issue ID**: proto-<NN>
**Feature**: feature-<N>-<slug>
**Type**: prototype
**Page**: <page name from spec>
**Status**: pending

---

## Description

[Detailed description of this prototype issue. Cover:
- What page this is and its purpose
- All components that need to be built, with their types and visual states (empty, loading, filled, error, disabled, etc.)
- What static/placeholder data each component should display
- What layout or structural requirements are implied by the spec
- Any visual behaviors that are driven by local state only (e.g. a toggle to switch between states)

Do not describe real API calls, database access, or business logic — those belong in func issues.]
```

### Step 5: Generate Batch 2 — Functional Issues

Functional issues wire each behavior to real data, API calls, form submissions, and backend logic.

**Scope rule**: one functional issue per behavior defined in the spec. Each behavior maps to exactly
one trigger → outcome pair. If a page has five behaviors, it gets five functional issues.

**Naming convention**: `func-<NN>-<behavior-slug>.md` where NN increments globally across all func
issues (func-01, func-02, func-03...). The behavior slug is derived from the behavior name in the spec.

For each behavior listed in the spec (across all pages and components), write one file with this structure:

```markdown
# Func: <Behavior Name>

**Issue ID**: func-<NN>
**Feature**: feature-<N>-<slug>
**Type**: functional
**Page**: <page name from spec>
**Component**: <component name>
**Behavior**: <behavior name from spec>
**Depends on**: proto-<NN> (the prototype issue for <Page Name>)
**Status**: pending

---

## Description

[Detailed description of this functional issue. Cover:
- What behavior this is, which component it lives on, and which page
- The trigger (what the user does)
- The happy path end-to-end: what must work from user action to system response
- All edge cases from the spec and what the system must do in each
- All error states from the spec and what feedback the user must see
- External dependencies: which API endpoint, database table, or service is involved
- Any data that must be fetched, written, or validated

Do not describe layout or visual details — those belong in the proto issue.]
```

### Step 6: Present summary and confirm

After generating all files, show the user:

```
Issues created for feature-<N>-<slug>:

Batch 1 — Prototypes (visual only, one per page)
  proto-01-<page-slug>.md — <Page Name>
  proto-02-<page-slug>.md — <Page Name>
  ...

Batch 2 — Functional (one per behavior)
  func-01-<behavior-slug>.md — <Page Name> › <Component> › <Behavior Name>
  func-02-<behavior-slug>.md — <Page Name> › <Component> › <Behavior Name>
  ...

Total: [N] prototype issues + [N] functional issues = [total] issues

Recommended execution order:
  Implement all proto issues first, then all func issues.
  Each func issue depends on its corresponding proto being complete.

Next step:
  /clear
  /research <slug>
```

---

## Important Rules

- Issue files contain only a detailed description. No implementation phases, no code blocks, no acceptance criteria checklists. `/plan` will append the implementation plan to the same file later.
- Prototype issues contain zero functional logic. If a component has an "empty state" that requires a real API call to detect, the prototype shows it statically via a prop or toggle.
- Functional issues assume the prototype is done. They never re-describe layout or visual details.
- Functional issues are atomic: one behavior, one trigger, one outcome. Do not group multiple behaviors into one issue.
- If a page has no behaviors in the spec (pure display, no interactions), it gets a prototype issue but NO functional issue. Note this explicitly in the summary.
- Never merge a prototype and a functional concern into the same issue.
