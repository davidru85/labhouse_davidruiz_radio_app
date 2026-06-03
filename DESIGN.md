---
name: Labhouse David Radio
colors:
  surface: '#121317'
  surface-dim: '#121317'
  surface-bright: '#38393d'
  surface-container-lowest: '#0d0e11'
  surface-container-low: '#1a1b1f'
  surface-container: '#1f1f21'
  surface-container-high: '#2a2a2c'
  surface-container-highest: '#343538'
  on-surface: '#e4e2e4'
  on-surface-variant: '#c0c6d6'
  inverse-surface: '#e3e2e6'
  inverse-on-surface: '#2f3034'
  outline: '#8e909a'
  outline-variant: '#43474f'
  surface-tint: '#aac7ff'
  primary: '#d6e2ff'
  on-primary: '#0c305f'
  primary-container: '#3e90ff'
  on-primary-container: '#355283'
  inverse-primary: '#415f90'
  secondary: '#c2c1ff'
  on-secondary: '#1800a7'
  secondary-container: '#332dbd'
  on-secondary-container: '#aeadff'
  tertiary: '#ffdea7'
  on-tertiary: '#412d00'
  tertiary-container: '#edc06d'
  on-tertiary-container: '#6d4d00'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d6e3ff'
  primary-fixed-dim: '#aac7ff'
  on-primary-fixed: '#001b3e'
  on-primary-fixed-variant: '#284777'
  secondary-fixed: '#e2dfff'
  secondary-fixed-dim: '#c2c1ff'
  on-secondary-fixed: '#0b006b'
  on-secondary-fixed-variant: '#332dbd'
  tertiary-fixed: '#ffdea7'
  tertiary-fixed-dim: '#edc06d'
  on-tertiary-fixed: '#271900'
  on-tertiary-fixed-variant: '#5e4200'
  background: '#131315'
  on-background: '#e3e2e6'
  surface-variant: '#343538'
  surface-elevated: '#2C2C2E'
  favorite-active: '#FF2D55'
  playback-accent: '#30D158'
  glass-stroke: rgba(255,255,255,0.12)
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 10px
    fontWeight: '500'
    lineHeight: 12px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  gutter: 12px
  card-padding: 16px
  margin-edge: 16px
  player-control-gap: 24px
---

# DESIGN AND UI ARCHITECTURE

## Design Status

Initial visual specifications are now available, synced from the **Labhouse David Radio** project in Google Stitch (exported 2026-05-29). See the [Screen Catalog](#screen-catalog) and [Design Tokens](#design-tokens) sections below.

These specifications cover layout structure, components, colors, typography, spacing, and shape. Final pixel-level visual treatment may still be refined.

The app uses a **#131315 glassmorphic dark theme** with extensive use of `backdrop-filter: blur(20px)` on elevated surfaces.

> Design asset files are synced in the [`stitch/`](stitch/) directory.


---

## Current Constraint

Do not generate code for:

* user interfaces
* layouts
* definitive styling
* final visual components

This restriction remains active until Phase 9 is reached and the user explicitly approves UI implementation.

---

## Current Allowed Scope

Until UI implementation is approved, work may continue only on:


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

> **Liquid Glass evaluated and deferred (ADR-0042).** Apple's Liquid Glass
> material (iOS 26) was considered for the iOS build. It is not adopted in v1:
> Flutter 3.41.6 exposes no native Liquid Glass material, it would require
> raising the iOS floor above the documented `13.0` minimum (ADR-0002), and a
> third-party renderer is not justified (ADR-0018). The iOS build therefore
> uses Cupertino with the shared glassmorphic treatment below (`BackdropFilter`).

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

The Stitch export (branded **"Labhouse David Radio"**) maps onto the shell architecture as follows:

| Stitch screen | Shell target | Notes |
| --- | --- | --- |
| Stations | `StationsScreen` | Hosts the search field + the vertical station list (search has no dedicated screen — see ADR-0014/ADR-0031) |
| Favorites | `FavoritesScreen` | 2-column grid + empty state |
| Full Player (Buffering / Paused) | `FullPlayerScreen` | One screen, multiple playback states |

> **Navigation in the export.** Both the Stations and Favorites screens show a **2-tab** bottom navigation (Stations, Favorites). An explicit code comment in the Stations screen notes that a Settings tab was intentionally removed ("keeping 'Settings' removed"). The Full Player view does NOT contain navigation tabs, as it is a modal/slide-up view. This matches the `UI Shell Architecture` section above, which lists only Stations + Favorites tabs.

---

## Brand & Style

The design system for this product is a sophisticated blend of **Material 3 Dark** principles and a **Glassmorphic** aesthetic, tailored for high-fidelity audio streaming. The brand personality is professional, immersive, and technically precise, designed to feel at home on both Android and iOS through an adaptive architectural approach.

The visual narrative centers on "Atmospheric Depth." By using translucent layers, background blurs, and hairline strokes, the UI creates a sense of spatial hierarchy where content—specifically station artwork—becomes the primary source of visual energy. The experience should evoke the feeling of a modern, premium studio console—reliable and high-performance, yet approachable and fluid.

### Design Principles
- **Atmospheric Immersion:** Use large background blurs and gradients derived from album art to create a deeply personal and moody environment.
- **Precision Glass:** Utilize ultra-thin 1px borders and high-density backdrop blurs (20px-40px) to define structural boundaries without creating visual clutter.
- **Adaptive Native DNA:** While the core theme is unified, the system adapts to the host OS (Material for Android, Cupertino for iOS) to respect user platform expectations while maintaining the brand's signature glassmorphic treatment.

---

## Screen Catalog

Synced from the **Labhouse David Radio** project in Google Stitch. The corresponding visual screen layouts and interactive HTML prototypes are saved inside the [`stitch/`](stitch/) directory as references. 

All screens use a Material 3 dark theme (`Inter` font) and consume shared BLoC state, rendering adaptive Material/Cupertino widgets per the architecture above. A glassmorphic treatment (`backdrop-filter: blur(20px)`, translucent surfaces, hairline `glass-stroke` borders) is used on app bars, the nav bar, and the mini-player.


### 1. Stations

Primary list screen.

- **Design Assets:** [Interactive HTML Prototype (code.html)](stitch/stations/code.html) | [Visual Mockup Image (screen.png)](stitch/stations/screen.png)
- **App bar:** sticky, translucent. `radio` icon + "Labhouse David Radio" wordmark (`headline-md`, bold).
- **Search field:** rounded-`xl`, `surface-container-high` background, leading `search` icon, placeholder "Search stations, genres, or frequencies…". Search is **hosted on this screen** — there is no dedicated search screen. Querying filters the station list below in place (server-side; debounced per ADR-0014, offset-paginated per ADR-0031).
- **Station list:** vertical list of cards (`surface-container`, rounded-2xl, `card-padding`). Each row: 64dp rounded artwork, station name (`body-lg` bold), primary tag + country subtitle (`body-md`, e.g. "Ambient • United Kingdom" - since internet radio stations do not have physical frequencies), a `favorite` toggle, and a circular `primary` play button. Active-favorite hearts use `favorite-active`. Doubles as both the default browse list and the search-results list.

- **Mini-player:** docked above the nav bar (see below).
- **Bottom nav:** Stations (active), Favorites.

### 2. Favorites

Saved stations.

- **Design Assets:** [Interactive HTML Prototype (code.html)](stitch/favorites/code.html) | [Visual Mockup Image (screen.png)](stitch/favorites/screen.png)
- **App bar:** sticky, translucent "Labhouse David Radio" wordmark.
- **Heading:** "Your Favorites" (`headline-lg-mobile`) + a "Search your favorites" field.
- **Populated state:** responsive 2-column grid (`station-grid`, `minmax(160px, 1fr)`, 16px gap). Each card: square artwork, a filled `favorite-active` heart button overlaid top-right (on a translucent blurred chip), station name (`body-lg` bold), and "primary tag • country" subtitle (e.g. "Synthwave • Japan").
- **Empty state:** centered `favorite_border` glyph in a circular surface, "No favorites yet", supporting copy, and an "Explore Stations" `primary` pill button. Toggled via `toggleEmptyState()`.

- **Mini-player:** includes a thin `primary` playback progress bar along its bottom edge.
- **Bottom nav:** Stations, Favorites (active).

### 3. Full Player

Full-screen now-playing view, presented via a bottom-to-top slide (`slideUp`, 0.6s). Reached from the mini-player. This screen is a modal/slide-up view and DOES NOT contain navigation tabs.

- **Design Assets:** [Visual Mockup Image (screen.png)](stitch/full_player/screen.png) (Note: `screen.png` is an invalid 28-byte placeholder and `stitch/full_player/code.html` is absent; design details are limited to this text specification).
- **Background:** atmospheric layered gradient (`primary-container/20` → background) with a large blurred `primary` glow.
- **Top bar:** `expand_more` collapse button (left), centered "Now Playing" label (`label-lg`, uppercase, tracked). The menu button has been removed to allow the title to be perfectly centered.
- **Hero artwork:** up to 320dp square, rounded `2rem`, with `artwork-glow` shadow and an inset `glass-stroke` ring.
- **Identity:** station name (`headline-lg-mobile`/`headline-lg`, bold), primary tag + country in `primary` (e.g. "Ambient • United Kingdom"), and a status line. A `favorite` toggle (`favorite_border`) is located to the right of the station name.
- **Transport:** A central 80dp primary control (`play_arrow`/`pause`). Skip previous and skip next buttons are intentionally omitted as they are not applicable to live radio streams (see ADR-0022). Volume row with `volume_mute`/`volume_up` icons and a custom `primary` slider (`volume-slider`) is present in the Stitch mockup but **MUST NOT be implemented** (refer to ADR-0010, system-only volume is used).
- **Footer actions:** Share, Sleep, Up Next (icon + `label-sm`) are present in the Stitch mockup but **MUST NOT be implemented** as they are out of scope for v1 (refer to ADR-0011 for Sleep timer, ADR-0022 for background controls only, and Share behavior is out of scope).
- **Playback states (same screen):**

  - **Buffering** — center control shows a spinning ring + `hourglass_empty`; status line reads "Buffering…"; artwork dimmed.
  - **Paused / Live** — center control is a `primary` `play_arrow`/`pause` button (`togglePlay()`); status line reads "Live"; artwork at full opacity.

### Shared components

- **Mini-player** — docked ~88px above the bottom, `surface-elevated/95` glass card, rounded-2xl. Shows 48dp artwork, station name, a "Live Now" indicator (pulsing `playback-accent` dot), and a play/pause control; tapping opens the Full Player. On Favorites it also shows a `primary` progress bar.
- **Bottom navigation** — fixed, translucent glass bar (`h-20`, rounded top). Present ONLY on the Stations and Favorites screens. Active tab is a `secondary-container` pill with a filled icon; inactive tabs are dimmed `on-surface-variant`.

---

## Brand Styling Specifications (by Component)

### Buttons
- **Primary Play:** Large circular buttons using the `primary` color with a dark icon.
- **Transport Controls:** In the Full Player, the center play/pause button is 80dp in size.
- **Favorite Toggle:** A heart icon using `outline` when inactive and `favorite-active` (`#FF2D55`) when toggled.

### Mini-Player
- **Structure:** A glass-card docked 88px from the bottom.
- **Visuals:** Displays 48dp rounded artwork and a "Live Now" dot (`playback-accent`) that pulses during active playback.
- **Progress:** On the Favorites screen, a 2px height `primary` progress bar is pinned to the bottom edge of the mini-player card.

### Cards
- **Station List Items:** Horizontal layout with 64dp artwork. Use `glass-stroke` for the border.
- **Favorite Grid Items:** Vertical layout with square artwork. The favorite toggle sits top-right on a blurred, translucent chip.

### Input Fields
- **Search:** `surface-container-high` background, `rounded-xl`, with a leading `search` icon. Placeholder text uses `on-surface-variant`.

### Adaptive Navigation
- **Android:** Use `BottomNavigationBar` with Material 3 pill indicators (`secondary-container`).
- **iOS:** Use `CupertinoTabBar` with translucent glass background and primary-tinted active icons.

---

## Design Tokens

Verbatim from the Stitch Tailwind config in the export. Material 3 dark theme.

### Color palette

| Token | Hex | Usage |
| --- | --- | --- |
| `background` | `#131315` | App canvas background |
| `surface` / `surface-dim` | `#121317` | Screen + base surface |
| `surface-container-lowest` | `#0d0e11` | Lowest elevation |
| `surface-container-low` | `#1a1b1f` | Low elevation |
| `surface-container` | `#1f1f21` | Cards |
| `surface-container-high` | `#2a2a2c` | Search fields, raised |
| `surface-container-highest` / `surface-variant` | `#343538` | Highest elevation / sliders |
| `surface-elevated` | `#2C2C2E` | Mini-player elevated glass card |
| `surface-bright` | `#38393d` | Bright surface |
| `on-background` | `#e3e2e6` | Primary background text |
| `on-surface` | `#e4e2e4` | Primary surface text |
| `on-surface-variant` | `#c0c6d6` | Secondary text |
| `outline` | `#8e909a` | Captions, inactive icons |
| `outline-variant` | `#43474f` | Dividers |
| `primary` | `#d6e2ff` | Accent, play buttons, active state |
| `on-primary` | `#0c305f` | Content on primary |
| `primary-container` | `#3e90ff` | Filled accents, gradients |
| `on-primary-container` | `#355283` | Content on primary container |
| `secondary` | `#c2c1ff` | Secondary accent |
| `secondary-container` | `#332dbd` | Active nav pill |
| `on-secondary-container` | `#aeadff` | Content on secondary container |
| `tertiary` | `#ffdea7` | Tertiary accent (Warm Gold/Peach) |
| `tertiary-container` | `#edc06d` | Tertiary container |
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
| `sm` | 0.25rem (4px) |
| `DEFAULT` | 0.5rem (8px) |
| `md` | 0.75rem (12px) |
| `lg` | 1rem (16px) |
| `xl` | 1.5rem (24px) |
| `full` | 9999px (pill / circle) |

> Note: artwork uses larger ad-hoc radii in the export (cards `rounded-2xl` ≈ 16px; full-player artwork `rounded-[2rem]` ≈ 32px).

### Effects

- **Glass blur:** `backdrop-filter: blur(20px)` on bars/mini-player; `blur(40px)` for the full-player glass panel.
- **Artwork glow:** `box-shadow: 0 20px 60px -15px rgba(62,144,255,0.3)`.
- **Full-player entrance:** `slideUp` keyframe, 0.6s `cubic-bezier(0.16, 1, 0.3, 1)`.

### Iconography

Material Symbols Outlined in the export → map to native `Icons` / `CupertinoIcons` per the iconography constraint. Icons used: `radio`, `search`, `favorite`, `favorite_border`, `play_arrow`, `pause`, `volume_mute`, `volume_up`, `share`, `timer`, `playlist_play`, `expand_more`, `hourglass_empty`.

---

_Last synced from Google Stitch ("Labhouse David Radio" / Flutter Radio App) on 2026-05-29. Raw export: [`stitch_export.txt`](./stitch_export.txt)._
