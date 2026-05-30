# IMPLEMENTATION ROADMAP

Development follows the TDD Red / Green / Refactor micro-cycle and its
review checkpoints, as defined in `AGENTS.md` §"Mandatory TDD
Micro-Cycle". This roadmap describes the sequence of work; the workflow
is governed there.

Before starting any new roadmap task or sub-task, the active git branch
MUST be verified. If the repository is on `main`, create a non-`main`
working branch using the ADR-0009 roadmap naming convention before
writing the RED test, production code, or task-specific documentation
changes (per ADR-0033).

Roadmap branch names MUST follow
`<type>/phase-<phase>-sub-task-<subtask>-<short-description>`, where
`<subtask>` removes punctuation from the roadmap sub-task number. Example:
`feature/phase-2-sub-task-21-domain-entities`.

---

## Phase 1: Infrastructure And Project Bootstrapping

> [!NOTE]
> **Dio Client Scope:** Phase 1 implements ONLY the base `Dio` client factory, required headers, timeout configuration, and a basic retry interceptor cycling through a static mirror list. Persisting the last-known mirror using Hive is strictly deferred to Phase 4 (Local Storage) and Phase 5 (Remote Data Source).

Tasks MUST follow the sequential TDD RED/GREEN/REFACTOR micro-cycle checkpoints:

### Sub-task 1.1: Platform Cleanup & Naming
* [x] **PHASE RED:** Write tests or run assertions verifying that non-conforming platform folders (`web/`, `macos/`, `linux/`, `windows/`) exist, that the default package name does not match `radio_app`, and that `main.dart` contains the default flutter template. Present failing checks.
* [x] **PHASE GREEN:** 
  * Delete `web/`, `macos/`, `linux/`, `windows/` platform folders to conform to Android/iOS only (per ADR-0001).
  * Update package name in `pubspec.yaml` to `radio_app`.
  * Update native package identifier to `com.labhouse.davidruizassessment.radioapp` (per ADR-0003).
  * Replace default counter code in `lib/main.dart` with a minimal clean shell (gating actual UI).
  * Initialise git repository, configure local SSH signing, and present passing checks.
* [x] **PHASE REFACTOR:** Ensure code formatting passes and files are cleanly organized.

### Sub-task 1.2: Strict Linter & Dependencies Setup
* [x] **PHASE RED:** Assert that `analysis_options.yaml` uses default rules and `pubspec.yaml` lacks the 13 production and 7 dev dependencies defined in ADR-0018. Present failing checks.
* [x] **PHASE GREEN:**
  * Configure `analysis_options.yaml` with `very_good_analysis` and the zero-warnings policy.
  * Add dependencies to `pubspec.yaml` (ADR-0018). Run `flutter pub get`.
* [x] **PHASE REFACTOR:** Verify linter returns zero warnings (`flutter analyze`).

### Sub-task 1.3: Folder Structure & App Configuration
* [x] **PHASE RED:** Assert that the mandatory Clean Architecture folders (`lib/core/utils`, `lib/domain/failures`, etc.) do not exist and `config/app.json` is missing. Present failing checks.
* [x] **PHASE GREEN:**
  * Create the folder structure specified in `ARCHITECTURE.md` §"Mandatory Folder Structure".
  * Create `config/app.json` with the initial configuration variables defined in ADR-0007.
* [x] **PHASE REFACTOR:** Ensure folder naming is perfectly aligned.

### Sub-task 1.4: Base Dio Client Factory & Mirror Constants
* [x] **PHASE RED:** Write unit tests in `test/core/network/dio_client_test.dart` verifying that `Dio` is configured with a 30s connection timeout, 60s read timeout, `Content-Type: application/json; charset=utf-8` header, custom descriptive `User-Agent` header (e.g. `RadioApp/1.0`), and checking that the 4 default HTTPS mirror URLs are defined in `core/constants/mirrors.dart`. Run and show failing test results.
* [x] **PHASE GREEN:**
  * Implement mirror constants in `lib/core/constants/mirrors.dart` (per ADR-0023).
  * Implement base `Dio` client factory in `lib/core/network/dio_client.dart` with timeout/header configurations. Run and show passing tests.
* [x] **PHASE REFACTOR:** Clean up factory and test code.

### Sub-task 1.5: CI/CD Workflows & Git Hooks
* [x] **PHASE RED:** Assert that `.github/workflows/ci.yml` and `lefthook.yml` are missing. Present failing checks.
* [x] **PHASE GREEN:**
  * Create `.github/workflows/ci.yml` with `analyze`, `test`, `build-android`, `build-ios` jobs (per ADR-0008).
  * Create `lefthook.yml` with pre-commit (format + analyze), pre-push (test), and commit-msg (Conventional Commits) hooks (per ADR-0008/0009). Run `lefthook install`.
* [x] **PHASE REFACTOR:** Verify hooks run successfully locally.

---

## Phase 2: Domain Layer - Entities And Failures

Tasks:

* [x] Define immutable domain entities in `domain/entities/`:
  * `RadioStation`
  * `Genre`
  * `Country`
  * `NowPlayingInfo` (per ADR-0012)
  * [x] **PHASE RED:** Add failing tests for the required domain
    entities and `NowPlayingInfo` parsing behavior.
  * [x] **PHASE GREEN:** Implement the minimum immutable `Equatable`
    entity classes required to make the tests pass.
  * [x] **PHASE REFACTOR:** Review entity/test structure, run analyzer
    and tests, and remove any duplication or naming drift.
* [x] Define the `AnalyticsEvent` sealed hierarchy under
  `domain/entities/analytics/` per the catalogue in ADR-0019
  (`AppOpenedEvent`, `ScreenViewedEvent`, `StationPlayedEvent`,
  `StationStoppedEvent`, `StationFavoritedEvent`,
  `StationUnfavoritedEvent`, `SearchPerformedEvent`,
  `FilterAppliedEvent`, `PlaybackErrorEvent`).
  * [x] **PHASE RED:** Add failing tests for the required sealed event
    catalogue, event fields, privacy-preserving search payload, and value
    equality.
  * [x] **PHASE GREEN:** Implement the minimum immutable `Equatable`
    analytics event hierarchy required to make the tests pass.
  * [x] **PHASE REFACTOR:** Review event/test structure, run analyzer
    and tests, and remove any duplication or naming drift.
* [x] Define all sealed failure classes in `domain/failures/`:
  * `ApiFailure` with subclasses (`ServerFailure`,
    `ValidationErrorFailure`, `UnauthorizedFailure`).
  - `NetworkFailure` with subclasses (`ConnectionTimeoutFailure`, `SocketFailure`, `MirrorFailure`).
  * `PlaybackFailure` (includes connectivity lost during playback,
    per ADR-0013).
  * `StorageFailure`.
  * [x] **PHASE RED:** Add failing tests for the sealed failure groups,
    concrete failure variants, localization keys, nullable messages, and
    value equality.
  * [x] **PHASE GREEN:** Implement the minimum immutable `Equatable`
    failure hierarchy required to make the tests pass.
  * [x] **PHASE REFACTOR:** Review failure/test structure, run analyzer
    and tests, and remove any duplication or naming drift.
* [ ] Define repository interfaces in `domain/repositories/` per
  the contracts listed in `ARCHITECTURE.md` §"Repository
  Contracts" (including `ConnectivityRepository` per ADR-0013).
* [ ] Configure `flutter_localizations` (per ADR-0005 and ADR-0032):
  * Create `l10n.yaml` in the project root to enable automatic localization generation.
  * Create `lib/l10n/intl_en.arb` with initial country name translation keys (`country_DE`, `country_AT`, `country_NL`, `country_FR`).


---

## Phase 3: Use Cases

Implement independent use case classes under `domain/usecases/`.

Station use cases:

* [ ] `SearchStationsUseCase`
* [ ] `CancelSearchUseCase` (per ADR-0014)
* [ ] `GetStationByUuidUseCase`
* [ ] `LoadPopularStationsUseCase` (parameterizes unified search sorting, per ADR-0027)

Favorites use cases:

* [ ] `ToggleFavoriteUseCase`
* [ ] `RefreshFavoritesUseCase`

Filter metadata use cases:

* [ ] `LoadGenresUseCase`
* [ ] `LoadCountriesUseCase`

History use cases:

* [ ] `AddToHistoryUseCase`
* [ ] `GetHistoryUseCase`
* [ ] `ClearHistoryUseCase`

Playback use cases:

* [ ] `PlayStationUseCase`
* [ ] `PausePlaybackUseCase`
* [ ] `StopPlaybackUseCase`

Connectivity use cases:

* [ ] `WatchConnectivityUseCase` (per ADR-0013).

Analytics use cases:

* [ ] `TrackAnalyticsEventUseCase` (per ADR-0019).

`PlayStationUseCase` resolves the playback URL using the fallback
chain defined in `API_SPEC.md` §5.3.

Testing requirements:

* [ ] Null handling.
* [ ] Empty results.
* [ ] Boundary conditions.

---

## Phase 4: Local Storage Layer - Hive

Tasks:

* [ ] Implement Hive `TypeAdapter`s via `build_runner` +
  `hive_generator` for favorite entries, cached genres, cached
  countries, and history entries (per ADR-0018). Commit the
  generated `*.g.dart` files.
* [ ] Implement `LocalFavoritesDataSource`.
* [ ] Implement `LocalHistoryDataSource`.
* [ ] Implement `LocalGenresDataSource`.
* [ ] Implement `LocalCountriesDataSource`.
* [ ] Implement `MirrorCacheDataSource` backed by the
  `app_settings` Hive box (per ADR-0016).
* [ ] Open all boxes (`favorites`, `history`, `genres`,
  `countries`, `app_settings`) during `Hive.initFlutter()` in
  `main.dart`, before `runApp`.

Local data sources are responsible for reading and writing data to
local storage.

Favorites cache the metadata required for offline rendering
(see `API_SPEC.md` §8).

---

## Phase 5: Remote API Data Source With Radio Browser Integration

Tasks:

* [ ] Implement `Dio`-based `RemoteStationDataSource`.
* [ ] Implement `Dio`-based `RemoteGenresDataSource`.
* [ ] Implement `Dio`-based `RemoteCountriesDataSource`.
* [ ] Implement `ConnectivityDataSource` (thin wrapper around
  `connectivity_plus`, per ADR-0013).
* [ ] Enforce required headers (`User-Agent`, `Content-Type`).
* [ ] Implement mirror failover with automatic retry, reading the
  cached mirror from `MirrorCacheDataSource` at startup
  (per ADR-0016) and writing the active mirror back on success.
* [ ] Handle malformed responses, empty payloads, non-2xx HTTP
  status codes, and timeouts.
* [ ] Map all API responses to DTOs in `data/models/`:
  * `StationDto`
  * `GenreDto`
  * `CountryCodeDto`
* [ ] Implement mappers from DTOs to domain entities, using the
  helpers in `core/utils/` (`tag_parser` for `tagList`;
  `country_name_resolver` for display names).
* [ ] Handle playback URL resolution through
  `/json/url/{stationuuid}` (see `API_SPEC.md` §5.3).

---

## Phase 6: Repository Implementations

Tasks:

* [ ] Implement `StationRepositoryImpl`.
* [ ] Implement `FavoritesRepositoryImpl` (ensuring missing remote stations during synchronization are marked as `lastCheckOk = false` rather than silently deleted).
* [ ] Implement `GenresRepositoryImpl`.
* [ ] Implement `CountriesRepositoryImpl`.
* [ ] Implement `HistoryRepositoryImpl` (enforcing the 50-item limit and FIFO eviction policy per ADR-0021).
* [ ] Implement `PlaybackUrlRepositoryImpl`.
* [ ] Implement `AudioPlayerRepositoryImpl`:
  * Wraps `just_audio` + `audio_service`.
  * Exposes `nowPlayingStream` from `just_audio`'s
    `icyMetadataStream`, adapted via `icy_metadata_parser`
    (per ADR-0012).
  * Configures the system background audio notification controls to be restricted to Play, Pause, and Stop, and maps station name and NowPlayingInfo to title/subtitle (per ADR-0022).
  * Listens to `ConnectivityRepository.onlineStatusStream` and
    surfaces transitions to offline during active playback as
    `PlaybackFailure` (per ADR-0013).
* [ ] Implement `ConnectivityRepositoryImpl` (per ADR-0013).
* [ ] Implement `NoOpAnalyticsRepositoryImpl` as the default
  registration in the composition root (per ADR-0019). A real
  provider adapter is out of scope until a separate ADR records the
  provider choice.

Rules:

* Repository contracts and the dependency rule live in
  `ARCHITECTURE.md` §"Repository Contracts" and §"Dependency
  Rule".
* Repositories wire local data sources where applicable:
  * favorites persistence
  * history tracking
  * genre caching
  * country caching
  * mirror caching

---

## Phase 7: BLoC Layer And Domain Testing

`bloc_test` is used throughout. The full BLoC test matrix lives in
`TESTING_STRATEGY.md` §"BLoC Testing".

Tasks:

* [ ] Implement `RadioPlayerBloc` with full lifecycle management:
  * play
  * pause
  * stop
  * playback error states
  * explicit `PlayerBufferingState` (per ADR-0015)
  * `PlayerPlayingState.nowPlaying` populated from
    `nowPlayingStream` (per ADR-0012)
* [ ] Implement `StationsBloc` with:
  * search (debounced 350 ms, minimum 3 chars, per ADR-0014)
  * country filter
  * tag filter
  * pagination / load more
  * popular stations
  * trigger explicit search cancellation via `CancelSearchUseCase` when playing a station or disposing the bloc (per ADR-0014)
  * API failure mapping to UI-representable states
* [ ] Implement `FavoritesBloc` with:
  * toggle favorite
  * refresh favorites
  * remove favorite
  * remote and local data source interaction
* [ ] Implement `HistoryBloc` using Hive persistence.
* [ ] Implement `GenresBloc` for loading and caching genres from
  `/tags`.
* [ ] Implement `CountriesBloc` for loading and caching countries
  from `/countrycodes`.
* [ ] Implement `ConnectivityBloc` (per ADR-0013).
* [ ] Instrument BLoCs to fire `AnalyticsEvent`s through
  `TrackAnalyticsEventUseCase` per the instrumentation table in
  ADR-0019.

Testing requirements (see `TESTING_STRATEGY.md` for the full
matrix):

* [ ] Event-to-state transitions.
* [ ] Error propagation.
* [ ] Pagination edge cases.
* [ ] Playback failure handling, including buffering, Icy, and
  connectivity transitions (such as verifying Buffering -> Error on offline play requests, per ADR-0025).

---

## Phase 8: Dependency Injection And Routing

Tasks:

* [ ] Initialise `get_it` service locator (rules in
  `ARCHITECTURE.md` §"Dependency Injection").
* [ ] Keep dependency setup in a separate composition-root file.
* [ ] Register all data sources, repositories, use cases, and
  BLoCs.
* [ ] Set up `go_router` with `AppShell` architecture.
* [ ] Define routes for:
  * `StationsScreen`
  * `FavoritesScreen`
  * `FullPlayerScreen`
* [ ] Ensure BLoC lifecycle management within the routing shell.
* [ ] Ensure proper disposal.

---

## Phase 9: Visual Components And Adaptive UI

This phase MUST NOT begin until visual specifications are provided
and the user explicitly approves UI work.

Tasks:

* [ ] Develop all screens implementing Material Design on Android.
* [ ] Develop all screens implementing Cupertino on iOS.
* [ ] Implement `AppShell` with an `IndexedStack`.
* [ ] Preserve scroll state across tabs.
* [ ] Build `MiniPlayerWidget` driven by `RadioPlayerBloc` state
  (must render the `PlayerBufferingState` distinctly from
  `PlayerPlayingState`).
* [ ] Animate mini-player visibility for idle / buffering / playing
  states.
* [ ] Navigate to `FullPlayerScreen` when the mini-player is
  tapped.
* [ ] Use a bottom-to-top vertical slide transition.
* [ ] Implement tab navigation with:
  * `BottomNavigationBar`
  * `CupertinoTabBar`
* [ ] Implement the global "You're offline" / "Back online" banner
  driven by `ConnectivityBloc` (per ADR-0013).
* [ ] Apply per-screen offline copy and retry affordances
  (per ADR-0013).
* [ ] Render `PlayerPlayingState.nowPlaying` (track / artist) in
  the `MiniPlayer` and `FullPlayer` when present, falling back to
  station name when absent (per ADR-0012).
* [ ] Run the visual accessibility checklist defined in ADR-0006:
  contrast ratios, TalkBack and VoiceOver walkthroughs, focus
  traversal.

---

## Phase Advancement Rule

Before advancing from one phase to another:

* [ ] Present completed work.
* [ ] Present test output.
* [ ] Present linter output.
* [ ] Request explicit user confirmation.
* [ ] Wait for approval.
