# ADR-0040 — Defer the Favorites local search field

- **Status:** Accepted
- **Date:** 2026-06-03
- **Deciders:** David Ruiz
- **Related:** `DESIGN.md` §Favorites, ADR-0014, ADR-0031, `TODO.md` §User interface

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

`DESIGN.md` §Favorites shows the Favorites screen with a "Your Favorites"
heading **and** a "Search your favorites" field that filters the saved
stations in place.

The presentation layer consumes `FavoritesBloc`, whose event surface is
`FavoritesStarted`, `FavoriteToggled`, and `FavoritesRefreshed`
(`lib/presentation/blocs/favorites/favorites_bloc.dart`). There is **no
filtering event or query state**: unlike the Stations search (server-side,
debounced per ADR-0014, paginated per ADR-0031), favorites are a small,
already-loaded local list, so any search would be client-side filtering that
does not exist in the current BLoC contract.

Phase 9 sub-task 9.1–9.2 (adaptive Material/Cupertino screens) is being
delivered in per-screen TDD slices. The `FavoritesScreen` slice implements the
loaded grid, empty state, error state, and the favorite toggle, but ships
without the search field.

## Decision

The Favorites screen local search field is **deferred** from v1 of the
`FavoritesScreen` slice. The screen ships with the heading, the favorites grid,
the empty state, and the favorite toggle; favorites browsing is not filterable
in v1.

## Consequences

### Positive
- Keeps the Phase 9 `FavoritesScreen` slice scoped to adaptive rendering of the
  existing `FavoritesBloc` states without expanding the BLoC contract.
- Avoids introducing a filtering concern (event/state or local filter widget)
  mid-UI-slice.

### Negative
- The shipped Favorites screen diverges from `DESIGN.md` §Favorites until the
  search field is implemented.

### Neutral
- Reintroducing the feature is additive: it needs either a new
  `FavoritesBloc` filter event + query state, or a local filter held in the
  screen, plus widget tests — no rearchitecting.

## Alternatives considered

### Option A — Implement favorites search now
Add a `FavoritesBloc` filter event + query state (or a local filter in the
screen) and the search field in this slice. Rejected for v1 of this slice: it
widens the slice beyond adaptive rendering and reaches back into the BLoC layer
(Phase 7) without a driving need.

### Option B — Drop the favorites search from the product
Remove it from `DESIGN.md` entirely. Rejected: the field is a reasonable
refinement worth keeping on the roadmap rather than discarding.

## Documentation impact

- `TODO.md` §User interface — record the deferral and cite this ADR.
- `docs/adr/README.md` — add the index entry.
- `MEMORY.md` §Decision Log — add the entry.

## Follow-ups

- Task: implement the "Search your favorites" field, backed by a
  `FavoritesBloc` filter event/state or a local filter, with widget tests.
