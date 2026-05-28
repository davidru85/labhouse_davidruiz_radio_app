# ADR-0013 — Offline behaviour

- **Status:** Accepted
- **Date:** 2026-05-28
- **Deciders:** David Ruiz
- **Related:** `CONTEXT.md` §Core Product Scope, `TECHNICAL_SPEC.md` §5, `API_SPEC.md` §8, ADR-0012

## Context

The original specification mentions offline considerations
incidentally — favorites, history, genres and country codes are
cached for offline reads — but does not define how the user-facing
surfaces respond when the device has no network connectivity.
Without an explicit model, each screen would either crash, hang, or
fall back inconsistently.

The application has five user-facing surfaces:

| Surface | Source | Offline reality |
|---|---|---|
| Stations (search, top) | Remote only | No data available |
| Favorites | Hive cache (read) + remote streams (play) | Listable; not playable |
| History | Hive cache (read) + remote streams (play) | Listable; not playable |
| Player | Live HTTP stream | Cannot play |
| Country / Genre filters | Hive cache + remote refresh | Cache when available |

Two facts shape the design:

1. Radio playback is inherently online: there is no realistic
   "downloaded radio". Promising offline playback would mislead
   the user.
2. The metadata cached for favorites and history is enough to
   *display* a list offline but not enough to *play* anything.

The application therefore needs (a) a way to detect connectivity
reactively, (b) per-surface offline behaviour rules, and (c) a
global indicator so the user understands when the application is
constrained by the network state rather than by a bug.

## Decision

### Connectivity detection

The application uses `connectivity_plus` for proactive detection
**and** HTTP error inference for individual request failures. Both
are needed:

- `connectivity_plus` drives the global UI indicator and lets
  surfaces render their offline state without first attempting a
  doomed request.
- HTTP error handling in the data layer continues to map per-request
  failures into domain `NetworkFailure` instances, regardless of
  what `connectivity_plus` reports (it can be inaccurate during
  captive-portal handshakes, brief outages, or VPN flips).

### New architectural pieces

- **Dependency:** `connectivity_plus` is added to `pubspec.yaml`
  under production dependencies.
- **Domain repository:** `ConnectivityRepository` abstracts the
  `connectivity_plus` plugin.
  ```dart
  abstract class ConnectivityRepository {
    Stream<bool> get onlineStatusStream;
    Future<bool> isCurrentlyOnline();
  }
  ```
- **Use case:** `WatchConnectivityUseCase` exposes
  `Stream<bool>` to the BLoC layer.
- **BLoC:** `ConnectivityBloc` emits `OnlineState` or
  `OfflineState`. It is constructed at the app shell level so the
  banner widget can react to it without per-screen wiring.

The `AudioPlayerRepositoryImpl` listens to
`ConnectivityRepository.onlineStatusStream` internally and maps a
transition to offline during active playback into the same
`PlaybackFailure` it already raises for broken streams. The
`RadioPlayerBloc` therefore needs no special connectivity-awareness
code; it sees a regular playback failure.

### Per-surface offline rules

**Stations screen.**
When offline, the screen shows a clear message — for example,
*"You're offline. Connect to discover stations. Your favorites and
history remain available."* — together with a retry affordance. No
attempt is made to fall back to favorites or history; doing so
would mix discovery with personal collections and mislead the user.

**Favorites and History screens.**
Lists continue to render from Hive without changes. Tapping a
station to play it while offline triggers the same
`PlaybackFailure` flow as a broken stream: a `PlayerErrorState`
with a clear "Cannot play while offline" message. The lists are
not modified; the player surface signals the failure.

**Player.**
- If playback is requested while offline, it fails immediately with
  `PlayerErrorState`.
- If connectivity is lost mid-playback, the
  `AudioPlayerRepositoryImpl` emits a `PlaybackFailure` and the
  `RadioPlayerBloc` transitions to `PlayerErrorState`.
- **No auto-resume on reconnection.** Recovery is manual: the user
  taps play again. This is tracked as a future improvement
  in `TODO.md`.

**Country / Genre filters.**
- Read from the Hive cache, which is the documented behaviour.
- If the cache is empty (typically only on first launch without
  network), the filter shows a message and is disabled until cache
  is populated.

### Global indicator

A persistent banner at the top of the app shell shows *"You're
offline"* whenever `ConnectivityBloc` is in `OfflineState`. When the
state transitions back to `OnlineState`, the banner shows
*"Back online"* for two seconds and then disappears. The exact
visual treatment is deferred to Phase 9 visual specifications; the
behaviour and BLoC contract are fixed here.

### Out of scope under this ADR

- Predictive download or caching of audio segments for offline
  playback. Not feasible for live radio.
- Automatic resume of playback when connectivity returns. Tracked
  in `TODO.md` under "Playback features".
- Distinguishing wifi from cellular in the UI. The application
  treats both as "online".

## Consequences

### Positive
- Every screen has a deterministic response to the network state.
- The user is informed honestly about what is and is not possible
  without connectivity.
- Detection is reactive (banner appears immediately) and resilient
  (failed requests still map to `NetworkFailure` even when
  `connectivity_plus` reports online during a brief outage).
- The connectivity concern lives in one BLoC plus one repository
  contract; it does not infect every screen.
- The player slice gains offline awareness without changes to the
  `RadioPlayerBloc`: the underlying repository surfaces the
  condition as a `PlaybackFailure`.

### Negative
- One additional production dependency (`connectivity_plus`).
- One additional BLoC, repository contract, use case and remote
  data source — small but real surface increase.
- The application cannot auto-resume on reconnection. Tracked.

### Neutral
- `connectivity_plus` exposes the cellular vs. wifi distinction;
  the application deliberately collapses both into "online".

## Alternatives considered

### Detection only via HTTP errors, no `connectivity_plus`
Rejected. Cannot drive a proactive banner; the user only learns the
app is offline after pressing a button that fails.

### Detection only via `connectivity_plus`, no HTTP error inference
Rejected. `connectivity_plus` is unreliable during captive-portal
handshakes, VPN transitions, and brief outages. Per-request error
handling is needed regardless.

### Show Favorites and History as "playable offline" on the Stations screen
Rejected. The metadata is cached but the streams are not. Promising
offline playback would mislead the user.

### Auto-resume playback on reconnection
Rejected for v1. Adds complexity (debounce after reconnection,
distinguishing user-initiated stop from connectivity-induced stop)
without proportional MVP value. Tracked in `TODO.md`.

### Embed connectivity state inside existing BLoCs instead of a
separate `ConnectivityBloc`
Rejected. Each BLoC would need to inject a connectivity stream,
multiplying wiring. A single `ConnectivityBloc` at the app shell
level is consumed by the banner and by whatever surface needs it,
with no per-BLoC plumbing.

## Documentation impact

- `TECHNICAL_SPEC.md` §2 (Official Dependencies) — add
  `connectivity_plus` under production dependencies.
- `TECHNICAL_SPEC.md` §4 — add a new row for `ConnectivityBloc`.
- `TECHNICAL_SPEC.md` §5 — note that `PlaybackFailure` includes the
  offline-during-playback transition.
- `ARCHITECTURE.md` §BLoC Boundaries — add `ConnectivityBloc` to
  the required BLoC list.
- `ARCHITECTURE.md` §Repository Contracts — add
  `ConnectivityRepository` and `ConnectivityRepositoryImpl`.
- `ROADMAP.md` Phase 2 — add `ConnectivityRepository` to the
  repository interfaces.
- `ROADMAP.md` Phase 3 — add `WatchConnectivityUseCase` to the
  use case list.
- `ROADMAP.md` Phase 5 — add a `ConnectivityDataSource` (thin
  wrapper around `connectivity_plus`).
- `ROADMAP.md` Phase 6 — add `ConnectivityRepositoryImpl`. Update
  `AudioPlayerRepositoryImpl` to listen to connectivity transitions
  and surface them as `PlaybackFailure`.
- `ROADMAP.md` Phase 7 — add `ConnectivityBloc` tests; add a
  `RadioPlayerBloc` test case for offline transition during
  playback.
- `ROADMAP.md` Phase 9 — add the persistent offline banner and
  per-screen offline copy to the UI scope.
- `TESTING_STRATEGY.md` — add a `ConnectivityBloc` section with the
  basic transitions; add a `RadioPlayerBloc` case for offline
  transition.
- `VALIDATION_CHECKLIST.md` — add an "Offline behaviour" section
  with checks for each per-surface rule.
- `TODO.md` — add "Auto-resume playback when connectivity returns"
  under Playback features.

## Follow-ups

- ADR for auto-resume on reconnection, if introduced later.
- ADR for any future caching of audio segments, if pursued.
