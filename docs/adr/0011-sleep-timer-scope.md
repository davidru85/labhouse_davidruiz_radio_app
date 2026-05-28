# ADR-0011 — Sleep timer scope

- **Status:** Accepted
- **Date:** 2026-05-28
- **Deciders:** David Ruiz
- **Related:** `TECHNICAL_SPEC.md` §4, `TODO.md`

## Context

A sleep timer — automatically pausing playback after a user-configured
duration — is a common feature in radio and audio applications
(Spotify, TuneIn, BBC Sounds, Apple Podcasts). The original
specification does not mention it; the omission is implicit rather
than deliberate. The polish phase requires the decision to be made
explicit before development starts.

A sleep timer is straightforward to implement on top of the existing
playback architecture:

- Extend `RadioPlayerBloc` with `SleepTimerStarted(Duration)`,
  `SleepTimerCancelled` and a periodic tick event.
- The timer triggers a `StopRequested` on expiry. Cancelling playback
  manually also cancels the timer.
- The UI in Phase 9 would add a control in `FullPlayerScreen` with
  preset durations (15 / 30 / 60 / 90 min, custom).

The cost is approximately one to two days of work, fully isolated to
the player slice.

The competencies the assessment showcases — Clean Architecture,
mirror failover, Hive persistence, TDD discipline, BLoC modelling —
are already covered by the in-scope features. A sleep timer adds
product surface without adding technical dimensions to the
demonstration.

## Decision

Sleep timer is **out of scope for v1**. It is tracked in `TODO.md`
under "Playback features" as a deliberate future improvement, not as
unfinished work.

The architectural boundary that would host the feature — the
`RadioPlayerBloc` and the `AudioPlayerRepository` — is designed in a
way that introducing the sleep timer later is additive: new events,
new repository interactions, no changes to existing contracts.

## Consequences

### Positive
- MVP scope stays focused on the core technical competencies the
  assessment is meant to demonstrate.
- `RadioPlayerBloc` stays narrowly scoped to playback lifecycle.
- `FullPlayerScreen` design (deferred to Phase 9) has fewer affordances
  to accommodate.

### Negative
- The application lacks a feature that comparable products offer.
- Adding it later requires a follow-up PR plus visual specifications
  for the timer control.

### Neutral
- Future addition is fully reversible by a follow-up ADR that
  introduces the timer as additive behaviour.

## Alternatives considered

### Option B — Include sleep timer in v1
Rejected. Adds product surface without adding new architectural
dimensions to demonstrate; lengthens the development cycle without
strengthening the assessment.

### Option C — Document as "architecturally prepared" without code
Rejected. A claim of preparation that is not validated by working
code adds documentation noise without operational value.

## Documentation impact

- `TODO.md` — add the sleep timer under "Playback features", linking
  back to this ADR.
- No removals from the rest of the specification (the feature was
  never documented).

## Follow-ups

- A future ADR may bring the sleep timer back into scope. The change
  would be additive: new events, new use case, no breaking changes.
