# ADR-0017 — `core/utils/` folder in the mandatory structure

- **Status:** Accepted
- **Date:** 2026-05-28
- **Deciders:** David Ruiz
- **Related:** `ARCHITECTURE.md` §Mandatory Folder Structure, `TECHNICAL_SPEC.md` §3, `API_SPEC.md` §6.3, ADR-0005, ADR-0012

## Context

`ARCHITECTURE.md` §Mandatory Folder Structure and `TECHNICAL_SPEC.md`
§3 list the canonical folder layout under `lib/core/` as
`constants/`, `errors/`, and `network/`. However, `API_SPEC.md` §6.3
references `core/utils/` explicitly:

> A mapping utility or the `intl` package must be implemented in
> `core/utils/` to resolve human-readable country names.

This is an internal inconsistency in the specification: a folder is
both required by one document and absent from the canonical
structure in another. The polish pass surfaces it for resolution.

Independently of the documentation gap, several stateless,
side-effect-free helpers are needed by the application and do not
fit cleanly anywhere else:

1. **Country name resolver.** Resolves an ISO 3166-1 alpha-2 code
   to a localised country name using `intl` (per ADR-0005). Used
   by the presentation layer when displaying station country
   metadata and country filters.
2. **Tag parser.** Splits the `tags` field of a `RadioStation`
   (comma-separated string from Radio Browser) into a normalised,
   trimmed, deduplicated `List<String>` (per
   `API_SPEC.md` §6 DTO mapping rules).
3. **Icy metadata parser.** Parses the `StreamTitle` string from an
   Icy emission into a `NowPlayingInfo` instance, applying the
   `Artist - Track` separator rule per ADR-0012.

All three share a profile:

- Stateless.
- No I/O.
- No domain dependencies.
- Independently unit-testable.

They belong in a single folder, not scattered across `data/models/`
(where DTOs live) or `core/constants/` (which is for values, not
logic).

## Decision

`core/utils/` is added to the canonical folder structure and is
populated initially with the three helpers above.

### Updated canonical structure

```text
lib/
  core/
    constants/   # mirror URLs, API defaults, hard-coded values
    errors/      # global error utilities
    network/     # Dio client factory, mirror failover interceptor
    utils/       # stateless pure helpers
  data/...
  domain/...
  presentation/...
```

### Initial contents of `core/utils/`

```
lib/core/utils/
  country_name_resolver.dart
  tag_parser.dart
  icy_metadata_parser.dart
```

Each helper has a corresponding unit test under
`test/core/utils/`.

### Conventions for `core/utils/`

- Pure functions or stateless classes only.
- No dependency on the `domain/` layer.
- No I/O, no async unless wrapping a synchronous transformation
  for ergonomic reasons.
- Anything that needs to be configurable (e.g. locale for the
  country name resolver) takes the configuration as a parameter,
  not from a singleton.

This guards `core/utils/` against becoming the dumping ground for
miscellaneous logic with hidden state, which is the common failure
mode of "utils" folders.

## Consequences

### Positive
- The inconsistency between `API_SPEC.md` and the canonical
  structure is resolved.
- Three identified helpers have a clear home that is
  test-friendly.
- `core/constants/` stays purely declarative.
- DTOs in `data/models/` stay focused on JSON shape and field
  mapping, not on auxiliary string parsing.

### Negative
- Adds a folder to the canonical structure. Negligible cost.
- The convention "stateless only" relies on developer discipline,
  not enforcement. Mitigation: documented in this ADR; reviewable
  in PR.

### Neutral
- Future helpers (e.g. URL validators, duration formatters) will
  also land here. The folder is expected to grow modestly.

## Alternatives considered

### Option B — `core/parsers/` for parsing-only helpers
Rejected. The country name resolver is not a parser. Splitting by
narrow subcategories produces fragmented folders.

### Option C — Disperse helpers: country resolver in `core/`, tag parser inside DTOs, Icy parser inside DTOs
Rejected. Inconsistent placement of equivalent helpers; makes the
test layout harder to mirror.

### Option D — Move parsers into `data/models/` as DTO methods
Rejected. DTOs should describe JSON shape, not own auxiliary
string parsing. Tag and Icy parsing are reused in places that
have nothing to do with the DTO (e.g. the player metadata stream).

## Documentation impact

- `ARCHITECTURE.md` §Mandatory Folder Structure — add `utils/`
  under `core/`.
- `TECHNICAL_SPEC.md` §3 — add `utils/` to the structure table
  with the comment "Stateless helpers (country name resolution,
  tag parsing, Icy metadata parsing)".
- `ROADMAP.md` Phase 1 — include the creation of `core/utils/`
  as a sub-task of folder scaffolding.
- `ROADMAP.md` Phase 5 — note that `tag_parser` and
  `icy_metadata_parser` are used during DTO-to-entity mapping.
- `API_SPEC.md` §6.3 — no change required; already references
  `core/utils/`.

## Follow-ups

- None.
