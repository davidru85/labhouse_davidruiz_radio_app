# ADR-0036 — Push the GREEN commit to the remote

- **Status:** Accepted
- **Date:** 2026-05-31
- **Deciders:** David Ruiz
- **Related:** ADR-0008, ADR-0009, `AGENTS.md` §Mandatory TDD Micro-Cycle

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

`AGENTS.md` mandates one commit per Red / Green / Refactor sub-step, but it
did not define when the agent publishes work to the remote. Until now the
commits stayed local until the user opened a pull request, which delayed
CI feedback on the green implementation and left no remote copy of the
approved work before the refactor checkpoint.

Merging to `main` is exclusively user-owned through GitHub pull requests
(per ADR-0008 and ADR-0009). Publishing an approved commit to a non-`main`
feature branch does not conflict with that ownership; it only makes the
work visible on the remote and triggers branch CI earlier.

## Decision

The final step of `PHASE GREEN`, performed after the user-approved commit,
is `git push` of the current non-`main` feature branch to its remote.

The push publishes the already-approved green commit. It MUST NOT target
`main`, MUST NOT force-push, and does not introduce a new approval gate:
the commit it publishes is still gated on the existing GREEN user review.
The agent then continues to `PHASE REFACTOR` as before.

## Consequences

### Positive
- CI runs against the green implementation early, before refactor.
- The approved work has a remote backup and is visible for review.
- Establishes a single, explicit publication point in the micro-cycle.

### Negative
- Requires remote availability at the end of `PHASE GREEN`.
- Adds one step to the green checkpoint.

### Neutral
- The rule applies only to `PHASE GREEN`; `PHASE RED` and
  `PHASE REFACTOR` commits are not auto-pushed by this decision.
- The push always targets the feature branch, never `main`; user-owned
  PR merge remains unchanged.

## Alternatives considered

### Option A — Push only once, just before opening the pull request
Rejected. It delays CI feedback on the green implementation and leaves the
approved work without a remote copy through the refactor step.

### Option B — Auto-push after every Red / Green / Refactor commit
Rejected. Not requested; it adds remote churn for intermediate red commits
that may intentionally fail static analysis at that checkpoint.

## Documentation impact

- `AGENTS.md` §Mandatory TDD Micro-Cycle, `PHASE GREEN` — add `git push`
  as the final step of the phase.
- `MEMORY.md` — record this ADR in the decision log.
- `docs/adr/README.md` — add the index entry.

## Follow-ups

- None.
