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
* `android:usesCleartextTraffic="true"` on the `<application>` tag in `AndroidManifest.xml` (per ADR-0030).
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

---

## Background Media Controls

The application MUST configure background playback notifications as follows (per ADR-0022):

* The notification widget MUST only enable controls for `Play`, `Pause`, and `Stop`.
* Skip controls (Next/Previous) and seek controls (Fast Forward/Rewind) MUST be disabled.
* Notification metadata MUST display the station name as the title, and the dynamically updated `NowPlayingInfo` (formatted as "Artist - Track") as the subtitle. If unavailable, it MUST fall back using this deterministic hierarchy: 1. Primary Genre/Tag (first item in the parsed tagList), 2. Country Display Name, 3. The app name or "Live Radio".

---

## Domain Contracts

This section defines the precise signatures, types, and error-handling conventions for repositories and use cases. All layers MUST conform to these contracts.

### 1. Functional Return Type: `Result<S, F>`

The application MUST NOT throw raw exceptions across layer boundaries (e.g. from data datasource to presentation BLoC). To enforce safe, compile-time error routing without adding unapproved third-party dependencies, a custom `Result` sealed class MUST be defined in `lib/core/errors/result.dart` (or similar core folder):

```dart
sealed class Result<S, F> {
  const Result();

  Result<T, F> map<T>(T Function(S value) transform);
  Result<S, T> mapFailure<T>(T Function(F failure) transform);
}

class Success<S, F> extends Result<S, F> {
  final S value;
  const Success(this.value);

  @override
  Result<T, F> map<T>(T Function(S value) transform) => Success(transform(value));

  @override
  Result<S, T> mapFailure<T>(T Function(F failure) transform) => Success(value);
}

class FailureResult<S, F> extends Result<S, F> {
  final F failure;
  const FailureResult(this.failure);

  @override
  Result<T, F> map<T>(T Function(S value) transform) => FailureResult(failure);

  @override
  Result<S, T> mapFailure<T>(T Function(F failure) transform) => FailureResult(transform(failure));
}
```

Every repository method that can fail MUST return a `Future<Result<T, Failure>>` where `Failure` is a sealed subclass from `domain/failures/`.

### 2. Sealed Failures

All domain failures MUST inherit from a base `Failure` sealed class:

```dart
sealed class Failure extends Equatable {
  final String? message;
  const Failure([this.message]);

  String get localizationKey;

  @override
  List<Object?> get props => [message];
}
```

Specific failure mapping:

* **`ApiFailure`** (subclasses):
  - `ServerFailure(String? message)` -> `localizationKey: 'error_server'`
  - `ValidationErrorFailure(String? message)` -> `localizationKey: 'error_validation'`
  - `UnauthorizedFailure(String? message)` -> `localizationKey: 'error_unauthorized'`
* **`NetworkFailure`** (subclasses):
  - `ConnectionTimeoutFailure(String? message)` -> `localizationKey: 'error_network_timeout'`
  - `SocketFailure(String? message)` -> `localizationKey: 'error_network_socket'`
  - `MirrorFailure(String? message)` -> `localizationKey: 'error_network_mirror'`
* **`PlaybackFailure`** (subclasses):
  - `StreamUnreachableFailure(String? message)` -> `localizationKey: 'error_playback_unreachable'`
  - `CodecUnsupportedFailure(String? message)` -> `localizationKey: 'error_playback_codec'`
  - `PlaybackInterruptedFailure(String? message)` -> `localizationKey: 'error_playback_interrupted'`
  - `ConnectivityLostFailure(String? message)` -> `localizationKey: 'error_playback_connectivity'`
* **`StorageFailure`** (subclasses):
  - `StorageReadWriteFailure(String? message)` -> `localizationKey: 'error_storage_io'`
  - `FavoritesSyncFailure(String? message)` -> `localizationKey: 'error_favorites_sync'`

### 3. Repository Method Signatures

Repositories MUST define the following interface contracts:

```dart
abstract class StationRepository {
  Future<Result<List<RadioStation>, Failure>> searchStations({
    String? query,
    String? countryCode,
    String? tag,
    int limit = 30,
    int offset = 0,
  });

  Future<Result<List<RadioStation>, Failure>> loadPopularStations({
    int limit = 30,
    int offset = 0,
  });

  Future<Result<void, Failure>> cancelPendingRequests();
}

abstract class FavoritesRepository {
  Future<Result<List<RadioStation>, Failure>> getFavorites();
  Future<Result<void, Failure>> addFavorite(RadioStation station);
  Future<Result<void, Failure>> removeFavorite(String stationUuid);
  Future<Result<void, Failure>> synchronizeFavorites();
  Stream<List<RadioStation>> get favoritesStream;
}

abstract class GenresRepository {
  Future<Result<List<Genre>, Failure>> getGenres({int limit = 50});
}

abstract class CountriesRepository {
  Future<Result<List<Country>, Failure>> getCountries();
}

abstract class HistoryRepository {
  Future<Result<List<RadioStation>, Failure>> getHistory();
  Future<Result<void, Failure>> addToHistory(RadioStation station);
  Future<Result<void, Failure>> clearHistory();
  Stream<List<RadioStation>> get historyStream;
}

abstract class PlaybackUrlRepository {
  Future<Result<String, Failure>> resolvePlaybackUrl(RadioStation station);
}

abstract class AudioPlayerRepository {
  Future<Result<void, Failure>> play(String url, {required String title, required String subtitle});
  Future<Result<void, Failure>> pause();
  Future<Result<void, Failure>> stop();
  Stream<PlayerState> get playerStateStream;
  Stream<NowPlayingInfo?> get nowPlayingStream;
}

abstract class ConnectivityRepository {
  Future<Result<bool, Failure>> checkConnectivity();
  Stream<bool> get connectivityStream;
}

abstract class AnalyticsRepository {
  Future<Result<void, Failure>> trackEvent(AnalyticsEvent event);
}
```

### 4. Use Case Call Contracts

All use cases MUST implement a consistent call signature pattern:

```dart
abstract class UseCase<Type, Params> {
  Future<Result<Type, Failure>> call(Params params);
}
```

Use cases that require no parameters MUST use a `NoParams` helper class:
```dart
class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => [];
}
```

Use cases that return a stream instead of a future (e.g. `WatchConnectivityUseCase`) MUST implement a different stream-specific contract:

```dart
abstract class StreamUseCase<Type, Params> {
  Stream<Type> call(Params params);
}
```

### 5. Search Cancellation & Pagination Contracts

- **Search Cancellation:** The `dio` request cancellation token (`CancelToken`) MUST be owned and managed by the remote data source. The repository contract does not expose `CancelToken`. Instead, when `CancelSearchUseCase` is called, it triggers the repository to invoke `cancelPendingRequests()` on `StationRepository`, which propagates down to the data source.
- **Pagination Shape:** The BLoC pagination uses the `offset` parameter, incremented by the limit (e.g. 30). When a query returns fewer results than requested, or if the total cached count reaches `STATIONS_MAX_LIMIT`, `hasReachedMax` MUST be set to true on the state to cease loading.
- **Empty Responses:** Empty list responses from the API (such as search queries returning 0 results) MUST NOT be treated as failures. They MUST return `Success(List.empty())`. Actual HTTP/Socket/Serialization errors MUST return a `FailureResult`.

### 6. Dio Exception Mapping

All data source implementations using `Dio` MUST map exceptions inside the catch blocks before converting to failures:

- `DioExceptionType.connectionTimeout`, `sendTimeout`, `receiveTimeout` -> `ConnectionTimeoutFailure`
- `DioExceptionType.badResponse` ->
  - HTTP 401/403 -> `UnauthorizedFailure`
  - HTTP 422 -> `ValidationErrorFailure`
  - HTTP 5xx -> `ServerFailure`
- `DioExceptionType.connectionError`, `unknown` (SocketException) -> `SocketFailure`
- If all mirror retries are exhausted -> `MirrorFailure`
