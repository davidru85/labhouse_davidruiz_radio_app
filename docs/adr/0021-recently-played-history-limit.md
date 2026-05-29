# ADR-0021 — Recently played history limit

- **Status:** Accepted
- **Date:** 2026-05-29
- **Deciders:** David Ruiz
- **Related:** `TECHNICAL_SPEC.md` §4, `VALIDATION_CHECKLIST.md` §Persistence, `ROADMAP.md` Phase 4/6

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

The application maintains a history of recently played radio stations, persisted locally using Hive. However, the documentation did not define a limit on the number of records kept in the history. 

Without a limit, the history database can grow indefinitely as the user listens to different stations. This increases storage footprint, slows down deserialization/serialization of Hive box operations, and can lead to performance degradation on low-end mobile devices.

We need a fixed cap that balances user utility with database performance.

## Decision

We enforce a strict limit of 50 stations in the recently played history database, managed via a FIFO (First-In, First-Out) policy.

Specifically:
1. The history database MUST NOT store more than 50 radio stations.
2. When a new station is played and the history has reached 50 items:
   - The repository MUST delete the oldest entry from the Hive box before adding the new station.
   - If the station being played is already in the history, it MUST be moved to the top/newest position rather than causing a duplicate entry.
3. This limit of 50 items MUST be documented as the official cap for history entries.

## Consequences

### Positive
- Bounds the storage growth of the history Hive box, ensuring quick startup and read/write times.
- Simplifies UI rendering, as the recently played list will never have to render thousands of items.
- Avoids duplicates by promoting existing entries to the top.

### Negative
- Users cannot retrieve stations they listened to beyond the last 50 entries.

### Neutral
- A limit of 50 is a common UX standard for "Recently Played" list sizes.

## Alternatives considered

### Option B — Capping at 20 entries
Too short for highly active users who browse many stations throughout the week.

### Option C — Unlimited history
Hive box is allowed to grow indefinitely. Rejected because it can cause performance issues and does not scale over months of continuous use.

## Documentation impact

- `TECHNICAL_SPEC.md` §4 — updated `HistoryBloc` row to specify the 50-item limit.
- `VALIDATION_CHECKLIST.md` §Persistence — added check validating the 50-item history cap and FIFO behavior.
- `ROADMAP.md` Phase 6 — updated `HistoryRepositoryImpl` task to enforce the 50-item limit.
