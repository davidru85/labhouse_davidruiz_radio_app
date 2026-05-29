# TESTING STRATEGY

## TDD Rule

The TDD Red / Green / Refactor micro-cycle and its review checkpoints
live in `AGENTS.md` §"Mandatory TDD Micro-Cycle". This document
describes what to test; the workflow is governed there.

---

## Unit Testing

Required coverage:

* DTO parsing with valid JSON.
* DTO parsing with null fields.
* DTO parsing with empty fields.
* DTO parsing with malformed payloads.
* Domain entity immutability.
* Correct DTO-to-domain field mappings.
* Repository integration using `mocktail`.
* Error propagation through repositories.
* `core/utils/` helpers (per ADR-0017):
  * `country_name_resolver` — resolve ISO codes dynamically by loading keys formatted as `country_XX` from localization ARB files, falling back to raw uppercase ISO codes on missing keys (per ADR-0032).
  * `tag_parser` — trim, deduplicate and split comma-separated tags;
    handle empty and whitespace-only input.
  * `icy_metadata_parser` — apply the rules in `API_SPEC.md` §6.4:
    valid `Artist - Track`, multiple separators (e.g. `Artist - Song - Show` split by first hyphen per ADR-0024), missing separator, empty/whitespace input, garbage.

---

## Use Case Testing

Each use case is tested for:

* success paths.
* null handling.
* empty results.
* boundary conditions.
* failure propagation.

Playback use case tests verify the fallback chain defined in
`API_SPEC.md` §5.3.

---

## BLoC Testing

`bloc_test` is used for all BLoC tests.

### StationsBloc

* search with results.
* search with no results.
* search with API failure.
* network failure during pagination.
* country filtering edge cases.
* tag filtering edge cases.
* pagination / load more behaviour.
* `SearchStations` events under 3 characters do not fire a request
  (per ADR-0014).
* Rapid `SearchStations` events within 350 ms collapse to a single
  use-case call (per ADR-0014).
* `CancelSearchUseCase` is invoked to cancel in-flight remote requests when a new search/filter event arrives, when a station play is requested, or when the BLoC is disposed (per ADR-0014).
* A `SearchStations("")` event maps to the popular-stations
  behaviour (per ADR-0014).
* search results containing duplicates are filtered out in memory (verify client-side deduplication via `stationuuid`, per ADR-0031).
* pagination loading limits requests when search results are exhausted or reach `STATIONS_MAX_LIMIT` (verify `hasReachedMax` transitions to `true` and new loading events are ignored, per ADR-0031).

### FavoritesBloc

* toggle favorite that already exists.
* toggle favorite that does not exist.
* remove stale favorite.
* refresh favorites after remote update.

### HistoryBloc

* add station to history.
* retrieve sorted history list.
* clear history.

### RadioPlayerBloc

* play station.
* pause mid-stream.
* playback error from broken stream.
* play-pause-play transitions.
* `PlayRequested` emits `[Buffering, Playing]` in order
  (per ADR-0015).
* Stream stall mid-playback emits `[Buffering, Playing]`
  (per ADR-0015).
* Buffering that fails emits `[Buffering, Error]` (per ADR-0015).
* Valid Icy emission updates `PlayerPlayingState.nowPlaying`
  (per ADR-0012).
* Station without Icy keeps `nowPlaying == null` throughout
  playback (per ADR-0012).
* Malformed Icy input does not crash the player and does not
  destroy player state (per ADR-0012).
* Track change mid-playback emits a fresh `PlayerPlayingState`
  with updated `nowPlaying` (per ADR-0012).
* Connectivity lost during playback emits `PlayerErrorState`
  (per ADR-0013).
* Playback requested while offline emits `[Buffering, Error]` (per ADR-0025).

### GenresBloc

* load genres successfully.
* empty genre list.
* API failure loading genres.

### CountriesBloc

* load countries successfully.
* empty country list.
* API failure loading countries.

### ConnectivityBloc

* Initial state reflects current connectivity.
* Transition from `OnlineState` to `OfflineState` on connection
  loss (per ADR-0013).
* Transition from `OfflineState` to `OnlineState` on connection
  recovery (per ADR-0013).

---

## Analytics Testing

Required coverage (per ADR-0019):

* `NoOpAnalyticsRepositoryImpl` MUST accept every `AnalyticsEvent`
  subtype without throwing.
* Each instrumented BLoC test MUST assert that the expected
  `TrackAnalyticsEventUseCase` call is made on the relevant
  transition, using `mocktail` verifications:
  * `RadioPlayerBloc` fires `StationPlayedEvent` on entering
    `PlayerPlayingState`.
  * `RadioPlayerBloc` fires `StationStoppedEvent` on leaving
    `PlayerPlayingState` or `PlayerPausedState`.
  * `RadioPlayerBloc` fires `PlaybackErrorEvent` on entering
    `PlayerErrorState`.
  * `FavoritesBloc` fires `StationFavoritedEvent` /
    `StationUnfavoritedEvent` after persistence succeeds.
  * `StationsBloc` fires `SearchPerformedEvent` after a successful
    search use-case call.
  * `StationsBloc` fires `FilterAppliedEvent` after
    `FilterByCountry` or `FilterByGenre`.
* Analytics failures (e.g. real-provider network errors when a real
  adapter is wired) MUST NOT propagate as `Failure`s to the calling
  BLoC. Wrap the call in a fire-and-forget pattern at the use case
  level.

---

## Playback Resilience Testing

Verify:

* Playing a broken stream results in `PlayerErrorState`.
* Playback failure does not destroy player state.
* Playback failure does not destroy favorites.
* The fallback chain in `API_SPEC.md` §5.3 works when primary
  stream URLs are unreachable.
* The Buffering → Playing transition exists on every successful
  play and is never skipped (per ADR-0015).
* Malformed Icy metadata does not crash the player
  (per ADR-0012).

---

## Phase 1 PHASE RED Testing Strategy

Before implementing production bootstrapping code, the implementer MUST write tests or validations to establish the failing (RED) state for each sequential sub-task.

### Sequential RED Checkpoints:

#### Sub-task 1.1: Platform Cleanup & Naming
* **RED Verification Check:** The developer executes verification script commands or tests proving that:
  - Default platform folders (`web/`, `macos/`, `linux/`, `windows/`) exist in the workspace.
  - The package name in `pubspec.yaml` is NOT `radio_app`.
  - The native app identifiers in `build.gradle` and `Info.plist` do not match `com.labhouse.davidruizassessment.radioapp`.
  - Native platform orientation settings, SDK versions, and background playback entitlements are unconfigured or default.

#### Sub-task 1.2: Strict Linter & Dependencies Setup
* **RED Verification Check:**
  - Verify that `analysis_options.yaml` does not enforce `very_good_analysis`.
  - Verify that a file-level search on `pubspec.yaml` reveals that the 13 production and 7 dev dependencies (per ADR-0018) are not added.

#### Sub-task 1.3: Folder Structure & App Configuration
* **RED Verification Check:**
  - Verify that directories under `lib/` (such as `core/utils/` and `domain/failures/`) are absent.
  - Verify that `config/app.json` does not exist in the project root.

#### Sub-task 1.4: Base Dio Client Factory & Mirror Constants
* **RED Unit Test:**
  - Create the unit test file `test/core/network/dio_client_test.dart`.
  - Assert that calling `DioClientFactory.create()` yields a `Dio` instance with a 30s connection timeout, 60s read timeout, and headers for `User-Agent: RadioApp/1.0` and `Content-Type: application/json; charset=utf-8`.
  - Assert that `core/constants/mirrors.dart` defines the four static default HTTPS mirrors.
  - Run `flutter test test/core/network/dio_client_test.dart` and verify it fails (as `DioClientFactory` and mirror constants do not exist yet).

#### Sub-task 1.5: CI/CD Workflows & Git Hooks
* **RED Verification Check:**
  - Assert that `.github/workflows/ci.yml` and `lefthook.yml` are absent.

Once all red checkpoints for a sub-task are verified as failing, present them for review before proceeding to the green implementation step.
