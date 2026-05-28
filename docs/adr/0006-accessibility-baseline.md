# ADR-0006 — Accessibility baseline

- **Status:** Accepted
- **Date:** 2026-05-28
- **Deciders:** David Ruiz
- **Related:** `DESIGN.md`, `TECHNICAL_SPEC.md`, `VALIDATION_CHECKLIST.md`

## Context

No document committed to an accessibility baseline. Flutter does not flag
accessibility issues at lint time, so the absence of an explicit
commitment translates to accessibility regressions discovered late or
never.

Two pressures favor an explicit baseline:

1. **Regulatory.** The European Accessibility Act (EAA) entered into force
   on 28 June 2025. Apps distributed to users in the EU — including
   Spain — are expected to meet WCAG 2.1 level AA. Even for a technical
   assessment, ignoring accessibility signals poor seniority.
2. **Engineering cost.** Adding `Semantics`, respecting `MediaQuery
   .textScalerOf(context)`, and sizing touch targets correctly is cheap
   at construction time and expensive to retrofit.

A complication: contrast ratios and screen reader walkthroughs cannot
be validated against an architecture-only deliverable. Per `DESIGN.md`,
UI work is blocked until visual specifications arrive. The baseline must
therefore split commitments by phase.

## Decision

RadioApp commits to **WCAG 2.1 level AA** as the accessibility baseline,
delivered in two checkpoints:

**Architectural checkpoint (Phases 1–8, no UI yet):**
- Every interactive widget exposes a meaningful `Semantics` label.
  Icon-only buttons have explicit `tooltip` and `semanticLabel`.
- Layouts do not assume `textScaler == 1.0`. Widget tests pump views
  at `textScaler = 2.0` and assert no overflow.
- Touch targets are at least 48×48 dp on Android and 44×44 pt on iOS,
  enforced by widget tests where applicable.

**Visual checkpoint (Phase 9, UI introduced):**
- Text contrast ratios meet 4.5:1 (normal text) and 3:1 (large text).
- Manual walkthroughs with TalkBack (Android) and VoiceOver (iOS)
  confirm complete and ordered traversal of every screen.
- No focus traps.

Out of scope for this baseline:

- External keyboard navigation (rare on mobile).
- A dedicated high-contrast mode (Flutter has no stable API).
- Audio subtitles / alternative content for streams (radio is audio-only
  by nature).

## Consequences

### Positive
- A reviewer asking about accessibility receives a concrete, phased
  answer rather than a vague gesture.
- Architectural commitments are testable now and gate Phase 9 entry.
- Visual commitments are deferred honestly to when they can actually be
  measured.
- Compatible with EAA expectations without overpromising what cannot
  be validated yet.

### Negative
- Two checkpoints add documentation complexity compared to a single
  blanket commitment.
- A bug in a Phase 1–8 widget that violates touch target sizing must be
  caught by an explicit widget test; Flutter does not warn at lint time.

### Neutral
- The two-checkpoint structure mirrors the existing phase split between
  "no UI" (now) and "UI" (Phase 9), so it does not introduce a new
  conceptual axis.

## Alternatives considered

### Option A — No explicit commitment
Rejected. Cheap now, costly later, and a negative signal in a senior
assessment.

### Option B — Architectural only (Semantics + touch targets)
Rejected. Ignores contrast and text scaling, which are also testable
at the architecture layer (text scaling) or addressable in Phase 9
(contrast).

### Option C — Full WCAG 2.1 AA commitment without phase split
Rejected. Cannot be validated for contrast or screen-reader UX until
UI exists. Committing to it without a validation plan is paperwork.

## Documentation impact

- `TECHNICAL_SPEC.md` — add a new "Accessibility Baseline" section
  describing the two-checkpoint commitment and the explicit out-of-scope
  items.
- `DESIGN.md` §Adaptive Design Requirements — reference the baseline.
- `VALIDATION_CHECKLIST.md` — add a new "Accessibility" section with
  architectural checks (verifiable now) and visual checks (deferred to
  Phase 9).
- `ROADMAP.md` Phase 9 — add a sub-task to run the visual accessibility
  checklist (contrast, TalkBack/VoiceOver walkthrough, focus
  traversal).

## Follow-ups

- A future ADR may add automatic detection of OS accessibility settings
  (large text, bold text, reduce motion) to drive UI behavior. Until
  then, the app respects system text scaling but does not branch
  behavior on other settings.
