---
name: feature-dev-implement
description: Use when the user invokes /implement, says "implementar", "executar plano", "codar", or wants to execute a planned issue with test evidence and final review.
---

# /implement — Implementation Agent

## Goal

Execute one planned issue with focused TDD, factual evidence, and one independent final review.
Keep the run resumable without per-phase artifacts or routine manual pauses.

## Inputs

- `<slug> <issue-id>`, for example `/implement pos-venda func-02`
- `.docs/features/feature-<N>-<slug>/issues/<issue-id>-<slug>.md` — issue plus plan
- `.docs/features/feature-<N>-<slug>/spec.md` — behavioral authority

When `/plan <slug>` was intentionally run in issueless mode, the input is instead
`.docs/features/feature-<N>-<slug>/plan.md`; its run identifier is `feature-plan`.

## Process

### 1. Resolve and read the issue

Find the single feature folder matching `<slug>`. With an issue ID, resolve its single matching
issue file. Without one, resolve `plan.md`, but only if no issue files exist; otherwise list issue
files and ask the user to choose one. If any required source is ambiguous or absent, list
candidates and ask. Confirm that the resolved source has an `## Implementation Plan` (or is the
top-level issueless plan); otherwise direct the user to `/plan <slug> <issue-id>`.

Read, in full, the issue (including all `Automated Test Contract` sections), `spec.md`, and every
file referenced by the plan before editing. If reality materially diverges from the plan, stop and
report the expected state, actual state, and impact; do not improvise a new scope.

### 2. Create or resume the minimal run workspace

For an issue run, use exactly this persistent directory:

```text
.docs/features/feature-<N>-<slug>/issues/.runs/<issue-id>/
├── progress.md
├── implement-report.md
└── final-review.md
```

For the explicit issueless mode, use `.docs/features/feature-<N>-<slug>/.runs/feature-plan/`
with the same three files. This is the only non-issue exception to the issue workspace pattern.

On a new run, record `git rev-parse HEAD` and the current branch in `progress.md`, create
`implement-report.md` with status `in progress`, and create `final-review.md` with status
`pending`. On resume, read the three files before acting.
Resume at the first incomplete phase; a completed phase needs factual GREEN and phase-check
evidence, not only a checkbox. Do not create per-phase files unless technically necessary.

`progress.md` is deliberately brief and is the recovery source of truth:

```markdown
# Run: <issue-id>

- Base commit: `<sha>`
- Branch: `<branch>`
- Final commit: `<sha or not yet recorded>`
- Phase 1: complete — `<focused command>` — `<factual result>`
- Finding: `<severity and summary>` — `<fixed | deferred with reason>`
- Decision/deviation: `<what changed and why>`
```

Do not change branches as a normal implementation step. Ask before an external, irreversible, or
shared-branch operation.

### 3. Execute phases in order

Create a short task list from the plan. For every phase, implement only its stated scope:

- Prototype issues never gain real API calls, database access, or business logic.
- Functional issues reuse the prototype rather than redoing its visual layout.
- Failed phase checks are fixed before the next phase.

#### Functional phase: light TDD

When a phase has an `Automated Test Contract`, follow this order:

1. Read the contract.
2. Create or change the named test before production code.
3. Run the focused command and confirm it fails for the expected missing behavior (RED).
4. Implement the minimum needed to pass.
5. Re-run the focused command (GREEN).
6. Run the contract’s phase-specific automated checks.
7. Add factual evidence to `implement-report.md` and a one-line phase result to `progress.md`.

Use this concise report section once per functional phase:

```markdown
### Phase <N> — Test evidence

- RED: `<command>` — failed because `<behavior was not implemented>`
- GREEN: `<command>` — `<factual result>`
- Phase checks: `<commands>` — `<factual result>`
```

Tests assert observable behavior and use expectations independent of the implementation. Prefer
real components and rules over excessive mocks; include relevant errors and edge cases. A test
that cannot fail for a real regression does not protect the change and must be improved.

#### Visual exception

For a plan’s explicit pure-visual exception, run its lint/typecheck/build checks and record the
results. Carry its concrete visual checks into the final manual checklist. Never add a fake unit
test merely to inflate coverage. Meaningful local behavior in a prototype may still merit a
component test.

#### Pause policy

Continue through ordinary phases without asking for confirmation. Pause only for material visual
or UX judgment, an unautomated e2e flow, migration or data change, permission/security/payment or
other high-risk validation, or a product decision that requires the user.

### 4. Run fresh final verification

After all phases, run the final commands named by the plan’s contracts once, freshly. During
implementation, run only focused tests; never run the full suite after each small edit. Before
closing, earlier output, checkboxes, “should work,” and another agent’s report are not evidence.

Update `implement-report.md` to the following factual shape:

```markdown
# Implementation Report: <Issue Title>

**Issue:** `<issue-file>`
**Feature:** `feature-<N>-<slug>`
**Type:** prototype | functional
**Status:** ready for review | blocked

## Phases and test evidence
### Phase 1: <name>
- RED / GREEN / phase checks: [factual results]

## Final verification
- `<command>` — [exit result and relevant output]

## Consolidated manual checklist
- [all manual and visual items from every phase]

## Deviations, decisions, and unresolved risks
- [or `None`]
```

Set the final commit in `progress.md`. If a final command fails, record it and do not close.

### 5. Dispatch one independent final reviewer

After fresh final verification, generate a base-to-current-worktree diff with
`git diff <base-commit>`, where the base is recorded in `progress.md`. This includes committed,
staged, and unstaged issue changes; do not use `<base>..HEAD` alone when work is uncommitted.
Dispatch exactly one independent, read-only reviewer — never the implementer and never one reviewer
per phase. Give it the paths to the spec, issue/plan, contracts, `implement-report.md`, and that
issue diff. It writes `final-review.md` in this form:

```markdown
## Spec compliance
- ✅ | ❌ — [reason]

## Quality
- Approved | Needs fixes

## Test assessment
- [contracts, observable coverage, RED/GREEN evidence, and final commands]

## Findings
### Critical
- `file:line` — [finding and impact]
### Important
- `file:line` — [finding and impact]
### Minor
- `file:line` — [finding and impact]
```

The reviewer compares the spec, plan, contracts, implementation report, and diff. Its report must
include `file:line` for every finding. Critical and Important findings block closure. Fix them,
then re-run focused tests/checks covering the amended code and update the factual report.

Do not request re-review automatically. Dispatch a second independent review only if the fix is
structural; involves security, permissions, payments, concurrency, or critical data; substantially
changes the diff; or reveals a serious misunderstanding of the spec. Record each finding and its
status in `progress.md`.

### 6. Close with evidence

An issue is ready to close only when final commands have fresh successful output, `final-review.md`
has no unresolved Critical/Important finding, and all three run artifacts are current. Present the
consolidated manual checklist, the evidence summary, and the next issue. Do not offer an optional
log: `implement-report.md` is the durable record.

## Important Rules

- Never skip or merge phases unless the user explicitly asks.
- A functional behavior cannot close without its test contract, RED/GREEN evidence, and fresh
  final verification output.
- Do not claim completion from old output, checkboxes, or a subagent’s assertion.
- Use focused tests while implementing; run full-suite or other final checks only as the plan says.
- One independent final review is mandatory per issue. Re-review is exceptional under Step 5.
- Keep reports factual: commands, results, decisions, deviations, and unresolved risks — not what
  was merely intended to happen.
