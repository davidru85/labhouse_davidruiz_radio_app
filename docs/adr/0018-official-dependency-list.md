# ADR-0018 — Official dependency list (consolidated)

- **Status:** Accepted
- **Date:** 2026-05-28
- **Amended:** 2026-05-30 — document the `analyzer` dependency
  override required for version solving (see "Toolchain version
  constraint: `analyzer` override" below).
- **Deciders:** David Ruiz
- **Related:** `TECHNICAL_SPEC.md` §2, ADR-0005, ADR-0007, ADR-0013, ADR-0014

## Context

The original `TECHNICAL_SPEC.md` §2 "Official Dependency List"
captures the dependencies chosen at project inception. Since then,
the polish pass has accepted decisions that require additional
packages or that contradict the existing list:

| Package | Source of the requirement | Was it in §2? |
|---|---|---|
| `go_router` | `CONTEXT.md` §Key Constraints, `TECHNICAL_SPEC.md` §1 | **No** (omitted from §2) |
| `flutter_localizations` | ADR-0005 | No |
| `intl` | ADR-0005, `API_SPEC.md` §6.3 | No |
| `connectivity_plus` | ADR-0013 | No |
| `stream_transform` | ADR-0014 | No |

A second concern: Hive `TypeAdapter`s for the cached entities
(favorites, history, genres, countries) can either be written by
hand or generated from annotations. The choice needs to be fixed
before Phase 4 starts so the toolchain is known.

A third concern: ambient utilities (logging, secure storage, UUID
generation) keep being floated as candidates and need an explicit
decision so they do not creep in later.

## Decision

The official dependency list is fully rewritten in
`TECHNICAL_SPEC.md` §2 with the consolidated set below.

### Production dependencies

| Category | Package | Origin |
|---|---|---|
| State management | `flutter_bloc` | Original spec |
| State management | `equatable` | Original spec |
| Dependency injection | `get_it` | Original spec |
| Routing | `go_router` | `CONTEXT.md`, `TECHNICAL_SPEC.md` §1 |
| Network | `dio` | Original spec |
| Network | `connectivity_plus` | ADR-0013 |
| Stream operators | `stream_transform` | ADR-0014 |
| Audio | `just_audio` | Original spec |
| Audio | `audio_service` | Original spec |
| Persistence | `hive_flutter` | Original spec |
| Image caching | `cached_network_image` | Original spec |
| i18n (SDK) | `flutter_localizations` | ADR-0005 |
| i18n | `intl` | ADR-0005, `API_SPEC.md` §6.3 |

### Dev dependencies

| Category | Package | Origin |
|---|---|---|
| Lint | `very_good_analysis` | Original spec |
| Test (SDK) | `flutter_test` | Original spec |
| Test | `bloc_test` | Original spec |
| Test | `mocktail` | Original spec |
| Test (SDK) | `integration_test` | Original spec |
| Code generation | `build_runner` | This ADR |
| Code generation | `hive_generator` | This ADR |

### Hive code generation

`build_runner` and `hive_generator` are adopted to generate Hive
`TypeAdapter` implementations from `@HiveType` / `@HiveField`
annotations on the cache entities (favorites, history, genres,
countries). Generated files (`*.g.dart`) are committed to the
repository so CI does not need to run code generation to build.

### Toolchain version constraint: `analyzer` override

`pubspec.yaml` declares a single `dependency_overrides` entry:

```yaml
dependency_overrides:
  analyzer: ^6.4.1
```

This is **not** a new product dependency. `analyzer` is a transitive
dev-toolchain package; the override is required for version solving,
not a stylistic preference:

- `hive_generator 2.0.1` (the codegen tool chosen above) depends on
  `analyzer >=4.6.0 <7.0.0`.
- The `bloc_test 10.0.0` → `test` → `flutter_test` chain pulls newer
  `test` releases that depend on `analyzer >=8.0.0`.

Without pinning, these two constraints are mutually exclusive and
`flutter pub get` fails with "version solving failed". Pinning
`analyzer` to `^6.4.1` keeps it under `hive_generator`'s `<7.0.0`
ceiling and forces `test` / `bloc_test` to resolve to versions
compatible with that range, so the graph resolves.

The override is scoped to the dev/codegen toolchain and has no effect
on shipped application behaviour. It should be removed once
`hive_generator` publishes a release that accepts `analyzer >=8.0.0`,
after which the newer analyzer can be used without pinning.

### Explicitly rejected dependencies

These packages have been considered and are **not** added:

- **`logger` / `logging`.** `dart:developer` `log` plus
  `kReleaseMode` (per ADR-0007) provide enough verbosity control
  for v1. A future ADR may revisit this when structured logging
  becomes useful.
- **`flutter_secure_storage`.** Radio Browser is unauthenticated;
  there are no secrets to protect.
- **`uuid`.** Station identifiers come from Radio Browser as
  `stationuuid`; no local generation is needed.
- **`path_provider`.** Pulled in transitively by `hive_flutter`;
  declaring it explicitly is redundant.
- **`rxdart`.** Superseded by `stream_transform` for the operators
  we actually need.

## Consequences

### Positive
- The list is internally consistent with every ADR accepted so far.
- Categorising the list makes new dependencies easy to evaluate
  against intent rather than alphabetical order.
- The codegen toolchain is fixed, so Phase 4 has no ambiguity over
  how adapters are produced.
- Explicit rejections record future considerations so they are not
  re-debated.

### Negative
- The total number of production dependencies grows from 7 to 13.
  Each one is justified by an ADR or by the original specification.
- `build_runner` adds a code generation step. Mitigated by
  committing the generated `*.g.dart` files so CI builds without
  running it.

### Neutral
- The list is expected to evolve. Future ADRs that need a new
  dependency must update this list as part of their
  "Documentation impact" section.

## Alternatives considered

### Add no codegen; write Hive `TypeAdapter`s by hand
Rejected. Hand-written adapters are mechanical, repetitive, and
error-prone when field shapes evolve.

### Add `logger` to the list
Rejected for v1. The SDK's `dart:developer` `log` is sufficient.

### Use `rxdart` for stream operators
Rejected (already decided in ADR-0014).

### Keep `TECHNICAL_SPEC.md` §2 as the source of truth and amend it directly without an ADR
Rejected. The decisions that drove the expansion (ADR-0005,
ADR-0007, ADR-0013, ADR-0014) are visible only by reading several
ADRs; consolidating in one ADR creates a single referenceable
record of the official dependency surface.

## Documentation impact

- `TECHNICAL_SPEC.md` §2 — rewrite using the categorised tables
  above. Add a closing note: "The dependency list is governed by
  ADR-0018; new dependencies require an ADR amendment."
- `ROADMAP.md` Phase 1 — under `pubspec.yaml` setup, list the 13
  production + 7 dev dependencies, grouped as in this ADR.
- `ROADMAP.md` Phase 4 — note that Hive adapters are produced via
  `build_runner` + `hive_generator`.
- No `.gitignore` change required: generated `*.g.dart` files are
  committed.
- `pubspec.yaml` — keep the `dependency_overrides: analyzer ^6.4.1`
  entry (with a comment pointing here) for as long as resolution
  requires it; remove it once `hive_generator` supports
  `analyzer >=8.0.0`. See "Toolchain version constraint" above.

## Follow-ups

- A future ADR may add structured logging if telemetry becomes a
  requirement.
- A future ADR may revisit `build_runner` if the generated files
  in source control become a maintenance burden.
