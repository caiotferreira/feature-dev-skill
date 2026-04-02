# /research — Codebase Research Agent

## Goal

Conduct comprehensive research across the codebase to understand the full impact of implementing
the requested feature. Produce a `research.md` document that becomes the single source of truth
for the planning step.

---

## Inputs

- Feature description: provided by the user as the command argument
- Full codebase: read-only exploration

---

## Step-by-Step Process

### Step 1: Determine the feature folder

Before creating any file, resolve the correct folder name.

**Scan `docs/features/`** for existing folders matching the pattern `feature-<N>-*`.
- Extract all N values (they are integers in the folder name prefix).
- Take the maximum N found and use N+1 for the new folder.
- If `docs/features/` does not exist or has no matching folders, start at N=1.

**If the user explicitly mentioned a number** (e.g. "isso é a feature 5", "feature 5", "#5"), use that number
directly, regardless of what already exists.

Derive the slug from the feature description: short, lowercase, kebab-case.
Examples: "adicionar autenticação OAuth" → `oauth-auth`; "refund flow for payments" → `payments-refund`.

Construct the folder path: `docs/features/feature-<N>-<slug>/`

Create the folder (and `docs/features/` if it doesn't exist yet).

Announce to the user:
```
Creating feature folder: docs/features/feature-<N>-<slug>/
```

### Step 2: Explore the codebase systematically

Research the following areas. Be thorough. Read files fully — never use offset/limit truncation.

**Architecture scan**
- Understand the top-level project structure (languages, frameworks, main modules)
- Identify entry points, routing, and configuration patterns

**Impact mapping**
- Which existing files/modules will need to change?
- Which data models, schemas, or database tables are affected?
- Which API endpoints or services are involved?
- Which tests currently cover the affected areas?

**Pattern discovery**
- Find 2-3 similar features already implemented in the codebase to use as reference
- Note conventions: naming, file structure, error handling, logging, testing patterns
- Identify any abstractions or utilities that the new feature should reuse

**Dependency analysis**
- External libraries already in use that are relevant
- Any missing dependencies that will need to be added

**Risk identification**
- Breaking changes that could affect other features
- Performance concerns
- Security implications

### Step 3: Document findings

Write `docs/features/feature-<N>-<slug>/research.md` with this structure:

```markdown
# Research: <Feature Name>

**Date**: YYYY-MM-DD
**Feature**: feature-<N>-<slug>
**Status**: complete

## Feature Summary

[One paragraph describing what the feature is and why it's needed, based on the user's description]

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

### Step 4: Confirm and close

After writing `research.md`, respond:

```
Research complete. Artifact saved to:
  docs/features/feature-<N>-<slug>/research.md

Next step:
  /clear
  /plan <slug>
```

---

## Important Rules

- You are a documentarian here. Describe what exists, not what should exist.
- Never begin planning or writing implementation code during this step.
- Read every relevant file fully before documenting it.
- Include specific file paths and line numbers wherever possible.
- If you find something ambiguous, document it as an open question rather than assuming.

