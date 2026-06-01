# ADR-0037 — Hive persistence model design (typeId registry, station model reuse, data-source boundary)

- **Status:** Accepted
- **Date:** 2026-06-01
- **Deciders:** David Ruiz
- **Related:** ADR-0016, ADR-0018, ADR-0020, ADR-0021, `ARCHITECTURE.md` §"Data Source Boundaries", `API_SPEC.md` §6, §8, `TECHNICAL_SPEC.md` §3, `ROADMAP.md` Phase 4

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

Phase 4 introduces the local storage layer. ADR-0018 fixed the codegen
toolchain (`build_runner` + `hive_generator`) and ADR-0016 fixed the
mirror-cache backend (`app_settings` box). What no ADR has fixed yet is
the **shape of the persisted Hive models** that back the four entity
caches — favorites, history, genres, and countries. Several decisions
must be pinned before the first RED so the persisted schema and the
data-source boundary are stable and reviewable:

1. **Where the persistence models live and how they are named.** Phase 5
   will introduce remote API DTOs (`StationDto`, `GenreDto`,
   `CountryCodeDto`) in `data/models/` (ROADMAP Phase 5). Phase 4 needs
   its own persistence models in the same folder. Without a naming rule,
   "a station model in `data/models/`" is ambiguous between the two
   boundaries.

2. **`typeId` allocation.** Every `@HiveType` requires a globally unique,
   stable integer `typeId`. Reusing or renumbering a `typeId` after data
   has been written corrupts existing boxes. The project needs one
   authoritative registry.

3. **Whether favorites and history share one station model.** Both
   `FavoritesRepository` and `HistoryRepository` expose
   `List<RadioStation>` (`lib/domain/repositories/`). Favorites also
   carry an offline-render metadata requirement (`API_SPEC.md` §8: name,
   favicon, country code, tags, stream URL) and a sync-resilience
   requirement (ADR-0020: retain a missing station with
   `lastCheckOk = false` rather than delete it).

4. **What crosses the data-source boundary.** `ARCHITECTURE.md` says
   local data sources "own Hive read/write" and repositories "return
   domain entities only", but it does not say whether the local data
   source's *public* methods return Hive models or domain entities.

5. **History ordering and timestamps.** ADR-0021 caps history at 50 with
   FIFO eviction and move-to-top on replay. It must be clear whether that
   ordering lives in the persisted model (e.g. a `playedAt` field) or in
   the repository.

## Decision

### A. Location and naming

The Hive persistence models live in `data/models/` and carry a `HiveModel`
suffix: `StationHiveModel`, `GenreHiveModel`, `CountryHiveModel`. The
`HiveModel` suffix MUST distinguish them from the Phase 5 remote API DTOs
(`StationDto`, `GenreDto`, `CountryCodeDto`), which model the *remote*
boundary. The two model families are intentionally separate: one projects
the local persistence schema, the other the Radio Browser wire format;
each maps to/from the same domain entities independently.

### B. `typeId` registry

`typeId`s are allocated from a single append-only registry. Allocated
values MUST NOT be reused or renumbered once any build has shipped:

| `typeId` | Model               | Backs                         |
|----------|---------------------|-------------------------------|
| `0`      | `StationHiveModel`  | `favorites` and `history` boxes |
| `1`      | `GenreHiveModel`    | `genres` box                  |
| `2`      | `CountryHiveModel`  | `countries` box               |

Future persistence models continue from `typeId 3`. `@HiveField` indices
within each model are likewise append-only: a field MAY be added with the
next free index and a field MAY be deprecated, but an index MUST NOT be
re-assigned to a different field.

### C. One `StationHiveModel`, reused for favorites and history

A single `StationHiveModel` (`typeId 0`) round-trips the **full**
`RadioStation` entity (all 17 fields) and is stored in **both** the
`favorites` and `history` boxes. Persisting the full entity:

- Satisfies the favorites offline-render metadata requirement
  (`API_SPEC.md` §8) as a superset.
- Supports ADR-0020 by allowing `lastCheckOk` to be flipped to `false`
  in place without a second, lossy model.
- Avoids a separate `HistoryHiveModel` that would carry the same fields.

The `tagList` field is persisted directly as a stored `List<String>`. It
is **not** re-derived on read: the `tag_parser` helper is a Phase 5
addition (ROADMAP Phase 5), and re-derivation would couple the
persistence layer to a helper it must not depend on.

### D. Data sources expose domain entities

The local entity-cache data sources (`LocalFavoritesDataSource`,
`LocalHistoryDataSource`, `LocalGenresDataSource`,
`LocalCountriesDataSource`) expose **domain entities** at their public
boundary (e.g. `Future<List<RadioStation>> getFavorites()`). The
`*HiveModel` types are an internal persistence detail and MUST NOT cross
the data-source boundary. Each model owns its mapping via a
`fromEntity(...)` constructor/factory and a `toEntity()` method; the data
source performs the conversion internally. This keeps Hive types confined
to `data/datasources/` + `data/models/` and leaves the Phase 6
repositories to coordinate sources and wrap results in `Result`/`Failure`.

(The `MirrorCacheDataSource` is unaffected: per ADR-0016 it deals in a
bare `String?` host, not a Hive model, and is delivered in a later Phase 4
sub-task.)

### E. Box keys

- `favorites`: a `Box<StationHiveModel>` keyed by `stationUuid` (String),
  per `API_SPEC.md` §8 ("`stationuuid` MUST be used as the primary key").
- `genres`: keyed by the genre `name`.
- `countries`: keyed by the `countryCode`.
- `history`: insertion-ordered. The key strategy, the 50-item FIFO cap,
  and move-to-top on replay are the **repository's** responsibility
  (ADR-0021, Phase 6); the data source preserves and returns values in
  insertion order and does not itself enforce the cap.

### F. Models are faithful projections — no persistence-only fields

The Hive models add no fields that the domain entities do not have. In
particular `StationHiveModel` carries **no** `playedAt`/timestamp field:
history ordering is positional (insertion order), owned by the repository
per decision E and ADR-0021. This keeps the persisted schema a faithful
projection of the domain and avoids leaking ordering policy into storage.

## Consequences

### Positive
- A single authoritative `typeId` registry prevents box-corrupting
  collisions and renumbering.
- One `StationHiveModel` removes duplication between favorites and history
  and makes ADR-0020's in-place `lastCheckOk` update trivial.
- Hive types never leak past the data layer, preserving the dependency
  rule and keeping Phase 6 repositories thin.
- The naming rule pre-empts the Phase 5 DTO collision before it happens.

### Negative
- Storing the full station in the `history` box is slightly larger than a
  minimal "uuid + name" record, but the 50-item cap (ADR-0021) bounds it.
- Two model families (`*HiveModel` now, `*Dto` in Phase 5) both map to the
  same entities, i.e. two mappers per entity. Accepted as the cost of
  keeping the local and remote boundaries independent.

### Neutral
- The registry is expected to grow; new models append `typeId`s and the
  table in this ADR is updated.

## Alternatives considered

### Option A — Separate `FavoriteHiveModel` and `HistoryHiveModel`
Rejected. Both round-trip `RadioStation`; two near-identical models add
maintenance cost and two `typeId`s for no schema difference.

### Option B — Minimal favorites model (only the §8 metadata subset)
Rejected. A lossy model cannot represent `lastCheckOk` and the other
fields ADR-0020 needs to retain a stale favorite, and would force a
re-fetch to render anything beyond the subset.

### Option C — Data sources return `*HiveModel` and repositories map
Rejected. Leaks Hive types into the repository layer and spreads the
model↔entity mapping across two layers. Confining Hive to the data source
keeps the boundary in one place.

### Option D — Re-derive `tagList` from `tags` on read
Rejected for Phase 4. The `tag_parser` helper does not exist until
Phase 5; persistence MUST NOT depend on it. Storing `tagList` directly is
self-contained.

### Option E — Add a `playedAt` timestamp to the history model
Rejected. Ordering is positional and owned by the repository (ADR-0021);
a timestamp would duplicate that policy in storage and diverge the
persisted schema from the domain entity.

## Documentation impact

- `ARCHITECTURE.md` §"Data Source Boundaries" — add that local entity-cache
  data sources expose domain entities and that `*HiveModel` types do not
  cross the data-source boundary; reference this ADR for the `typeId`
  registry.
- `ROADMAP.md` Phase 4 — note the `*HiveModel` naming and the `typeId`
  registry source (this ADR).
- `docs/adr/README.md` — add the ADR-0037 index row.
- `MEMORY.md` — add the decision-log entry.

## Follow-ups

- Phase 5 introduces the remote `*Dto` models and their mappers; this ADR
  reserves the naming split they rely on.
- A future ADR MAY introduce a `schema_version` key (ADR-0016 already
  floats one for `app_settings`) and a migration strategy if a persisted
  shape must change incompatibly.
