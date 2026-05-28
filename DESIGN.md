# DESIGN AND UI ARCHITECTURE

## Design Status

Final visual and aesthetic details are pending.

No specialized visual specifications have been provided yet.

---

## Current Constraint

Do not generate code for:

* user interfaces
* layouts
* definitive styling
* final visual components

This restriction remains active until detailed visual specifications are provided.

---

## Current Allowed Scope

Until design specifications are provided, work may continue only on:

1. Core architecture.
2. Contracts.
3. Business logic.
4. Tests.
5. API integration.
6. Non-visual routing and shell contracts where required by the approved phase.

---

## Adaptive Design Requirements

When UI work is approved, the UI must be adaptive:

* Android uses Material Design.
* iOS uses Cupertino.

Presentation logic must remain unified and shared.

Screens must use adaptive components or visual factories to render the appropriate widgets based on the operating system.

All platforms must consume the same BLoC states.

---

## Iconography

Use native icon catalogs:

* `Icons`
* `CupertinoIcons`

Do not introduce third-party icon packages.

---

## UI Shell Architecture

The foundational interface layout, independent of final styling, will use a single root `Scaffold`.

The scaffold body contains an `IndexedStack`.

Required shell behavior:

* Use `IndexedStack` to preserve scroll state and navigation history for the Stations and Favorites tabs.
* Add a `MiniPlayerWidget` driven by `RadioPlayerBloc`.
* The mini-player uses animated vertical visibility.
* The mini-player is hidden during the `idle` state.
* Tapping the mini-player navigates to `FullPlayerScreen`.
* Full player navigation uses a bottom-to-top vertical `SlideTransition`.
* Use a platform-appropriate tab bar:
  * `BottomNavigationBar` for Material.
  * `CupertinoTabBar` for Cupertino.

---

## Expected Screens

When UI work is approved, the app shell will define:

* `AppShell`
* `StationsScreen`
* `FavoritesScreen`
* `FullPlayerScreen`

Final appearance, layout, spacing, colors, typography, and definitive visual treatment remain pending.
