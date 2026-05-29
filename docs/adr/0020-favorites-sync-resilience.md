# ADR-0020 — Favorites synchronization resilience

- **Status:** Accepted
- **Date:** 2026-05-29
- **Deciders:** David Ruiz
- **Related:** `API_SPEC.md` §8, `VALIDATION_CHECKLIST.md` §Persistence, `ROADMAP.md` Phase 5/6

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

The application periodically refreshes locally stored favorite radio stations by invoking the `/json/stations/byuuid` endpoint. However, the documentation did not specify what the system should do if a favorited station is no longer returned in the API response (e.g. if the station was deleted or its record became obsolete). 

If the application silently deletes the station from the local database, the user loses their favorites without warning or consent. Conversely, if the error is ignored, the user may try to play a broken station without any visual indication of its status.

We need a resilient strategy that prevents data loss while maintaining visual clarity.

## Decision

We retain missing favorited stations locally and mark them as inactive instead of deleting them.

During favorites synchronization, if a station UUID exists locally but is absent from the API response:
1. The repository MUST NOT delete the station from the local Hive box.
2. The repository MUST update the station's metadata in local storage, setting `lastCheckOk = false`.
3. Playback attempts for these orphaned stations will fail gracefully in the player layer, prompting the user with a clear message and providing an option to remove the favorite manually.

## Consequences

### Positive
- Prevents silent data loss caused by temporary API index inconsistencies or re-indexing.
- Ensures the user remains in control of their local storage and is aware of why a station cannot be played.
- Fits cleanly into the existing player error and retry UI flows.

### Negative
- Local favorites storage can retain orphaned records unless the user manually unfavorites them.
- Slightly increases the validation logic in the repository implementation.

### Neutral
- An orphaned station is marked as `lastCheckOk = false`, which is already a standard field on the `RadioStation` entity.

## Alternatives considered

### Option B — Silent deletion
Automatically and silently delete the station from local storage if missing in the API response. Rejected because it causes data loss and a poor user experience.

### Option C — No change / Ignore
Ignore the absence of the station during sync and keep the old local metadata intact. Rejected because it does not flag the station as potentially broken, leading to unexpected playback errors later.

## Documentation impact

- `API_SPEC.md` §8 — added rules defining favorites synchronization behavior and prohibiting silent deletions.
- `VALIDATION_CHECKLIST.md` §Persistence — added check validating that synchronization does not silently delete local stations.
- `ROADMAP.md` Phase 6 — updated the `FavoritesRepositoryImpl` implementation task to specify this requirement.
