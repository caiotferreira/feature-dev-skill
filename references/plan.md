# /plan — Implementation Plan Agent

## Goal

Read a specific issue file, the feature's `spec.md` and `research.md`, then explore the codebase
to produce a detailed, phased implementation plan for that single issue.
A developer (or an AI agent) must be able to execute this plan step by step without ambiguity.

---

## Inputs

- `<slug> <issue-id>`: provided as the command argument.
  Examples: `/plan pos-venda proto-01`, `/plan pos-venda func-02`
  The `<issue-id>` is optional — if omitted and no issues exist, a feature-level plan is produced from `research.md`.
- `docs/features/feature-<N>-<slug>/issues/<issue-id>-<page-slug>.md`: the issue to plan (optional)
- `docs/features/feature-<N>-<slug>/spec.md`: full feature specification
- `docs/features/feature-<N>-<slug>/research.md`: codebase research (required when no issue is provided)

---

## Step-by-Step Process

### Step 1: Resolve the feature folder and issue file

Scan `docs/features/` for a folder whose name contains the provided slug.
- If exactly one match is found, use it. Announce: `Resolved to: docs/features/feature-<N>-<slug>/`
- If multiple folders match, list them and ask the user to clarify.
- If no folder matches, report the error and list all existing feature folders.

Then resolve the issue file:

**If an issue-id was provided:**
- Search inside `docs/features/feature-<N>-<slug>/issues/` for a file whose name contains the issue-id.
- If exactly one match is found, use it.
- If no match is found, list all files in the `issues/` folder and ask the user to pick one.

**If no issue-id was provided:**
- Check whether `docs/features/feature-<N>-<slug>/issues/` exists and contains any files.
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
2. `docs/features/feature-<N>-<slug>/spec.md`
3. `docs/features/feature-<N>-<slug>/research.md` (if it exists — skip silently if not)

**Issueless mode:**
1. `docs/features/feature-<N>-<slug>/spec.md`
2. `docs/features/feature-<N>-<slug>/research.md` (required — if it doesn't exist, respond:
   ```
   research.md not found. Run /research <slug> first, then /plan <slug>.
   ```
   and stop)

If `spec.md` doesn't exist in either mode, respond:
```
spec.md not found in docs/features/feature-<N>-<slug>/.
Run /spec first, then /plan <slug>.
```

### Step 3: Explore the codebase for this issue's scope

Based on what the issue (or feature, in issueless mode) requires, explore the relevant parts of the codebase:

**For prototype issues**:
- Find existing UI components that can be reused (look for component libraries, design system files, similar screens)
- Identify the routing pattern to add a new page
- Find 1–2 existing pages as reference for file structure and naming conventions

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
2. Component structure (layout, composition of sub-components)
3. All visual states (empty, loading, filled, error — driven by local props or toggle)

**For functional issues**, typical phase order:
1. Data layer (API route, database query, or service function)
2. Data fetching in the component (replacing static data with real calls)
3. Form submission and mutations
4. Error handling and edge cases

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

### Step 7: Write the plan file

**Issue mode:** Write `docs/features/feature-<N>-<slug>/plan-<issue-id>-<page-slug>.md`

**Issueless mode:** Write `docs/features/feature-<N>-<slug>/plan.md`

Use this structure:

```markdown
# Plan: <Issue Title or Feature Name>

**Date**: YYYY-MM-DD
**Issue**: `docs/features/feature-<N>-<slug>/issues/<issue-file>.md` ← omit in issueless mode
**Spec**: `docs/features/feature-<N>-<slug>/spec.md`
**Research**: `docs/features/feature-<N>-<slug>/research.md`
**Feature**: feature-<N>-<slug>
**Type**: prototype | functional | feature ← use "feature" in issueless mode
**Mode**: issue-based | issueless
**Status**: ready

---

## Overview

[2–3 sentences: what this plan implements and why, scoped to this issue only]

## Desired End State

[Concrete description of what success looks like for this issue specifically]

## What We Are NOT Doing

[Explicit out-of-scope items — especially important to separate prototype from functional concerns]

---

## Implementation Phases

---

## Phase 1: <Descriptive Name>

### Goal
[One sentence]

### Changes

#### `path/to/file.ext`
**Change type**: new file | modify | delete
**Summary**: [what changes and why]

```language
// Specific code block showing the change or addition
```

### Success Criteria

#### Automated
- [ ] [command that must pass]

#### Manual
- [ ] [observable behavior to verify by hand]

> After automated verification passes, pause and ask the user to confirm manual testing before proceeding.

---

## Phase 2: <Descriptive Name>

[Same structure as Phase 1]

---

## Testing Strategy

### Automated
- [what to test, which file, which command]

### Manual Testing Checklist
1. [Step-by-step flow to verify this specific issue is complete]

## References

- Issue: `docs/features/feature-<N>-<slug>/issues/<issue-file>.md`
- Spec: `docs/features/feature-<N>-<slug>/spec.md`
- [Any specific file:line references used as anchors during planning]
```

### Step 8: Confirm and close

After writing the plan file, respond:

**Issue mode:**
```
Plan complete. Artifact saved to:
  docs/features/feature-<N>-<slug>/plan-<issue-id>-<page-slug>.md

Next step:
  /clear
  /implement <slug> <issue-id>
```

**Issueless mode:**
```
Plan complete. Artifact saved to:
  docs/features/feature-<N>-<slug>/plan.md

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
- In issueless mode: the plan covers the full feature scope defined in `spec.md` and `research.md`. It is not tied to a single issue, but must still be broken into clearly scoped phases.
- Code blocks in the plan should be illustrative but accurate — read the actual files to write them.
- Success criteria must separate automated checks (runnable commands) from manual checks (human verification).
- In issue mode: each plan file is scoped to exactly one issue. Never plan two issues in the same file.
- Running `/break` is not required before `/plan`. When skipped, issueless mode applies.
