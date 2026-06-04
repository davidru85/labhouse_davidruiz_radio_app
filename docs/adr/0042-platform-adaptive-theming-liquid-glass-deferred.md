# ADR-0042 — Platform-adaptive theming: Material (Android) + Cupertino (iOS), Liquid Glass deferred

- **Status:** Accepted
- **Date:** 2026-06-04
- **Deciders:** David Ruiz
- **Related:** ADR-0001, ADR-0002, ADR-0018, `DESIGN.md` §Adaptive Design Requirements, `DESIGN.md` §Brand & Style

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

The `feature/ui-visual-polish` branch applies the finished visual design.
During that work the question was raised of adopting Apple's **Liquid Glass**
design language (introduced for iOS 26) for the iOS build, while keeping
**Material Design** on Android.

`DESIGN.md` already commits to a platform-adaptive UI: §Adaptive Design
Requirements states "Android uses Material Design. iOS uses Cupertino", with
a unified presentation layer and a shared glassmorphic brand treatment
(§Brand & Style). Before fixing the visual-polish slices, the Liquid Glass
option had to be evaluated against the project's existing constraints:

- **No native Flutter support.** The pinned toolchain is Flutter 3.41.6
  (stable). Its `cupertino` library exposes no Liquid Glass material — only
  `CupertinoButton.tinted` and the general-purpose `BackdropFilter`. The real
  system material (with live lensing/refraction) is not available through the
  Flutter SDK at this version.
- **OS-version floor.** Liquid Glass is an iOS 26+ system effect, but the app
  targets iOS `13.0` minimum (ADR-0002). Adopting the real material would mean
  either raising the floor (dropping supported devices — an ADR-0002 change) or
  maintaining a separate iOS 13–25 fallback path.
- **Dependency cost.** Approximating Liquid Glass with a third-party renderer
  would require amending the consolidated dependency allowlist (ADR-0018) and
  taking on the maintenance/risk of an unvetted package.

## Decision

RadioApp uses **platform-adaptive theming**: **Material Design on Android** and
**Cupertino on iOS**, with the shared glassmorphic brand treatment from
`DESIGN.md` rendered via the SDK's `BackdropFilter` (translucent surfaces,
hairline `glass-stroke` borders) on both platforms. This reaffirms the existing
`DESIGN.md` adaptive decision.

Adopting Apple's **Liquid Glass** material is **deferred**. It is not pursued
in this branch because the pinned Flutter SDK provides no native support, it
would require raising the iOS floor above the documented minimum, and a
third-party approximation is not justified for v1.

## Consequences

### Positive
- No change to the iOS deployment floor (ADR-0002) and no new dependency
  (ADR-0018); the work stays within the existing toolchain and allowlist.
- The brand's glassmorphic look is delivered uniformly on both platforms with
  first-party widgets, keeping the presentation layer shared.
- Aligns the implementation with the already-documented `DESIGN.md` adaptive
  decision instead of diverging from it.

### Negative
- The iOS build does not use Apple's signature Liquid Glass material; on iOS 26
  devices the app looks "Liquid-Glass-inspired" (Cupertino + blur) rather than
  using the true system effect.

### Neutral
- The decision is revisitable: once a stable Flutter release exposes Liquid
  Glass natively and the iOS floor allows it, a follow-up ADR can supersede
  this one.

## Alternatives considered

### Option A — Real Liquid Glass on iOS
Rejected for v1. Requires iOS 26+ (raising the ADR-0002 floor from 13.0 and
dropping older devices) and native SDK support that Flutter 3.41.6 does not
provide.

### Option B — Third-party Liquid Glass renderer
Rejected for v1. Would require amending the ADR-0018 dependency allowlist and
accepting the maintenance and rendering-fidelity risk of an unvetted package,
which is not warranted for the assessment scope.

## Documentation impact

- `DESIGN.md` §Adaptive Design Requirements / §Brand & Style — add a note that
  Liquid Glass was evaluated and deferred per this ADR, and that the iOS build
  uses Cupertino with the shared glassmorphic treatment.
- `docs/adr/README.md` — add the index row for ADR-0042.

## Follow-ups

- None. A future ADR MAY revisit Liquid Glass when Flutter ships native support
  and the iOS floor permits it.
