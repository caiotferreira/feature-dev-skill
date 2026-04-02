# /plan — Implementation Plan Agent

## Goal

Read a specific issue file, the feature's `spec.md` and `research.md`, then explore the codebase
to produce a detailed, phased implementation plan for that single issue.
A developer (or an AI agent) must be able to execute this plan step by step without ambiguity.

---

## Inputs

- `<slug> <issue-id>`: provided as the command argument.
  Examples: `/plan pos-venda proto-01`, `/plan pos-venda func-02`
- `docs/features/feature-<N>-<slug>/issues/<issue-id>-<page-slug>.md`: the issue to plan
- `docs/features/feature-<N>-<slug>/spec.md`: full feature specification
- `docs/features/feature-<N>-<slug>/research.md`: codebase research (if it exists)

---

## Step-by-Step Process

### Step 1: Resolve the feature folder and issue file

Scan `docs/features/` for a folder whose name contains the provided slug.
- If exactly one match is found, use it. Announce: `Resolved to: docs/features/feature-<N>-<slug>/`
- If multiple folders match, list them and ask the user to clarify.
- If no folder matches, report the error and list all existing feature folders.

Then resolve the issue file inside `docs/features/feature-<N>-<slug>/issues/`:
- Search for a file whose name contains the issue-id (e.g. `proto-01`, `func-02`).
- If exactly one match is found, use it.
- If no match is found, list all files in the `issues/` folder and ask the user to pick one.

If no issue-id was provided, list all files in `issues/` and ask the user to specify one.

### Step 2: Read all context documents fully

Read in this order, completely, before doing anything else:

1. The resolved issue file
2. `docs/features/feature-<N>-<slug>/spec.md`
3. `docs/features/feature-<N>-<slug>/research.md` (if it exists — skip silently if not)

If `spec.md` doesn't exist, respond:
```
spec.md not found in docs/features/feature-<N>-<slug>/.
Run /spec first, then /break, then /plan <slug> <issue-id>.
```

### Step 3: Explore the codebase for this issue's scope

Based on what the issue requires, explore the relevant parts of the codebase:

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

```
Issue: <issue-id> — <Issue Title>
Type: prototype | functional

Proposed phases:

Phase 1: [name] — [one sentence goal]
Phase 2: [name] — [one sentence goal]
Phase 3: [name] — [one sentence goal]

Does this look right? Should I adjust before I write the full plan?
```

Wait for confirmation before proceeding.

### Step 7: Write the plan file

Write `docs/features/feature-<N>-<slug>/plan-<issue-id>-<page-slug>.md` with this structure:

```markdown
# Plan: <Issue Title>

**Date**: YYYY-MM-DD
**Issue**: `docs/features/feature-<N>-<slug>/issues/<issue-file>.md`
**Spec**: `docs/features/feature-<N>-<slug>/spec.md`
**Feature**: feature-<N>-<slug>
**Type**: prototype | functional
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

```
Plan complete. Artifact saved to:
  docs/features/feature-<N>-<slug>/plan-<issue-id>-<page-slug>.md

Next step:
  /clear
  /implement <slug> <issue-id>
```

---

## Important Rules

- Never start implementation during this step.
- Every decision must be explicit in the plan before you finalize it.
- All open questions must be resolved before writing.
- For prototype issues: the plan must never include API calls, database writes, or business logic.
- For functional issues: the plan must reference the specific prototype files it will modify.
- Code blocks in the plan should be illustrative but accurate — read the actual files to write them.
- Success criteria must separate automated checks (runnable commands) from manual checks (human verification).
- Each plan file is scoped to exactly one issue. Never plan two issues in the same file.
