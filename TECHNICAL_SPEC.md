# TECHNICAL SPECIFICATIONS

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## 1. Tech Stack And Base Configuration

* **Framework:** Flutter >= 3.22 (Dart >= 3.4).
* **State Management:** BLoC.
* **Routing:** `go_router`.
* **Code Quality:** strict static analysis using `very_good_analysis`.

Restrictions:

* Riverpod MUST NOT be used.
* Manual Provider-based state management MUST NOT be used.
* Code MUST pass the linter with zero warnings.

---

## 2. Official Dependency List

The dependency list is governed by ADR-0018. New dependencies require
an ADR amendment.

### Production

| Category | Package |
|---|---|
| State management | `flutter_bloc` |
| State management | `equatable` |
| Dependency injection | `get_it` |
| Routing | `go_router` |
| Network | `dio` |
| Network | `connectivity_plus` |
| Stream operators | `stream_transform` |
| Audio | `just_audio` |
| Audio | `audio_service` |
| Persistence | `hive_flutter` |
| Image caching | `cached_network_image` |
| i18n (SDK) | `flutter_localizations` |
| i18n | `intl` |

Hive was chosen over Isar for the project's data scale to prevent
over-engineering.

### Dev

| Category | Package |
|---|---|
| Lint | `very_good_analysis` |
| Test (SDK) | `flutter_test` |
| Test | `bloc_test` |
| Test | `mocktail` |
| Test (SDK) | `integration_test` |
| Code generation | `build_runner` |
| Code generation | `hive_generator` |

---

## 3. Clean Architecture

A strict Clean Architecture approach MUST be enforced.

Presentation logic MUST be completely isolated from the visual
framework.

The canonical folder structure and the dependency rule live in
`ARCHITECTURE.md` §"Mandatory Folder Structure" and §"Dependency Rule".
This section MUST NOT diverge from them.

---

## 4. Expected BLoC Responsibilities

| BLoC | Responsibility | Key Events | Key States |
| --- | --- | --- | --- |
| `RadioPlayerBloc` | Manage playback lifecycle using an `AudioPlayerRepository`, which abstracts `just_audio` and `audio_service`. Subscribes to the now-playing stream while playing. Configures system background audio notification controls restricted to Play, Pause, and Stop (per ADR-0022). | `PlayRequested`, `PauseRequested`, `StopRequested`, `PlayStationFailed` | `PlayerIdleState`, `PlayerBufferingState`, `PlayerPlayingState`, `PlayerPausedState`, `PlayerErrorState` |
| `StationsBloc` | Fetch, filter, search, and paginate stations from Radio Browser API. `SearchStations` is debounced 350 ms with a minimum query length of 3 characters (per ADR-0014). Popular station recommendations are retrieved by searching with clickcount or votes parameters (per ADR-0027). | `SearchStations`, `LoadMoreStations`, `FilterByCountry`, `FilterByGenre`, `StationPlayRequested` | `StationsInitial`, `StationsLoadingState`, `StationsLoadedState`, `StationsErrorState` |
| `FavoritesBloc` | Manage favorites list persisted in Hive. | `ToggleFavorite`, `RefreshFavorites`, `RemoveFavorite` | `FavoritesInitial`, `FavoritesLoadedState`, `FavoritesErrorState` |
| `HistoryBloc` | Manage recently played stations history persisted in Hive, capped at 50 items using FIFO (per ADR-0021). Additions to history are triggered by the presentation layer when the playback transitions to `PlayerPlayingState` (per ADR-0026). Renders as a section in `StationsScreen` when idle (per ADR-0029). | `AddToHistory`, `ClearHistory`, `GetHistory` | `HistoryInitial`, `HistoryLoadedState`, `HistoryErrorState` |
| `GenresBloc` | Load genre list for filter UI from `/tags`. | `LoadGenres`, `FilterByGenre` | `GenresInitial`, `GenresLoadedState`, `GenresErrorState` |
| `CountriesBloc` | Load country list for filter UI from `/countrycodes`. | `LoadCountries`, `FilterByCountry` | `CountriesInitial`, `CountriesLoadedState`, `CountriesErrorState` |
| `ConnectivityBloc` | Track online/offline state via `connectivity_plus` for the global banner and per-screen offline behaviour (per ADR-0013). | `ConnectivityChanged` (internal) | `OnlineState`, `OfflineState` |

`PlayerPlayingState` carries an optional `nowPlaying: NowPlayingInfo?`
field, populated from the Icy metadata stream (per ADR-0012).

BLoCs fire `AnalyticsEvent`s through `TrackAnalyticsEventUseCase` at
the transitions defined in ADR-0019 §"Instrumentation policy". The
analytics use case is injected through the constructor like any other
dependency.

---

## 5. Error Handling And Edge Cases

Data failures MUST be modeled using sealed classes in `domain/failures/`.

Required failure groups:

* `ApiFailure`
  * `ServerFailure`
  * `ValidationErrorFailure`
  * `UnauthorizedFailure`
* `NetworkFailure`
  * connection timeout
  * socket error
  * mirror failure
* `PlaybackFailure`
  * stream unreachable
  * codec unsupported
  * playback interrupted
  * connectivity lost during playback (per ADR-0013)
* `StorageFailure`
  * Hive read/write corruption
  * favorites synchronization error

---

## 6. Dependency Injection

The dependency injection rules live in `ARCHITECTURE.md`
§"Dependency Injection". This section MUST NOT diverge from them.

---

## 7. Configuration

Compile-time variable injection MUST be used:

* `--dart-define`
* `--dart-define-from-file`

`.env` files MUST NOT be used.

A single build flavor is in effect (per ADR-0007). Configuration values
live in `config/app.json` and are injected via
`--dart-define-from-file=config/app.json`. The file is committed to
git; the Radio Browser API requires no secrets.

Debug-vs-release differentiation MUST use `kReleaseMode` / `kDebugMode`
from `package:flutter/foundation.dart`. No Android `productFlavors` and
no additional iOS schemes are introduced.

Mirrors are code and MUST live in `core/constants/`, not in
`config/app.json`.

---

## 8. Native Configuration

The native Android and iOS configuration rules live in
`ARCHITECTURE.md` §"Native Platform Configuration". This section MUST
NOT diverge from them.

---

## 9. Adaptive Design And Visual Decoupling

The UI MUST be adaptive:

* Material Design when running on Android.
* Cupertino when running on iOS.

Rules:

* Presentation logic MUST be unified and shared.
* BLoCs MUST consume and emit the same states regardless of platform.
* Screens MUST use adaptive components or visual factories to render
  OS-specific widgets.
* Native icon catalogs MUST be used:
  * `Icons`
  * `CupertinoIcons`
* Third-party icon packages MUST NOT be added.

---

## 10. Accessibility Baseline

The application commits to WCAG 2.1 level AA, delivered in two
checkpoints (per ADR-0006).

### Architectural checkpoint (Phases 1–8)

* Every interactive widget MUST expose a meaningful `Semantics` label.
  Icon-only buttons MUST have explicit `tooltip` and `semanticLabel`.
* Layouts MUST NOT assume `textScaler == 1.0`. Widget tests SHOULD
  pump views at `textScaler = 2.0` and assert no overflow.
* Touch targets MUST be at least 48×48 dp on Android and 44×44 pt on
  iOS.

### Visual checkpoint (Phase 9)

* Text contrast ratios MUST meet 4.5:1 (normal text) and 3:1 (large
  text).
* TalkBack (Android) and VoiceOver (iOS) walkthroughs MUST confirm
  complete and ordered traversal of every screen.
* No focus traps.

### Out of scope

* External keyboard navigation.
* Dedicated high-contrast mode.
* Audio subtitles / alternative content for streams.

---

## 11. CI/CD

The CI/CD strategy is governed by ADR-0008.

Three verification layers MUST be in place:

1. **Local git hooks** via `lefthook`:
   * `pre-commit`: `dart format --set-exit-if-changed lib/ test/`
     and `flutter analyze`.
   * `pre-push`: `flutter test`.
2. **Remote CI** via GitHub Actions in `.github/workflows/ci.yml`:
   * Four jobs in parallel: `analyze`, `test`, `build-android`,
     `build-ios`.
3. **Branch protection on `main`**:
   * Pull requests REQUIRED.
   * Required status checks: `analyze`, `test`, `build-android`,
     `build-ios`.
   * Linear history REQUIRED.
   * Signed commits REQUIRED (SSH signing).
   * Squash merge only.
   * Force pushes and deletions DISABLED.
   * Required approvals = 0 (per ADR-0008 rationale for solo developer).

The git workflow is governed by ADR-0009 (GitHub Flow + Conventional
Commits).

---

## 12. Seamless Integration Validation

Validation checks are tracked in `VALIDATION_CHECKLIST.md`. The
checklist MUST be reviewed before completing each phase.

---

## 13. Testing Strategy

Detailed testing requirements live in `TESTING_STRATEGY.md`. This
section lists only the binding rules.

### Unit Testing

The following MUST be tested:

* DTO parsing with valid JSON.
* DTO parsing with null fields.
* DTO parsing with empty fields.
* DTO parsing with malformed payloads.
* Domain entity immutability.
* Correct field mappings.
* Repository integration using `mocktail` to mock data sources.
* Error propagation through repositories.

### BLoC Testing

`bloc_test` MUST be used.

Required coverage per BLoC is defined in `TESTING_STRATEGY.md`.

### Playback Resilience Testing

The following MUST be verified:

* Playing a broken stream results in `PlayerErrorState`.
* Broken stream playback MUST NOT destroy player state.
* Broken stream playback MUST NOT destroy the favorites list.
* The fallback URL chain MUST work when primary stream URLs are
  unreachable.
* Malformed Icy metadata MUST NOT crash the player.
* The Buffering → Playing transition MUST exist on every successful
  play.
* A play request while offline MUST transition through Buffering before emitting `PlayerErrorState` (per ADR-0025).
