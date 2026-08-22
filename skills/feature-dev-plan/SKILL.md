---
name: feature-dev-plan
description: Use when the user invokes /plan, says "criar plano", "planejar issue", "planejar implementação", or wants to write a phased implementation plan for a specific issue file before coding.
---

# /plan — Implementation Plan Agent

## Goal

Read a specific issue file, the feature's `spec.md` and `research.md`, then explore the codebase
to produce a detailed, phased implementation plan. The plan is appended directly to the issue file —
no separate plan file is created. A developer (or AI agent) must be able to execute it step by step
without ambiguity.

---

## Inputs

- `<slug> <issue-id>`: provided as the command argument.
  Examples: `/plan pos-venda proto-01`, `/plan pos-venda func-02`
  The `<issue-id>` is optional — if omitted and no issues exist, a feature-level plan is produced from `research.md`.
- `.docs/features/feature-<N>-<slug>/issues/<issue-id>-<slug>.md`: the issue to plan (optional)
- `.docs/features/feature-<N>-<slug>/spec.md`: full feature specification
- `.docs/features/feature-<N>-<slug>/research.md`: codebase research (required when no issue is provided)

---

## Step-by-Step Process

### Step 1: Resolve the feature folder and issue file

Scan `.docs/features/` for a folder whose name contains the provided slug.
- If exactly one match is found, use it. Announce: `Resolved to: .docs/features/feature-<N>-<slug>/`
- If multiple folders match, list them and ask the user to clarify.
- If no folder matches, report the error and list all existing feature folders.

Then resolve the issue file:

**If an issue-id was provided:**
- Search inside `.docs/features/feature-<N>-<slug>/issues/` for a file whose name contains the issue-id.
- If exactly one match is found, use it.
- If no match is found, list all files in the `issues/` folder and ask the user to pick one.

**If no issue-id was provided:**
- Check whether `.docs/features/feature-<N>-<slug>/issues/` exists and contains any files.
- If issues exist, list them and ask the user to specify one.
- If no issues exist (folder is absent or empty), ask:
  ```
  No issues found for feature-<N>-<slug>. /break has not been run.

  Do you want to proceed and generate a plan directly from research.md?
  This is suitable for simple implementations that don't need issue breakdown. (y/n)
  ```
  - If the user says **no**: stop and suggest running `/break <slug>` first.
  - If the user says **yes**: continue in **issueless mode** — the plan will be based on `spec.md` + `research.md` only.

### Step 2: Read all context documents fully

Read in this order, completely, before doing anything else:

**Issue mode (normal):**
1. The resolved issue file
2. `.docs/features/feature-<N>-<slug>/spec.md`
3. `.docs/features/feature-<N>-<slug>/research.md` (if it exists — skip silently if not)

**Issueless mode:**
1. `.docs/features/feature-<N>-<slug>/spec.md`
2. `.docs/features/feature-<N>-<slug>/research.md` (required — if it doesn't exist, respond:
   ```
   research.md not found. Run /research <slug> first, then /plan <slug>.
   ```
   and stop)

If `spec.md` doesn't exist in either mode, respond:
```
spec.md not found in .docs/features/feature-<N>-<slug>/.
Run /spec first, then /plan <slug>.
```

### Step 3: Explore the codebase for this issue's scope

Based on what the issue (or feature, in issueless mode) requires, explore the relevant parts of the codebase.

**For prototype issues**:
- For each component in the issue description, check whether it already exists in the codebase
  (use the component inventory in `research.md` as a starting point, then verify directly)
- Identify the routing pattern to add a new page
- Find 1–2 existing pages as reference for file structure and naming conventions
- Find existing UI components that can be reused (component libraries, design system files)

**For functional issues**:
- Find the existing prototype files that this issue will wire up
- Identify data fetching patterns (how existing pages fetch data)
- Find relevant database models, schemas, or API routes
- Identify form submission patterns and error handling conventions
- Find any existing service or hook that handles similar logic

**In issueless mode**:
- Use `research.md` as the primary codebase map — avoid redundant re-exploration of what it already covers
- Focus additional exploration only on gaps or specific files referenced in `spec.md` that `research.md` doesn't address

Read all relevant files fully. Never use offset or truncation.

### Step 4: Resolve open questions

If the issue file or spec has open questions, or if the codebase exploration reveals ambiguities:
- Answer each one from your direct codebase reading if possible
- For any that require a human decision, ask the user before continuing
- Do not write the plan with unresolved questions

### Step 5: Design the phases

Break implementation into phases where:
- Each phase is independently testable
- Each phase has a clear goal
- Phases are ordered by dependency

**For prototype issues**, typical phase order:
1. Route and page shell (file creation, routing registration)
2. Component structure (layout, composition of sub-components — create any that don't exist yet)
3. All visual states (empty, loading, filled, error — driven by local props or toggle)

**For functional issues**, typical phase order:
1. Data layer (API route, database query, or service function)
2. Data fetching in the component (replacing static data with real calls)
3. Form submission and mutations
4. Error handling and edge cases

Classify each phase before proposing it:

- A phase that changes functional behavior **must** include an `Automated Test Contract`.
- Purely visual prototype work does not need an artificial unit test; define relevant lint,
  typecheck, or build commands plus visual/manual proof instead.
- Meaningful local prototype behavior (modal, filter, selection, or client-side validation) may
  have a component test.

For functional phases, the contract must name test files, level (`unit`, `integration`, or `e2e`),
observable happy-path/error/edge behavior proportional to risk, one focused command, and the
final issue commands. Detect the project’s existing scripts and package manager; `pnpm` in an
example is never an assumption.

### Step 6: Present structure for confirmation

Before writing the full plan, show the user:

**Issue mode:**
```
Issue: <issue-id> — <Issue Title>
Type: prototype | functional

Proposed phases:

Phase 1: [name] — [one sentence goal]
Phase 2: [name] — [one sentence goal]
Phase 3: [name] — [one sentence goal]

Does this look right? Should I adjust before I write the full plan?
```

**Issueless mode:**
```
Feature: <slug> (no issue breakdown — planning from research.md)

Proposed phases:

Phase 1: [name] — [one sentence goal]
Phase 2: [name] — [one sentence goal]
Phase 3: [name] — [one sentence goal]

Does this look right? Should I adjust before I write the full plan?
```

Wait for confirmation before proceeding.

### Step 7: Append the plan to the issue file

**Issue mode:** Append the plan section directly to `.docs/features/feature-<N>-<slug>/issues/<issue-file>.md`.

**Issueless mode:** Write `.docs/features/feature-<N>-<slug>/plan.md` as a standalone file.

For issue mode, append this block at the end of the existing issue file:

```markdown
---

## Implementation Plan

**Planned**: YYYY-MM-DD
**Spec**: `.docs/features/feature-<N>-<slug>/spec.md`
**Research**: `.docs/features/feature-<N>-<slug>/research.md`
**Status**: planned

### Overview

[2–3 sentences: what this plan implements and why, scoped to this issue only]

### Desired End State

[Concrete description of what success looks like for this issue specifically]

### What We Are NOT Doing

[Explicit out-of-scope items — especially important to separate prototype from functional concerns]

---

### Phase 1: <Descriptive Name>

#### Goal
[One sentence]

#### Changes

##### `path/to/file.ext`
**Change type**: new file | modify | delete
**Summary**: [what changes and why]

```language
// Specific code block showing the change or addition
```

#### Automated Test Contract

- **Test file:** `path/to/behavior.test.ext`
- **Level:** unit | integration | e2e
- **Behaviors:**
  - [observable happy-path behavior]
  - [relevant error behavior]
  - [relevant boundary behavior]
- **Focused command:** `[project test command] path/to/behavior.test.ext`
- **Final verification:** `[relevant full test, lint, typecheck, and/or build commands]`

For a valid visual-only exception, use this explicit replacement:

```markdown
#### Automated Test Contract

**Exception:** Purely visual prototype work; no meaningful automated behavior boundary changed.
**Automated checks:** [lint, typecheck, and/or build commands]
**Manual/visual proof:** [specific states or viewport checks]
```

#### Success Criteria

##### Automated
- [ ] [focused command and phase-specific checks from the contract]

##### Manual
- [ ] [observable behavior to verify by hand]

> Do not pause after ordinary phases. Consolidate manual checks at the issue end. Pause only for
> material visual/UX judgment, an unautomated e2e flow, migration/data change, permissions,
> security, payment/high-risk work, or a product decision that needs the user.

---

### Phase 2: <Descriptive Name>

[Same structure as Phase 1]

---

### Testing Strategy

#### Automated
- [all phase contracts, focused commands, and final issue checks]
- Final verification must be fresh immediately before closing; earlier output and checked boxes
  are not evidence.

#### Manual Testing Checklist
1. [Step-by-step flow to verify this specific issue is complete]

### References

- Spec: `.docs/features/feature-<N>-<slug>/spec.md`
- [Any specific file:line references used as anchors during planning]
```

For issueless mode, use the same structure but wrap it in a top-level heading:

```markdown
# Plan: <Feature Name>

**Date**: YYYY-MM-DD
**Spec**: `.docs/features/feature-<N>-<slug>/spec.md`
**Research**: `.docs/features/feature-<N>-<slug>/research.md`
**Feature**: feature-<N>-<slug>
**Mode**: issueless
**Status**: planned

[same sections as above]
```

### Step 8: Confirm and close

After appending (or writing) the plan, respond:

**Issue mode:**
```
Plan complete. Appended to:
  .docs/features/feature-<N>-<slug>/issues/<issue-file>.md

Next step:
  /clear
  /implement <slug> <issue-id>
```

**Issueless mode:**
```
Plan complete. Artifact saved to:
  .docs/features/feature-<N>-<slug>/plan.md

Next step:
  /clear
  /implement <slug>
```

---

## Important Rules

- Never start implementation during this step.
- Every decision must be explicit in the plan before you finalize it.
- All open questions must be resolved before writing.
- For prototype issues: the plan must never include API calls, database writes, or business logic.
- For functional issues: the plan must reference the specific prototype files it will modify.
- For prototype issues: if a component doesn't exist in the codebase, the plan must include a phase to create it. Never assume a component exists without verifying.
- In issueless mode: the plan covers the full feature scope defined in `spec.md` and `research.md`.
- Code blocks in the plan should be illustrative but accurate — read the actual files to write them.
- Success criteria must separate automated checks (runnable commands) from manual checks (human verification).
- Every functional phase must contain `#### Automated Test Contract`. An omission is valid only
  when it states the scoped visual exception and why no automated boundary is meaningful.
- A contract must identify behaviors and a test file; a generic test-suite command is not a
  substitute for regression coverage.
- Contracts test observable behavior and avoid mock-call assertions, implementation-coupled
  expectations, excessive mocks, and coverage-only tests.
- Functional/data contracts cover relevant happy path, error path, and edge case proportionally;
  static visual composition does not get a fake test.
- Each plan is scoped to exactly one issue. Never plan two issues in the same session.
- Running `/break` is not required before `/plan`. When skipped, issueless mode applies.
