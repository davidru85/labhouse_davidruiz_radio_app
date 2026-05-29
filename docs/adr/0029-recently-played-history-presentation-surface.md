# ADR-0029 — Recently played history presentation surface

- **Status:** Accepted
- **Date:** 2026-05-29
- **Deciders:** David Ruiz
- **Related:** `DESIGN.md` §Expected Screens, `ROADMAP.md` Phase 8, ADR-0021

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

[ADR-0021](0021-recently-played-history-limit.md) introduces the tracking of a recently played history of up to 50 items. However, `DESIGN.md` lists only three primary screens (`StationsScreen`, `FavoritesScreen`, `FullPlayerScreen`) and tab-bar buttons for "Stations" and "Favorites". There is no dedicated history screen or tab.

We need to clarify where and how the recently played history is displayed to the user so that we can structure routes and BLoC subscriptions correctly in Phase 8 (Routing) and Phase 9 (UI).

## Decision

The recently played history MUST NOT have a dedicated tab or screen. Instead, the history list MUST be displayed within the `StationsScreen` as a horizontal or vertical scrollable "Recently Played" section.

Specifically:
- This section is only visible when the user is not actively searching (i.e. the search query input is empty) and no country or genre filter is active.
- When a search query is entered or a filter is selected, the "Recently Played" section is replaced by the search results.
- This UI component is driven by the state of `HistoryBloc`.

## Consequences

### Positive
- Simplifies navigation: keeps the tab bar clean and focused on the core features (Discovery and Favorites).
- Promotes engagement: users immediately see their recent stations upon launching the app, providing a fast way to resume listening.
- Avoids routing bloat or complex back-stack management for a secondary history screen.

### Negative
- None.

## Alternatives considered

### Option A — Add a third tab for History
Add a dedicated `HistoryScreen` accessible via a third tab in the bottom navigation. Rejected because it adds unnecessary complexity to the UI layout and navigation back-stack, whereas history is best presented as part of the initial discovery state.

## Documentation impact

- `DESIGN.md` §Expected Screens — clarified that `StationsScreen` hosts the history list.
- `ROADMAP.md` Phase 8 — aligned route configurations.
- `TECHNICAL_SPEC.md` §4 — updated history presentation context.
