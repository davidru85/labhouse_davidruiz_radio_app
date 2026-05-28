# ADR-0015 — Player buffering state

- **Status:** Accepted
- **Date:** 2026-05-28
- **Deciders:** David Ruiz
- **Related:** `TECHNICAL_SPEC.md` §4, ADR-0012, ADR-0013, `ROADMAP.md` Phase 7

## Context

The original specification of `RadioPlayerBloc` (`TECHNICAL_SPEC.md`
§4) defines four key states: `PlayerIdleState`,
`PlayerPlayingState`, `PlayerPausedState`, `PlayerErrorState`. No
state is defined for **buffering**, even though buffering is an
unavoidable, perceptible phase of every live radio playback session:

- Initial buffering after `PlayRequested`: TCP connection,
  headers, first audio chunk, codec decode. Typically 1–5 seconds,
  occasionally longer with slow connections or distant mirrors.
- Mid-playback re-buffering: when the network deteriorates,
  `just_audio` re-buffers transparently.

Without an explicit state, the bloc would have to choose between:

- Emitting `PlayerPlayingState` immediately upon `PlayRequested`,
  which lies to the UI (no audio yet) and makes the user think the
  app is broken when the first second is silent.
- Staying in `PlayerIdleState` until audio actually starts, which
  makes the user think nothing happened when they pressed play.

The `just_audio` package already exposes the underlying signal:
`PlayerState.processingState` takes values `idle`, `loading`,
`buffering`, `ready`, `completed`. The bloc only needs to project
this onto a clean state machine.

## Decision

Introduce **`PlayerBufferingState`** as a first-class state in
`RadioPlayerBloc`, distinct from `PlayerPlayingState`. The state is
emitted whenever the underlying player is connecting, loading or
buffering, regardless of whether buffering is the initial connect or
a mid-playback re-buffer.

### State shape

```dart
sealed class PlayerState extends Equatable {
  const PlayerState();
}

final class PlayerIdleState extends PlayerState {
  const PlayerIdleState();
}

final class PlayerBufferingState extends PlayerState {
  final RadioStation station;
  const PlayerBufferingState(this.station);
}

final class PlayerPlayingState extends PlayerState {
  final RadioStation station;
  final NowPlayingInfo? nowPlaying;
  const PlayerPlayingState({required this.station, this.nowPlaying});
}

final class PlayerPausedState extends PlayerState {
  final RadioStation station;
  const PlayerPausedState(this.station);
}

final class PlayerErrorState extends PlayerState {
  final RadioStation? station;
  final PlaybackFailure failure;
  const PlayerErrorState({this.station, required this.failure});
}
```

`PlayerBufferingState` carries the `RadioStation` so the UI can keep
showing the station identity (name, favicon) while the spinner
displays. It deliberately does **not** carry `NowPlayingInfo`: no
track has started, so any metadata would be either stale or
misleading.

### State machine

```
Idle ──PlayRequested──→ Buffering ──ready──→ Playing
                                  └─fail──→ Error
Playing ──PauseRequested──→ Paused
Playing ──stream stall──→ Buffering ──ready──→ Playing
                                    └─fail──→ Error
Paused ──PlayRequested──→ Buffering ──→ Playing
Any non-Idle ──StopRequested──→ Idle
Any non-Idle ──connectivity lost (per ADR-0013)──→ Error
```

The same `PlayerBufferingState` is used for both initial buffering
and mid-playback re-buffering. Distinguishing the two would
complicate the state surface without changing what the UI shows:
in both cases the action is "display a spinner over the station
identity".

If a future product requirement needs to distinguish them, the
state can be extended with an optional `wasPlaying: bool` flag
without breaking existing consumers.

### Timeouts

No bloc-level timeout is introduced for buffering. The underlying
`just_audio` stream timeout governs the upper bound; on failure,
the bloc transitions to `PlayerErrorState` with the appropriate
`PlaybackFailure` subtype. Bloc tests assert the transition, not
the specific timeout duration.

## Consequences

### Positive
- The bloc state truthfully reflects whether audio is currently
  sounding.
- The UI gains an unambiguous signal to display a spinner. The
  `MiniPlayerWidget` and `FullPlayerScreen` can render
  appropriately during the first second of playback.
- Mid-playback re-buffering reuses the same state without new
  machinery.
- Tests are more expressive: a `PlayRequested` test asserts the
  emission `[Buffering, Playing]` rather than collapsing the
  buffering phase.
- Coherent with the sealed-type modelling already used across the
  project.

### Negative
- One additional state to handle in the UI projection for Phase 9.
  Minor.
- Slightly more complex bloc transition logic; mitigated by clear
  test coverage.

### Neutral
- The state does not distinguish initial from mid-playback
  buffering. Acceptable for v1.

## Alternatives considered

### Option B — Boolean `isBuffering` field inside `PlayerPlayingState`
Rejected. Mixes two orthogonal concerns into a single state and
forces consumers to read both the state type and a flag to know
what to display. Inconsistent with the sealed-type discipline used
elsewhere in the project.

### Option C — No buffering modelling
Rejected. Forces a lie in the bloc (claiming Playing when audio is
not sounding) or a degraded UX (claiming Idle after play was
pressed).

### Distinguish `InitialBufferingState` from `ReBufferingState` as separate states
Rejected for v1. The UI treatment is identical in both cases. The
distinction can be reintroduced additively if a need emerges.

## Documentation impact

- `TECHNICAL_SPEC.md` §4 — add `PlayerBufferingState` to the Key
  States column of the `RadioPlayerBloc` row.
- `ARCHITECTURE.md` §BLoC Boundaries — note that `RadioPlayerBloc`
  models buffering as an explicit state distinct from playing.
- `ROADMAP.md` Phase 7 — under `RadioPlayerBloc`, add the
  buffering transition to the list of behaviours to implement.
- `TESTING_STRATEGY.md` §RadioPlayerBloc — add test cases:
  - `PlayRequested` emits `[Buffering, Playing]` in order.
  - Stream stall mid-playback emits `[Buffering, Playing]`.
  - Buffering that fails emits `[Buffering, Error]`.
- `VALIDATION_CHECKLIST.md` §Playback — add: the Buffering →
  Playing transition exists and is never skipped on a successful
  play.

## Follow-ups

- If the UI ever needs to distinguish initial buffering from
  mid-playback re-buffering, add an optional `wasPlaying` field
  without breaking consumers.
