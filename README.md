# RadioApp

A production-grade online radio streaming application built with
Flutter, backed exclusively by the
[Radio Browser](https://api.radio-browser.info/) public community-
maintained API.

> **Status:** Pre-implementation polish phase. A basic Flutter project
> has been scaffolded, but is currently non-conforming and is being
> cleaned up and configured in Phase 1. The repository contains the
> specification suite, ADRs, and operational documents that the
> implementation will be built from. See `MEMORY.md` for the live
> phase tracker.

---

## Demo

A screen recording of the app running on a device (dark theme, glassmorphic
chrome, station artwork, mini-player and full player) is available at
[`extras/recording.mov`](extras/recording.mov) — download the file to play it.

---

## Quick links

- [`extras/recording.mov`](extras/recording.mov) — screen recording of the app in action.
- [`CONTEXT.md`](CONTEXT.md) — what we are building and why.
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — Clean Architecture layout,
  repository contracts, native config.
- [`ROADMAP.md`](ROADMAP.md) — implementation phases.
- [`docs/adr/README.md`](docs/adr/README.md) — index of accepted
  architectural decisions.
- [`TODO.md`](TODO.md) — deliberately deferred features.
- [`MEMORY.md`](MEMORY.md) — current phase, decision log, open risks.

---

## Reading order

### For an assessment reviewer

1. `CONTEXT.md` — project intent and constraints.
2. `MEMORY.md` §"Decision Log" — at-a-glance index of every accepted
   decision.
3. `docs/adr/` — full reasoning for each decision, including
   alternatives considered.
4. `ROADMAP.md` — the implementation plan.

### For a new contributor

1. `CONVENTIONS.md` — documentation conventions (RFC 2119 keywords).
2. `AGENTS.md` — execution protocol and TDD micro-cycle.
3. `CONTEXT.md`, `ARCHITECTURE.md`, `TECHNICAL_SPEC.md` — the
   contractual surface.
4. `MEMORY.md` for the live state, then `ROADMAP.md` for the next
   tasks.

### For an AI agent resuming a session

1. `MEMORY.md` — current phase, decision log, open risks, pending questions.
2. `CONTEXT.md` — project intent and key constraints.
3. `CONVENTIONS.md` — normative keyword convention used in contractual documents.
4. `docs/adr/README.md` — index of accepted ADRs.
5. Any ADR directly referenced by the user's request or by the current task in `MEMORY.md`.
6. The contractual document(s) relevant to the current task (`ARCHITECTURE.md`, `TECHNICAL_SPEC.md`, `API_SPEC.md`, or `VALIDATION_CHECKLIST.md`).

---

## Document map

| Document                                                              | Category             | Purpose                                                                 |
|-----------------------------------------------------------------------|----------------------|-------------------------------------------------------------------------|
| [`CONTEXT.md`](CONTEXT.md)                                            | Narrative            | Project intent, scope, key constraints (TL;DR with links).              |
| [`CONVENTIONS.md`](CONVENTIONS.md)                                    | Operational          | RFC 2119 / BCP 14 / RFC 8174 keyword convention.                        |
| [`ARCHITECTURE.md`](ARCHITECTURE.md)                                  | Contractual          | Folder structure, dependency rule, repository contracts, native config. |
| [`TECHNICAL_SPEC.md`](TECHNICAL_SPEC.md)                              | Contractual          | Tech stack, dependency list, BLoC table, configuration, CI/CD.          |
| [`API_SPEC.md`](API_SPEC.md)                                          | Contractual          | Radio Browser integration, mirror failover, domain modelling.           |
| [`VALIDATION_CHECKLIST.md`](VALIDATION_CHECKLIST.md)                  | Contractual          | Per-domain verification checks gating phase advancement.                |
| [`DESIGN.md`](DESIGN.md)                                              | Narrative            | UI shell architecture and adaptive design (Stitch specs available, but UI implementation blocked).|
| [`ROADMAP.md`](ROADMAP.md)                                            | Operational          | Phase-by-phase implementation plan.                                     |
| [`TESTING_STRATEGY.md`](TESTING_STRATEGY.md)                          | Operational          | What to test at each layer; BLoC test matrix.                           |
| [`AGENTS.md`](AGENTS.md)                                              | Operational          | Execution protocol; mandatory TDD micro-cycle.                          |
| [`MEMORY.md`](MEMORY.md)                                              | Live state           | Decision log index, progress tracker, open risks, pending questions.    |
| [`TODO.md`](TODO.md)                                                  | Live state           | Deliberately deferred features, grouped by domain.                      |
| [`GLOSSARY.md`](GLOSSARY.md)                                          | Reference            | Domain-specific terms (mirror, Icy, HLS, etc.).                         |
| [`docs/adr/`](docs/adr/)                                              | Contractual (per ADR)| Immutable architectural decision records.                               |
| `README.md` (this file)                                               | Entrypoint           | Reading order, document map, project summary.                           |

---

## Methodology

- **Clean Architecture** — strict layer separation (`domain` is pure;
  presentation depends on use cases; data implements domain contracts).
- **BLoC** — exclusive state management (Riverpod and Provider are
  explicitly prohibited).
- **TDD** — every sub-task follows Red / Green / Refactor with user
  review checkpoints before each commit (see `AGENTS.md`).
- **ADR-driven decisions** — every architectural or product decision
  is captured as an immutable Architecture Decision Record under
  `docs/adr/`.
- **GitHub Flow** — protected `main`, short-lived feature branches,
  Conventional Commits, signed commits, squash merges (per
  ADR-0009).

---

## Decision summary

The polish phase produced **32 accepted ADRs** and **6 inherited
foundational decisions**. The full index and links live in
`MEMORY.md` §"Decision Log" and `docs/adr/README.md`. Highlights:

- **Platforms:** Android + iOS only (no web, no desktop).
- **Min OS:** Android `minSdk=23`, `target/compileSdk=34`; iOS 13.
- **Identifiers:** `com.labhouse.davidruizassessment.radioapp`,
  Dart package `radio_app`.
- **UI:** portrait-only, adaptive Material / Cupertino.
- **i18n:** English only at launch, scaffold ready for additions.
- **Accessibility:** WCAG 2.1 AA in two checkpoints (architectural
  now, visual at Phase 9).
- **Config:** single build flavor; `config/app.json` injected via
  `--dart-define-from-file`; no `.env` files.
- **CI/CD:** GitHub Actions (`analyze`, `test`, `build-android`,
  `build-ios`) + lefthook + branch protection on `main` (signed
  commits, squash only).
- **Player:** explicit `PlayerBufferingState`; Icy now-playing
  metadata surfaced via `NowPlayingInfo`; system volume only (no
  in-app slider).
- **Network:** mirror failover with persisted last-known mirror in
  Hive `app_settings`; offline behaviour handled by
  `ConnectivityBloc` with global banner.
- **Search:** debounce 350 ms, minimum 3 characters, data-layer
  cancellation of in-flight requests.
- **Analytics:** provider-agnostic interface with sealed event
  catalogue and no-op default; real provider, adapter, and GDPR
  consent flow tracked in `TODO.md`.

21 features (including the analytics provider choice, remote crash reporting, and GDPR
consent flow) have been **deliberately deferred** to a future version
and are tracked in [`TODO.md`](TODO.md).

---

## Getting started

The Flutter project scaffold has been created, and Phase 1 of `ROADMAP.md`
covers configuring and aligning it. Once aligned, the canonical workflow
is:

```bash
# install local git hooks (after first clone, per ADR-0008)
lefthook install

# run the app with compile-time configuration
flutter run --dart-define-from-file=config/app.json

# run tests
flutter test

# static analysis (must pass with zero warnings)
flutter analyze
```

---

## License

To be decided before the repository is made public.
