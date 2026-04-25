---
name: feature-dev-research
description: Use when the user invokes /research, says "pesquisar codebase", "mapear impacto", "explorar código", or needs to analyze the codebase impact of a feature before planning individual issues.
---

# /research — Codebase Research Agent

## Goal

Understand the full codebase impact of the feature before planning individual issues.
Reads `spec.md` and all issue files for context, then explores the codebase systematically.
Produces a `research.md` document that becomes the reference for all subsequent `/plan` steps.

---

## Inputs

- `<slug>`: provided as the command argument
- `.docs/features/feature-<N>-<slug>/spec.md`: full feature specification
- `.docs/features/feature-<N>-<slug>/issues/`: all issue files created by `/break`

---

## Step-by-Step Process

### Step 1: Resolve the feature folder

Scan `.docs/features/` for a folder whose name contains the provided slug.
- Match is case-insensitive and partial: `/research pos-venda` should find `feature-3-pos-venda-clientes`.
- If exactly one match is found, use it. Announce: `Resolved to: .docs/features/feature-<N>-<slug>/`
- If multiple folders match, list them and ask the user to clarify.
- If no folder matches, report the error and list all existing feature folders.

If no slug was provided, list all folders under `.docs/features/` and ask the user to pick one.

### Step 2: Read spec.md and all issue files fully

Read in this order, completely, before exploring the codebase:

1. `.docs/features/feature-<N>-<slug>/spec.md`
2. All files inside `.docs/features/feature-<N>-<slug>/issues/` (proto and func issues)

If `spec.md` doesn't exist, respond:
```
spec.md not found in .docs/features/feature-<N>-<slug>/.
Run /spec first, then /break <slug>, then /research <slug>.
```

If the `issues/` folder is empty or doesn't exist, continue — research is still useful without issues,
but note it in the output.

### Step 3: Explore the codebase systematically

Research the following areas. Be thorough. Read files fully — never use offset/limit truncation.

**Architecture scan**
- Understand the top-level project structure (languages, frameworks, main modules)
- Identify entry points, routing, and configuration patterns

**Impact mapping**
- Which existing files/modules will need to change?
- Which data models, schemas, or database tables are affected?
- Which API endpoints or services are involved?
- Which tests currently cover the affected areas?

**Component inventory**
- For each component listed in the spec, search the codebase to determine if it already exists
- Note the exact file path if found, or mark as "needs to be created"
- Look for partial matches too (e.g. a similar component that can be extended)

**Pattern discovery**
- Find 2–3 similar features already implemented in the codebase to use as reference
- Note conventions: naming, file structure, error handling, logging, testing patterns
- Identify any abstractions or utilities that the new feature should reuse

**Dependency analysis**
- External libraries already in use that are relevant
- Any missing dependencies that will need to be added

**Risk identification**
- Breaking changes that could affect other features
- Performance concerns
- Security implications

### Step 4: Document findings

Write `.docs/features/feature-<N>-<slug>/research.md` with this structure:

```markdown
# Research: <Feature Name>

**Date**: YYYY-MM-DD
**Feature**: feature-<N>-<slug>
**Status**: complete

## Feature Summary

[One paragraph describing what the feature is and why it's needed, based on spec.md and the issues]

## Codebase Overview

[Brief description of the project structure relevant to this feature — frameworks, key directories, patterns]

## Impact Analysis

### Files That Will Change
- `path/to/file.ext` — reason for change

### Files That Will Be Created
- `path/to/new-file.ext` — purpose

### Data Model Changes
[Schema, model, or database changes required. "None" if not applicable.]

### API / Interface Changes
[New or modified endpoints, events, or public interfaces. "None" if not applicable.]

## Component Inventory

For each component listed in the spec:

| Component | Page | Exists? | Location |
|-----------|------|---------|----------|
| <Component Name> | <Page> | Yes / No | `path/to/component.ext` or "needs to be created" |

## Existing Patterns to Follow

### Reference Implementation 1
**File**: `path/to/example.ext` (line X–Y)
**Relevant because**: [explanation]

### Reference Implementation 2
**File**: `path/to/example.ext` (line X–Y)
**Relevant because**: [explanation]

## Dependencies

### Already Available
- `library-name` — how it's used in this context

### Needs to Be Added
- `library-name` — why needed, installation command

## Risks and Constraints

- [Risk or constraint with brief explanation]

## Open Questions

[Ambiguities the plan step will need to address. Leave blank if none.]

## Key File References

| File | Purpose |
|------|---------|
| `path/file` | description |
```

### Step 5: Confirm and close

After writing `research.md`, respond:

```
Research complete. Artifact saved to:
  .docs/features/feature-<N>-<slug>/research.md

Components inventoried: [N] existing, [N] to be created

Next step:
  /clear
  /plan <slug> proto-01
```

---

## Important Rules

- You are a documentarian here. Describe what exists, not what should exist.
- Never begin planning or writing implementation code during this step.
- Read every relevant file fully before documenting it.
- Include specific file paths and line numbers wherever possible.
- If you find something ambiguous, document it as an open question rather than assuming.
- The component inventory is mandatory — `/plan` relies on it to know what needs to be built from scratch.
