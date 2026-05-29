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
  * `country_name_resolver` — resolve known and unknown ISO codes
    against multiple locales.
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
* An in-flight request is cancelled when a new `SearchStations`,
  `FilterByCountry`, or `FilterByGenre` event arrives
  (per ADR-0014).
* A `SearchStations("")` event maps to the popular-stations
  behaviour (per ADR-0014).

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

Before writing production bootstrapping code, introduce failing
tests or checks that prove the expected infrastructure does not
exist yet.

Recommended initial Phase 1 Red checks:

* Verify required dependencies are present in `pubspec.yaml`
  (the 13 production + 7 dev packages governed by ADR-0018).
* Verify `analysis_options.yaml` includes `very_good_analysis`.
* Verify the required folder structure exists (including
  `core/utils/`).
* Verify `AndroidManifest.xml` contains the `INTERNET` permission
  and the portrait orientation lock.
* Verify Android `build.gradle` configures `minSdkVersion = 23`,
  `targetSdkVersion = 34`, `compileSdkVersion = 34`, and
  `applicationId = com.labhouse.davidruizassessment.radioapp`.
* Verify iOS `Info.plist` contains the audio Background Mode,
  `NSAppTransportSecurity` with `NSAllowsArbitraryLoads`, the
  portrait orientation lock, and
  `CFBundleIdentifier = com.labhouse.davidruizassessment.radioapp`.
* Verify iOS deployment target is `13.0`.
* Verify `Dio` client configuration exposes required headers
  (`User-Agent`, `Content-Type`) and timeouts (30 s connect,
  60 s read).
* Verify `config/app.json` is present and committed.
* Verify `.github/workflows/ci.yml` runs `analyze`, `test`,
  `build-android`, `build-ios`.
* Verify `lefthook.yml` defines pre-commit (format + analyze) and
  pre-push (test) hooks.

After writing these checks, run them and present the failing
output for review.
