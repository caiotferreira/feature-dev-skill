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
| 5 | `/implement <slug> <issue-id>` | Executed code with focused TDD, factual verification, and one final independent review |

Each command runs in a fresh context window (`/clear` between them). All artifacts are saved to `.docs/features/feature-<N>-<slug>/` in the project root.

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

**Batch 2 — Functional issues** (`func-NN-*.md`): one per behavior defined in the spec. Each functional issue depends on its corresponding prototype being complete. Scope is wiring the visual shell to real data, form submission, API calls, error handling, and all behaviors from the spec.

### Step 3 — `/research`

Runs once per feature, before planning any issue. The agent reads `spec.md` and all issue files, then explores the codebase to produce `research.md`: which files will change, which existing patterns to follow, which dependencies are already available, and what risks exist.

### Step 4 — `/plan <slug> <issue-id>`

Runs once per issue. The agent reads the issue file, `spec.md`, and `research.md`, then explores the relevant parts of the codebase to produce a phased implementation plan — appended directly to the issue file. Functional phases include an **Automated Test Contract**: test file, level, observable behaviors, focused command, and final issue checks. The plan detects the project’s existing package manager and scripts; `pnpm` is never assumed.

Before writing the full plan, the agent presents the proposed phase structure and waits for confirmation.

### Step 5 — `/implement <slug> <issue-id>`

Executes functional contracts with a light RED → GREEN cycle: write the test first, prove its focused command fails for the intended missing behavior, implement the minimum, then record GREEN and phase checks. It runs only focused tests during development and final commands once at issue close — not the full suite after every edit.

Routine phases continue without a human checkpoint. Manual validation is consolidated at the end; it pauses only for meaningful visual/UX judgment, unautomated e2e flows, data migrations, security/permission/payment/high-risk work, or a product decision. Every issue ends with fresh final-command output and one independent review of the spec, plan, test contracts, implementation report, and base-to-HEAD diff. Critical and Important findings are fixed before closure; a second review is exceptional rather than automatic.

A guard rule enforces the proto/func boundary: if a prototype implementation starts writing a fetch call or a database query, the agent stops. If a functional implementation starts re-doing layout work, the agent stops and references the existing prototype instead.

---

## Folder structure

```
.docs/features/
├── feature-1-pos-venda-clientes/
│   ├── spec.md
│   ├── research.md
│   └── issues/
│       ├── proto-01-tela-dashboard.md
│       ├── proto-02-tela-clientes.md
│       ├── func-01-salvar-cliente.md
│       ├── func-02-excluir-cliente.md
│       └── .runs/
│           └── func-01/
│               ├── progress.md
│               ├── implement-report.md
│               └── final-review.md
└── feature-2-checkout-flow/
    └── ...

```

The plan is appended directly to each issue file by `/plan` — no separate plan files are created. Each implementation run keeps only the three persistent artifacts in `issues/.runs/<issue-id>/`, so interrupted work resumes without repeating completed phases.

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

Clone this repository and run `setup.sh`:

```bash
git clone <repo-url>
cd feature-dev-skill
./setup.sh
```

The script creates symlinks for each of the five skills into `~/.claude/skills/` and `~/.codex/skills/`:

```
~/.claude/skills/feature-dev-spec       -> /path/to/feature-dev-skill/skills/feature-dev-spec
~/.claude/skills/feature-dev-break      -> /path/to/feature-dev-skill/skills/feature-dev-break
~/.claude/skills/feature-dev-research   -> /path/to/feature-dev-skill/skills/feature-dev-research
~/.claude/skills/feature-dev-plan       -> /path/to/feature-dev-skill/skills/feature-dev-plan
~/.claude/skills/feature-dev-implement  -> /path/to/feature-dev-skill/skills/feature-dev-implement
```

Because the install uses symlinks, any changes you make to the skill files in this repository take effect immediately — no reinstall needed.

To update an existing installation, pull the repository changes. Existing symlinks point to the
same directories, so no reinstall is needed. If the repository was moved or the links are absent,
run `./setup.sh` again to recreate them.

---

## Repository structure

```
feature-dev-skill/
├── README.md
├── setup.sh
└── skills/
    ├── feature-dev-spec/
    │   └── SKILL.md
    ├── feature-dev-break/
    │   └── SKILL.md
    ├── feature-dev-research/
    │   └── SKILL.md
    ├── feature-dev-plan/
    │   └── SKILL.md
    └── feature-dev-implement/
        └── SKILL.md
```

Each skill is self-contained: its `SKILL.md` holds the full instructions for that command with no external references. This means each command loads exactly the context it needs — nothing more.

---

## Key design decisions

**Why five separate skills instead of one.** Each command is a distinct skill with its own description and trigger conditions. The model loads only the skill relevant to the current command, instead of loading a hub that routes to references. This reduces context load per command and makes trigger matching more precise.

**Why spec before research.** The `/research` command reads `spec.md` before exploring the codebase. This means the agent understands what the feature must do before it sees how the codebase is structured. Without this order, the agent anchors its understanding to existing patterns and builds toward them instead of toward the spec.

**Why prototype before functional.** Separating visual from functional forces a clean interface between layout and behavior. The functional issue receives a stable, reviewed visual shell and wires into it. This eliminates the common failure mode where an AI mixes layout work with data fetching in the same pass, producing code that is hard to review and harder to change.

**Why one plan per issue.** A single plan scoped to one issue means the agent's context window is focused. It reads one issue, one spec, one research document, and the relevant files. It does not try to hold the entire feature in mind at once.

**Why contracts instead of a heavyweight test process.** Functional behavior gets a small, concrete test contract and RED/GREEN proof; visual-only prototype work gets honest visual/manual evidence instead of coverage theater. The only subagent review is the final independent issue review, not a dispatch and re-review loop for each phase.

**Why `/clear` between every step.** Each command is designed to run with a clean context. Accumulated conversation history adds noise and can cause the agent to anchor on earlier assumptions. The artifacts on disk are the memory.

---

## Status

This skill reflects my current understanding of how to build features with AI effectively. I update it whenever I find a better approach in practice.
