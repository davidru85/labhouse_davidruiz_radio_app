# ADR-0033 — Branch before task execution

- **Status:** Accepted
- **Date:** 2026-05-30
- **Deciders:** David Ruiz
- **Related:** ADR-0008, ADR-0009, `AGENTS.md` §Critical Execution Rules

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

ADR-0009 defines GitHub Flow and states that work happens on short-lived
working branches. The operational kickoff protocol did not explicitly say
that the branch must exist before starting a new roadmap task or sub-task.
As a result, Phase 2 Sub-task 2.1 RED started on `main` before a branch
was created.

The project already prohibits direct merges to `main`, requires pull
requests for integration, and uses TDD micro-cycle checkpoints. The branch
checkpoint must therefore be part of the task-start protocol, not an
afterthought.

## Decision

Before starting any new roadmap task or sub-task, the agent MUST verify
the current branch and MUST create or switch to an appropriately named
non-`main` working branch before writing tests, production code, or
task-specific documentation changes.

If the repository is on `main` at task start, the agent MUST create a
branch using the ADR-0009 roadmap branch pattern:
`<type>/phase-<phase>-sub-task-<subtask>-<short-description>`.

The `<subtask>` segment MUST remove punctuation from the roadmap sub-task
number. For example, Sub-task 2.1 becomes `21`, so the Phase 2 domain
entities branch is `feature/phase-2-sub-task-21-domain-entities`.

If the repository is already on a non-`main` branch, the agent MUST
confirm that the branch name exactly matches the current task scope before
continuing. If it does not match, the branch MUST be renamed or the agent
MUST switch to the correctly named branch before continuing.

The current branch SHOULD be recorded in `MEMORY.md` while work is active.

## Consequences

### Positive
- Prevents accidental task work from starting directly on `main`.
- Prevents ambiguous short branch names for roadmap work.
- Makes the TDD micro-cycle and pull request workflow align from the
  first RED test.
- Gives the user a visible branch checkpoint before each task begins.

### Negative
- Adds one explicit setup step before every new task or sub-task.
- Requires branch naming judgement when a task spans more than one
  Conventional Commits type, but still requires the phase/sub-task
  segment.

### Neutral
- Existing in-flight changes may be moved onto a new branch with
  `git switch -c <branch>` when no commit has been made yet.
- A locally created branch with an incorrect name may be renamed with
  `git branch -m <correct-branch>` before it is pushed.

## Alternatives considered

### Option A — Create the branch after RED
Rejected. RED tests are already task work and should not be authored on
`main`.

### Option B — Rely on ADR-0009 only
Rejected. ADR-0009 states the branching model but did not make the
branch check an operational prerequisite before each roadmap task.

### Option C — Allow short branch names for roadmap work
Rejected. Short names such as `feature/domain-entities` omit the roadmap
phase and sub-task, making branch scope inconsistent with existing
branches and harder to audit.

## Documentation impact

- `AGENTS.md` §Critical Execution Rules — add a branch-before-task rule.
- `AGENTS.md` §Hard Constraints — add a CI/CD and Git prohibition against
  task work on `main`.
- `docs/adr/0009-git-workflow.md` §Branching model — clarify the
  concrete roadmap branch naming pattern.
- `ROADMAP.md` — add a branch checkpoint to the roadmap execution preface.
- `MEMORY.md` — record the active branch in the progress tracker.

## Follow-ups

- None.
