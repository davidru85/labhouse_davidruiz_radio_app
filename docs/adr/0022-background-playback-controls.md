# ADR-0022 — Background playback notification controls

- **Status:** Accepted
- **Date:** 2026-05-29
- **Deciders:** David Ruiz
- **Related:** `ARCHITECTURE.md` §Native Platform Configuration, `TECHNICAL_SPEC.md` §4, `VALIDATION_CHECKLIST.md` §Playback, `ROADMAP.md` Phase 6

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

The application integrates `audio_service` with `just_audio` to manage background audio playback. This configuration triggers a system notification on iOS and Android with playback controls (e.g., lock screen and notification shade widget). 

The specification did not define which media control buttons should be displayed, nor how the notification metadata should be populated. In a live radio streaming application, standard controls like "Skip to Next" and "Skip to Previous" are ambiguous because there is no native song queue. Showing these buttons could frustrate users, as pressing them would require initiating a heavy, multi-second failover URL resolution for a completely different station, which is prone to network failure.

We need to define a stable, user-friendly control scheme and metadata layout for the native background playback widget.

## Decision

The background playback widget MUST expose only basic playback state controls, and MUST NOT expose queue navigation actions.

Specifically:
1. The background media notification controls MUST be limited to **Play**, **Pause**, and **Stop**.
2. Skip to Next, Skip to Previous, Fast Forward, and Rewind actions MUST NOT be enabled or displayed in the notification widget.
3. The notification metadata MUST show the station name as the title, and the dynamically updated `NowPlayingInfo` (formatted as "Artist - Track") as the subtitle. If no `NowPlayingInfo` is available, the subtitle MUST fallback to a static message (e.g. the station's genre or country).

## Consequences

### Positive
- Prevents user frustration by hiding buttons that have no logical action (like "Next" in a single-stream context).
- Simplifies player implementation, avoiding the need to sync a background queue with the UI state of search or favorites.
- Keeps the system lock screen responsive, as toggling Play/Pause/Stop is instant, unlike resolving a new station stream URL fallback chain.

### Negative
- Users cannot cycle through their favorites directly from the lock screen; they must open the app to switch stations.

### Neutral
- This behavior aligns with industry standards for live streaming applications (e.g., TuneIn, BBC iPlayer Radio).

## Alternatives considered

### Option B — Mappings skip actions to local Favorites list
Enable skip buttons to switch between favorites. Rejected because if the user has no favorites, the buttons would become inactive or crash, leading to a broken user experience.

### Option C — Mapping skip actions to active Stations search list
Maintain an active search queue in the background. Rejected due to the high complexity of synchronizing search state changes between BLoCs and the background audio service.

## Documentation impact

- `ARCHITECTURE.md` §Native Platform Configuration — added rules for background media controls and notification metadata.
- `TECHNICAL_SPEC.md` §4 (`RadioPlayerBloc` row) — updated description to note background control restrictions.
- `VALIDATION_CHECKLIST.md` §Playback — added validation check for lock screen/notification controls and metadata.
- `ROADMAP.md` Phase 6 (`AudioPlayerRepositoryImpl` task) — updated implementation detail to configure lock screen buttons.
