# ADR-0041 — Routing shell via `StatefulShellRoute.indexedStack`

- **Status:** Accepted
- **Date:** 2026-06-03
- **Deciders:** David Ruiz
- **Related:** ADR-0005 (adaptive UI), ADR-0009 (routing), `ROADMAP.md`
  §Phase 9 (tasks 9.3–9.4), `DESIGN.md`, sub-task 8.2/8.3

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

Phase 8 wired routing with a `go_router` `ShellRoute` wrapping the
`/stations` and `/favorites` tabs in a minimal passthrough `AppShell`,
with `/player` as a top-level route outside the shell (sub-task 8.2). A
`ShellRoute` renders a single `child` and swaps it on tab change, so the
inactive tab's widget subtree is torn down and rebuilt on every switch.

`ROADMAP.md` §Phase 9 requires an `AppShell` built on an `IndexedStack`
(task 9.3) and the preservation of scroll state across tabs (task 9.4).
A plain `ShellRoute` child-swap cannot satisfy either: the destroyed
subtree loses its scroll offset and any in-flight tab-local state.

A hand-rolled `IndexedStack` inside `AppShell` was considered, but it
would force the shell to own tab indexing and would not retain a separate
`Navigator` (and therefore navigation history) per tab.

## Decision

The routing shell is built with **`StatefulShellRoute.indexedStack`**.
`go_router` owns a single `IndexedStack` hosting one live `Navigator` per
`StatefulShellBranch` (`/stations`, `/favorites`), and the shell builder
hands the resulting `navigationShell` to `AppShell` as its `child`. This
preserves both scroll state and per-tab navigation history across tab
switches.

Both branches set **`preload: true`** so the `IndexedStack` mounts every
tab from the first frame rather than lazily on first visit. For the
current two-tab shell this guarantees both tabs (and their scroll state)
are alive immediately and keeps the keep-alive behaviour deterministic.

`AppShell` keeps the optional `ShellScopeBuilder` seam introduced in
sub-task 8.3: it still wraps the shell content so shell-scoped BLoCs
(`StationsBloc`, `FavoritesBloc`) are shared across tabs and disposed when
the shell leaves the tree. The root `RadioPlayerBloc` is provided by
`MyApp` **above** the router so both the shell and the out-of-shell
`/player` route share one instance.

The existing route URLs (`/stations`, `/favorites`, `/player`) are
unchanged.

## Consequences

### Positive
- Scroll state and per-tab navigation history survive tab switches
  (satisfies tasks 9.3–9.4).
- `go_router` owns the `IndexedStack` and tab indexing; `AppShell` stays a
  thin host for the shell `Scaffold` (and, later, the bottom nav + mini
  player).
- Route URLs and the sub-task 8.3 scope/disposal mechanism are preserved.

### Negative
- `preload: true` builds every branch up front, so each tab's initial
  build cost is paid at shell start rather than on first visit. Acceptable
  for the current two-tab shell; revisit if the shell grows many tabs.

### Neutral
- The migration restructures the router (`ShellRoute` →
  `StatefulShellRoute.indexedStack` with `StatefulShellBranch`es) but does
  not change the public route map.

## Alternatives considered

### Option A — Keep `ShellRoute` and swap children
Rejected. The inactive tab subtree is destroyed on every switch, losing
scroll state and tab-local navigation, which directly violates tasks
9.3–9.4.

### Option B — Hand-rolled `IndexedStack` inside `AppShell`
Rejected. It keeps widgets alive but forces `AppShell` to own tab indexing
and does not retain a separate `Navigator` per tab, so per-tab navigation
history is lost. `StatefulShellRoute.indexedStack` provides both for free.

### Option C — Lazy branches (`preload: false`, the default)
Rejected for this shell. Lazy branches are only built on first visit, so
the keep-alive assertions and immediate cross-tab state would not hold
until each tab had been opened once. Eager preload is cheap for two tabs.

## Documentation impact

- `ROADMAP.md` §Phase 9 — check off "Implement `AppShell` with an
  `IndexedStack`".
- `MEMORY.md` — record this ADR in the decision log and advance the
  progress tracker.
- `docs/adr/README.md` — add the index entry.

## Follow-ups

- Task 9.4 adds an explicit scroll-offset-preservation test over this
  shell.
- Tasks 9.5–9.6 add the `MiniPlayerWidget` and its visibility animation
  inside `AppShell`.
