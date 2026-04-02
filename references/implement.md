# /implement — Implementation Agent

## Goal

Execute a specific issue's plan file phase by phase with precision.
Verify each phase before proceeding to the next.
Write a final implementation log documenting what was done.

---

## Inputs

- `<slug> <issue-id>`: provided as the command argument.
  Examples: `/implement pos-venda proto-01`, `/implement pos-venda func-02`
- `docs/features/feature-<N>-<slug>/plan-<issue-id>-<page-slug>.md`: must exist before this command runs
- `docs/features/feature-<N>-<slug>/issues/<issue-id>-<page-slug>.md`: read for acceptance criteria
- `docs/features/feature-<N>-<slug>/spec.md`: read for broader context

---

## Step-by-Step Process

### Step 1: Resolve the feature folder and plan file

Scan `docs/features/` for a folder whose name contains the provided slug.
- If exactly one match is found, use it. Announce: `Resolved to: docs/features/feature-<N>-<slug>/`
- If multiple folders match, list them and ask the user to clarify.
- If no folder matches, report the error and list all existing feature folders.

Then resolve the plan file inside `docs/features/feature-<N>-<slug>/`:
- Search for a file whose name matches `plan-<issue-id>-*.md`.
- If exactly one match is found, use it.
- If no match is found, respond:
  ```
  plan-<issue-id>-*.md not found in docs/features/feature-<N>-<slug>/.
  Run /plan <slug> <issue-id> first, then /clear, then /implement <slug> <issue-id>.
  ```

If no issue-id was provided, list all `plan-*.md` files in the feature folder and ask the user to pick one.

### Step 2: Read the plan, issue, and spec fully

Read in this order, completely:

1. `plan-<issue-id>-<page-slug>.md`
2. `issues/<issue-id>-<page-slug>.md` (acceptance criteria are the ground truth)
3. `spec.md` (for broader behavioral context)

Check for any existing checkmarks (`- [x]`) in the plan — these mark already-completed work.
If some phases are already done, pick up from the first unchecked item.

### Step 3: Read all referenced files

Before writing any code, read every file that the plan references.
Read them fully. Direct knowledge of the existing code is required to implement correctly.

### Step 4: Build a task list

Create a todo list tracking each phase and its success criteria.
This helps maintain progress across the implementation session.

### Step 5: Implement phase by phase

For each phase in the plan:

**5a. Implement the changes**
- Make exactly the changes described in the plan for this phase
- Follow the patterns identified in `research.md` and referenced files
- For prototype issues: never add real API calls, database access, or business logic — even if it would be easy
- For functional issues: never re-implement visual layout already covered by the prototype

If reality diverges from the plan (file structure changed, pattern is different), STOP.
Report the mismatch clearly:
```
Mismatch in Phase [N]:
Plan expected: [what the plan says]
Found instead: [actual situation]
Impact: [why this matters]

How should I proceed?
```
Wait for guidance before continuing.

**5b. Run automated verification**
- Run every command listed in the phase's "Automated" success criteria
- Fix any failures before proceeding — do not move to the next phase with failing checks
- Check off each passing item in the plan file using file edits

**5c. Pause for manual verification**
After all automated checks pass, pause and tell the user:

```
Phase [N] complete — ready for manual verification.

Automated checks passed:
- [list of commands that passed]

Please verify manually:
- [list of manual checklist items from the plan]

Let me know when manual testing is done so I can proceed to Phase [N+1].
```

Wait for explicit confirmation before starting the next phase.

Exception: if the user instructed you to run multiple phases consecutively (e.g. "implement all phases"),
skip the pause until the final phase.

### Step 6: Verify issue acceptance criteria

After all phases are complete, go back to the issue file and check each acceptance criterion:
- Run any automated checks listed there
- For criteria that require manual verification, list them explicitly for the user to confirm

Do not write the implementation log until the user confirms all manual acceptance criteria are met.

### Step 7: Write the implementation log

Write `docs/features/feature-<N>-<slug>/implementation-<issue-id>-<page-slug>.md`:

```markdown
# Implementation Log: <Issue Title>

**Date**: YYYY-MM-DD
**Issue**: `docs/features/feature-<N>-<slug>/issues/<issue-file>.md`
**Plan**: `docs/features/feature-<N>-<slug>/plan-<issue-id>-<page-slug>.md`
**Feature**: feature-<N>-<slug>
**Type**: prototype | functional
**Status**: complete

---

## Summary

[2–3 sentences describing what was implemented for this issue]

## Phases Completed

### Phase 1: <name>
- **Status**: complete
- **Files changed**: `path/file`, `path/file`
- **Notes**: [any deviations from the plan or notable decisions]

### Phase 2: <name>
...

## Deviations from Plan

[Document anything done differently from the plan and why. "None" if plan was followed exactly.]

## Files Created or Modified

| File | Change Type | Summary |
|------|-------------|---------|
| `path/file` | created | description |
| `path/file` | modified | description |

## Verification

### Automated checks passed
- `command` ✓

### Acceptance criteria confirmed
- [ ] [each criterion from the issue file, checked off]

## Next Steps

[The next issue to implement, e.g. "proto-02 is next" or "func-01 can now start". "None" if this was the last issue.]
```

### Step 8: Close

After writing the implementation log, respond:

```
Implementation complete.

  docs/features/feature-<N>-<slug>/
  └── issues/
      └── <issue-file>.md       ✓ (acceptance criteria met)
  plan-<issue-id>-<page-slug>.md ✓
  implementation-<issue-id>-<page-slug>.md ✓

Next step:
  /clear
  /plan <slug> <next-issue-id>
```

---

## Important Rules

- Never skip phases or merge them unless the user explicitly asks.
- Never proceed past a phase with failing automated checks.
- Never check off manual verification items until the user explicitly confirms them.
- For prototype issues: if you find yourself writing a fetch call, a database query, or a form submit handler, stop. That belongs in the functional issue.
- For functional issues: if you find yourself re-doing layout work the prototype already covers, stop. Reference the existing component instead.
- If the plan is ambiguous or the codebase doesn't match expectations, stop and ask.
- The plan is a guide — your judgment matters. If following the plan literally would produce wrong code, raise the issue rather than writing bad code.
- Keep the implementation log factual: document what happened, not what was supposed to happen.
