# ADR-0009 — Git workflow and commit conventions

- **Status:** Accepted
- **Date:** 2026-05-28
- **Deciders:** David Ruiz
- **Related:** ADR-0008, `AGENTS.md` §Mandatory TDD Micro-Cycle, `ROADMAP.md` Phase 1

## Context

ADR-0008 fixes branch protection rules, CI gates and signed commits but
does not address three orthogonal questions:

1. **Repository lifecycle.** When does git tracking start, and on which
   directory?
2. **Branching model.** With `main` protected, how are working branches
   named and what is their lifetime?
3. **Commit message format.** `AGENTS.md` asks for "high-quality" commit
   messages but does not define a format. Squash merge (per ADR-0008)
   makes the PR title the single commit message that survives on
   `main`, so a deliberate format is required for the `main` history to
   be readable.

Additional context: the current polish phase produces only markdown
artifacts intended to be consumed by an AI agent. The Flutter project
does not exist yet. The intent is to scaffold a Flutter "Hello World"
project at the start of Phase 1, move the polished documentation into
it, and initialise git at that point.

## Decision

### Repository lifecycle

Git is initialised **at the start of Phase 1**, not now. The sequence is:

1. Phase 1 begins.
2. `flutter create` scaffolds the new Flutter project with the
   parameters defined by ADR-0003.
3. The polished documentation (including all ADRs) is moved into the
   new project directory.
4. `git init` runs in the new directory.
5. The first commit captures the scaffold and the documentation as a
   single starting point.
6. The remote repository is created on GitHub as **private**.
7. Branch protection rules from ADR-0008 are applied to `main`.
8. Subsequent work happens on feature branches via pull request.

The repository becomes **public** at the moment of assessment
delivery, not before.

### Branching model

**GitHub Flow** is the documented model:

- `main` is the only long-lived branch. It is always in a releasable
  state.
- All other branches are short-lived working branches. They are
  created from `main`, merged back via squash, and deleted.
- Merging branches into `main` (or `master`) is exclusively performed by the USER via GitHub Pull Requests. The agent MUST NOT merge branches directly.
- Branch names use a `<type>/<short-description>` format. The type
  prefix mirrors the Conventional Commits type of the work being done.

| Branch prefix | When                                                |
|---------------|-----------------------------------------------------|
| `feature/`    | New product functionality.                          |
| `fix/`        | Bug fix.                                            |
| `refactor/`   | Internal change without behaviour change.           |
| `test/`       | Test-only changes (rare on its own).                |
| `docs/`       | Documentation only, including ADRs.                 |
| `chore/`      | Maintenance, build, CI, dependency bumps.           |

Example branch names: `feature/dio-client-factory`,
`docs/adr-0010-volume-scope`, `chore/upgrade-flutter-3.22.5`.

Branches are automatically deleted by GitHub after merge
(repository setting "Automatically delete head branches").

### Commit message convention

**Conventional Commits** is the format. Every commit on every branch
follows:

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

- `<type>` is one of: `feat`, `fix`, `refactor`, `test`, `docs`,
  `chore`, `style`, `perf`.
- `<scope>` is optional and short. Suggested values:
  `stations`, `favorites`, `history`, `player`, `genres`,
  `countries`, `network`, `storage`, `di`, `routing`, `adr`, `ci`.
- `<subject>` is imperative mood, no trailing period, lower-case
  start, ≤ 72 characters total line length.

Examples:

```
feat(stations): add LoadMoreStations event to StationsBloc
test(stations): add red test for paginated search
refactor(network): extract mirror failover into interceptor
docs(adr): add ADR-0009 git workflow
chore(ci): pin Flutter version in workflow to 3.22.x
```

### TDD micro-cycle and commits

`AGENTS.md` mandates one commit per Red / Green / Refactor sub-step
inside the working branch. The conventions are:

- **Red:** `test(<scope>): add failing test for <thing>`
- **Green:** `feat(<scope>): make <thing> pass` (or `fix` if it is a
  bug)
- **Refactor:** `refactor(<scope>): clean up <thing>`

These three commits live inside the PR. Squash merge (per ADR-0008)
collapses them into one commit on `main`. The squash commit message
follows the same Conventional Commits format and is generally a `feat`
or `fix` summarising the whole micro-cycle.

### Enforcement

Conventional Commits format is enforced by a `commit-msg` hook in
`lefthook.yml`. The hook is a regex check, not a Node-based tool, to
avoid pulling additional dependencies. The pattern is approximately:

```
^(feat|fix|refactor|test|docs|chore|style|perf)(\([a-z0-9-]+\))?: .{1,72}$
```

A commit that does not match is rejected locally. CI does not re-check
the commit message format because squash merge replaces every commit
on `main` with a single PR-title-derived message; the PR title is
enforced by the same convention via documentation, not automation, at
this stage.

### Repository visibility

The GitHub repository is created **private** at Phase 1 start. It
becomes **public** at the moment of assessment delivery.

Reasoning:

- Private during development avoids exposing in-flight, unpolished
  work to anyone who searches GitHub.
- Public at delivery allows the assessor (and any future reviewer) to
  inspect the entire history without sharing credentials.
- The two-step approach uses GitHub's built-in visibility toggle —
  no migration, no history loss.

## Consequences

### Positive
- Every commit on `main` is machine-readable and human-skimmable.
- `git log --oneline main` becomes a chronological record of feature
  additions and fixes, suitable for a CHANGELOG.
- Branch names declare intent before the first commit lands.
- The polish phase remains an offline, non-git activity, keeping the
  eventual repository history focused on the project itself rather
  than its prelude.
- TDD commits are recoverable from PR history when needed but do not
  pollute `main`.

### Negative
- The polish phase produces no git history. If the working directory
  is lost before Phase 1, all work is lost. Mitigation: regular
  manual backups by the user during polish.
- Lefthook's `commit-msg` regex is approximate. A user can craft a
  format-valid but semantically wrong message; this is not enforced
  beyond format.

### Neutral
- The branch prefix taxonomy mirrors the Conventional Commits types.
  A branch may carry commits of mixed types internally; only the
  squash-merge message must reflect the dominant type. This is
  documented and accepted.

## Alternatives considered

### Option A (lifecycle) — initialise git now, before Phase 1
Rejected. The user explicitly chose to keep polish git-less and to
initialise the repository when the Flutter project is created.

### Option B (branching) — GitFlow
Rejected. Designed for multi-developer projects with formal release
cadences. Overkill for a solo-developer assessment.

### Option A (branching) — Trunk-based without naming conventions
Rejected. The naming convention is the only marker that distinguishes
work in flight; in a solo-dev project it is the difference between an
intelligible branch list and an opaque one.

### Option B (commit message) — Free-form messages with style
guidelines (50/72, imperative)
Rejected. Loses machine readability and consistency in `git log`.

### Option C (commit message) — Conventional Commits enforced by `commitlint`
Rejected. `commitlint` requires Node.js. A regex hook in lefthook
achieves the same enforcement floor without adding a runtime
dependency.

### Public repository from day one
Rejected. The user opted for private during development, public at
delivery.

## Documentation impact

- `AGENTS.md` §Mandatory TDD Micro-Cycle — refine the commit message
  guidance to reference Conventional Commits and the Red/Green/Refactor
  message templates defined above.
- `TECHNICAL_SPEC.md` — add a "Git workflow" subsection (or fold into
  the CI/CD section from ADR-0008) summarising branching and commit
  conventions, with this ADR as the source of truth.
- `VALIDATION_CHECKLIST.md` — add a "Git workflow" section:
  - All commits follow Conventional Commits.
  - Working branches follow `<type>/<short-description>`.
  - `main` is squash-merged and linear.
  - Branches deleted on merge.
- `ROADMAP.md` Phase 1 — add sub-tasks:
  - `flutter create` (with parameters from ADR-0003).
  - Move polished documentation into the new project.
  - `git init`, first commit, push to private GitHub repository.
  - Apply branch protection rules (ADR-0008).
  - Add `commit-msg` hook to `lefthook.yml`.

## Follow-ups

- A future task at delivery time: toggle repository visibility from
  private to public.
- A future ADR may automate CHANGELOG generation from Conventional
  Commits on `main` once enough history exists to justify it.
