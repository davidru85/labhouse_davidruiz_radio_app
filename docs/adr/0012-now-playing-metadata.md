# ADR-0012 — Now-playing metadata (Icy stream)

- **Status:** Accepted
- **Date:** 2026-05-28
- **Deciders:** David Ruiz
- **Related:** `TECHNICAL_SPEC.md` §4, `ARCHITECTURE.md` §Repository Contracts, `ROADMAP.md` Phases 2 / 6 / 7

## Context

Shoutcast and Icecast — the protocols behind the vast majority of
stations indexed by Radio Browser — embed inline metadata in the
HTTP audio stream. Every `icy-metaint` bytes the server injects a
short block of `StreamTitle='Artist - Track';StreamUrl='...';`. This
is **live information about the currently playing track**, distinct
from the static station metadata returned by the Radio Browser API.

The `just_audio` package, already in the dependency list, exposes
this information via `player.icyMetadataStream`. The capability is
therefore available at zero protocol cost; the open question is
whether to model it explicitly in the domain, surface it through the
`AudioPlayerRepository` contract, propagate it through the
`RadioPlayerBloc`, and display it in the UI.

The original specification does not mention Icy metadata. Without an
explicit decision, the player slice would silently drop a piece of
information that distinguishes a "live" radio application from a
generic URL player.

Two practical realities constrain the design:

- A non-trivial number of stations do **not** emit Icy metadata, or
  emit it malformed (empty `StreamTitle`, no `Artist - Track`
  separator, occasional binary garbage). The application must
  degrade gracefully.
- The metadata changes mid-playback: every new track produces a new
  emission. The model must reflect this stream-like nature, not a
  one-shot fetch.

## Decision

Now-playing metadata is **in scope for v1**. The application surfaces
the current track and artist when the station provides them, and
silently falls back to station-level information when it does not.

### Domain model

A new immutable entity `NowPlayingInfo` is added under
`domain/entities/`:

```dart
class NowPlayingInfo extends Equatable {
  const NowPlayingInfo({this.raw, this.artist, this.track});

  final String? raw;     // the StreamTitle value verbatim, when present
  final String? artist;  // parsed from "Artist - Track"; null on failure
  final String? track;   // parsed from "Artist - Track"; null on failure
}
```

Parsing rules:

- If `raw` is null or empty, both `artist` and `track` are null.
- If `raw` contains exactly one ` - ` (space-hyphen-space) separator,
  the left side is `artist` and the right side is `track`.
- If `raw` cannot be split, `raw` is exposed verbatim and both
  `artist` and `track` are null.

### Repository contract

`AudioPlayerRepository` gains:

```dart
Stream<NowPlayingInfo?> get nowPlayingStream;
```

Emissions:

- `null` whenever playback is idle, stopped, or the station has no
  Icy metadata at all.
- A `NowPlayingInfo` with the latest values every time the underlying
  `just_audio` `icyMetadataStream` produces a new title.

### BLoC modelling

`RadioPlayerBloc` extends `PlayerPlayingState` with a nullable
`nowPlaying` field:

```dart
class PlayerPlayingState {
  final RadioStation station;
  final NowPlayingInfo? nowPlaying;
  ...
}
```

The bloc subscribes to `nowPlayingStream` while in
`PlayerPlayingState` and re-emits the state with the new
`nowPlaying` value via `copyWith`. The subscription is cancelled on
pause, stop, error and dispose. The subscription is not active during
buffering — `PlayerBufferingState` does not carry `nowPlaying`.

### UI projection (Phase 9)

When UI work begins:

- `MiniPlayerWidget` shows track and artist when both are present,
  station name otherwise.
- `FullPlayerScreen` shows track, artist and station name as separate
  visual elements; missing fields collapse without showing
  placeholders.
- No spinner is shown while waiting for the first Icy emission;
  station name is the always-available fallback.

### Out of scope under this ADR

- Persisting now-playing history (separate from `HistoryBloc`, which
  tracks stations, not tracks).
- Album art / artwork lookup from external services.
- Lyrics or extended metadata enrichment.

## Consequences

### Positive
- The application surfaces what is actually playing, not just the
  station identity. This is the qualitative difference between a
  "live" radio experience and a URL player.
- Demonstrates integration with a reactive stream sourced from the
  audio player itself, complementing the otherwise
  request/response-heavy architecture (HTTP, Hive, BLoC events).
- Graceful handling of malformed Icy data is consistent with the
  resilience posture already in place for malformed Radio Browser
  payloads and broken streams.
- Adds a small, well-isolated domain entity with clear parsing
  semantics that is easy to unit-test.

### Negative
- `PlayerPlayingState` gains a nullable field, slightly increasing
  the surface area of the player BLoC.
- Two additional bloc tests required: emission flow and graceful
  handling of malformed input.
- The UI in Phase 9 must layout for "may or may not be present"
  text fields without showing placeholders that flash on every
  station change.

### Neutral
- The subscription lifecycle is fully owned by the bloc; no global
  listener is introduced.

## Alternatives considered

### Option A — Out of scope, no reserved field
Rejected. Adding the feature later would change the
`AudioPlayerRepository` contract and the `PlayerPlayingState` shape,
making the addition breaking instead of additive.

### Option B — Out of scope but reserved field on `PlayerPlayingState`
Rejected. A field that is permanently null adds documentation cost
("why is this here?") without any operational benefit. Either the
feature exists or it does not.

## Documentation impact

- `TECHNICAL_SPEC.md` §4 (`RadioPlayerBloc` row) — add `nowPlaying`
  field to `PlayerPlayingState`. No new event needed; the bloc
  subscribes internally to the repository stream.
- `ARCHITECTURE.md` §Repository Contracts → `AudioPlayerRepository` —
  add `Stream<NowPlayingInfo?> get nowPlayingStream;`.
- `API_SPEC.md` §6 (Domain Modelling) — add the `NowPlayingInfo`
  entity definition.
- `ROADMAP.md` Phase 2 — add `NowPlayingInfo` to the list of entities
  defined under `domain/entities/`.
- `ROADMAP.md` Phase 6 — under `AudioPlayerRepositoryImpl`, mention
  subscribing to `just_audio`'s `icyMetadataStream` and adapting
  emissions into `NowPlayingInfo` domain instances.
- `ROADMAP.md` Phase 7 — under `RadioPlayerBloc` tests, add cases
  for: valid Icy emission, station without Icy, malformed Icy,
  track change mid-playback.
- `TESTING_STRATEGY.md` §RadioPlayerBloc — extend the bullet list
  with the four cases above. Add a separate bullet for unit-testing
  the `NowPlayingInfo` parser.
- `VALIDATION_CHECKLIST.md` §Playback — add a check that malformed
  Icy data does not crash the player or destroy the player state.

## Follow-ups

- A future ADR may add album-art lookup against an external service,
  scoped separately to avoid coupling the player BLoC to an HTTP
  client.
- A future ADR may introduce a separate `TracksHistoryBloc` if track
  history (distinct from station history) becomes desirable.
