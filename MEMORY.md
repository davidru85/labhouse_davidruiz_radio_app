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
| [0014](docs/adr/0014-search-debounce.md)         | Search debounce 350 ms, min 3 chars, data-layer cancellation | 2026-05-28 |
| [0015](docs/adr/0015-player-buffering-state.md)  | Explicit `PlayerBufferingState` in `RadioPlayerBloc` | 2026-05-28 |
| [0016](docs/adr/0016-mirror-cache-persistence.md) | Mirror cache persisted in Hive box `app_settings` | 2026-05-28 |
| [0017](docs/adr/0017-core-utils-folder.md)       | Add `core/utils/` to canonical folder structure   | 2026-05-28 |
| [0018](docs/adr/0018-official-dependency-list.md) | Consolidated dependency list (13 prod + 7 dev); add `build_runner`/`hive_generator` | 2026-05-28 |
| [0019](docs/adr/0019-analytics-interface.md)     | Analytics interface (provider-agnostic); sealed events + no-op default; consent deferred | 2026-05-28 |
| [0020](docs/adr/0020-favorites-sync-resilience.md) | Prevent silent deletion of missing remote favorites; set lastCheckOk=false | 2026-05-29 |
| [0021](docs/adr/0021-recently-played-history-limit.md) | Enforce a strict FIFO cap of 50 items on recently played history | 2026-05-29 |
| [0022](docs/adr/0022-background-playback-controls.md) | Limit background media notification to Play/Pause/Stop and configure title/subtitle metadata | 2026-05-29 |
| [0023](docs/adr/0023-api-mirrors-list.md) | Pre-configure a static list of four default HTTPS API mirrors (DE, AT, NL, FR) | 2026-05-29 |
| [0024](docs/adr/0024-now-playing-parsing-rules.md) | Split raw Icy metadata on the first space-hyphen-space separator | 2026-05-29 |
| [0025](docs/adr/0025-offline-playback-state-transitions.md) | Transition through Buffering before emitting PlayerErrorState on offline playback request | 2026-05-29 |
| [0026](docs/adr/0026-recently-played-history-triggers.md) | Recently played history triggers: successful PlayerPlayingState | 2026-05-29 |
| [0027](docs/adr/0027-popular-stations-strategy.md) | Popular stations strategy: re-use search endpoint with clickcount/votes | 2026-05-29 |
| [0028](docs/adr/0028-error-observability-crash-reporting.md) | Error observability: standard console logging for v1, no third-party services | 2026-05-29 |
| [0029](docs/adr/0029-recently-played-history-presentation-surface.md) | Recently played history presentation surface: StationsScreen empty query section | 2026-05-29 |
| [0030](docs/adr/0030-android-cleartext-traffic.md) | Android cleartext traffic configuration: allow usesCleartextTraffic="true" | 2026-05-29 |
| [0031](docs/adr/0031-search-pagination-deduplication-and-end.md) | Search pagination: client-side deduplication by UUID and hasReachedMax tracking | 2026-05-29 |
| [0032](docs/adr/0032-country-name-resolution-strategy.md) | Country name resolution strategy: integrate via standard ARB localization resources (amended 2026-06-01: `country_name_resolver` is a pure helper taking a lookup callback since gen-l10n has no dynamic key lookup; resolution at the presentation boundary, data mapper leaves name as raw ISO code) | 2026-05-29 |
| [0033](docs/adr/0033-branch-before-task.md) | Create or confirm a correctly named non-main branch before every new roadmap task or sub-task | 2026-05-30 |
| [0034](docs/adr/0034-domain-free-core-utils.md) | Keep `core/utils` domain-free; map Icy parser output to domain entities at consuming boundaries | 2026-05-30 |
| [0035](docs/adr/0035-pr-before-next-task-branch.md) | Wait for PR merge and synced `main` before creating the next sub-task branch | 2026-05-31 |
| [0036](docs/adr/0036-push-after-green-commit.md) | Push the approved commit to the remote feature branch as the final step of PHASE GREEN and PHASE REFACTOR (amended 2026-06-01 to add REFACTOR) | 2026-05-31 |
| [0037](docs/adr/0037-hive-persistence-model-design.md) | Hive persistence model design: `*HiveModel` naming, append-only `typeId` registry (0 Station, 1 Genre, 2 Country), one `StationHiveModel` for favorites+history, data sources expose domain entities | 2026-06-01 |
| [0038](docs/adr/0038-adopt-hive-community-edition.md) | Adopt Hive Community Edition (`hive_ce`/`hive_ce_flutter`/`hive_ce_generator`), replacing `hive_flutter`/`hive_generator` and removing the `analyzer ^6.4.1` override; supersedes ADR-0018 in part (unmaintained `hive_generator` is incompatible with the current Dart SDK) | 2026-06-01 |
| [0039](docs/adr/0039-mirror-failover-and-remote-error-mapping.md) | Mirror failover networking: `MirrorFailoverInterceptor` + async `DioClientFactory` (initial mirror from `MirrorCacheDataSource`, retry on connection/5xx, caps 2/mirror & 6 total, write-back on success); `mapDioException`→`Failure`; remote data sources throw `NetworkException(failure)` and repositories convert to `Result` in Phase 6 | 2026-06-01 |

---

## Current Progress Tracker
 
* **Current Task:** Phase 6, **combined Sub-task 6.7** (`AudioPlayerRepositoryImpl` + `ConnectivityRepositoryImpl` + `NoOpAnalyticsRepositoryImpl`) — **REFACTOR/PR-ready** on branch `feature/phase-6-sub-task-67-remaining-repository-impls` (branched from synced `main` @ `3af5896` after PR #33 merged, per ADR-0033/0035; combining the remaining repos into one sub-task was a user-approved one-off exception). `NoOpAnalyticsRepositoryImpl`: const no-op `track()` (ADR-0019). `ConnectivityRepositoryImpl`: forwards `onlineStatusStream`; `checkConnectivity()` guards `isOnline()` and maps a probe error to `SocketFailure` (ADR-0013). `AudioPlayerRepositoryImpl`: over a testable `AudioPlaybackDataSource` port (`PlaybackStatus` enum + Icy stream) — forwards play/pause/stop, maps engine errors to `StreamUnreachableFailure`/`PlaybackInterruptedFailure`, maps Icy via `parseIcyMetadata`→`NowPlayingInfo`, and merges a connectivity drop **during an active session (playing OR buffering, `_isSessionActive`)** into `playerStateStream` as `PlayerErrorState(ConnectivityLostFailure)` (ADR-0012/0013/0025); added concrete `PlayerState` subclasses to domain. **Scope deferral:** the concrete `just_audio`/`audio_service` adapter + ADR-0022 notification controls are untested glue deferred to composition-root wiring. RED `1787d79`; GREEN `ad1b82a`; review fix B4 (offline-during-rebuffering) RED `a859a88`→GREEN `b862358`; **GREEN pushed** (per ADR-0036). `flutter analyze` clean, full suite **284 green**. Code review (`/fix_review_issues`) resolved: B2/B1-compliance were false positives, B4 fixed, N2 patch artifact removed, B3/N1 noted as accepted scope/contract items.
* **Last Completed Task:** Phase 6, Sub-task 6.6 (`PlaybackUrlRepositoryImpl`), merged via PR #33 (`3af5896`, now the `main` tip). §5.3 fallback chain click→`resolvedStreamUrl`→`streamUrl`; `NetworkException` from click degrades to the station URLs; `StreamUnreachableFailure` only when no usable URL. (6.4 Countries PR #31, 6.5 History PR #32 merged earlier.)
* **Active Branch:** `feature/phase-6-sub-task-67-remaining-repository-impls` (branched from synced `main` @ `3af5896` after PR #33 merged, per ADR-0035).
* **Next Up:** after 6.7 merges, Phase 6 repository implementations are complete (concrete audio plugin adapter still deferred). Next is **Phase 7 — BLoC Layer And Domain Testing** (`bloc_test`); the concrete `just_audio`/`audio_service` adapter + ADR-0022 controls need wiring in the composition root with an integration test.

---

## Open Risks

* Radio Browser mirrors may be unavailable or inconsistent.
* Some station streams may be broken even when `lastcheckok == 1`.
* HTTP audio streams may require permissive native configuration, especially on iOS.
* Dynamic ISO country code lookup via ARB keys is resolved at strategy level but requires verification during Phase 2.
* UI implementation is strictly gated on Phase 9 and requires explicit user approval.

---

## Pending Questions

* None. The pre-coding documentation gaps have been fully resolved.
