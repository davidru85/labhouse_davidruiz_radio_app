# PROJECT MEMORY / LOG

## Decision Log

Architectural and product decisions are recorded as immutable ADRs in
`docs/adr/`. This log is an index; consult the linked ADR for context,
alternatives considered, and consequences.

### Foundational stack decisions (pre-ADR)

These decisions predate the ADR process and are inherited from the
original specification. The date below reflects when they were
incorporated into the project's source-of-truth documents (the `.md`
files that initiated this polish phase). They may be retro-converted
to ADRs if revisited.

| Decision                                                          | Date       |
|-------------------------------------------------------------------|------------|
| Hive over Isar for local persistence (scale, avoid over-engineering) | 2026-05-28 |
| BLoC as the exclusive state management pattern                    | 2026-05-28 |
| `go_router` for routing                                           | 2026-05-28 |
| `very_good_analysis` for strict static analysis                   | 2026-05-28 |
| UI implementation blocked until visual specifications are provided | 2026-05-28 |
| Radio Browser API details isolated in data and networking layers  | 2026-05-28 |

### Recorded ADRs

| ADR  | Decision                                          | Date       |
|------|---------------------------------------------------|------------|
| [0001](docs/adr/0001-target-platforms.md)        | Target platforms: Android + iOS only             | 2026-05-28 |
| [0002](docs/adr/0002-minimum-os-versions.md)     | Android `minSdk=23`/`target=compile=34`, iOS 13  | 2026-05-28 |
| [0003](docs/adr/0003-app-identifiers.md)         | Bundle ID `com.labhouse.davidruizassessment.radioapp` | 2026-05-28 |
| [0004](docs/adr/0004-screen-orientation.md)      | Portrait-only on both platforms                  | 2026-05-28 |
| [0005](docs/adr/0005-i18n-and-country-names.md)  | English-only UI with i18n scaffold; `intl` for countries | 2026-05-28 |
| [0006](docs/adr/0006-accessibility-baseline.md)  | WCAG 2.1 AA in two checkpoints                   | 2026-05-28 |
| [0007](docs/adr/0007-build-flavors.md)           | Single flavor; `config/app.json` for compile-time values | 2026-05-28 |
| [0008](docs/adr/0008-ci-cd-strategy.md)          | GitHub Actions CI + lefthook + branch protection on `main` | 2026-05-28 |
| [0009](docs/adr/0009-git-workflow.md)            | GitHub Flow + Conventional Commits; git initialised at Phase 1 | 2026-05-28 |
| [0010](docs/adr/0010-volume-control-scope.md)    | System volume only; no in-app volume control     | 2026-05-28 |
| [0011](docs/adr/0011-sleep-timer-scope.md)       | Sleep timer out of scope for v1; tracked in TODO.md | 2026-05-28 |
| [0012](docs/adr/0012-now-playing-metadata.md)    | Now-playing (Icy) metadata in scope; `NowPlayingInfo` entity + stream | 2026-05-28 |
| [0013](docs/adr/0013-offline-behavior.md)        | Offline behaviour: `connectivity_plus`, `ConnectivityBloc`, global banner, no auto-resume | 2026-05-28 |
| [0014](docs/adr/0014-search-debounce.md)         | Search debounce 350 ms, min 3 chars, `CancelToken` cancellation | 2026-05-28 |
| [0015](docs/adr/0015-player-buffering-state.md)  | Explicit `PlayerBufferingState` in `RadioPlayerBloc` | 2026-05-28 |
| [0016](docs/adr/0016-mirror-cache-persistence.md) | Mirror cache persisted in Hive box `app_settings` | 2026-05-28 |
| [0017](docs/adr/0017-core-utils-folder.md)       | Add `core/utils/` to canonical folder structure   | 2026-05-28 |
| [0018](docs/adr/0018-official-dependency-list.md) | Consolidated dependency list (13 prod + 7 dev); add `build_runner`/`hive_generator` | 2026-05-28 |
| [0019](docs/adr/0019-analytics-interface.md)     | Analytics interface (provider-agnostic); sealed events + no-op default; consent deferred | 2026-05-28 |

---

## Current Progress Tracker

* **Current Phase:** Phase 1 - Infrastructure And Project Bootstrapping.
* **Current Task:** Present Phase 1 PHASE RED testing strategy before production implementation.
* **Last Completed Task:** Split original project setup prompt into concern-specific markdown files.

---

## Open Risks

* Radio Browser mirrors may be unavailable or inconsistent.
* Some station streams may be broken even when `lastcheckok == 1`.
* HTTP audio streams may require permissive native configuration, especially on iOS.
* Country code API returns raw ISO codes, so human-readable names require a mapping utility or `intl`.
* UI work must not begin before visual specifications are provided.

---

## Pending Questions

* What exact visual design system will be used once UI work is approved?
* Should popular stations rely on explicit top endpoints or search with `order=clickcount`?

