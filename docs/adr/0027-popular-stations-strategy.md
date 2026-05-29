# ADR-0027 — Popular stations strategy

- **Status:** Accepted
- **Date:** 2026-05-29
- **Deciders:** David Ruiz
- **Related:** `API_SPEC.md` §5.2, `ROADMAP.md` Phase 3/5, `TECHNICAL_SPEC.md` §4

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

The Radio Browser API provides two dedicated endpoints to retrieve recommended or popular stations:
1. `/json/stations/topclick/{limit}` (top clicked stations)
2. `/json/stations/topvote/{limit}` (top voted stations)

However, these endpoints do not support standard pagination (offset query parameters) or filtering (by name, country, or tag) in the same way the standard `/json/stations/search` endpoint does. The standard search endpoint supports the `order=clickcount` and `order=votes` parameters along with all filters and pagination features.

We need to decide whether to implement dedicated repositories/use cases for these top endpoints or unify the popular station queries under the standard search mechanism.

## Decision

The application MUST retrieve popular stations using the standard `/json/stations/search` endpoint with `order=clickcount` (or `order=votes`) and `reverse=true` parameters.

Specifically:
- Separate dedicated endpoints `/json/stations/topclick` and `/json/stations/topvote` SHALL NOT be integrated into the data layer.
- The `LoadTopClickStationsUseCase` and `LoadTopVoteStationsUseCase` are replaced by a unified search parameterization.
- The `RemoteStationDataSource` search method MUST accept sorting parameters to support popular queries directly.

## Consequences

### Positive
- Reduces code duplication: a single remote data source query covers search, filtering, and popular recommendation sections.
- Popular sections automatically gain pagination (lazy-loading) and filtering capabilities for free.
- Simplifies testing since only one endpoint request needs to be mocked and validated.

### Negative
- None.

## Alternatives considered

### Option A — Integrate dedicated endpoints
Create separate remote calls, use cases, and repository methods for top clicked and top voted stations. Rejected because it increases maintenance overhead, code footprint, and makes it difficult to add pagination or tag filters to the popular sections later.

## Documentation impact

- `API_SPEC.md` §5.2 — marked `/json/stations/topclick` and `/json/stations/topvote` as out of scope, confirming search-based popularity.
- `ROADMAP.md` Phase 3/5 — simplified use-cases checklist.
- `TECHNICAL_SPEC.md` §4 — updated `StationsBloc` entry to specify search-based recommendation queries.
