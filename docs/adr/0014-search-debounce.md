# ADR-0014 — Search debounce and request cancellation

- **Status:** Accepted
- **Date:** 2026-05-28
- **Deciders:** David Ruiz
- **Related:** `TECHNICAL_SPEC.md` §4, `API_SPEC.md` §5.1, `ROADMAP.md` Phase 7

## Context

The `StationsBloc` exposes a `SearchStations` event. The original
specification does not state how user input throttles into actual
HTTP requests against the Radio Browser API. Without an explicit
policy:

- Every keystroke risks producing an HTTP request.
- Mirrors of the public, community-maintained Radio Browser API
  receive disproportionate load from a single user typing a query.
- In-flight requests for older prefixes can deliver their responses
  after newer ones, overwriting state with stale results (the
  classic search-race-condition).

The decision has four dimensions:

1. How long to wait after the last keystroke before firing the
   request (debounce window).
2. How short a query is allowed to fire (minimum character count).
3. Where the debounce lives in the architecture.
4. Whether in-flight requests are cancelled when a new search is
   triggered.

## Decision

### Debounce window: 350 ms

The `StationsBloc` waits **350 ms** of input inactivity after the
last `SearchStations` event before dispatching the corresponding
use case. The 350 ms window is the de-facto industry standard for
search autocomplete (used by Google Search, Algolia, and others) and
balances perceived responsiveness against API load.

### Minimum query length: 3 characters

`SearchStations` only triggers an actual remote query when the
trimmed input has **at least three characters**. Below that
threshold the result set against Radio Browser is dominated by
noise, and the query produces high cardinality with low signal.

Special cases:

- Inputs of zero characters after trim — the user cleared the
  field — map to a "load popular stations" behaviour (Radio Browser
  search with `order=clickcount`, `reverse=true`, `limit=30`, no
  `name` parameter). This is consistent with the default population
  of the Stations screen.
- Inputs of one or two characters after trim are ignored: no
  request is fired and the previous state is preserved.

### Architectural placement: BLoC layer

Debounce is implemented in the `StationsBloc` using
`flutter_bloc`'s `EventTransformer` API combined with
`stream_transform`. Concretely, the `SearchStations` event handler
is registered with a transformer of the shape
`(events, mapper) => events.debounce(Duration(milliseconds: 350)).switchMap(mapper)`.

The presentation layer (the search input widget) dispatches a
`SearchStations` event on **every** keystroke. The widget does not
know about debounce; the bloc owns the timing.

`stream_transform` is preferred over `rxdart` because it is
maintained by the Dart team, has a minimal surface, and ships only
the operators actually needed here (`debounce`, `switchMap`).

### Request cancellation

Each in-flight HTTP request carries a `CancelToken` (`Dio`) managed entirely inside the network and data layers (specifically in the `RemoteStationDataSource`). The presentation layer (BLoCs) remains completely unaware of `Dio`'s cancellation tokens. 

Cancellation happens under two scenarios:

1. **Automatic cancellation on supersession:** When a new search or filter request is initiated, the `RemoteStationDataSource` automatically cancels the `CancelToken` of the previously active search request before launching the new request.
2. **Explicit cancellation:** The `StationRepository` contract exposes a `cancelSearch()` method (wrapped in a `CancelSearchUseCase`). The `StationsBloc` calls this use case when a `StationPlayRequested` event occurs or when the bloc is disposed, indicating that the user is navigating away and search results are no longer needed.

This ensures stale responses from previous HTTP requests do not overwrite the state, and prevents wasted bandwidth without leaking `Dio` types into the domain or presentation layers.

### Exact timeline

| User action | Time | Bloc behaviour | Network / Data Layer behaviour |
|---|---|---|---|
| Types `r` | t=0 | Below 3-char floor: ignored | None |
| Types `ra` | t=200 ms | Below 3-char floor: ignored | None |
| Types `rad` | t=400 ms | At floor; debounce timer starts | None |
| Types `radio` | t=550 ms | Debounce timer restarts | None |
| Stops typing | – | Counts 350 ms of inactivity | None |
| – | t=900 ms | `SearchStationsUseCase("radio")` invoked | Remote data source starts request with a fresh `CancelToken` |
| Types `radio rock` | t=1200 ms | Previous request is superseded | Previous `CancelToken` is cancelled by remote data source; new request starts with a fresh token |

## Consequences

### Positive
- API load is bounded by the user's pause behaviour rather than
  their keystroke rate.
- Race conditions cannot deliver stale results to the UI because
  cancelled requests do not produce state transitions.
- Debounce and minimum-length policies are testable in isolation
  inside the bloc.
- The search input widget remains stateless apart from its
  controller; UX behaviour lives entirely in the bloc.

### Negative
- A small additional dependency (`stream_transform`) is added.
- The 3-character floor means very short station names cannot be
  searched directly. Acceptable trade-off given the noise pattern
  of the Radio Browser data.

### Neutral
- The choice of 350 ms is a conventional pick. A future ADR may
  revise it based on telemetry once such telemetry exists.

## Alternatives considered

### Debounce 250 ms
Rejected. Too aggressive for HTTP against a public API; perceived
responsiveness gain is marginal and load reduction is meaningfully
worse.

### Debounce 500 ms or higher
Rejected. Perceptible lag for the user when typing finishes.

### Minimum query length 2 characters
Rejected. Trade-off favoured by some UI patterns but produces
excessive noise against the Radio Browser corpus.

### Debounce in the UI widget with a `Timer`
Rejected. Places timing logic in the presentation layer, contradicts
the architectural rule that the bloc owns event flow, and complicates
testing.

### `rxdart` as the stream operator source
Rejected. Larger surface than needed; `stream_transform` is the
minimal, Dart-team-maintained alternative.

### No request cancellation, response-side guard with sequence numbers
Rejected. Workable but more code than `CancelToken` and still
incurs wasted network round trips.

## Documentation impact

- `TECHNICAL_SPEC.md` §2 — add `stream_transform` under production
  dependencies.
- `TECHNICAL_SPEC.md` §4 — annotate `SearchStations` on the
  `StationsBloc` row with "debounced 350 ms, minimum 3 characters".
- `API_SPEC.md` §5.1 — note that the application enforces a
  client-side minimum query length of 3 characters before reaching
  the Radio Browser endpoint.
- `ROADMAP.md` Phase 7 — under `StationsBloc`, mention
  `EventTransformer` with a 350 ms `debounce` and `switchMap` of the
  use case.
- `TESTING_STRATEGY.md` §`StationsBloc` — add test cases:
  - `SearchStations` events under 3 characters do not fire a
    request.
  - Rapid `SearchStations` events within 350 ms collapse to a single
    use case call.
  - An in-flight request is cancelled when a new `SearchStations`,
    `FilterByCountry`, or `FilterByGenre` event arrives.
  - A `SearchStations("")` event maps to the popular-stations
    behaviour.
- `VALIDATION_CHECKLIST.md` §Radio Browser Integration — add:
  - Search debounce window: 350 ms.
  - Minimum search query length: 3 characters.
  - In-flight requests cancelled on supersession.

## Follow-ups

- Telemetry of search latency could justify revising the debounce
  window. No telemetry is planned in v1.
- A future ADR may introduce a server-side or client-side cache of
  recent searches if API load becomes a concern.
