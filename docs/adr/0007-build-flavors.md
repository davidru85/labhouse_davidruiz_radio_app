# ADR-0007 — Build flavors and configuration injection

- **Status:** Accepted
- **Date:** 2026-05-28
- **Deciders:** David Ruiz
- **Related:** `TECHNICAL_SPEC.md` §7, `ARCHITECTURE.md` §Configuration, `CONTEXT.md` §Key Constraints

## Context

The documentation fixes the configuration **mechanism** (compile-time
injection via `--dart-define` or `--dart-define-from-file`; no `.env`
files) but does not fix the **number of build flavors**, the layout of
the configuration file, or how debug-vs-release differences are
modelled.

The configuration surface of this application is small and stable:

- `BASE_USER_AGENT` (`API_SPEC.md` §3).
- API timeouts: 30 s connect, 60 s read (`API_SPEC.md` §4).
- Pagination defaults and maximum internal cap (`API_SPEC.md` §5.1).

The mirror list (`API_SPEC.md` §2) is not configuration — it is code,
and lives in `core/constants/`.

Multiple flavors imply Gradle `productFlavors` on Android and Xcode
schemes/configurations on iOS, plus a parallel `--dart-define-from-file`
per flavor. That cost is recurring; the benefit only materialises when
the application actually has differing values per environment.

Radio Browser is a public, unauthenticated, single-environment API. There
is no staging endpoint to point at.

## Decision

- **Single build flavor.** No Android `productFlavors`. No iOS schemes
  beyond the defaults produced by `flutter create`.
- **Configuration file.** Compile-time configuration values live in
  `config/app.json` and are injected via
  `--dart-define-from-file=config/app.json`.
- **Initial contents of `config/app.json`:**
  ```json
  {
    "BASE_USER_AGENT": "RadioApp/1.0",
    "API_CONNECT_TIMEOUT_SECONDS": "30",
    "API_READ_TIMEOUT_SECONDS": "60",
    "STATIONS_MAX_LIMIT": "100",
    "DEFAULT_STATIONS_PAGE_LIMIT": "30"
  }
  ```
- **The file is committed to git.** Radio Browser is unauthenticated;
  there are no secrets to protect.
- **Debug vs release** differentiation uses
  `kReleaseMode` / `kDebugMode` from `package:flutter/foundation.dart`.
  No flavor split is introduced for logging verbosity or assertion
  density.
- **Mirror list** stays in `core/constants/`, not in `config/app.json`.
  Mirrors are code; rotating them is a code change, not a deploy-time
  configuration change.

## Consequences

### Positive
- No invasive Gradle or Xcode customisation. The native build files
  remain close to `flutter create` defaults.
- A single `flutter run` invocation (with the `--dart-define-from-file`
  flag) covers the whole development workflow.
- The configuration surface stays small and centralised in one JSON
  file.
- `kReleaseMode` covers the actual day-to-day need (more logs in debug,
  fewer in release) with zero infrastructure cost.

### Negative
- A development build and a production build cannot coexist on the
  same device. For an assessment, this is acceptable.
- If a staging or QA backend is added later — for example, if the team
  fronts Radio Browser with its own caching proxy — adding flavors
  becomes a non-trivial migration. The migration is mechanical, but
  it touches Gradle, Xcode and the configuration directory layout.

### Neutral
- `config/app.json` is treated as code: any change to its values is a
  reviewed commit. There is no runtime override mechanism.

## Alternatives considered

### Option B — Two flavors (dev, prod) with applicationId suffix in dev
Rejected. The differing values between dev and prod would be limited
to log verbosity and possibly the User-Agent. Both are reachable with
`kReleaseMode` and a build-time check, without invading Gradle and
Xcode.

### Option C — Three flavors (dev, staging, prod)
Rejected outright. Radio Browser has no staging environment.

### Option D — Single flavor with `kReleaseMode` only, no JSON
Considered partially. Combined with the chosen approach: `kReleaseMode`
handles the runtime-mode dimension, while `config/app.json` handles
named configuration values. Pure-D was rejected because injecting
values via `--dart-define` flags directly is more error-prone and less
discoverable than a JSON file.

## Documentation impact

- `TECHNICAL_SPEC.md` §7 — replace the brief "use `--dart-define`" rule
  with the full single-flavor, `config/app.json`-based policy
  described above.
- `ARCHITECTURE.md` §Configuration — add a clarifying sentence that
  mirrors live in `core/constants/`, not in configuration files.
- `VALIDATION_CHECKLIST.md` — add a "Configuration" section with
  checks for: single flavor, presence of `config/app.json`, no `.env`
  files in the repo, no `productFlavors` block in `build.gradle`.
- `ROADMAP.md` Phase 1 — add sub-task: create `config/app.json` with
  the initial values listed above.

## Follow-ups

- If a staging environment is introduced later, a new ADR supersedes
  this one and introduces flavors.
- The values in `config/app.json` may be revised during Phase 1 RED
  testing as concrete tests reveal needed parameters.
