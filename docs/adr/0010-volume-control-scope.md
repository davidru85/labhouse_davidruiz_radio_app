# ADR-0010 — Volume control scope

- **Status:** Accepted
- **Date:** 2026-05-28
- **Deciders:** David Ruiz
- **Related:** `TECHNICAL_SPEC.md` §4, `ARCHITECTURE.md` §Repository Contracts, `ROADMAP.md` Phase 3

## Context

The original specification commits to an in-app volume control in four
different documents:

- `TECHNICAL_SPEC.md` §4 lists `VolumeChanged` as a `RadioPlayerBloc`
  event and `VolumeChangedState` as one of its states.
- `ARCHITECTURE.md` §Repository Contracts declares
  `AudioPlayerRepository.setVolume(double volume)`.
- `ROADMAP.md` Phase 3 includes `SetVolumeUseCase` in the playback use
  cases.
- `TESTING_STRATEGY.md` requires `RadioPlayerBloc` tests to cover
  "volume changes".

Two volume models exist for mobile audio applications:

1. **System volume.** The OS handles up/down via physical buttons. The
   application does not expose its own volume control. This is the
   default behaviour for `just_audio` on both Android and iOS and
   requires no application code.
2. **Application-level volume.** The application keeps its own
   `0.0–1.0` multiplier on top of the system volume. It exposes a
   slider in the UI, persists the value, and applies it on every play.

Industry-standard radio applications (Spotify, TuneIn, Apple Music,
iHeartRadio) follow model 1. Media-style notifications and lock-screen
controls do not display a volume slider on either platform; the
application-level slider has no parity in OS-level controls.

## Decision

RadioApp uses **system volume only**. The application does not expose
an in-app volume control. Concretely:

- `RadioPlayerBloc` does not define a `VolumeChanged` event nor a
  `VolumeChangedState`.
- `AudioPlayerRepository` does not declare a `setVolume(double)`
  method.
- `SetVolumeUseCase` is not implemented.
- `FullPlayerScreen` does not include a volume slider widget when UI
  work begins in Phase 9.

Physical volume buttons continue to work as expected because both
Android and iOS — together with `just_audio` and `audio_service` —
handle them at the OS level without application involvement.

## Consequences

### Positive
- `RadioPlayerBloc` scope is narrower and focuses on playback
  lifecycle (play / pause / stop / buffering / error). One fewer event,
  one fewer state, one fewer use case, one fewer repository method,
  fewer tests.
- Matches the user expectations set by every comparable radio
  application.
- `FullPlayerScreen` gets one fewer control to design, leaving room
  for the metadata and playback affordances that actually need surface
  area.
- No persistence question to answer (where would the last volume value
  live — Hive box? memory only?). Removed entirely.

### Negative
- The application cannot offer "RadioApp quieter than other apps"
  behaviour. For a radio app this is not a documented user need.
- Adding the feature later requires reintroducing the bloc event,
  state, use case, repository method, persistence and UI control. The
  change is mechanical and fully isolated to the player slice.

### Neutral
- The `AudioPlayerRepository` abstraction remains a clean boundary;
  reintroducing `setVolume` later would not break the abstraction.

## Alternatives considered

### Option B — Keep both system volume and in-app volume
Rejected. The application-level slider would go unused by the vast
majority of users while incurring the cost of additional bloc surface,
persistence, and UI design. Two independent controls create user
confusion when one is adjusted but not the other.

### Option C — In-app volume only, disabling system volume
Rejected. Mobile OSes always respond to physical volume buttons; there
is no portable way to disable them. Pursuing this leads to
inconsistent and surprising behaviour.

## Documentation impact

- `TECHNICAL_SPEC.md` §4 — remove `VolumeChanged` and
  `VolumeChangedState` from the `RadioPlayerBloc` row.
- `ARCHITECTURE.md` §Repository Contracts — remove
  `setVolume(double volume)` from `AudioPlayerRepository`.
- `ROADMAP.md` Phase 3 — remove `SetVolumeUseCase` from the playback
  use cases list.
- `TESTING_STRATEGY.md` §RadioPlayerBloc — remove the "volume changes"
  bullet.

## Follow-ups

- None. The decision is fully reversible by a future ADR if a clear
  product need emerges.
