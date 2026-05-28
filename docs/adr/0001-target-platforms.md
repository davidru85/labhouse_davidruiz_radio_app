# ADR-0001 — Target platforms

- **Status:** Accepted
- **Date:** 2026-05-28
- **Deciders:** David Ruiz
- **Related:** `CONTEXT.md` §Key Constraints, `ARCHITECTURE.md` §Native Platform Configuration

## Context

The specification suite (`CONTEXT.md`, `ARCHITECTURE.md`, `TECHNICAL_SPEC.md`,
`DESIGN.md`) implicitly assumes a mobile-only application: native
configuration is defined for Android and iOS, the UI strategy contrasts
Material against Cupertino, and the audio stack relies on `audio_service`,
which targets mobile platforms.

However, no document states explicitly which platforms are in scope. Flutter
6 supports six target platforms out of the box (Android, iOS, web, macOS,
Linux, Windows). Without an explicit decision:

- `flutter create` may scaffold native folders for platforms that will not
  be maintained.
- Dependency choices that are mobile-only (`audio_service`) become
  questionable.
- Reviewers cannot evaluate platform coverage objectively.

## Decision

RadioApp targets **Android and iOS only**. Web and desktop platforms (macOS,
Linux, Windows) are explicitly out of scope.

The project is bootstrapped with `flutter create --platforms=android,ios`.

## Consequences

### Positive
- The mobile-only assumption that pervades the specification is now
  explicit and verifiable.
- The dependency stack — in particular `audio_service` — is fully
  supported on every target platform.
- The Material/Cupertino adaptive UI strategy applies coherently to every
  supported platform.
- Surface area for QA, native configuration, and CI build matrix is
  minimised.

### Negative
- Adding web support later requires retrofitting an alternative
  `AudioPlayerRepository` implementation, since `audio_service` does not
  support web.
- Adding desktop support later requires platform-specific native
  configuration and accepting the limitations of `audio_service` on
  desktop.

### Neutral
- The `AudioPlayerRepository` abstraction defined in `ARCHITECTURE.md`
  remains a sound boundary for future platform additions, even though
  none are planned.

## Alternatives considered

### Option B — Android + iOS + Web
Rejected. `audio_service` does not support web; the project would need
two parallel `AudioPlayerRepository` implementations. Browser CORS and
autoplay policies also break a significant portion of public radio
streams.

### Option C — All Flutter platforms
Rejected. Desktop targets have no production-quality `audio_service`
support and would add maintenance surface for no functional gain.

### Option D — Single platform (Android only or iOS only)
Rejected. The adaptive Material/Cupertino strategy already documented
in `DESIGN.md` only makes sense with both targets present, and an
assessment showcasing only one platform is less informative.

## Documentation impact

- `CONTEXT.md` §Key Constraints — add an explicit "Target platforms" entry.
- `ARCHITECTURE.md` §Native Platform Configuration — add a leading
  statement scoping the section to Android and iOS only.
- `ROADMAP.md` Phase 1 — specify the `flutter create` invocation with
  `--platforms=android,ios`.

## Follow-ups

- None.
