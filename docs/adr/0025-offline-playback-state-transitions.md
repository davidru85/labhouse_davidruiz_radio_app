# ADR-0025 — Offline playback state transitions

- **Status:** Accepted
- **Date:** 2026-05-29
- **Deciders:** David Ruiz
- **Related:** `TECHNICAL_SPEC.md` §13, `TESTING_STRATEGY.md` §RadioPlayerBloc, `VALIDATION_CHECKLIST.md` §Playback, ADR-0013, ADR-0015

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

When a device is offline, attempting to start playback or losing network connectivity mid-playback triggers a playback failure. [ADR-0013](0013-offline-behavior.md) and [ADR-0015](0015-player-buffering-state.md) establish that the player BLoC (`RadioPlayerBloc`) transitions to `PlayerErrorState` on these failures. 

However, the previous specification did not define whether the BLoC should transition directly to `PlayerErrorState` or go through `PlayerBufferingState` first when a play request is initiated in an offline state. 

Establishing a deterministic state sequence is critical for consistent BLoC unit testing (TDD) and ensuring that the UI displays a clean attempt-and-fail user feedback loop rather than flashing immediate errors.

## Decision

When a user initiates playback for a station while the device is offline, the `RadioPlayerBloc` MUST transition through `PlayerBufferingState` before emitting `PlayerErrorState`.

Specifically, the event handling MUST emit the states in this order:
1. `PlayerBufferingState`
2. `PlayerErrorState` (carrying a `PlaybackFailure` with the network connectivity error message).

If connection is lost mid-playback, the transition is from `PlayerPlayingState` to `PlayerErrorState` directly (or via `PlayerBufferingState` if the player attempts to re-buffer before failing).

This ensures that *all* playback requests adhere to a uniform lifecycle structure: `PlayRequested` $\rightarrow$ `Buffering` $\rightarrow$ `Success (Playing) | Failure (Error)`.

## Consequences

### Positive
- Simplifies testing and assertions in Phase 7 BLoC testing, as there are no exceptions to the rule that playback requests always trigger a buffering state first.
- Provides a clean user experience by indicating that the app is responding to the tap (showing a spinner/buffer indicator briefly) before confirming that connection is missing.
- Prevents coupling the BLoC to synchronous, pre-emptive connectivity checks before launching playback.

### Negative
- A user may see a very brief flash of the buffering indicator before the error dialog/snackbar appears when tapping a station offline. This is a standard and acceptable UX pattern.

### Neutral
- None.

## Alternatives considered

### Option B — Direct transition to Error without Buffering
Check connectivity first, and transition directly from `PlayerIdleState` to `PlayerErrorState` if offline. Rejected because it requires the BLoC to synchronously check connectivity state before emitting, complicating the BLoC test setup and breaking the uniformity of the playback request lifecycle.

### Option C — Infinite buffering
Let the player buffer infinitely until the user cancels or the HTTP connection times out. Rejected because mobile connectivity drops are immediately detectable, and forcing a user to wait on a spinner without internet is poor UX.

## Documentation impact

- `TECHNICAL_SPEC.md` §13 — clarified buffering to error transition.
- `TESTING_STRATEGY.md` §RadioPlayerBloc — clarified test case for offline playback request emitting `[Buffering, Error]`.
- `VALIDATION_CHECKLIST.md` §Playback — added verification check for buffering to error transition on offline play requests.
- `ROADMAP.md` Phase 7 — updated testing tasks.
