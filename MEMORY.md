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
 
* **Current Task:** Phase 9 **Sub-task 9.1–9.2 — Material & Cupertino screens** (Step 2 of the Phase 9 plan). Building the adaptive screens that render the shared BLoC states with Material on Android and Cupertino on iOS via a `PlatformBuilder` visual factory (per DESIGN.md / ADR-0005 / ADR-0032). Slices: (1) `PlatformBuilder` foundation — RED→GREEN done (RED `b188c51`, GREEN `3b5d0ff`, pushed); (2) `StationsScreen` — RED `ceb90c1`, GREEN `9bf4141` (pushed), REFACTOR in progress; (3) `FavoritesScreen`; (4) `FullPlayerScreen`. Shell/`IndexedStack`, mini-player, tab bars, transitions, offline banner, now-playing fallback and the a11y checklist stay in Steps 3–5.
* **Last Completed Task:** Phase 8 **Sub-task 8.3 — Shell BLoC scope lifecycle & disposal** — merged via **PR #40 (`382b2e2`)**. Closed Phase 8 (DI + routing).
* **Active Branch:** `feature/phase-9-sub-task-91-92-material-cupertino-screens` (branched from synced `main` @ `382b2e2`, per ADR-0033/0035).
* **Next Up:** Finish the `StationsScreen` RED→GREEN→REFACTOR slice, then the `FavoritesScreen` and `FullPlayerScreen` slices, then open the PR for Step 2 (user owns the merge).

### Phase 8 governing decisions (DI + routing)

* **Routing uses a `createAppRouter({navigatorKey})` factory** (not a shared global) so each test gets an isolated `GoRouter`. `initialLocation` is `/stations`. A `ShellRoute` wraps `/stations` + `/favorites` in `AppShell`; `/player` is a **top-level route outside the shell** (full-screen player), asserted by tests (`AppShell` is `findsNothing` on `/player`).
* **`AppShell` is intentionally a minimal passthrough** (`Scaffold(body: child)`) and the screens are minimal route-compilation placeholders — NOT a UI-gate breach, because Phase 8 mandates routing wiring and the targets must exist to compile. The real shell (bottom nav, mini-player, **`IndexedStack`**) is Phase 9 (ROADMAP §Phase 9).
* **Shell BLoC lifecycle & disposal (Sub-task 8.3) are now done as a mechanism:** `AppShell` exposes an optional `ShellScopeBuilder` (`Widget Function(BuildContext, Widget child)`); when supplied it wraps `Scaffold(body: child)` so a shell-scoped `BlocProvider` is shared across tabs and **auto-disposed** when the shell leaves the tree (incl. nav to out-of-shell `/player`). The widget never touches `GetIt` — the composition root will pass the builder. **Which concrete BLoCs are shell-scoped (and the root-scoped `RadioPlayerBloc`/`ConnectivityBloc` reachable from the out-of-shell `FullPlayerScreen`/global banner) is STILL deferred to Phase 9**, wired when the real `IndexedStack` shell + screens are built.

### Phase 7 governing decisions (BLoC layer — reuse from Phase 8 on)

* **BLoCs depend on use cases only** (ARCHITECTURE.md §"Dependency Rule"). Use cases are `final class` and therefore unmockable, so BLoC tests **mock the repository contracts and build REAL use cases** with `mocktail`. BLoCs never touch `Dio`/Hive/DTOs/HTTP/`GetIt` directly.
* **Mocktail no-arg stubs MUST use tear-offs** (`when(repo.method)`), not closures (`when(() => repo.method())`) — `very_good_analysis`/`unnecessary_lambdas` rejects the closure form. This is a recurring AI-review false positive; keep tear-offs.
* Each BLoC is single-file (event + state + bloc together), imports `flutter_bloc` (not transitive `bloc`), documents every public member.
* `RadioPlayerBloc`: stream-driven; a play request **optimistically emits `RadioPlayerBuffering`** before Playing/Error (ADR-0015/0025); UI states are named `RadioPlayer*` to avoid clashing with the domain `PlayerState`. It takes an **injectable `now` clock** (`DateTime Function()`, defaults to `DateTime.now`) so playback-duration analytics are deterministic in tests. `StationPlayedEvent` fires once per session (a mid-playback Buffering stall does not re-fire it); `StationStoppedEvent` fires on leaving Playing — including a **direct station switch** and a **Playing→Error** transition — with duration derived from the transition timestamps (ADR-0019).
* `StationsBloc`: trim before search, 350 ms debounce + `switchMap`, min 3 chars, empty query → popular, dispose-cancellation in `close()`, `STATIONS_MAX_LIMIT` cap (`maxStations`, default 100), dedup by `stationUuid` (ADR-0014/0031). Fires `SearchPerformedEvent` only on non-empty text searches (not the popular fallback) and `FilterAppliedEvent(country|genre)` on filters. A new text search intentionally resets country/tag filters (pre-existing, ADR-0014/API_SPEC §5.1 do not mandate preserving them).
* `ConnectivityBloc`: built over `WatchConnectivityUseCase`; uses a distinct `ConnectivityInitial` so the first stream value always surfaces as a state transition (ADR-0013). NB: ADR-0013 names `onlineStatusStream`/`isCurrentlyOnline()` but the real `ConnectivityRepository` contract is `connectivityStream`/`checkConnectivity()` — trust the code.
* **Analytics is fire-and-forget and MUST NOT propagate failures to BLoCs.** `TrackAnalyticsEventUseCase.call` wraps `_repository.track` in try/catch and swallows any error; BLoCs invoke it via `unawaited(...)` (TESTING_STRATEGY §Analytics / ADR-0019). Default repo is `NoOpAnalyticsRepositoryImpl`; no real provider until a GDPR consent flow exists.
* mocktail typed matchers (`any<SomeEvent>()`) need a `registerFallbackValue` of that exact subtype — a base `AppOpenedEvent` fallback does NOT satisfy `any<StationPlayedEvent>()` (resolved by `value is T`).

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
