# API SPECIFICATION: RADIO BROWSER

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## 1. Overview

The application communicates exclusively with the Radio Browser public
community-maintained API.

Official documentation:

* https://api.radio-browser.info/

The infrastructure is mirror-based. There is no single guaranteed
permanent server.

The implementation MUST treat mirrors as interchangeable and MUST
abstract this away from all layers above the networking client.

---

## 2. Mirror Failover Strategy

The networking layer MUST:

* Maintain a static list of default HTTPS mirrors (per ADR-0023):
  * `https://de1.api.radio-browser.info` (Germany)
  * `https://at1.api.radio-browser.info` (Austria)
  * `https://nl1.api.radio-browser.info` (Netherlands)
  * `https://fr1.api.radio-browser.info` (France)
* Encapsulate active mirror selection inside the networking layer,
  specifically the `dio` client factory in `core/network/`.
* Automatically retry on the next available mirror when any request
  fails with:
  * a connection-level error
  * a 5xx HTTP status
* Cap retries at most 2 attempts per mirror.
* Cap total attempts at 6 requests maximum.
* Persist the last-known-working mirror in the Hive box `app_settings`
  under the key `last_known_mirror` (per ADR-0016).
* Use the cached last-known-working mirror first on app startup.

Mirror failover MUST NOT leak into the domain or presentation layers.

---

## 3. Required Headers

All requests MUST include:

* `User-Agent`: a descriptive custom app identifier, for example
  `RadioApp/1.0`.
* `Content-Type`: `application/json; charset=utf-8`.

The application MUST NOT send generic or empty `User-Agent` strings.
The API MAY reject them.

---

## 4. Error Handling And Resilience

The networking layer MUST handle:

* Explicit request timeouts:
  * 30 seconds connect timeout.
  * 60 seconds read timeout.
* Socket and network failures with automatic mirror retry.
* Malformed or partial JSON responses.
* Empty payloads.
* Non-2xx HTTP status codes.
* Invalid stream URLs during playback.

Required behaviour:

* Malformed or partial JSON SHOULD gracefully return an empty list or
  fallback data where appropriate.
* Empty payloads MUST NOT crash the app.
* Non-2xx responses MUST map to domain-level failure variants.
* Invalid playback URLs MUST expose friendly errors to the UI without
  destroying player state.

---

## 5. Core API Endpoints And Integration Mapping

All endpoints MUST be integrated through domain use cases.

Presentation logic MUST NOT directly call HTTP endpoints.

### 5.1 Station Search

Endpoint:

```http
GET /json/stations/search
```

Purpose:

* Main station discovery.
* Search.
* Filtering.
* Pagination.

Query parameters:

* `name`
* `countrycode`
* `tag`
* `tagList`
* `language`
* `codec`
* `hidebroken`
* `order`
* `reverse`
* `limit`
* `offset`

Recommended defaults:

* `hidebroken=true` (REQUIRED for user-facing queries).
* `order=clickcount` (RECOMMENDED).
* `reverse=true` (RECOMMENDED).
* `limit=30` (RECOMMENDED).

Integration mapping:

* `SearchStationsUseCase`
* `LoadMoreStationsUseCase`
* `StationsBloc`

Important rules:

* The application MUST NOT load extremely large station lists at once.
* The application MUST cap the maximum limit internally
  (see `STATIONS_MAX_LIMIT` in `config/app.json`, per ADR-0007).
* All user-facing queries MUST set `hidebroken=true`.
* The bloc MUST enforce a client-side minimum query length of
  3 characters before reaching the endpoint (per ADR-0014).
* The data or repository layer MUST filter out duplicate station entries in memory using their unique `stationuuid` (per ADR-0031).
* The `StationsBloc` MUST track whether the search results have been exhausted (e.g. via a `hasReachedMax` boolean). If a page request returns fewer items than the limit, or if the cumulative loaded list reaches `STATIONS_MAX_LIMIT`, the bloc MUST ignore any subsequent `LoadMoreStations` events (per ADR-0031).
* Search by name MUST be supported.
* Country filtering MUST be supported.
* Genre/tag filtering MUST be supported.
* Popularity sorting MUST be supported.

### 5.2 Popular Stations

Endpoints:

```http
GET /json/stations/topclick/{limit}
GET /json/stations/topvote/{limit}
```

Purpose:

* Discovery sections.
* Featured stations.
* Onboarding or home recommendations.

Integration mapping:

* `LoadTopClickStationsUseCase`
* `LoadTopVoteStationsUseCase`

These endpoints are OPTIONAL because the architecture MAY derive
popularity through station search using `order=clickcount`.

### 5.3 Playback URL Resolution

Endpoint:

```http
GET /json/url/{stationuuid}
```

Purpose:

* Register station click.
* Retrieve a potentially improved or resolved playback URL.

Critical behaviour:

* The application MUST call this endpoint when playback starts for a
  station.
* If the returned URL is usable, the application SHOULD prefer it as
  the stream source.
* The application MUST apply the fallback chain in this order:
  1. resolved click URL
  2. `url_resolved` from station data
  3. `url`
* Playback MUST NOT fail solely because click registration fails.
* If click registration fails, the application MUST degrade gracefully
  and still attempt playback with available URLs.

### 5.4 Tags / Genres

Endpoint:

```http
GET /json/tags
```

Recommended query parameters:

* `hidebroken=true` (RECOMMENDED).
* `order=stationcount` (RECOMMENDED).
* `reverse=true` (RECOMMENDED).
* `limit=50` (RECOMMENDED).

Mapped fields:

* `name`
* `stationcount`

Integration mapping:

* `LoadGenresUseCase`
* Genre filter UI

Results MUST be cached locally via Hive for offline access.

### 5.5 Country Codes

Endpoint:

```http
GET /json/countrycodes
```

Purpose:

* Country filter UI.
* Localized browsing.

Mapped fields:

* `name`
* station count metadata

Integration mapping:

* `LoadCountriesUseCase`
* Country filter section

Results MUST be cached locally via Hive.

### 5.6 Stations By UUID

Endpoint:

```http
GET /json/stations/byuuid?uuid=<comma-separated-uuids>
```

Purpose:

* Restore persisted favorites.
* Refresh locally cached station data.

Integration mapping:

* `RefreshFavoriteStationsUseCase`
* Favorites screen loading
* Favorites rehydration from local storage

---

## 6. Domain Modeling

### 6.1 RadioStation Entity

The `RadioStation` domain entity MUST minimally support:

```dart
class RadioStation {
  final String stationUuid;        // stationuuid: stable ID; MUST NOT use legacy numeric IDs
  final String name;
  final String streamUrl;          // url: raw stream URL, lowest priority
  final String resolvedStreamUrl;  // url_resolved: preferred for playback
  final String? favicon;           // station logo/branding
  final String? homepage;
  final String tags;               // comma-separated genres/tags
  final List<String> tagList;      // normalized tags parsed from tags
  final String country;
  final String countryCode;        // ISO country code, used for filtering
  final String? language;
  final String? codec;
  final int? bitrate;
  final int votes;
  final int clickCount;
  final bool lastCheckOk;          // true when lastcheckok == 1
  final bool isHLS;                // true when hls == 1
}
```

DTO mapping rules:

* `stationuuid` MUST be the only stable identifier across sessions.
* The application MUST NOT use numeric IDs.
* `url_resolved` MUST be preferred for playback over raw `url`.
* `tags` arrives as a comma-separated string.
* The mapper MUST parse `tags` into `List<String>` (via the
  `tag_parser` helper in `core/utils/`, per ADR-0017).
* `lastcheckok == 1` MUST map to `lastCheckOk == true`.
* `hls == 1` MUST map to `isHLS == true`.

### 6.2 Genre Entity

```dart
class Genre {
  final String name;
  final int? stationCount;
}
```

### 6.3 Country Entity

```dart
class Country {
  final String name;
  final String countryCode;       // ISO 3166-1 alpha-2 code
  final int? stationCount;
}
```

The `/json/countrycodes` API returns raw ISO codes and counts.

The `country_name_resolver` helper in `core/utils/` (per ADR-0017)
MUST be used to resolve human-readable country names from ISO codes. 

Specifically:
- It MUST look up the localized country name using standard ARB translation keys formatted as `country_XX` (where `XX` is the uppercase ISO country code), resolved via the generated localization classes (`intl`, per ADR-0005).
- If the translation key is missing, it MUST fall back to returning the raw uppercase ISO country code (per ADR-0032).

### 6.4 NowPlayingInfo Entity

```dart
class NowPlayingInfo {
  final String? raw;     // the StreamTitle value verbatim, when present
  final String? artist;  // parsed from "Artist - Track"; null on failure
  final String? track;   // parsed from "Artist - Track"; null on failure
}
```

`NowPlayingInfo` is surfaced through `AudioPlayerRepository
.nowPlayingStream` and consumed by `RadioPlayerBloc` (per ADR-0012).

Parsing rules MUST follow:

* If `raw` is null or empty, all fields MUST be null.
* If `raw` contains one or more ` - ` (space-hyphen-space) separators, the substring to the left of the FIRST separator MUST map to `artist` (trimmed) and the substring to the right of the FIRST separator MUST map to `track` (trimmed, per ADR-0024).
* If `raw` contains no ` - ` separator, `raw` MUST be exposed verbatim and both `artist` and `track` MUST be null.

---

## 7. Playback Resilience Requirements

Radio streaming is inherently unreliable.

The architecture MUST enforce:

* Playback MAY fail even when `lastcheckok == 1`.
* Broken streams MUST fail gracefully.
* Playback failures MUST use non-blocking user-facing errors, such as
  snackbar or alert.
* Playback errors MUST NOT crash the app.
* Playback errors MUST NOT destroy player state.
* Playback errors MUST NOT destroy the favorites list.
* Invalid stream handling MUST expose retry capability.
* Temporary playback failures MAY optionally be marked in memory.

The playback fallback chain is defined in §5.3 of this document.

---

## 8. Favorites Strategy

Favorites MUST persist locally using Hive.

Requirements:

* `stationuuid` MUST be used as the primary key.
* The cache MUST include enough metadata for offline rendering:
  * station name
  * favicon
  * country code
  * tags
  * stream URL
* On startup or when loading the Favorites screen, the application MAY
  re-fetch fresh station data through `/stations/byuuid`.
* If a favorited station is no longer returned by the remote API during this synchronization, the repository/usecase MUST NOT silently delete it from local storage. Instead, the application MUST retain the cached station and update its state to `lastCheckOk = false`. Playback attempts will then fail gracefully, prompting the user with an option to remove the favorite manually.

---

## 9. Data Source Abstraction

Interfaces and repository contracts MUST be defined in the domain layer.

All Radio Browser API specifics MUST live exclusively in the data
layer.

Rules:

* DTOs and mappers MUST transform API responses into pure business
  entities.
* Presentation logic MUST NOT directly call HTTP endpoints.
* Presentation logic MUST NOT access `Dio`.
* Mirror abstraction MUST be encapsulated in `data/datasources/` and
  `core/network/`.
* Header injection MUST be encapsulated in `data/datasources/` and
  `core/network/`.
* Retry logic MUST be encapsulated in `data/datasources/` and
  `core/network/`.
* Error mapping MUST be encapsulated in `data/datasources/` and
  `core/network/`.
