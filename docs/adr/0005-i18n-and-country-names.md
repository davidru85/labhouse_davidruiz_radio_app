# ADR-0005 — i18n scaffold and country name resolution

- **Status:** Accepted
- **Date:** 2026-05-28
- **Deciders:** David Ruiz
- **Related:** `API_SPEC.md` §6.3, `MEMORY.md` §Pending Questions, `TECHNICAL_SPEC.md` §2

## Context

Two related but distinct concerns were unresolved in the specification:

1. **UI language.** No document specified the language of in-app strings
   (labels, errors, button text).
2. **Country name resolution.** `API_SPEC.md` §6.3 noted that the
   `/json/countrycodes` endpoint returns raw ISO 3166-1 alpha-2 codes and
   that a mapping utility or the `intl` package would be required, but
   `MEMORY.md` §Pending Questions left the choice open.

Retrofitting `flutter_localizations` into a project that hard-coded
English strings is mechanical but tedious. Conversely, committing to a
fully bilingual build from day 1 doubles the cost of every string while
the project is in heavy development.

For country names, a hand-maintained ISO-to-name table would mean keeping
~250 entries in sync, multiplied by every supported language. The `intl`
package — already adjacent to `flutter_localizations` — does this with
zero maintenance.

## Decision

- **UI language:** English only at launch.
- **i18n scaffold is configured from day 1:** `flutter_localizations` is
  added to dependencies, `pubspec.yaml` declares `generate: true` and an
  `l10n.yaml` config, and a single `lib/l10n/intl_en.arb` ARB file is
  the source of all user-facing strings. No hard-coded literals in
  widgets.
- **Country names** resolve via the `intl` package against the app's
  active locale.
- **No automatic locale detection** based on the system locale at launch.
  The app uses `en_US` unconditionally. Detection can be added later
  without rearchitecting.

## Consequences

### Positive
- Future bilingual support is additive: add `intl_es.arb`, no code
  refactor.
- Country name resolution requires no hand-maintained tables and
  follows the same locale mechanism as the rest of the UI.
- `intl` is reused both for ARB code generation and for country name
  resolution — a single dependency for two purposes.
- Closes one of the open questions in `MEMORY.md`.

### Negative
- Slight day-1 boilerplate: ARB workflow even with a single language.
- All Failure messages, button labels, etc. must go through ARB lookup
  even when there is only one translation. Authors must remember not
  to inline strings.

### Neutral
- A user with the system locale set to Spanish sees the UI in English.
  This is intentional and documented; it is not a bug. If automatic
  detection is desired in a future iteration, a new ADR will supersede
  this one.

## Alternatives considered

### Option A — English-only, no scaffold
Rejected. Adding `flutter_localizations` later forces a string-by-string
migration across every widget. The day-1 cost is low; the deferred cost
is high.

### Option B — Spanish-only
Rejected. Documentation is in English and the audience for the
assessment is mixed; defaulting to English keeps the artifact
reviewable by anyone.

### Option C — Bilingual (en + es) from day 1, with automatic locale detection
Rejected for the assessment scope. Every new string would need two
translations during heavy development. Can be reached additively
later.

### Option F — Hand-maintained ISO-to-name table
Rejected for country names. ~250 entries per language, with no
maintenance benefit over `intl`.

## Documentation impact

- `TECHNICAL_SPEC.md` §2 (Official Dependency List) — add
  `flutter_localizations` (SDK) and `intl` under Production dependencies.
- `CONTEXT.md` §Key Constraints (or new section) — record the
  English-only-at-launch policy and the i18n scaffold commitment.
- `API_SPEC.md` §6.3 — close the question: country resolution uses
  `intl` against the active locale.
- `MEMORY.md` §Pending Questions — remove the country-name resolution
  question (now answered by this ADR).
- `ROADMAP.md` Phase 2 — add a sub-task to configure
  `flutter_localizations`, `l10n.yaml`, and `intl_en.arb`.

## Follow-ups

- A future ADR may add automatic locale detection or additional
  languages. Until then, default locale is `en_US`.
