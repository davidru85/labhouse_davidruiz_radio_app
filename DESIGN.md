# DESIGN AND UI ARCHITECTURE

## Design Status

Initial visual specifications are now available, synced from the **Flutter Radio
App** project in Google Stitch (exported 2026-05-29). See the
[Screen Catalog](#screen-catalog) and [Design Tokens](#design-tokens) sections
below.

These specifications cover layout structure, components, colors, typography,
spacing, and shape. Final pixel-level visual treatment may still be refined.

> Source of truth for the raw export: [`stitch_export.txt`](./stitch_export.txt).

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
* `StationsScreen` (which includes a "Recently Played" section when no search query or filter is active, per ADR-0029)
* `FavoritesScreen`
* `FullPlayerScreen`

### Mapping to Stitch screens

The Stitch export (branded **"SonicStream"**) maps onto the shell architecture
as follows:

| Stitch screen | Shell target | Notes |
| --- | --- | --- |
| Stations | `StationsScreen` | Hosts the search field + the vertical station list (search has no dedicated screen — see ADR-0014/ADR-0031) |
| Favorites | `FavoritesScreen` | 2-column grid + empty state |
| Full Player (Buffering / Paused) | `FullPlayerScreen` | One screen, multiple playback states |

> **Navigation in the export.** Both the Stations and Favorites screens show a
> **2-tab** bottom navigation (Stations, Favorites). An explicit code comment in
> the Stations screen notes that a Settings tab was intentionally removed
> ("keeping 'Settings' removed"). This matches the `UI Shell Architecture`
> section above, which lists only Stations + Favorites tabs.

---

## Screen Catalog

Synced from the **SonicStream** project in Google Stitch (exported 2026-05-29,
raw HTML in [`stitch_export.txt`](./stitch_export.txt)). All screens use a
Material 3 dark theme (`Inter` font) and consume shared BLoC state, rendering
adaptive Material/Cupertino widgets per the architecture above. A glassmorphic
treatment (`backdrop-filter: blur`, translucent surfaces, hairline
`glass-stroke` borders) is used on app bars, the nav bar, and the mini-player.

### 1. Stations

Primary list screen.

- **App bar:** sticky, translucent. `radio` icon + "SonicStream" wordmark (`headline-md`, bold).
- **Search field:** rounded-`xl`, `surface-container-high` background, leading `search` icon, placeholder "Search stations, genres, or frequencies…". Search is **hosted on this screen** — there is no dedicated search screen. Querying filters the station list below in place (server-side; debounced per ADR-0014, offset-paginated per ADR-0031).
- **Station list:** vertical list of cards (`surface-container`, rounded-2xl, `card-padding`). Each row: 64dp rounded artwork, station name (`body-lg` bold), frequency + genre subtitle (`body-md`, e.g. "101.9 MHz • Ambient"), a `favorite` toggle, and a circular `primary` play button. Active-favorite hearts use `favorite-active`. Doubles as both the default browse list and the search-results list.
- **Mini-player:** docked above the nav bar (see below).
- **Bottom nav:** Stations (active), Favorites.

### 2. Favorites

Saved stations.

- **App bar:** sticky, translucent "SonicStream" wordmark.
- **Heading:** "Your Favorites" (`headline-lg-mobile`) + a "Search your favorites" field.
- **Populated state:** responsive 2-column grid (`station-grid`, `minmax(160px, 1fr)`, 16px gap). Each card: square artwork, a filled `favorite-active` heart button overlaid top-right (on a translucent blurred chip), station name (`body-lg` bold), and "genre • city" subtitle (e.g. "Synthwave • Tokyo").
- **Empty state:** centered `favorite_border` glyph in a circular surface, "No favorites yet", supporting copy, and an "Explore Stations" `primary` pill button. Toggled via `toggleEmptyState()`.
- **Mini-player:** includes a thin `primary` playback progress bar along its bottom edge.
- **Bottom nav:** Stations, Favorites (active).

### 3. Full Player

Full-screen now-playing view, presented via a bottom-to-top slide
(`slideUp`, 0.6s). Reached from the mini-player.

- **Background:** atmospheric layered gradient (`primary-container/20` → background) with a large blurred `primary` glow.
- **Top bar:** `expand_more` collapse button (left), "Now Playing" label (`label-lg`, uppercase, tracked).
- **Hero artwork:** up to 320dp square, rounded `2rem`, with `artwork-glow` shadow and an inset `glass-stroke` ring.
- **Identity:** station name (`headline-lg-mobile`/`headline-lg`, bold), frequency + city in `primary` (e.g. "104.2 FM — London"), and a status line. A `favorite` toggle sits to the right.
- **Transport:** `skip_previous`, a large 80dp center control, `skip_next`. Volume row with `volume_mute`/`volume_up` icons and a custom `primary` slider (`volume-slider`).
- **Footer actions:** Share, Sleep, Up Next (icon + `label-sm`).
- **Playback states (same screen):**
  - **Buffering** — center control shows a spinning ring + `hourglass_empty`; status line reads "Buffering…"; artwork dimmed.
  - **Paused / Live** — center control is a `primary` `play_arrow`/`pause` button (`togglePlay()`); status line reads "Live"; artwork at full opacity.

### Shared components

- **Mini-player** — docked ~88px above the bottom, `surface-elevated/95` glass card, rounded-2xl. Shows 48dp artwork, station name, a "Live Now" indicator (pulsing `playback-accent` dot), and a play/pause control; tapping opens the Full Player. On Favorites it also shows a `primary` progress bar.
- **Bottom navigation** — fixed, translucent glass bar (`h-20`, rounded top). Active tab is a `secondary-container` pill with a filled icon; inactive tabs are dimmed `on-surface-variant`.

---

## Design Tokens

Verbatim from the Stitch Tailwind config in the export. Material 3 dark theme.

### Color palette

| Token | Hex | Usage |
| --- | --- | --- |
| `background` / `surface` / `surface-dim` | `#131315` | Screen + base surface |
| `surface-container-lowest` | `#0e0e10` | Lowest elevation |
| `surface-container-low` | `#1b1b1d` | Low elevation |
| `surface-container` | `#1f1f21` | Cards |
| `surface-container-high` | `#2a2a2c` | Search fields, raised |
| `surface-container-highest` / `surface-variant` | `#353437` | Highest elevation / sliders |
| `surface-elevated` | `#2C2C2E` | Mini-player |
| `surface-bright` | `#39393b` | Bright surface |
| `on-background` / `on-surface` | `#e4e2e4` | Primary text |
| `on-surface-variant` | `#c0c6d6` | Secondary text |
| `outline` | `#8b91a0` | Captions, inactive icons |
| `outline-variant` | `#414754` | Dividers |
| `primary` | `#aac7ff` | Accent, play buttons, active state |
| `on-primary` | `#003064` | Content on primary |
| `primary-container` | `#3e90ff` | Filled accents, gradients |
| `on-primary-container` | `#002957` | Content on primary container |
| `secondary` | `#c2c1ff` | Secondary accent |
| `secondary-container` | `#3630bf` | Active nav pill |
| `on-secondary-container` | `#b1b1ff` | Content on secondary container |
| `tertiary` / `tertiary-container` | `#ffb2b7` / `#ff506c` | Tertiary accents |
| `error` / `error-container` | `#ffb4ab` / `#93000a` | Errors |
| `favorite-active` | `#FF2D55` | Active favorite heart |
| `playback-accent` | `#30D158` | "Live" / playback indicator |
| `glass-stroke` | `rgba(255,255,255,0.12)` | Hairline glass borders |

### Typography

Font family: **Inter** (`400/500/600/700`).

| Token | Size / line-height | Weight | Tracking |
| --- | --- | --- | --- |
| `label-sm` | 10 / 12 px | 500 | — |
| `label-lg` | 12 / 16 px | 600 | +0.05em |
| `body-md` | 14 / 20 px | 400 | — |
| `body-lg` | 16 / 24 px | 400 | — |
| `headline-md` | 24 / 32 px | 600 | −0.01em |
| `headline-lg-mobile` | 28 / 34 px | 700 | — |
| `headline-lg` | 32 / 40 px | 700 | −0.02em |

### Spacing

| Token | Value |
| --- | --- |
| `base` | 8px |
| `gutter` | 12px |
| `card-padding` | 16px |
| `margin-edge` | 16px |
| `player-control-gap` | 24px |

### Shape (border radius)

| Token | Value |
| --- | --- |
| `DEFAULT` | 0.25rem (4px) |
| `lg` | 0.5rem (8px) |
| `xl` | 0.75rem (12px) |
| `full` | 9999px (pill / circle) |

> Note: artwork uses larger ad-hoc radii in the export (cards `rounded-2xl` ≈ 16px;
> full-player artwork `rounded-[2rem]` ≈ 32px).

### Effects

- **Glass blur:** `backdrop-filter: blur(20px)` on bars/mini-player; `blur(40px)` for the full-player glass panel.
- **Artwork glow:** `box-shadow: 0 20px 60px -15px rgba(62,144,255,0.3)`.
- **Full-player entrance:** `slideUp` keyframe, 0.6s `cubic-bezier(0.16, 1, 0.3, 1)`.

### Iconography

Material Symbols Outlined in the export → map to native `Icons` / `CupertinoIcons`
per the iconography constraint. Icons used: `radio`, `search`, `favorite`,
`favorite_border`, `play_arrow`, `pause`, `skip_previous`, `skip_next`,
`volume_mute`, `volume_up`, `share`, `timer`, `playlist_play`,
`expand_more`, `hourglass_empty`.

---

_Last synced from Google Stitch ("SonicStream" / Flutter Radio App) on 2026-05-29. Raw export: [`stitch_export.txt`](./stitch_export.txt)._
