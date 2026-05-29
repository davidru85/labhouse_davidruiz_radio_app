# ADR-0026 — Recently played history triggers

- **Status:** Accepted
- **Date:** 2026-05-29
- **Deciders:** David Ruiz
- **Related:** `TECHNICAL_SPEC.md` §4, `TESTING_STRATEGY.md` §HistoryBloc, ADR-0021

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

[ADR-0021](0021-recently-played-history-limit.md) establishes a strict 50-item limit and FIFO eviction policy on the recently played history. However, it does not define the exact point in the application lifecycle or which component triggers the addition of a station to the history list. 

Without a clear trigger point, there is a risk of adding unavailable or broken streams to the history when a play request is first initiated, which degrades the user experience.

## Decision

The addition of a station to the recently played history list MUST be triggered only when the playback starts successfully.

Specifically:
- The trigger point is when `RadioPlayerBloc` transitions to `PlayerPlayingState` carrying the active `RadioStation` payload.
- The presentation layer (e.g., the UI shell, a global bloc listener, or coordinator) MUST dispatch the `AddToHistory(station)` event to the `HistoryBloc` upon detecting this transition.
- Playback requests that fail (i.e. transition to `PlayerErrorState`) MUST NOT trigger any addition to the history list.

## Consequences

### Positive
- Prevents broken, offline, or invalid streams from cluttering the recently played history.
- Maintains clean separation of concerns: the playback engine (`RadioPlayerBloc`) does not directly depend on or manage the history storage.
- The history list reflects only stations that the user has successfully listened to.

### Negative
- Requires coordinating state changes between `RadioPlayerBloc` and `HistoryBloc` in the presentation/UI layer.

### Neutral
- A station is only added after the stream starts playing, so a brief delay in connection resolution means the station will not appear in the history list immediately upon tap.

## Alternatives considered

### Option A — Trigger on tap / event initiation
Trigger `AddToHistory` immediately when `StationPlayRequested` is received by `StationsBloc` or `PlayRequested` by `RadioPlayerBloc`. Rejected because this would add broken or offline streams to the history.

### Option B — Trigger from the Playback Use Case
Inject `HistoryRepository` into the play use case and record it there. Rejected because it violates the separation of concerns, coupling playback resolution with historical logging at the domain level.

## Documentation impact

- `TECHNICAL_SPEC.md` §4 — updated BLoC Table entry for `HistoryBloc` and `RadioPlayerBloc` to specify the trigger.
- `ROADMAP.md` Phase 6/7 — clarified integration and testing details.
