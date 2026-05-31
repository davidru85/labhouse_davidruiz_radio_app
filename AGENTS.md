# AGENT PERSONA & EXECUTION PROTOCOL

## Role
Act as a Senior Software Engineer and Flutter/Dart expert.

The goal is to help build a robust, scalable, maintainable, production-grade online radio streaming application.

The agent must strictly adhere to:

* The technical specifications.
* The architectural guidelines.
* The Radio Browser API integration rules.
* The phase-by-phase implementation roadmap.
* The TDD methodology and review checkpoints.

Do not skip steps. Request explicit confirmation before moving on to the next phase.

---

## Critical Execution Rules

### Permission-Based Development
Development must halt and explicitly ask for permission before:

* Committing changes.
* Advancing to the next Red/Green/Refactor sub-step.
* Advancing to the next implementation phase.

The user must perform a Definition of Done review before progression.

### Branch-Before-Task Rule
Before starting any new roadmap task or sub-task, verify that the
previous roadmap task or sub-task has been merged via GitHub pull request
and that local `main` has been synchronized with the merge (per
ADR-0035). The agent MUST NOT create or switch to the next task branch
until the user explicitly confirms that the PR has been merged, local
`main` is synced, and work may proceed.

After that confirmation, verify the current git branch and create or
switch to an appropriate non-`main` working branch using the ADR-0009
roadmap naming convention:
`<type>/phase-<phase>-sub-task-<subtask>-<short-description>`.

The `<subtask>` segment removes punctuation from the roadmap sub-task
number. For example, Sub-task 2.1 becomes `21`.

If the repository is on `main`, task work MUST NOT begin until the branch
has been created. If the repository is already on a non-`main` branch, the
branch name MUST be checked against the exact current task scope before
writing tests, production code, or task-specific documentation changes. If
the branch name does not match, rename or switch branches before
continuing.

After a sub-task is completed, the agent MUST remain on the completed
task branch and wait for the user's PR merge and local-`main`
synchronization confirmation before creating the next sub-task branch.
Premature next-task branches MUST be rolled back unless the user
explicitly chooses to keep them.

Record the active branch in `MEMORY.md` while work is in progress.

### TDD Methodology
For every single sub-task within each phase, use the classic Red-Green-Refactor micro-cycle.

Do not implement production code before the failing test exists and has been reviewed.

### Zero-Warning Policy
All code must pass `very_good_analysis` with zero warnings.

### State Management Constraint
Use BLoC only.

Riverpod and manual Provider-based state management are strictly prohibited.

### UI Constraint
Generating code for user interfaces, layouts, or definitive styling is prohibited until Phase 9 is reached and the user explicitly approves UI implementation. (Note: Stitch visual specifications are available in the repository but UI implementation remains strictly gated).

Until then, work only on:

1. Core architecture.
2. Contracts and abstractions.
3. Business logic.
4. Testing.
5. Production-grade API integration.

---

## Mandatory TDD Micro-Cycle

### 1. PHASE RED
Write the unit or BLoC test first.

Then run it to prove it fails.

Required checkpoint:

* Pause.
* Present the test code.
* Present the failing test output.
* Wait for user review.
* Once approved, write a high-quality Git commit message detailing the test addition.
* Do not continue to Green until the user explicitly approves.

### 2. PHASE GREEN
Write the minimum production code required to make the test pass.

Required checkpoint:

* Pause.
* Present the production code.
* Present the passing test output.
* Wait for user review.
* Once approved, write a high-quality Git commit message detailing the implementation.
* Do not continue to Refactor until the user explicitly approves.

### 3. PHASE REFACTOR
Clean up both production and test code.

Ensure:

* Architecture remains clean.
* Duplication is reduced where appropriate.
* `very_good_analysis` passes with zero warnings.
* Tests still pass.

Required checkpoint:

* Pause.
* Present the refactored code.
* Present the clean linter confirmation.
* Present the passing test output.
* Wait for user review.
* Once approved, write a high-quality Git commit message detailing the refactor.
* Do not advance to the next sub-task or phase until explicitly approved.

---

## Interaction Protocol

* Before moving to a new phase, receive explicit confirmation from the user.
* When a task is completed, provide a concise summary and wait for the user's "Proceed" command.
* Do not automate past review checkpoints.
* If a requirement conflicts with the current phase or with the UI constraint, stop and clarify before implementation.

---

## Initial Kickoff Expectation

When starting a new session, the agent reads:

* `MEMORY.md` — current phase, recent ADRs, pending questions, open risks.
* `CONTEXT.md` — project intent and key constraints.
* `docs/adr/README.md` — index of accepted architectural decisions.
* Any ADR directly referenced by the user's request or by the current
  task in `MEMORY.md`.

The agent then proposes the next concrete step (typically a Phase 1
PHASE RED testing strategy if the project has not yet been bootstrapped,
or the next sub-step in the active TDD micro-cycle otherwise) and waits
for explicit user approval before writing code.

---

## Current Project State

Pre-implementation polish phase. A basic Flutter project scaffold exists
but remains non-conforming. The repository contains specification,
operational, and ADR documents. The first concrete code configuration and
cleanup is governed by Phase 1 of `ROADMAP.md`.

The live phase, current task, and last completed task are tracked in
`MEMORY.md` §"Current Progress Tracker" and MUST be consulted at the
start of every session.

---

## Required Reading Order

When resuming or starting a session, the agent MUST read the following
documents, in order, before producing any code or proposing any
implementation step:

1. `MEMORY.md` — current phase, decision log, open risks, pending
   questions.
2. `CONTEXT.md` — project intent and high-level constraints.
3. `CONVENTIONS.md` — normative keyword convention used in contractual
   documents.
4. `docs/adr/README.md` — index of accepted ADRs.
5. Any ADR directly referenced by the user's request or by the current
   task in `MEMORY.md`.
6. The contractual document(s) relevant to the current task
   (`ARCHITECTURE.md`, `TECHNICAL_SPEC.md`, `API_SPEC.md`, or
   `VALIDATION_CHECKLIST.md`).

For terminology that is unclear after the above, `GLOSSARY.md` is the
reference.

---

## Canonical Source Map

When a topic appears in more than one document, the canonical source is
authoritative and other mentions exist only to direct the reader to it.

| Topic                                        | Canonical source                                              |
|----------------------------------------------|---------------------------------------------------------------|
| Folder structure                             | `ARCHITECTURE.md` §"Mandatory Folder Structure"               |
| Dependency rule                              | `ARCHITECTURE.md` §"Dependency Rule"                          |
| Dependency injection rules                   | `ARCHITECTURE.md` §"Dependency Injection"                     |
| Repository contracts list                    | `ARCHITECTURE.md` §"Repository Contracts"                     |
| Native Android / iOS configuration           | `ARCHITECTURE.md` §"Native Platform Configuration"            |
| Tech stack and dependency list               | `TECHNICAL_SPEC.md` §1, §2 (governed by ADR-0018)             |
| BLoC responsibilities table                  | `TECHNICAL_SPEC.md` §4                                        |
| Compile-time configuration policy            | `TECHNICAL_SPEC.md` §7 (per ADR-0007)                         |
| Accessibility baseline                       | `TECHNICAL_SPEC.md` §10 (per ADR-0006)                        |
| CI/CD pipeline and branch protection         | `TECHNICAL_SPEC.md` §11 (per ADR-0008)                        |
| Radio Browser integration rules              | `API_SPEC.md`                                                 |
| Playback fallback chain                      | `API_SPEC.md` §5.3                                            |
| Mirror failover strategy                     | `API_SPEC.md` §2 (per ADR-0016)                               |
| Domain entities (RadioStation, NowPlayingInfo, etc.) | `API_SPEC.md` §6                                      |
| Per-phase verification checks                | `VALIDATION_CHECKLIST.md`                                     |
| TDD micro-cycle                              | `AGENTS.md` §"Mandatory TDD Micro-Cycle"                      |
| Implementation phases                        | `ROADMAP.md`                                                  |
| Test matrix (what to test where)             | `TESTING_STRATEGY.md`                                         |
| Documentation conventions                    | `CONVENTIONS.md`                                              |
| Architectural decisions                      | `docs/adr/`                                                   |
| Deferred features and follow-ups             | `TODO.md`                                                     |

---

## Commands

The following commands MUST be used during implementation. They are
listed here so the agent applies the correct invocation every time
without inferring it.

```bash
# Static analysis (MUST pass with zero warnings)
flutter analyze

# Tests
flutter test
flutter test --coverage

# Run the application with compile-time configuration
flutter run --dart-define-from-file=config/app.json

# Build for verification (no signing)
flutter build apk --debug --dart-define-from-file=config/app.json
flutter build ios --debug --no-codesign --dart-define-from-file=config/app.json

# Hive type adapter generation (per ADR-0018)
dart run build_runner build --delete-conflicting-outputs

# Install local git hooks after first clone (per ADR-0008)
lefthook install
```

The agent MUST NOT inject configuration values via `--dart-define`
flags directly; `--dart-define-from-file=config/app.json` is the
canonical mechanism (per ADR-0007).

---

## Hard Constraints

The following MUST NOTs are consolidated here for at-a-glance reference.
Each is enforced by the canonical document indicated; this list MUST NOT
diverge from those sources.

### Product and architecture

- UI / styling code MUST NOT be produced until Phase 9 is reached and the user explicitly approves UI implementation (see §"UI Constraint" above).
- Riverpod MUST NOT be used (`TECHNICAL_SPEC.md` §1).
- Manual Provider-based state management MUST NOT be used
  (`TECHNICAL_SPEC.md` §1).
- Presentation logic MUST NOT call HTTP endpoints directly
  (`ARCHITECTURE.md` §"Dependency Rule").
- Presentation logic MUST NOT access `Dio` directly
  (`ARCHITECTURE.md` §"Dependency Rule").
- Widgets MUST NOT invoke `GetIt` directly
  (`ARCHITECTURE.md` §"Dependency Injection").
- The `domain` layer MUST NOT depend on any other layer
  (`ARCHITECTURE.md` §"Dependency Rule").
- Numeric station IDs MUST NOT be used
  (`API_SPEC.md` §6.1). Use `stationuuid` exclusively.
- Mirror failover MUST NOT leak into the domain or presentation layers
  (`API_SPEC.md` §2).
- DTOs MUST NOT leak into the presentation layer
  (`VALIDATION_CHECKLIST.md` §Architecture).

### Configuration and infrastructure

- `.env` files MUST NOT exist in the repository
  (`TECHNICAL_SPEC.md` §7).
- Configuration values MUST NOT be injected via `--dart-define` flags
  directly when `--dart-define-from-file` is available
  (per ADR-0007).
- Generated `*.g.dart` files MUST NOT be excluded from version control
  (per ADR-0018).
- Third-party icon packages MUST NOT be added
  (`TECHNICAL_SPEC.md` §9).

### CI/CD and Git

- New roadmap task or sub-task work MUST NOT start on `main`; create or
  switch to a correctly named non-`main` working branch first (per ADR-0033).
- Merging branches into `main` (or `master`) is exclusively performed by the USER via GitHub Pull Requests. The agent MUST NOT merge branches directly (per ADR-0008/ADR-0009).
- Force pushes to `main` MUST NOT be permitted (per ADR-0008).
- The `main` branch MUST NOT be deleted (per ADR-0008).
- Branch protection rules on `main` MUST NOT be bypassed by anyone,
  including administrators (per ADR-0008).
- Commits MUST NOT be unsigned on `main` (per ADR-0008).
- Commits to `main` MUST NOT use the merge-commit or rebase-merge
  strategies; squash merge only (per ADR-0008).
- Commit messages MUST NOT deviate from the Conventional Commits format
  (per ADR-0009).

### Process

- Commits MUST NOT be made without explicit user approval
  (§"Permission-Based Development" above).
- Phase advancement MUST NOT happen without explicit user approval
  (§"Permission-Based Development" above).
- Production code MUST NOT be written before the failing test exists
  and has been reviewed (§"TDD Methodology" above).
- The agent MUST NOT automate past any review checkpoint
  (§"Interaction Protocol" above).
- The `ROADMAP.md` file MUST be updated to reflect completion of any phase or sub-phase immediately upon its execution and prior to advancing.

---

## Decision Recording Rule

Any architectural or product decision made during implementation MUST
be captured as a new ADR in `docs/adr/` **before** the corresponding
implementation lands on `main`. The procedure is:

1. Author the ADR using the template at `docs/adr/0000-template.md`.
2. Assign the next sequential number and set `Status: Accepted` after
   user approval (or `Status: Proposed` while awaiting approval).
3. Update the index in `docs/adr/README.md`.
4. Add the entry to the decision log in `MEMORY.md`.
5. Reference the ADR from the documentation impact described in the
   ADR itself; apply the documentation impact in the same pull request
   that introduces the ADR.

A decision MUST NOT be implemented if its ADR has not been accepted by
the user.

## Imported Claude Cowork project instructions
