# feature-dev skill

A personal Claude Code skill built around my own development process: **SDD (Spec-Driven Development)**.

I created this workflow after noticing a consistent failure pattern when using AI to build features: the AI anchors its understanding on what already exists in the codebase and builds toward that, instead of building toward what I actually want. SDD fixes this by forcing a full specification of the feature before the AI touches a single file.

This is a living workflow. I use it daily and refine it as I find better ways to structure each step.

---

## What is SDD

Spec-Driven Development is a workflow where every feature starts with a complete behavioral specification — what the user sees, what the user can do, and what happens in every scenario — before any code is written or any codebase is explored.

The spec becomes the source of truth. Every subsequent step (research, planning, implementation) inherits and references it. The AI never has to infer intent from existing code.

---

## The five commands

| Step | Command | What it produces |
|------|---------|-----------------|
| 1 | `/spec <description>` | A structured specification: Overview, Pages, Components, and Behaviors with GIVEN/WHEN/THEN scenarios |
| 2 | `/break <slug>` | Two batches of issue files: prototype issues (visual only) and functional issues (real data and logic) |
| 3 | `/research <slug>` | A codebase map: impacted files, existing patterns to follow, dependencies, risks |
| 4 | `/plan <slug> <issue-id>` | A phased implementation plan scoped to one issue, grounded in the spec and the codebase |
| 5 | `/implement <slug> <issue-id>` | Executed code, phase by phase, with verification checkpoints |

Each command runs in a fresh context window (`/clear` between them). All artifacts are saved to `docs/features/feature-<N>-<slug>/` in the project root.

---

## How it works

### Step 1 — `/spec`

You describe the feature in natural language. The agent produces `spec.md` with four layers:

- **Overview** — what the feature is and who uses it
- **Pages** — every screen involved
- **Components** — every visible element on each page, with its states
- **Behaviors** — every user interaction, documented as GIVEN/WHEN/THEN scenarios covering happy path, edge cases, and error states

No code is touched at this step.

### Step 2 — `/break`

The agent reads `spec.md` and generates issue files in two batches:

**Batch 1 — Prototype issues** (`proto-NN-*.md`): one per page. Scope is visual only. No API calls, no database writes, no business logic. Static data and local state are acceptable. The goal is a pixel-accurate screen that can be navigated and inspected.

**Batch 2 — Functional issues** (`func-NN-*.md`): one per page (or more if a page has independent behavior clusters). Each functional issue depends on its corresponding prototype being complete. Scope is wiring the visual shell to real data, form submission, API calls, error handling, and all behaviors from the spec.

### Step 3 — `/research`

Runs once per feature, before planning any issue. The agent reads `spec.md` and then explores the codebase to produce `research.md`: which files will change, which existing patterns to follow, which dependencies are already available, and what risks exist.

### Step 4 — `/plan <slug> <issue-id>`

Runs once per issue. The agent reads the issue file, `spec.md`, and `research.md`, then explores the relevant parts of the codebase to produce a plan file. The plan contains exact file paths, illustrative code blocks, and success criteria split between automated (runnable commands) and manual (human verification).

Before writing the full plan, the agent presents the proposed phase structure and waits for confirmation.

### Step 5 — `/implement <slug> <issue-id>`

Executes the plan phase by phase. After each phase, automated checks run. If they pass, the agent pauses and asks for manual verification before continuing. If anything in the codebase diverges from what the plan expected, the agent stops and reports the mismatch instead of improvising.

A guard rule enforces the proto/func boundary: if a prototype implementation starts writing a fetch call or a database query, the agent stops. If a functional implementation starts re-doing layout work, the agent stops and references the existing prototype instead.

---

## Folder structure

```
docs/features/
└── feature-1-pos-venda-clientes/
    ├── spec.md
    ├── research.md
    ├── issues/
    │   ├── proto-01-tela-dashboard.md
    │   ├── proto-02-tela-clientes.md
    │   ├── func-01-tela-dashboard.md
    │   └── func-02-tela-clientes.md
    ├── plan-proto-01-tela-dashboard.md
    ├── plan-func-01-tela-dashboard.md
    ├── implementation-proto-01-tela-dashboard.md
    └── implementation-func-01-tela-dashboard.md
```

---

## Full execution order

```
/spec <description>
/clear
/break <slug>
/clear
/research <slug>

# Prototype pass
/plan <slug> proto-01
/clear
/implement <slug> proto-01
/clear
/plan <slug> proto-02
/clear
/implement <slug> proto-02
/clear
# ... repeat for all proto issues

# Functional pass
/plan <slug> func-01
/clear
/implement <slug> func-01
/clear
# ... repeat for all func issues
```

---

## Installation

**Per project:**
```bash
npx skills add ./path/to/feature-dev
```

**Global (via `~/.claude/CLAUDE.md`):**

Add the following to your global Claude config so the skill is available in every project without copying files:

```markdown
## Global skills

Before any task, read and follow the instructions in:
~/skills/feature-dev/SKILL.md
```

---

## Repository structure

```
feature-dev/
├── README.md
├── SKILL.md
└── references/
    ├── spec.md
    ├── break.md
    ├── research.md
    ├── plan.md
    └── implement.md
```

---

## Key design decisions

**Why spec before research.** The `/research` command reads `spec.md` before exploring the codebase. This means the agent understands what the feature must do before it sees how the codebase is structured. Without this order, the agent anchors its understanding to existing patterns and builds toward them instead of toward the spec.

**Why prototype before functional.** Separating visual from functional forces a clean interface between layout and behavior. The functional issue receives a stable, reviewed visual shell and wires into it. This eliminates the common failure mode where an AI mixes layout work with data fetching in the same pass, producing code that is hard to review and harder to change.

**Why one plan per issue.** A single plan file scoped to one issue means the agent's context window is focused. It reads one issue, one spec, one research document, and the relevant files. It does not try to hold the entire feature in mind at once.

**Why `/clear` between every step.** Each command is designed to run with a clean context. Accumulated conversation history adds noise and can cause the agent to anchor on earlier assumptions. The artifacts on disk are the memory.

---

## Status

This skill reflects my current understanding of how to build features with AI effectively. I update it whenever I find a better approach in practice.
