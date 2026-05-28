# ADR-0004 — Screen orientation

- **Status:** Accepted
- **Date:** 2026-05-28
- **Deciders:** David Ruiz
- **Related:** ADR-0001, `DESIGN.md` §UI Shell Architecture, `ARCHITECTURE.md` §Native Platform Configuration

## Context

`DESIGN.md` describes the UI shell as a single root `Scaffold` with an
`IndexedStack`, a `MiniPlayerWidget`, and a `FullPlayerScreen` reached via
a bottom-to-top slide transition. None of this implies an orientation, and
no document fixes one. Flutter's default behavior allows every orientation
on every device.

For a radio app, allowing every orientation implies:

- Designing and testing landscape layouts for the `MiniPlayer`, the
  `FullPlayer`, station lists, and filter UIs.
- Handling tablet split views and rotation-during-playback edge cases.
- Doubling the screenshot matrix for any visual regression testing.

Reference apps in the category (Spotify, TuneIn, iHeartRadio) are
portrait-only on phones.

## Decision

RadioApp is **portrait-only** on both phones and tablets, on both Android
and iOS. The lock is enforced at the native manifest level:

- **Android:** `android:screenOrientation="portrait"` on the main
  `<activity>` in `AndroidManifest.xml`.
- **iOS:** `UISupportedInterfaceOrientations` in `Info.plist` is limited
  to `UIInterfaceOrientationPortrait`.
- **Dart (optional reinforcement):** `SystemChrome.setPreferredOrientations`
  called in `main.dart` before `runApp`. Manifests remain the source of
  truth.

## Consequences

### Positive
- The UI surface to design, build, and test is halved.
- The `MiniPlayer` / `FullPlayer` / `BottomNavigationBar` layouts in
  `DESIGN.md` can be designed against a single aspect ratio per device
  size.
- Phase 9 visual regression suites have a single orientation matrix.
- Aligns with industry-standard behavior for the radio app category.

### Negative
- On tablets and iPads, the application is "phone UI scaled up". This
  is consistent with most radio apps but visibly less polished than a
  proper tablet layout.
- Users with landscape-only stands or accessibility mounts may find the
  app unusable in those configurations.

### Neutral
- Locking orientation at the manifest level overrides any future code
  changes that try to enable rotation. This is the intended behavior
  and matches the documented decision.

## Alternatives considered

### Option B — Portrait on phones, all orientations on tablets
Rejected. Requires breakpoint detection logic and doubles the design
surface specifically for tablet, which is not the primary target.

### Option C — All orientations always
Rejected. Multiplies design and testing effort with no proven user
demand for landscape radio listening.

## Documentation impact

- `DESIGN.md` — add a new section "Orientation" stating the portrait-only
  commitment.
- `ARCHITECTURE.md` §Native Platform Configuration — list the manifest
  entries for Android and iOS.
- `VALIDATION_CHECKLIST.md` — add a check that orientation lock is
  configured at the manifest level.
- `ROADMAP.md` Phase 1 — include orientation lock as a native
  configuration sub-task.

## Follow-ups

- None.
