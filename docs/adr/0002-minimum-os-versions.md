# ADR-0002 — Minimum OS versions

- **Status:** Accepted
- **Date:** 2026-05-28
- **Deciders:** David Ruiz
- **Related:** ADR-0001, `ARCHITECTURE.md` §Native Platform Configuration

## Context

`CONTEXT.md` pins Flutter `>= 3.22` and Dart `>= 3.4`, but says nothing
about the minimum OS versions of the supported platforms (Android and iOS,
per ADR-0001).

If left unspecified:

- Defaults come from whichever Flutter version runs `flutter create` and
  drift between SDK releases.
- The audio plugins effectively impose a floor — `just_audio` and
  `audio_service` both require Android API 21 and iOS 13 — but that floor
  is implicit, not validated.
- Phase 1 RED tests cannot assert anything about manifest version values.

Additional context: Google Play currently mandates `targetSdkVersion = 34`
for new apps, and Apple requires recent Xcode versions that target iOS 12
or higher.

## Decision

- **Android:** `minSdkVersion = 23`, `targetSdkVersion = 34`,
  `compileSdkVersion = 34`.
- **iOS:** deployment target `13.0`.

These values are recorded in `android/app/build.gradle` and
`ios/Podfile` / `ios/Runner/Info.plist`, and asserted by Phase 1 RED tests.

## Consequences

### Positive
- Android 23 (Marshmallow, 2015) is the sane modern floor: runtime
  permissions, stable modern APIs, and no legacy quirks.
- iOS 13 satisfies both `just_audio` and `audio_service` requirements
  without going higher than necessary for a radio app.
- `targetSdkVersion = 34` satisfies Play Store publishing requirements
  for new apps.
- Versions are explicit and Phase 1 RED tests can verify them.

### Negative
- Devices on Android 5.x and 6.0 (a residual but non-zero share of the
  global install base) are excluded. Acceptable trade-off for a modern
  radio app.
- Devices on iOS 12 and below are excluded. Negligible share.

### Neutral
- Raising `minSdkVersion` later is mechanically trivial but may invalidate
  workarounds in code that targeted the older floor; lowering it later
  is also mechanically trivial but may expose calls to APIs unavailable
  on older OS versions. The floor is therefore a long-lived commitment.

## Alternatives considered

### Option A — Android 21 / iOS 13 (minimum allowed by dependencies)
Rejected. Android 21 and 22 add device coverage of <1% while introducing
known quirks (TLS, file storage, runtime permissions partial). Not worth
the support cost.

### Option C — Android 24 / iOS 15
Rejected. More aggressive than needed; for a radio app whose users are
often on older devices, the exclusion is not justified by any required
API.

### Option D — Leave defaults from `flutter create`
Rejected. Defaults drift across Flutter versions and leave Phase 1 RED
tests with no assertable values.

## Documentation impact

- `ARCHITECTURE.md` §Native Platform Configuration — add the explicit
  version numbers for both platforms.
- `VALIDATION_CHECKLIST.md` — add a check that the manifests configure
  `minSdkVersion = 23` and iOS deployment target `13.0`.
- `ROADMAP.md` Phase 1 — list version configuration as a sub-task under
  native setup.

## Follow-ups

- None.
