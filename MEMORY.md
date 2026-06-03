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
| [0040](docs/adr/0040-favorites-local-search-deferral.md) | Defer the `DESIGN.md`-specified "Search your favorites" field from the Phase 9 FavoritesScreen slice (FavoritesBloc has no filter event); reintroduction is additive via a filter event/state or local filter + tests | 2026-06-03 |

---

## Current Progress Tracker
 
* **Current Task:** Phase 9 **Step 3 — tasks 9.3–9.6** (real `IndexedStack` `AppShell` + scroll preservation + `MiniPlayerWidget` + mini-player visibility animation). **Not started.** Branch off freshly-synced `main` @ `2f8b89a` per ADR-0033/0035 and start RED — see the execution plan below.
* **Last Completed Task:** Phase 9 **Step 2 — Sub-task 9.1–9.2 (Material & Cupertino list/browse screens)** — **merged via PR #41 (`main` now @ `2f8b89a`)**. Adaptive screens that render the shared BLoC states with Material on Android and Cupertino on iOS via a `PlatformBuilder` visual factory (DESIGN.md / ADR-0005 / ADR-0032). Slices delivered, each RED→GREEN→REFACTOR:
  * (1) `PlatformBuilder` adaptive visual factory — RED `b188c51`, GREEN `3b5d0ff`.
  * (2) `StationsScreen` (adaptive browse/search list) — RED `ceb90c1`, GREEN `9bf4141`, REFACTOR `581a935` (extract shared body layout).
  * (3) `FavoritesScreen` (adaptive grid) — RED `00b35e6`, GREEN `04c1077`; the DESIGN.md "Search your favorites" field was deferred via **ADR-0040** (add `c5cceff`, accept `24e74b1`) because `FavoritesBloc` has no filter event — see TODO.md §User interface.
  * (4) Cross-screen REFACTOR — extracted the shared "primary tag • country" subtitle into `lib/presentation/utils/station_subtitle.dart` and the adaptive loading spinner into `AdaptiveProgressIndicator` (`lib/presentation/widgets/adaptive/adaptive_progress_indicator.dart`); both screens reuse them. Commits `d3f4f62` (refactor) + `f577211` (docs: documented the new `presentation/utils/` folder in ARCHITECTURE.md, also adding the previously-undocumented `presentation/l10n/` and `presentation/routing/`). Reviewed via `/review_my_code` → Approved, then `/fix_review_issues` resolved the single non-blocking finding (N1, the folder-map note). `flutter analyze` clean; 389 tests green.
  * **NOTE — `FullPlayerScreen` and `AppShell` are still Phase-8 route-compilation placeholders** (`lib/presentation/screens/full_player_screen.dart` renders `Text('Player')`; `lib/presentation/widgets/app_shell.dart` is the `ShellScopeBuilder` passthrough). The real shell is built in **Step 3 (task 9.3)** and the real player screen in **Step 4 (task 9.7)** — they were NOT part of Step 2.
* **Active Branch:** `docs/memory-phase-9-execution-plan` — a docs-only branch (off synced `main` @ `2f8b89a`) that records this tracker + the Phase 9 execution plan. The Step 3 feature branch is created only after this docs branch is handled and `main` is synced.
* **Next Up:** **Step 3 (tasks 9.3–9.6)**, RED first — see the execution plan below.

### Phase 9 execution plan (canonical sequencing — Steps map onto the 13 flat ROADMAP §Phase 9 tasks)

The Phase 9 UI gate is **UNBLOCKED** (the user confirmed the visual specs in DESIGN.md / `stitch/` are final and explicitly approved UI work). The 13 ROADMAP §Phase 9 tasks are numbered 9.1–9.13 in roadmap order and bundled into **5 TDD steps**, each on its own branch off a freshly-synced `main`, one PR per step, RED→GREEN→REFACTOR per slice, **the user owns every merge** (ADR-0033/0035/0036, see [[dev-workflow]] for the strict cycle):

* **Step 1 — Phase 8 deferred shell lifecycle (DONE).** BLoC-shell scope + proper disposal, delivered logic-only as Sub-task 8.3 / PR #40: `AppShell` takes an optional `ShellScopeBuilder` so one shell-scoped BLoC instance is shared across tabs and auto-disposed when the shell leaves the tree. **Which concrete BLoCs are shell-scoped** (vs. the root-scoped `RadioPlayerBloc`/`ConnectivityBloc` reachable from the out-of-shell `FullPlayerScreen` and the global banner) is wired in Step 3 with the real `IndexedStack` shell.
* **Step 2 — Tasks 9.1–9.2: Material (Android) + Cupertino (iOS) list/browse screens (DONE, merged via PR #41).** `StationsScreen` + `FavoritesScreen` adaptive via `PlatformBuilder`. (The "all screens" wording of 9.1/9.2 also covers the real player screen, but that is intentionally built in Step 4 / task 9.7; Step 2 shipped the two list screens.)
* **Step 3 — Tasks 9.3–9.6:** 9.3 replace the placeholder `AppShell` with a real `IndexedStack` shell (and wire the concrete shell-scoped BLoCs from Step 1); 9.4 preserve scroll state across tabs; 9.5 `MiniPlayerWidget` driven by `RadioPlayerBloc` (must render `RadioPlayerBuffering` distinctly from `RadioPlayerPlaying`, per ADR-0015); 9.6 animate mini-player visibility for idle / buffering / playing.
* **Step 4 — Tasks 9.7–9.10:** 9.7 navigate to the real `FullPlayerScreen` when the mini-player is tapped (replaces the placeholder); 9.8 bottom-to-top vertical slide transition; 9.9 tab navigation (`BottomNavigationBar` on Android, `CupertinoTabBar` on iOS); 9.10 global "You're offline" / "Back online" banner driven by `ConnectivityBloc` (ADR-0013).
* **Step 5 — Tasks 9.11–9.13:** 9.11 per-screen offline copy + retry affordances (ADR-0013); 9.12 render `RadioPlayerPlaying.nowPlaying` (track / artist) in the Mini and Full players, falling back to station name when absent (ADR-0012); 9.13 the visual accessibility checklist from ADR-0006 (contrast ratios, TalkBack + VoiceOver walkthroughs, focus traversal).

Phase 9 is the **final** roadmap phase (ROADMAP.md ends with it, followed only by the §Phase Advancement Rule). Once all 5 steps merge, v1 is feature-complete; the closing activity is the `VALIDATION_CHECKLIST.md` pass plus the §Phase Advancement Rule gate (present work / test output / linter output / explicit user approval). All deliberately deferred, post-v1 scope lives in `TODO.md`.

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
