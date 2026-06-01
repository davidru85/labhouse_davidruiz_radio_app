# ADR-0016 — Mirror cache persistence backend

- **Status:** Accepted
- **Date:** 2026-05-28
- **Deciders:** David Ruiz
- **Related:** `API_SPEC.md` §2, `ARCHITECTURE.md` §Data Source Boundaries, `MEMORY.md` §Pending Questions

## Context

`API_SPEC.md` §2 requires the application to cache the
last-known-working Radio Browser mirror in persistent storage and
to use that cached value first on subsequent startups. The choice
of persistence backend was deliberately left open in
`MEMORY.md` §Pending Questions.

The cached datum is small and infrequently written:

- A single hostname string (~30 bytes), e.g. `"de1.api.radio-browser.info"`.
- One read on every cold start (used by the Dio client factory to
  pick the initial base URL).
- One write whenever a mirror failover successfully resolves a
  request against a different mirror than the one previously
  cached.

The project already pulls in Hive (`hive_ce_flutter`, per ADR-0038) for favorites,
history, and the genre / country caches. Introducing a second
persistence mechanism for a 30-byte string would create two parallel
storage stacks, two initialisation sequences and two debugging
surfaces.

## Decision

The last-known-working mirror is persisted in **Hive**, in a
dedicated box `app_settings`, under the key `last_known_mirror`.
The value is the bare hostname (no scheme, no path).

### Domain placement

The cached mirror is **not** a domain entity. It is an
infrastructure detail of the networking layer and lives entirely
inside `data/` and `core/network/`. No domain repository contract
is introduced for it.

### Data layer

A `MirrorCacheDataSource` is defined under
`data/datasources/local/`:

```dart
abstract class MirrorCacheDataSource {
  Future<String?> getLastKnownMirror();
  Future<void> setLastKnownMirror(String host);
}
```

The implementation `HiveMirrorCacheDataSource` opens (or reuses) the
`app_settings` box and reads/writes the `last_known_mirror` key.

### Network layer integration

`DioClientFactory` in `core/network/` consumes the
`MirrorCacheDataSource`:

- On construction, it asynchronously fetches
  `getLastKnownMirror()`. If the returned hostname is non-null and
  belongs to the known mirror whitelist (the constant list in
  `core/constants/`), it is used as the initial `baseUrl`.
  Otherwise the first mirror in the whitelist is used.
- The mirror-failover interceptor calls
  `setLastKnownMirror(host)` whenever a request succeeds against a
  mirror different from the one currently cached.

### Initialisation order

`Hive.initFlutter()` and the opening of every used box (including
`app_settings`) run in `main.dart` before `runApp` and before the
`get_it` composition root is initialised. The composition root then
registers the data source and the `DioClientFactory` with the open
box already available.

## Consequences

### Positive
- Single persistence stack across the project. One initialisation,
  one abstraction pattern (`...DataSource` local classes), one
  debugging surface.
- No new dependencies.
- `MirrorCacheDataSource` follows the same shape as the other local
  data sources (`LocalFavoritesDataSource`, `LocalHistoryDataSource`,
  etc.), so the composition root and tests remain symmetric.
- The cached mirror lives outside the domain layer, preserving the
  domain's purity.

### Negative
- Hive is heavier than `shared_preferences` for the scale of this
  data, but the overhead is unmeasurable in practice.
- Adding a second key to `app_settings` later (e.g. for a future
  user preference) is convenient but tempting toward leaking
  domain-level state into infrastructure storage. The
  responsibility of `app_settings` is documented as
  "infrastructure-level persistence" and must be guarded.

### Neutral
- The `app_settings` box is reusable for other infrastructure
  values (e.g. a future "schema version" key) without changing
  ADRs.

## Alternatives considered

### Option B — `shared_preferences`
Rejected. Adds a second persistence stack alongside Hive without
functional benefit. Doubles the initialisation surface.

### Option C — Plain file under `path_provider`
Rejected. Bypasses any framework safety; needs manual error
handling, corruption recovery and concurrent-access reasoning that
Hive already provides.

### Option D — No persistence; always start with the first mirror in the constant list
Rejected. Violates the explicit requirement in `API_SPEC.md` §2 to
prefer the last-known-working mirror on startup.

## Documentation impact

- `API_SPEC.md` §2 — replace "persistent storage" with an explicit
  mention of Hive box `app_settings` key `last_known_mirror`.
- `ARCHITECTURE.md` §Data Source Boundaries → Local data sources —
  add `MirrorCacheDataSource` to the list of local data sources.
  Note its responsibility (last-known-working mirror persistence).
- `ROADMAP.md` Phase 4 — add `MirrorCacheDataSource` to the local
  data source implementations; document the `app_settings` box.
- `ROADMAP.md` Phase 5 — note that the `Dio` client factory reads
  the cached mirror at construction time and writes via the failover
  interceptor.
- `MEMORY.md` §Pending Questions — remove the question about
  mirror persistence.

## Follow-ups

- A future ADR may define a "schema version" key inside
  `app_settings` to support migrations as the persisted shapes
  evolve.
