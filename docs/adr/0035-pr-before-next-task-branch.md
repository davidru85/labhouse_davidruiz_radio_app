# ADR-0035 — Pull request before next task branch

- **Status:** Accepted
- **Date:** 2026-05-31
- **Deciders:** David Ruiz
- **Related:** ADR-0008, ADR-0009, ADR-0033, `AGENTS.md` §Branch-Before-Task Rule

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

ADR-0033 requires a correctly named non-`main` branch before starting any
new roadmap task or sub-task. That rule prevents work from starting
directly on `main`, but it did not explicitly define when the next
sub-task branch may be created after the previous sub-task is completed.

Creating the next sub-task branch before the previous pull request is
merged creates a stacked branch. That makes the new branch depend on
unmerged work, complicates review, and can cause the next sub-task to be
based on a stale or non-canonical history.

The user owns pull request creation and merging on GitHub. The agent must
therefore wait until the user has completed the pull request workflow and
confirmed that local `main` is synchronized before creating the next
roadmap branch.

## Decision

After a roadmap task or sub-task is completed, the agent MUST NOT create
or switch to the next roadmap task or sub-task branch until the user has
explicitly confirmed that:

1. The completed task's pull request has been created and merged on
   GitHub.
2. The local `main` branch has been synchronized with the merged pull
   request.
3. The agent may proceed with the next roadmap task or sub-task.

The next task branch MUST be created from synchronized `main`, using the
ADR-0009 and ADR-0033 roadmap branch naming convention.

If the agent is still on the completed task branch after a sub-task is
finished, the agent MUST wait there. It MAY update completion
documentation on that branch before PR creation, but it MUST NOT start
RED tests, production code, task-specific documentation, or branch setup
for the next task.

If a next-task branch is created prematurely, the agent MUST roll it back
before continuing, unless the user explicitly chooses to keep that
stacked branch.

## Consequences

### Positive
- Ensures every roadmap branch starts from the canonical merged `main`.
- Avoids accidental stacked branches and hidden dependencies between
  sub-task pull requests.
- Keeps GitHub pull request review and local development state aligned.

### Negative
- Adds a waiting point between completed sub-tasks.
- Requires explicit user confirmation after PR merge and local sync.

### Neutral
- The agent may still complete all Red/Green/Refactor work for the
  current branch before waiting.
- Documentation-only completion commits for the current sub-task remain
  part of the completed sub-task branch.

## Alternatives considered

### Option A — Continue creating stacked next-task branches
Rejected. Stacked branches make PR review and main synchronization less
predictable for this project's user-owned merge workflow.

### Option B — Let the agent merge or rebase branches automatically
Rejected. Merging to `main` is exclusively performed by the user via
GitHub pull requests, and branch synchronization must remain explicit.

## Documentation impact

- `AGENTS.md` §Branch-Before-Task Rule — require PR merge and synced
  `main` before creating the next task branch.
- `ROADMAP.md` preface — add the handoff gate between sub-tasks.
- `MEMORY.md` — record this ADR and make the current waiting state
  explicit.

## Follow-ups

- None.
