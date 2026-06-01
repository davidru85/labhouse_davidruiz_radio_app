# ADR-0036 — Push approved phase commits to the remote

- **Status:** Accepted
- **Date:** 2026-05-31 (amended 2026-06-01 to cover `PHASE REFACTOR`)
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

The original decision pushed only the `PHASE GREEN` commit. In practice
the `PHASE REFACTOR` commit (cleanup and completion docs — checking off
the `ROADMAP.md` item and updating the `MEMORY.md` progress tracker)
then stayed local until the user manually requested a push. A sub-task
branch with a local-only refactor commit is **not** PR-ready: the user
cannot open or merge the pull request until every approved commit is on
the remote. This amendment closes that gap.

## Decision

The final step of every **approved, hook-passing checkpoint commit** —
namely `PHASE GREEN` and `PHASE REFACTOR` — is `git push` of the current
non-`main` feature branch to its remote, performed after the
user-approved commit.

The push publishes only already-approved commits. It MUST NOT target
`main`, MUST NOT force-push, and does not introduce a new approval gate:
the commit it publishes is still gated on the existing per-phase user
review. After the `PHASE REFACTOR` push the branch is fully PR-ready and
the agent hands back for the user-owned PR.

`PHASE RED` commits are **not** separately auto-pushed: they are
committed with `--no-verify` because they intentionally fail the
pre-commit static-analysis hook (production symbols do not yet exist),
so the branch tip should not sit on the remote at that state. The RED
commit still reaches the remote as part of the subsequent `PHASE GREEN`
push, which publishes the whole branch up to the green tip.

## Consequences

### Positive
- CI runs against the green implementation early, before refactor.
- The approved work has a remote backup and is visible for review.
- After `PHASE REFACTOR` the branch is fully PR-ready with no
  local-only commits, so the user can open and merge the PR without a
  manual push request.
- Establishes explicit publication points in the micro-cycle.

### Negative
- Requires remote availability at the end of `PHASE GREEN` and
  `PHASE REFACTOR`.
- Adds one step to each of those checkpoints.

### Neutral
- The rule applies to `PHASE GREEN` and `PHASE REFACTOR`; `PHASE RED`
  commits are not auto-pushed on their own (they ride along with the
  GREEN push, per the Decision above).
- The push always targets the feature branch, never `main`; user-owned
  PR merge remains unchanged.

## Alternatives considered

### Option A — Push only once, just before opening the pull request
Rejected. It delays CI feedback on the green implementation and leaves the
approved work without a remote copy through the refactor step.

### Option B — Auto-push after every Red / Green / Refactor commit
Rejected for `PHASE RED`: pushing immediately after the red commit would
park the branch tip on the remote in a state that intentionally fails
static analysis. The 2026-06-01 amendment adopts the push for
`PHASE REFACTOR` (an approved, hook-passing commit) while keeping RED
out of the auto-push, so the original red-churn concern still holds.

## Documentation impact

- `AGENTS.md` §Mandatory TDD Micro-Cycle, `PHASE GREEN` — add `git push`
  as the final step of the phase.
- `AGENTS.md` §Mandatory TDD Micro-Cycle, `PHASE REFACTOR` — add
  `git push` as the final step of the phase (2026-06-01 amendment).
- `MEMORY.md` — record this ADR in the decision log.
- `docs/adr/README.md` — add the index entry.

## Follow-ups

- None.
