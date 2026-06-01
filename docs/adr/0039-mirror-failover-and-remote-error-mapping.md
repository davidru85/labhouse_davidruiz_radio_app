# ADR-0039 — Mirror failover networking architecture and remote error mapping

- **Status:** Accepted
- **Date:** 2026-06-01
- **Deciders:** David Ruiz
- **Related:** `API_SPEC.md` §2, §3, §4, §9, ADR-0016, ADR-0023, `ARCHITECTURE.md` §"Data Source Boundaries", `core/errors/result.dart`, `domain/failures/`

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

`API_SPEC.md` §2 requires mirror-aware networking with automatic failover,
and §4/§9 require Dio errors to be mapped into domain failures inside the
data/networking layers. The concrete architecture is not yet fixed:

- `core/network/dio_client.dart` currently builds only base `BaseOptions`
  (headers + timeouts). It has no `baseUrl`, no failover, and is created
  synchronously with no dependencies.
- ADR-0016 says a `DioClientFactory` reads the cached mirror from
  `MirrorCacheDataSource` **asynchronously at construction**, and that a
  failover interceptor writes the working mirror back. ADR-0023 fixes the
  four-mirror whitelist (`defaultApiMirrors`). The cached value is a **bare
  hostname** (e.g. `de1.api.radio-browser.info`); whitelist entries are
  full `https://…` URLs.
- `API_SPEC.md` §2 caps retries at **2 attempts per mirror** and **6 total
  attempts**, retrying on **connection-level errors** and **5xx** only.
- The domain failures already exist (`ServerFailure`,
  `ValidationErrorFailure`, `UnauthorizedFailure`,
  `ConnectionTimeoutFailure`, `SocketFailure`, `MirrorFailure`). `Failure`
  extends `Equatable`, **not** `Exception`, so it cannot be `throw`n
  directly.
- `ARCHITECTURE.md` says repositories convert data-layer failures into
  domain failures, while `API_SPEC.md` §9/§4 require error **mapping** to
  live in `data/datasources/` + `core/network/`.

A single architecture must reconcile all of the above before the remote
data sources (sub-task 5.2) are written.

## Decision

### Components (all in `core/network/`)

1. `DioClient.create()` stays the synchronous **base-options** factory
   (headers per `API_SPEC.md` §3, timeouts per §4). Unchanged.
2. `MirrorFailoverInterceptor` — a Dio `Interceptor` implementing the
   failover rotation and mirror write-back.
3. `DioClientFactory` — an **async** factory:
   `Future<Dio> create(MirrorCacheDataSource cache, {List<String> mirrors})`.
   It resolves the initial mirror, attaches `MirrorFailoverInterceptor`,
   and returns a ready `Dio`. `mirrors` defaults to `defaultApiMirrors`
   (ADR-0023).
4. `mapDioException(DioException) → Failure` — the Dio→domain-failure mapper.
5. `NetworkException implements Exception { final Failure failure; }` — a
   thin carrier so the mapped failure can cross the data-source→repository
   boundary without leaking `DioException` or `throw`ing a non-`Exception`.
6. `MirrorFailoverExhausted` — a small, `const`-constructible **sentinel**
   (a plain marker, not a `Failure` and not an `Exception`) that lives in
   `core/network/` (alongside `mapDioException`). It carries no data; its
   only purpose is to tag a propagated `DioException` as "all mirrors
   exhausted" so the mapper can distinguish that case from an ordinary
   connection error. It MUST NOT be added to `domain/failures/`: failover
   exhaustion is a networking detail, and the domain layer never sees
   mirrors. The corresponding domain value remains `MirrorFailure`.

### Initial mirror selection (per ADR-0016)

`DioClientFactory.create` awaits `cache.getLastKnownMirror()`. If the
cached host is non-null and matches the host of a whitelist entry, that
entry becomes the initial `baseUrl` and the head of the rotation order;
otherwise the first whitelist mirror is used. The rotation order is the
active mirror followed by the remaining whitelist mirrors, in list order.

### Failover rotation (`MirrorFailoverInterceptor.onError`)

- **Retriable** errors are connection-level (`DioExceptionType
  .connectionError`, `connectionTimeout`, `sendTimeout`, `receiveTimeout`)
  and `badResponse` with **status ≥ 500**.
- On a retriable error, the interceptor switches the request to the **next
  mirror** in rotation, rewrites the request `baseUrl`, and re-dispatches.
- Caps: **≤ 2 attempts per mirror** and **≤ 6 total attempts** per logical
  request. When the caps are reached, the interceptor stops rotating and
  lets the error propagate. Before propagating, it **re-tags** the
  `DioException` so its `error` field is a `MirrorFailoverExhausted`
  sentinel (`DioException.copyWith(error: const MirrorFailoverExhausted())`,
  preserving `type`/`requestOptions`/`response`). This marks the otherwise
  ordinary connection-level error as "failover exhausted" for the mapper.
- **Non-retriable** errors (4xx, malformed 2xx) propagate immediately with
  no rotation.

### Mirror write-back

When a response succeeds against a mirror whose host differs from the
cached one, the interceptor calls `cache.setLastKnownMirror(host)` with the
**bare host**. Persisting is best-effort: a write failure MUST NOT fail the
request (it is swallowed).

### Error mapping and the data-source boundary

`mapDioException` maps:

| Dio condition | Failure |
|---|---|
| `connectionTimeout` / `sendTimeout` / `receiveTimeout` | `ConnectionTimeoutFailure` |
| `connectionError` (socket/DNS) | `SocketFailure` |
| `badResponse` 5xx | `ServerFailure` |
| `badResponse` 422 | `ValidationErrorFailure` |
| `badResponse` 401 / 403 | `UnauthorizedFailure` |
| failover exhausted — any `DioException` whose `error` is a `MirrorFailoverExhausted` sentinel (caps hit on retriable errors) | `MirrorFailure` |

The exhausted-failover row is checked **first**: when `error` is a
`MirrorFailoverExhausted`, `mapDioException` returns `MirrorFailure`
regardless of `DioExceptionType` (e.g. a tagged `connectionError` maps to
`MirrorFailure`, not `SocketFailure`).

Remote data sources wrap each Dio call in `try/catch`, call
`mapDioException`, and `throw NetworkException(failure)`. They do **not**
return `Result` — converting `NetworkException` into
`Result<T, Failure>` is the Phase 6 repository's job (`ARCHITECTURE.md`).
This keeps Dio specifics inside `core/network` + `data/datasources`
(`API_SPEC.md` §9) while honouring the repository's conversion role.

Malformed/empty payloads follow `API_SPEC.md` §4: list endpoints return an
empty list rather than throwing where a payload is merely empty.

## Consequences

### Positive
- One place owns rotation, caps, and write-back; the domain and
  presentation layers never see mirrors or Dio.
- Reuses the existing failures; only a thin `NetworkException` carrier is
  added.
- The async factory matches ADR-0016's initialisation contract.

### Negative
- Re-dispatching inside an interceptor with per-request attempt state is
  more intricate than a single request; it needs careful testing with a
  mocked adapter.
- A `NetworkException` carrier is an extra type, justified by `Failure`
  not being an `Exception`.

### Neutral
- The factory depends on `MirrorCacheDataSource` (a Phase 4 local data
  source), wiring the network layer to local storage exactly as ADR-0016
  anticipated.

## Alternatives considered

### Option A — Loop over mirrors in each data-source method
Rejected. Spreads rotation/caps/write-back across every call site and
leaks mirror concerns out of `core/network`.

### Option B — Data sources return `Result<T, Failure>` directly
Rejected. Duplicates the repository's documented conversion role and makes
every data-source signature carry `Result`. Throwing a typed
`NetworkException` keeps signatures clean and defers `Result` to Phase 6.

### Option C — `dio_smart_retry` / external retry package
Rejected. The 2-per-mirror / 6-total + host-rotation + write-back policy is
bespoke; an external package would not match it and adds a dependency
outside ADR-0018.

## Documentation impact

- `docs/adr/README.md` — add the ADR-0039 index row.
- `MEMORY.md` — add the decision-log entry.
- `ROADMAP.md` Phase 5 — note the failover lives in `MirrorFailoverInterceptor`
  + `DioClientFactory`, and remote data sources throw `NetworkException`.
- No `API_SPEC.md` change: this ADR implements §2/§4/§9 as written.

## Follow-ups

- Phase 6 repositories catch `NetworkException` and return
  `Result.failure(e.failure)`.
