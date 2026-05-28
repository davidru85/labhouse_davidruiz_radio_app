# ADR-0003 — App identifiers

- **Status:** Accepted
- **Date:** 2026-05-28
- **Deciders:** David Ruiz
- **Related:** ADR-0001, `ARCHITECTURE.md` §Native Platform Configuration

## Context

A Flutter project carries three different identifiers, often confused:

1. **Application ID / Bundle ID** — globally unique reverse-DNS string used
   by Android (`applicationId`) and iOS (`CFBundleIdentifier`) to identify
   the installable artifact in stores and on devices.
2. **Dart package name** — the `name:` field in `pubspec.yaml`, used in
   `package:` imports across the codebase.
3. **Display name** — the human-readable label shown on the launcher
   (`android:label`, `CFBundleDisplayName`).

None of these were specified anywhere in the documentation. They must be
fixed before `flutter create` runs, because changing any of them after the
fact is disruptive:

- Changing the Application ID causes Android reinstall and total local data
  loss (including the Hive boxes that hold favorites and history).
- Changing the Bundle ID on iOS requires a new provisioning profile and,
  in the store, registers as a distinct application.
- Renaming the Dart package name forces find-and-replace across every
  `import` site in the codebase.

`com.example.*` is reserved for tutorials and is rejected by both stores.

## Decision

- **Application ID / Bundle ID:** `com.labhouse.davidruizassessment.radioapp`
- **Dart package name:** `radio_app`
- **Display name:** `RadioApp`

Project is scaffolded with:

```
flutter create \
  --org com.labhouse.davidruizassessment \
  --project-name radio_app \
  --platforms=android,ios \
  .
```

## Consequences

### Positive
- Identifiers make the context (LABHOUSE assessment by David Ruiz)
  immediately readable to reviewers.
- The four-segment Application ID is unlikely to collide with any other
  app on any device or store.
- The Dart package name is short, valid (snake_case), and produces
  clean imports such as `package:radio_app/core/...`.

### Negative
- The Application ID is longer than the conventional three-segment form,
  which is slightly unwieldy in build scripts and logs.
- The Application ID hard-codes the assessment context. If the project is
  later repurposed as a production product, the ID is awkward — but
  changing it is intentionally costly precisely because it is a stable
  identity, so this is accepted.

### Neutral
- Display name is identical to the Dart package name in PascalCase
  form (`RadioApp`), which is convenient but coincidental and may
  diverge later without code impact.

## Alternatives considered

### Option A — `com.labhouse.radioapp`
Rejected. Cleaner but does not reflect that this is David Ruiz's
assessment artifact, not LABHOUSE's product.

### Option B — `com.davidruiz.radioapp`
Rejected. Reasonable for personal portfolio but disconnects the
identifier from the assessment context that originated the project.

## Documentation impact

- `ARCHITECTURE.md` §Native Platform Configuration — record all three
  identifiers explicitly.
- `ROADMAP.md` Phase 1 — record the full `flutter create` invocation
  including `--org` and `--project-name`.
- `CONTEXT.md` §Project Goal — optionally reference the Dart package
  name `radio_app`.

## Follow-ups

- None.
