# ADR-0031 — Search pagination deduplication and end-of-list behavior

- **Status:** Accepted
- **Date:** 2026-05-29
- **Deciders:** David Ruiz
- **Related:** `API_SPEC.md` §5.1, `TECHNICAL_SPEC.md` §4, `TESTING_STRATEGY.md` §StationsBloc, ADR-0007, ADR-0014

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

The Radio Browser API `/json/stations/search` endpoint is queried using pagination parameters (`limit` and `offset`). As a user scrolls through the stations list, additional pages are fetched and appended.

This approach presents two classic pagination issues:
1. **Deduplication:** A station's sorting index (such as popularity or vote count) can change dynamically between page requests. This can cause a station to appear on page `N` and again on page `N+1`, resulting in duplicates in the UI.
2. **End-of-List detection:** We need a way to detect when no more stations are available (either because the API is exhausted, or we hit our internal `STATIONS_MAX_LIMIT` cap), so that the application does not dispatch redundant API requests on further scrolling.

## Decision

The application's paginated station listing MUST implement client-side deduplication and explicit end-of-list detection.

Specifically:
- The data or repository layer MUST filter out any duplicate stations by mapping results against their unique `stationuuid`.
- The `StationsBloc` MUST track whether the end of the list has been reached:
  - If a page request returns fewer items than the requested page limit, the list is considered exhausted.
  - If the cumulative number of loaded stations reaches `STATIONS_MAX_LIMIT` (governed by `config/app.json`), the list is capped.
  - In either case, the bloc state MUST record this (e.g. via a `hasReachedMax` boolean or transition state), and the bloc MUST ignore any subsequent `LoadMoreStations` events.

## Consequences

### Positive
- Prevents visual anomalies (duplicate list items) when scrolling through search results.
- Protects the Radio Browser API from redundant, repetitive network requests once a query is exhausted or capped.
- Simplifies UI rendering by enabling the view to hide the spinner/loading indicator when the list is fully loaded.

### Negative
- Requires maintaining state in `StationsBloc` and performing duplicate filtering on the loaded list in memory (negligible performance cost for lists under 100 items).

## Documentation impact

- `API_SPEC.md` §5.1 — added deduplication and limit capping constraints.
- `TECHNICAL_SPEC.md` §4 — updated `StationsBloc` state description to incorporate end-of-list tracking.
- `TESTING_STRATEGY.md` §StationsBloc — added test cases for deduplication and `hasReachedMax` state transition.
