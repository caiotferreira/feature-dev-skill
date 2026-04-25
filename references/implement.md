# /implement — Implementation Agent

## Goal

Execute a specific issue's plan phase by phase with precision.
Verify each phase before proceeding to the next.
At the end, present a test summary and ask the user whether to write a documentation log.

---

## Inputs

- `<slug> <issue-id>`: provided as the command argument.
  Examples: `/implement pos-venda proto-01`, `/implement pos-venda func-02`
- `.docs/features/feature-<N>-<slug>/issues/<issue-id>-<slug>.md`: the issue file — contains both
  the description and the implementation plan appended by `/plan`
- `.docs/features/feature-<N>-<slug>/spec.md`: read for broader context

---

## Step-by-Step Process

### Step 1: Resolve the feature folder and issue file

Scan `.docs/features/` for a folder whose name contains the provided slug.
- If exactly one match is found, use it. Announce: `Resolved to: .docs/features/feature-<N>-<slug>/`
- If multiple folders match, list them and ask the user to clarify.
- If no folder matches, report the error and list all existing feature folders.

Then resolve the issue file inside `.docs/features/feature-<N>-<slug>/issues/`:
- Search for a file whose name contains the issue-id.
- If exactly one match is found, use it.
- If no match is found, list all files in `issues/` and ask the user to pick one.

Check that the issue file contains an `## Implementation Plan` section.
If it doesn't, respond:
```
No implementation plan found in <issue-file>.md.
Run /plan <slug> <issue-id> first, then /clear, then /implement <slug> <issue-id>.
```

If no issue-id was provided, list all issue files and ask the user to pick one.

### Step 2: Read the issue file and spec fully

Read in this order, completely:

1. The resolved issue file (description + implementation plan)
2. `spec.md` (for broader behavioral context)

The `## Implementation Plan` section inside the issue file is the source of truth for phases and
success criteria.

Check for any existing checkmarks (`- [x]`) in the plan phases — these mark already-completed work.
If some phases are already done, pick up from the first unchecked item.

### Step 3: Read all referenced files

Before writing any code, read every file that the plan references.
Read them fully. Direct knowledge of the existing code is required to implement correctly.

### Step 4: Check and select the working branch

Before writing any code, determine which branch the implementation will land on.

**4a. List existing branches related to this work**

Run:
```
git branch --list
git branch -r --list
```

Look for branches that match:
- The feature slug (e.g. `feature/pos-venda`, `feat/pos-venda`)
- The issue id (e.g. `proto-01`, `func-02`)
- Any combination (e.g. `feature/pos-venda/proto-01`)

**4b. Ask the user**

Present the findings and ask:

```
Before I start implementing, let me check the branch setup.

Current branch: <current-branch>

Branches related to this work:
  - <branch-a>
  - <branch-b>
  (or: "None found matching this feature/issue")

Which branch should I implement and commit to?
  1. Use current branch (<current-branch>)
  2. Switch to an existing branch (list them)
  3. Create a new branch — what should it be named?

Please choose an option.
```

Wait for the user's answer before continuing.

**4c. Switch or create the branch if needed**

- If the user picks an existing branch: `git checkout <branch>`
- If the user wants a new branch: `git checkout -b <branch-name>`
- If the user picks the current branch: no action needed

Confirm the active branch before proceeding:
```
Now on branch: <branch>. Proceeding with implementation.
```

### Step 5: Build a task list

Create a todo list tracking each phase and its success criteria.
This helps maintain progress across the implementation session.

### Step 6: Implement phase by phase

For each phase in the `## Implementation Plan` section of the issue file:

**6a. Implement the changes**
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

**6b. Run automated verification**
- Run every command listed in the phase's Automated success criteria
- Fix any failures before proceeding — do not move to the next phase with failing checks
- Check off each passing item in the issue file using file edits

**6c. Pause for manual verification**
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

### Step 7: Present test cases

After all phases are complete, present the full test coverage for this issue based on the
Testing Strategy section of the plan:

```
Implementation complete. Here are the test cases for this issue:

## Automated Tests

[For each automated test in the Testing Strategy:]
- File: `path/to/test-file.ext`
- Command: [test command]
- Covers: [what scenario this test validates]

[If no automated tests were defined or implemented, say so explicitly and explain why.]

## Manual Test Checklist

[The complete manual testing checklist from the plan, ready to execute:]
1. [Step]
2. [Step]
...
```

If tests are defined in the plan but were not yet written, ask the user:
```
The plan includes automated tests but they haven't been written yet.
Should I write them now before closing? (y/n)
```

### Step 8: Ask about documentation

After presenting the test cases, ask the user:

```
Would you like me to write an implementation log documenting what was done? (y/n)
```

**If yes**, write `docs/features/summary/<issue-id>-<slug>.md`:

```markdown
# Implementation Log: <Issue Title>

**Date**: YYYY-MM-DD
**Issue**: `.docs/features/feature-<N>-<slug>/issues/<issue-file>.md`
**Feature**: `.docs/features/feature-<N>-<slug>/`
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

### Manual verification confirmed
- [each manual item confirmed by the user]

## Next Steps

[The next issue to implement, e.g. "proto-02 is next" or "func-01 can now start". "None" if this was the last issue.]
```

**If no**, close without writing the log.

### Step 9: Close

After Step 8, respond:

```
Done.

  .docs/features/feature-<N>-<slug>/issues/<issue-file>.md   ✓ (plan executed)
  [docs/features/summary/<issue-id>-<slug>.md                ✓ (if documented)]

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
