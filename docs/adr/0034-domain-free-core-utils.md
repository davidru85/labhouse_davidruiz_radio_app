# ADR-0034 — Domain-free core utility return types

- **Status:** Accepted
- **Date:** 2026-05-30
- **Deciders:** David Ruiz
- **Related:** ADR-0017, ADR-0024, `ARCHITECTURE.md` §Dependency Rule

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

ADR-0017 introduced `core/utils/` for stateless pure helpers and stated
that those helpers have no domain dependencies. The same ADR also
described the Icy metadata parser as parsing `StreamTitle` metadata into a
`NowPlayingInfo` domain entity, which creates a dependency from
`core/utils/` to `domain/entities/`.

That dependency direction is undesirable because `core/` is shared
infrastructure. Keeping it domain-free makes helpers easier to reuse from
data, domain, or presentation code without creating hidden layer coupling.

## Decision

Utilities in `core/utils/` MUST NOT import from `domain/`, `data/`, or
`presentation/`.

The Icy metadata parser returns a domain-free parsed value containing
`raw`, `artist`, and `track` fields. Mapping that parsed value into the
`NowPlayingInfo` domain entity belongs at the boundary that consumes the
parser, such as the audio player repository implementation.

## Consequences

### Positive
- Preserves the `core/utils/` convention from ADR-0017.
- Keeps domain entities free of parsing behavior while avoiding a reverse
  dependency from `core/` to `domain/`.
- Makes the parser independently testable without importing domain types.

### Negative
- Consumers that need a `NowPlayingInfo` must explicitly map the parsed
  value into the domain entity.

### Neutral
- The parsing behavior from ADR-0024 is unchanged.

## Alternatives considered

### Option A — Let `core/utils` return `NowPlayingInfo`
Rejected. This violates the no-domain-dependencies convention recorded in
ADR-0017.

### Option B — Move the parser into `domain/entities/`
Rejected. It keeps the entity less focused and makes parsing behavior part
of the value object rather than a reusable stateless helper.

## Documentation impact

- `MEMORY.md` — add this ADR to the decision log.
- `docs/adr/README.md` — add this ADR to the index.
- Future data/audio repository work MUST map parser output to
  `NowPlayingInfo` explicitly.

## Follow-ups

- None.
