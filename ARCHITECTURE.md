# ARCHITECTURE

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Architectural Style

The application MUST follow strict Clean Architecture with BLoC.

The presentation layer MUST be isolated from:

* Radio Browser API details.
* `Dio`.
* DTOs.
* local storage implementation details.
* visual framework decisions beyond adaptive rendering.

---

## Dependency Rule

* `domain/` MUST be the pure core and MUST NOT depend on any other
  layer.
* `domain/repositories/` MUST define abstract repository contracts.
* `domain/usecases/` MUST coordinate business actions.
* `data/` MUST implement domain contracts.
* `presentation/blocs/` MUST depend on use cases only.
* Widgets MUST consume BLoC states and MUST dispatch BLoC events.

---

## Mandatory Folder Structure

```text
lib/
  core/
    constants/   # mirror URLs, API defaults, hard-coded values
    errors/      # global error utilities
    network/     # Dio client factory, mirror failover interceptor
    utils/       # stateless pure helpers (per ADR-0017)
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    failures/
    repositories/
    usecases/
  presentation/
    blocs/
    screens/
    widgets/
```

---

## Data Source Boundaries

Remote data sources MUST:

* Own Radio Browser endpoint calls.
* Own DTO parsing.
* Own malformed payload handling.
* Own mirror-aware API behaviour in collaboration with `core/network/`.

Local data sources MUST:

* Own Hive read/write operations.
* Persist favorites.
* Persist history.
* Cache genres.
* Cache country codes.
* Persist the last-known-working mirror in the `app_settings` box
  (per ADR-0016).

Repositories MUST:

* Coordinate remote and local data sources.
* Convert data-layer failures into domain failures.
* Return domain entities only.

---

## Repository Contracts

Required domain repository interfaces:

* `StationRepository`
* `FavoritesRepository`
* `GenresRepository`
* `CountriesRepository`
* `HistoryRepository`
* `PlaybackUrlRepository`
* `AudioPlayerRepository`
* `ConnectivityRepository` (per ADR-0013)
* `AnalyticsRepository` (per ADR-0019)

Required implementation classes:

* `StationRepositoryImpl`
* `FavoritesRepositoryImpl`
* `GenresRepositoryImpl`
* `CountriesRepositoryImpl`
* `HistoryRepositoryImpl`
* `PlaybackUrlRepositoryImpl`
* `AudioPlayerRepositoryImpl`
* `ConnectivityRepositoryImpl`
* `NoOpAnalyticsRepositoryImpl` (default implementation per ADR-0019;
  swapped for a real provider adapter in a future ADR)

---

## BLoC Boundaries

BLoCs MUST:

* Depend on use cases through constructors.
* Emit pure business states.
* Avoid direct HTTP usage.
* Avoid direct Hive usage.
* Avoid direct GetIt usage.
* Map domain failures into UI-representable states.

Required BLoCs:

* `RadioPlayerBloc` (models buffering as an explicit state per ADR-0015)
* `StationsBloc`
* `FavoritesBloc`
* `HistoryBloc`
* `GenresBloc`
* `CountriesBloc`
* `ConnectivityBloc` (per ADR-0013)

---

## Dependency Injection

`get_it` MUST be used as the centralized service locator.

Rules:

* `get_it` MUST be configured before `runApp`.
* Registrations MUST live in a composition root.
* Data sources, repositories, use cases, and BLoCs MUST be registered.
* Dependencies MUST be injected into BLoCs through constructors.
* Widgets MUST NOT invoke GetIt directly.

---

## Configuration

Compile-time configuration MUST be used:

* `--dart-define`
* `--dart-define-from-file`

`.env` files MUST NOT be used.

The application uses a single build flavor and a single
`config/app.json` configuration file (per ADR-0007). Mirrors are code
and MUST live in `core/constants/`, not in `config/app.json`.

---

## Native Platform Configuration

The application targets Android and iOS only (per ADR-0001).

### Android

The Android module MUST configure:

* `INTERNET` permission.
* Background service registration for `audio_service`.
* `applicationId` = `com.labhouse.davidruizassessment.radioapp`
  (per ADR-0003).
* `minSdkVersion = 23`, `targetSdkVersion = 34`,
  `compileSdkVersion = 34` (per ADR-0002).
* `android:screenOrientation="portrait"` on the main activity
  (per ADR-0004).

### iOS

The iOS module MUST configure:

* Background Modes for Audio.
* `NSAppTransportSecurity` in `Info.plist`.
* `NSAllowsArbitraryLoads` in `Info.plist` to allow HTTP audio streams.
* `CFBundleIdentifier` = `com.labhouse.davidruizassessment.radioapp`
  (per ADR-0003).
* Deployment target `13.0` (per ADR-0002).
* `UISupportedInterfaceOrientations` limited to
  `UIInterfaceOrientationPortrait` (per ADR-0004).
