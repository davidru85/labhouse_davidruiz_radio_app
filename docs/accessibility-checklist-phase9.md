# Phase 9 — Visual accessibility checklist (ADR-0006, sub-task 9.13)

ADR-0006 splits the WCAG 2.1 AA commitment into an architectural checkpoint
(Phases 1–8) and a **visual checkpoint (Phase 9)**. This file records the
visual-checkpoint verification for the Phase 9 UI.

## Automated coverage (enforced by the test suite)

| Check | Status | Evidence |
|---|---|---|
| Every interactive control exposes a meaningful `Semantics` label | ✅ Done | `mini_player.dart` ("Open player"), `full_player_screen.dart` transport + collapse (`full_player_a11y_test.dart`), `_FavoriteToggle` (favorites) |
| Icon-only buttons carry a tooltip + screen-reader label | ✅ Done | `_ControlButton` (`Semantics(label) + Tooltip`), `_FavoriteToggle` |
| Touch targets ≥ 48dp (Android) / 44pt (iOS) | ✅ Done | mini-player `kMinInteractiveDimension` guard (`full_player_navigation_test.dart`); `IconButton`/`CupertinoButton` minimums |
| Layouts do not assume `textScaler == 1.0` (no overflow at 2.0×) | ✅ Done | `full_player_a11y_test.dart`, `stations_screen_test.dart` (`takeException() isNull` at 2.0×) |
| Adaptive Material/Cupertino rendering per screen | ✅ Done | `PlatformBuilder` on Stations/Favorites/FullPlayer (TECHNICAL_SPEC §9) |

## Contrast ratios

The app currently renders on the stock **Material 3 light `ColorScheme`**
(no custom palette applied yet — the DESIGN.md dark glassmorphic tokens are a
later visual pass). M3 default schemes are generated to meet WCAG AA contrast
for on-* color pairs. The only ad-hoc color in use is `favorite-active`
(`#FF2D55`) for the favorite heart, used as an icon tint on a light surface.

- [ ] **Manual:** re-verify text/background contrast (≥ 4.5:1 normal, ≥ 3:1
  large) once the DESIGN.md dark theme + glassmorphic surfaces are applied,
  since translucency changes effective contrast.

## Manual device walkthrough — pending

The following require a real device / screen reader and have **not** been
run yet (tracked as the remaining 9.13 action before release):

- [ ] **TalkBack (Android):** complete, ordered traversal of Stations,
  Favorites, mini-player, Full Player, offline banner; every control announces
  its label; no unlabeled nodes.
- [ ] **VoiceOver (iOS):** same traversal on iOS.
- [ ] **Focus traversal:** no focus traps; the Full Player collapse returns
  focus to the mini-player; tab switches move focus to the active branch.

## Out of scope (per ADR-0006)

External keyboard navigation, a dedicated high-contrast mode, and audio
subtitles — deferred (see `TODO.md` §Accessibility).
