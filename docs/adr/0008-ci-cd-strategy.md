# ADR-0008 — CI/CD strategy and branch protection

- **Status:** Accepted
- **Date:** 2026-05-28
- **Deciders:** David Ruiz
- **Related:** ADR-0007, `AGENTS.md` §Critical Execution Rules, `CONTEXT.md` §Project Goal

## Context

`CONTEXT.md` calls for a "production-grade" application but the
specification suite does not define how code quality is enforced beyond
the static-analysis rule (`very_good_analysis` with zero warnings).
Concretely, the documentation says nothing about:

- Where tests run (locally only, or on a remote CI server).
- Who or what guards the `main` branch against broken changes.
- How `--dart-define-from-file=config/app.json` (per ADR-0007) is
  invoked in non-local builds.
- Whether commit authenticity is verified.

The project is developed by a single person (David Ruiz) and lives on
GitHub. GitHub's branch protection feature can enforce most of the
guarantees a "production-grade" claim implies, but two of those features
require a second human reviewer:

- **Required pull request approvals.** GitHub does not allow a pull
  request's author to approve their own pull request. A solo developer
  cannot satisfy `Required approvals >= 1` without a second account or
  an admin bypass — both of which dilute the guarantee.

This ADR fixes the verification strategy and the branch protection
rules that match the solo-developer reality without compromising the
"production-grade" claim where it can be honestly upheld.

## Decision

### Verification layers

Three independent layers protect the codebase, applied in order from
fastest feedback to most authoritative:

1. **Local git hooks via [lefthook](https://github.com/evilmartians/lefthook).**
   `lefthook.yml` is versioned in the repository; `lefthook install`
   wires the hooks after cloning.
   - `pre-commit`: `dart format --set-exit-if-changed lib/ test/`,
     then `flutter analyze`.
   - `pre-push`: `flutter test`.
2. **Remote CI via GitHub Actions.** A single workflow
   `.github/workflows/ci.yml` runs on every `push` to non-`main`
   branches and on every `pull_request` targeting `main`. Four jobs
   in parallel:
   - `analyze` — Ubuntu runner, `flutter analyze` with zero warnings.
   - `test` — Ubuntu runner, `flutter test --coverage`.
   - `build-android` — Ubuntu runner,
     `flutter build apk --debug --dart-define-from-file=config/app.json`.
   - `build-ios` — macOS runner,
     `flutter build ios --debug --no-codesign --dart-define-from-file=config/app.json`.
3. **Branch protection on `main`.** See rules table below.

Flutter version is pinned in the workflow via
`subosito/flutter-action@v2` with `flutter-version: 3.41.x` (bundles
Dart 3.11.4, matching the `sdk: ^3.11.4` constraint in `pubspec.yaml`).
Pub and Gradle caches are enabled.

### Branch protection rules on `main`

| Rule                                                                  | Value                                                       |
|-----------------------------------------------------------------------|-------------------------------------------------------------|
| Require a pull request before merging                                 | Enabled                                                     |
| Required approvals                                                    | **0** (see "Required approvals = 0" rationale below)        |
| Dismiss stale pull request approvals when new commits are pushed      | Enabled                                                     |
| Require status checks to pass before merging                          | Enabled                                                     |
| Required status checks                                                | `analyze`, `test`, `build-android`, `build-ios`             |
| Require branches to be up to date before merging                      | Enabled                                                     |
| Require conversation resolution before merging                        | Enabled                                                     |
| Require linear history                                                | Enabled                                                     |
| Require signed commits                                                | Enabled (SSH signing)                                       |
| Do not allow bypassing the above settings                             | Enabled (applies to admins)                                 |
| Restrict who can push to matching branches                            | Enabled (implicit via PR requirement)                       |
| Allow force pushes                                                    | Disabled                                                    |
| Allow deletions                                                       | Disabled                                                    |
| Allowed merge methods on the repository                               | **Squash only** (rebase and merge commits disabled)         |

### Required approvals = 0 — rationale

GitHub does not allow a PR's author to approve their own PR. As a solo
developer, setting `Required approvals >= 1` would force one of:

- maintaining a second GitHub account whose only purpose is approval
  (theatre);
- enabling admin bypass and merging without approval (undermines the
  rule);
- self-comment review followed by admin bypass (still bypass).

All three options would put a visible asterisk on the workflow. Setting
`Required approvals = 0` is the honest configuration: the review gate
is replaced by the rest of the rules (PR mandatory, CI mandatory, linear
history, signed commits, no bypass), which collectively prevent every
class of accidental harm that an approval gate would. The substitution
is documented in this ADR and surfaced in `README.md` (when added) so
that any reviewer of the project understands the trade-off explicitly.

If the project ever grows to more than one developer, a new ADR
supersedes this one and sets `Required approvals = 1`.

### Signed commits

Signed commits are required at the branch protection level. SSH signing
is used (not GPG):

- Lower setup friction on macOS than GPG with `pinentry-mac`.
- The same SSH key used for git auth can be registered as a signing key
  on GitHub.
- `git config gpg.format ssh` and `git config user.signingkey <path>`
  configure the local repo.

Every commit on `main` therefore carries the "Verified" badge.

### Squash merge only

`Allow merge commits` and `Allow rebase merging` are both disabled at
the repository level. Only squash merge is offered when merging a PR.

This is consistent with:

- The linear-history requirement on `main`.
- The TDD micro-cycle in `AGENTS.md`: each pull request closes a single
  Red-Green-Refactor sub-task, so one commit on `main` per PR is the
  correct projection. The Red, Green and Refactor commits inside the
  PR remain accessible from the PR view.

### What is explicitly out of scope

- **Continuous delivery.** No automated release artifacts, no upload to
  Play Console or TestFlight, no signed release builds. Generating an
  installable build is a manual operation performed locally when
  needed.
- **Coverage thresholds.** `test` produces a coverage report but no
  minimum percentage is enforced yet. Coverage policy will be decided
  in a later ADR alongside the testing strategy refinement.

## Consequences

### Positive
- A pull request that does not analyze, test or build on Android and
  iOS cannot be merged into `main`. Period.
- Local hooks give second-level feedback before a push round-trip.
- The `main` branch carries a fully verified, squash-merged, linear
  history.
- The substitution of approval gate for stricter automated gates is
  documented and defensible.
- The full strategy is reproducible from the repository contents:
  `.github/workflows/ci.yml` and `lefthook.yml` are versioned;
  branch protection is configured once on GitHub.

### Negative
- Branch protection settings live on GitHub, not in the repository.
  They must be re-applied if the repository is forked or migrated.
- Signed commits require per-machine SSH-signing setup. Forgetting it
  blocks the next push until configured.
- The `build-ios` job consumes macOS runner minutes from the GitHub
  Actions quota. For the assessment scope this is well within the
  free tier; for sustained development on a private repo it should be
  monitored.

### Neutral
- Lefthook adds one development-time dependency. It is invoked by git,
  not by Flutter, so it does not affect the Flutter dependency graph.

## Alternatives considered

### Option A — No CI/CD
Rejected. Incompatible with the "production-grade" claim in
`CONTEXT.md`.

### Option B — Local hooks only, no remote CI
Rejected. Local hooks are not verifiable by any third party (including
an assessment reviewer). The "build is green" claim requires a remote
witness.

### Option D-prime — Branch protection with `Required approvals = 1` + second GitHub account
Rejected. The user explicitly opted against maintaining a second
account.

### Option D-prime-prime — Branch protection with `Required approvals = 1` + admin bypass
Rejected. The bypass is visible in the merge metadata and undermines
the rule.

### Continuous delivery in scope from day 1
Rejected. iOS release signing requires a paid Apple Developer Program
account, which is not in scope. Android release signing is feasible
but offers no value at this stage.

## Documentation impact

- `TECHNICAL_SPEC.md` — add a new "CI/CD" section summarising the
  layers, the workflow, the hooks and the branch protection rules.
  Refer to this ADR for rationale.
- `VALIDATION_CHECKLIST.md` — add a new "CI/CD" section:
  - `.github/workflows/ci.yml` runs `analyze`, `test`, `build-android`,
    `build-ios`.
  - `lefthook.yml` runs `dart format`, `flutter analyze` on pre-commit
    and `flutter test` on pre-push.
  - `main` branch protection matches the rules table in ADR-0008.
- `ROADMAP.md` Phase 1 — add sub-tasks:
  - Create `.github/workflows/ci.yml`.
  - Create `lefthook.yml`.
  - Run `lefthook install` after first clone.
  - Apply branch protection rules to `main` on GitHub.
  - Configure SSH signing on the development machine.
- A future `README.md` (per pending Task #24) explains the
  `Required approvals = 0` choice for any external reviewer.

## Follow-ups

- ADR for coverage threshold policy, alongside testing strategy
  refinement.
- ADR for continuous delivery if release builds are ever automated.

## Appendix A — Initial `.github/workflows/ci.yml` skeleton

```yaml
name: CI

on:
  push:
    branches-ignore: [main]
  pull_request:
    branches: [main]

env:
  FLUTTER_VERSION: "3.41.x"

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      - run: flutter pub get
      - run: flutter analyze

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      - run: flutter pub get
      - run: flutter test --coverage

  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: "17"
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      - run: flutter pub get
      - run: flutter build apk --debug --dart-define-from-file=config/app.json

  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      - run: flutter pub get
      - run: flutter build ios --debug --no-codesign --dart-define-from-file=config/app.json
```

## Appendix B — Initial `lefthook.yml` skeleton

```yaml
pre-commit:
  parallel: true
  commands:
    format:
      run: dart format --set-exit-if-changed lib/ test/
    analyze:
      run: flutter analyze

pre-push:
  commands:
    test:
      run: flutter test
```
