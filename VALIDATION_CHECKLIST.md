# VALIDATION CHECKLIST

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Radio Browser Integration

The following MUST hold:

* No numeric IDs are used anywhere.
* All station references use `stationuuid`.
* All user-facing station queries set `hidebroken=true`.
* Search defaults use:
  * `hidebroken=true`
  * `order=clickcount`
  * `reverse=true`
  * `limit=30`
* Search debounce window is 350 ms (per ADR-0014).
* Minimum search query length is 3 characters (per ADR-0014).
* In-flight search requests are cancelled on supersession in the network/data layer (per ADR-0014).
* Tags query defaults use:
  * `hidebroken=true`
  * `order=stationcount`
  * `reverse=true`
  * `limit=50`
* Playback URL fallback chain is:
  1. resolved click URL
  2. `url_resolved`
  3. `url`
* Playback does not fail solely because click registration fails.
* Mirror failover never leaks into the domain layer.
* Mirror failover never crashes the app.
* Required headers are present:
  * `User-Agent`
  * `Content-Type`
* Request timeouts are configured:
  * 30 seconds connect
  * 60 seconds read

---

## Domain And Data Modeling

The following MUST hold:

* `RadioStation.stationUuid` maps from `stationuuid`.
* `stationuuid` is the stable primary identifier.
* `url_resolved` is preferred over `url`.
* `tags` is parsed into `tagList` via the `tag_parser` helper in
  `core/utils/` (per ADR-0017).
* `lastcheckok == 1` maps to `lastCheckOk == true`.
* `hls == 1` maps to `isHLS == true`.
* Country codes resolve to human-readable names through the
  `country_name_resolver` helper in `core/utils/`, backed by `intl`
  against the active locale (per ADR-0005, ADR-0017).
* `NowPlayingInfo` parsing follows the first-separator split rules in `API_SPEC.md` §6.4 (per ADR-0012, ADR-0024).

---

## Persistence

The following MUST hold:

* Favorites persist in Hive.
* Favorites use `stationuuid` as primary key.
* Favorites cache enough metadata for offline rendering:
  * name
  * favicon
  * country code
  * tags
  * stream URL
* Favorites MAY optionally refresh through `/json/stations/byuuid`.
* Favorites synchronization does not silently delete local stations if they are missing from the remote API response.
* History persists in Hive, is capped at 50 items, and implements a FIFO eviction policy (per ADR-0021).
* Genres are cached locally in Hive.
* Country codes are cached locally in Hive.
* The last-known-working mirror is persisted in the Hive box
  `app_settings` under the key `last_known_mirror`
  (per ADR-0016).
* Hive `TypeAdapter`s are generated via `build_runner` +
  `hive_ce_generator` (per ADR-0018, ADR-0038) and the generated
  `*.g.dart` files are committed to the repository.

---

## Playback

The following MUST hold:

* Broken streams fail gracefully.
* Playback errors expose retry capability.
* Playback errors are non-blocking.
* Playback errors do not destroy player state.
* Playback errors do not destroy favorites.
* Unsupported codec errors map to `PlaybackFailure`.
* Stream unreachable errors map to `PlaybackFailure`.
* The `Buffering → Playing` transition exists on every successful
  play and is never skipped (per ADR-0015).
* Malformed Icy metadata does not crash the player or destroy player
  state (per ADR-0012).
* Connectivity lost during playback maps to `PlayerErrorState`
  (per ADR-0013).
* Playback requested while offline transitions through Buffering before emitting `PlayerErrorState` (per ADR-0025).
* Lockscreen/notification controls are restricted to Play, Pause, and Stop (per ADR-0022).
* Lockscreen/notification metadata displays the station name as the title, and NowPlayingInfo or static fallback as the subtitle (per ADR-0022).

---

## Offline Behaviour

The following MUST hold (per ADR-0013):

* `connectivity_plus` is wired through `ConnectivityRepository` and
  `ConnectivityBloc`.
* A global "You're offline" banner is shown while
  `ConnectivityBloc` emits `OfflineState`.
* A "Back online" indicator is shown for 2 seconds on transition to
  `OnlineState`.
* Stations screen renders a clear offline message with a retry
  affordance when offline.
* Favorites and History lists keep rendering from Hive when offline.
* Tapping play on a station while offline triggers
  `PlayerErrorState`.
* Country and Genre filters read from the Hive cache when offline.
* No automatic playback resume on reconnection (deferred per
  `TODO.md`).

---

## Architecture

The following MUST hold:

* Domain layer depends on nothing.
* Presentation depends on use cases only.
* BLoCs emit pure business states.
* Widgets do not call GetIt directly.
* Presentation never accesses `Dio`.
* Presentation never calls Radio Browser endpoints directly.
* API specifics live in the data layer and `core/network/`.
* DTOs do not leak into presentation.
* Android `minSdk = flutter.minSdkVersion` (resolving dynamically), `targetSdk = 34`,
  `compileSdk = 36` (per ADR-0002).
* iOS deployment target = 13.0 (per ADR-0002).
* Android activity locks portrait. iOS supports portrait only
  (per ADR-0004).
* `applicationId` and `CFBundleIdentifier` =
  `com.labhouse.davidruizassessment.radioapp` (per ADR-0003).

---

## Configuration

The following MUST hold (per ADR-0007):

* Single build flavor. No Android `productFlavors`. No additional
  iOS schemes.
* `config/app.json` is injected via `--dart-define-from-file`.
* No `.env` files anywhere in the repo.
* No `productFlavors` block in `build.gradle`.

---

## CI / CD

The following MUST hold (per ADR-0008):

* `.github/workflows/ci.yml` runs `analyze`, `test`, `build-android`,
  and `build-ios`.
* `lefthook.yml` runs `dart format` and `flutter analyze` on
  pre-commit, and `flutter test` on pre-push.
* Branch protection on `main` matches ADR-0008:
  * Pull request required.
  * Required status checks: `analyze`, `test`, `build-android`,
    `build-ios`.
  * Linear history required.
  * Signed commits required (SSH signing).
  * Squash merge only.
  * Force pushes disabled.
  * Deletions disabled.

---

## Git Workflow

The following MUST hold (per ADR-0009):

* All commits follow Conventional Commits format.
* Working branches follow `<type>/<short-description>`.
* `main` is squash-merged and linear.
* Branches are deleted on merge.
* Repository is private during development and public on delivery.

---

## Accessibility

### Architectural checkpoint (Phases 1–8)

The following MUST hold (per ADR-0006):

* Every interactive widget exposes a meaningful `Semantics` label.
* Icon-only buttons carry explicit `tooltip` and `semanticLabel`.
* Widget tests pump views at `textScaler = 2.0` and assert no
  overflow.
* Touch targets are at least 48×48 dp on Android and 44×44 pt on
  iOS.

### Visual checkpoint (Phase 9)

The following MUST hold (per ADR-0006):

* Text contrast meets 4.5:1 (normal) and 3:1 (large text).
* TalkBack and VoiceOver walkthroughs traverse every screen.
* No focus traps.

---

## Quality Gates

Before each checkpoint the following MUST hold:

* Tests pass.
* `very_good_analysis` passes with zero warnings.
* TDD checkpoint output has been presented.
* User approval was received before advancing.

---

## UI Gate

The following MUST hold:

* No UI code is generated before visual specifications are provided.
* No definitive layout or styling is implemented before approval.
* Adaptive UI rules are followed once UI work begins.
* Material is used on Android.
* Cupertino is used on iOS.
* Native icons are used instead of third-party icon packages.
