---
name: feature-dev
description: >
  Five-command workflow for developing new features in Claude Code: spec, break, research, plan, and implement.
  Use this skill whenever the user wants to build a new feature, says "nova feature", "quero implementar",
  "criar funcionalidade", "desenvolver feature", or invokes /spec, /break, /research, /plan, or /implement.
  Also triggers for any multi-step feature development flow that involves specification, issue breakdown,
  codebase research, implementation planning, and code execution.
  Always use this skill when the user references any of the five workflow commands.
---

# Feature Dev

A five-command workflow to build new features with full specification, structured breakdown into issues,
codebase research, per-issue planning, and clean implementation.
Each command is designed to be run in a fresh context window (`/clear` between them), and all artifacts are
organized under `docs/features/` in the project root, with auto-numbered folders.

---

## Folder Structure

```
docs/features/
├── feature-1-pos-venda-clientes/
│   ├── spec.md
│   ├── issues/
│   │   ├── proto-01-tela-dashboard.md
│   │   ├── proto-02-tela-clientes.md
│   │   ├── func-01-tela-dashboard.md
│   │   └── func-02-tela-clientes.md
│   ├── plan-proto-01-tela-dashboard.md
│   ├── plan-func-01-tela-dashboard.md
│   ├── implementation-proto-01-tela-dashboard.md
│   └── implementation-func-01-tela-dashboard.md
└── feature-2-checkout-flow/
    └── ...
```

Folder naming convention: `feature-<N>-<slug>` where N is an auto-incremented integer.

---

## Folder Numbering Rules

### On `/spec` (creates the folder)

Before creating any file, scan `docs/features/` for folders matching `feature-<N>-*`.
Extract all N values, take the maximum, and use N+1 for the new folder.
If no folders exist yet, start at 1.

If the user explicitly mentions a number (e.g. "isso é a feature 5", "feature number 5"), use that number directly
instead of auto-incrementing, even if it skips ahead.

Examples:
- No folders exist → create `feature-1-pos-venda-clientes/`
- Folders 1 and 2 exist → create `feature-3-checkout-flow/`
- User says "feature 5" → create `feature-5-checkout-flow/` regardless of what exists

### On `/break`, `/plan`, and `/implement` (resolve existing folder)

The user passes only the slug (e.g. `/plan pos-venda proto-01`).
Search `docs/features/` for any folder whose name contains the slug.
Use that folder — do not require the user to type the number prefix.

If multiple folders match, list them and ask the user to clarify.
If no folder matches, report the error and list available feature folders.

---

## The Five Commands

### `/spec <description>`

**Purpose**: Transform the feature description into a structured specification document covering
Overview, Pages, Components, and Behaviors (with GIVEN/WHEN/THEN scenarios).

**When to use**: First step for every new feature. No code is touched.

**Full instructions**: See `references/spec.md`

---

### `/break <slug>`

**Purpose**: Read `spec.md` and generate two batches of issue files inside `issues/`:
first prototype issues (visual only, no functionality), then functional issues (wiring each
prototype to real data, APIs, and backend logic).

**When to use**: After `/spec` completes and you've done `/clear`.

**Full instructions**: See `references/break.md`

---

### `/research <slug>`

**Purpose**: Understand the codebase impact for the entire feature before planning individual issues.
Reads `spec.md` as context before exploring the codebase.

**When to use**: After `/break` completes and you've done `/clear`. Optional but recommended
before planning the first issue of a feature.

**Full instructions**: See `references/research.md`

---

### `/plan <slug> <issue-id>`

**Purpose**: Read a specific issue file, the feature's `spec.md` and `research.md`, explore the
codebase, and produce a phased implementation plan scoped to that single issue.

**When to use**: Before implementing each issue. Run once per issue.

**Full instructions**: See `references/plan.md`

---

### `/implement <slug> <issue-id>`

**Purpose**: Execute the issue's plan file phase by phase, verify each phase, and write an
implementation log.

**When to use**: After `/plan` completes for a specific issue and you've done `/clear`.

**Full instructions**: See `references/implement.md`

---

## Quick Reference

| Step | Command | Reads | Writes |
|------|---------|-------|--------|
| 1 | `/spec <description>` | nothing | `spec.md` |
| 2 | `/break <slug>` | `spec.md` | `issues/proto-NN-*.md` + `issues/func-NN-*.md` |
| 3 | `/research <slug>` | `spec.md` + codebase | `research.md` |
| 4 | `/plan <slug> <issue-id>` | issue file + `spec.md` + `research.md` + codebase | `plan-<issue-id>-*.md` |
| 5 | `/implement <slug> <issue-id>` | plan file + issue file + `spec.md` | code + `implementation-<issue-id>-*.md` |

---

## Recommended Execution Order

```
/spec <description>
/clear
/break <slug>
/clear
/research <slug>          ← once per feature
/clear
/plan <slug> proto-01
/clear
/implement <slug> proto-01
/clear
/plan <slug> proto-02
/clear
/implement <slug> proto-02
...                       ← finish all proto issues
/clear
/plan <slug> func-01
/clear
/implement <slug> func-01
...                       ← finish all func issues
```

---

## Conventions

- Always create `docs/features/` if it does not exist.
- Always create the feature folder before writing any artifact inside it.
- Always create the `issues/` subfolder before writing any issue file.
- Slugs are lowercase kebab-case derived from the feature description.
- Never skip steps or merge two steps into one context window.
- Prototype issues must never contain real API calls, database writes, or business logic.
- Functional issues must never re-implement visual work already covered by the corresponding prototype.
- If `/plan` or `/implement` are called without arguments, list existing feature folders and issue files and ask the user to pick.
