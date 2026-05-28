# ADR-0019 — Analytics interface (provider-agnostic)

- **Status:** Accepted
- **Date:** 2026-05-28
- **Deciders:** David Ruiz
- **Related:** `ARCHITECTURE.md` §"Repository Contracts", `TECHNICAL_SPEC.md` §4, `TODO.md`

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

Product analytics is required to measure usage patterns and inform
future iterations of the application. The choice of analytics provider
(Firebase Analytics, Amplitude, Mixpanel, PostHog, or another) has
**not** been made. Locking in a provider now would couple the
application to that SDK and force a refactor when the choice is
revisited.

The architectural pattern used elsewhere in the project — abstract a
boundary in `domain/repositories/`, implement in `data/repositories/`,
inject through `get_it` — applies cleanly: analytics is a side-effect
concern with multiple potential backends.

Two design dimensions need to be fixed before any provider is chosen:

1. **Event modelling.** Whether events are typed sealed entities
   (`StationPlayedEvent(...)`) or generic key/value pairs
   (`logEvent("station_played", {...})`).
2. **Privacy.** Any real analytics provider triggers GDPR obligations
   for the European audience. The interface itself does not, but its
   activation does.

## Decision

### Event modelling

Events are modelled as a **sealed type hierarchy** under
`domain/entities/analytics/`. Each event is an immutable, equatable
data class describing a specific user-meaningful action.

```dart
sealed class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
}

final class AppOpenedEvent extends AnalyticsEvent {
  const AppOpenedEvent();
}

final class ScreenViewedEvent extends AnalyticsEvent {
  final String screenName;
  const ScreenViewedEvent(this.screenName);
}

final class StationPlayedEvent extends AnalyticsEvent {
  final String stationUuid;
  final String stationName;
  final String countryCode;
  const StationPlayedEvent({
    required this.stationUuid,
    required this.stationName,
    required this.countryCode,
  });
}

final class StationStoppedEvent extends AnalyticsEvent {
  final String stationUuid;
  final int durationSeconds;
  const StationStoppedEvent({
    required this.stationUuid,
    required this.durationSeconds,
  });
}

final class StationFavoritedEvent extends AnalyticsEvent {
  final String stationUuid;
  const StationFavoritedEvent(this.stationUuid);
}

final class StationUnfavoritedEvent extends AnalyticsEvent {
  final String stationUuid;
  const StationUnfavoritedEvent(this.stationUuid);
}

final class SearchPerformedEvent extends AnalyticsEvent {
  final int queryLength;     // length, not the literal query, for privacy
  final int resultCount;
  const SearchPerformedEvent({
    required this.queryLength,
    required this.resultCount,
  });
}

final class FilterAppliedEvent extends AnalyticsEvent {
  final String filterType;   // "country" | "genre"
  final String value;
  const FilterAppliedEvent({
    required this.filterType,
    required this.value,
  });
}

final class PlaybackErrorEvent extends AnalyticsEvent {
  final String stationUuid;
  final String failureType;  // class name of the PlaybackFailure variant
  const PlaybackErrorEvent({
    required this.stationUuid,
    required this.failureType,
  });
}
```

The catalogue above is the **initial event surface**. Adding events
later requires extending the sealed hierarchy and updating any provider
adapter implementations to translate them appropriately.

### Repository contract

```dart
abstract class AnalyticsRepository {
  Future<void> track(AnalyticsEvent event);
}
```

The repository contract lives in `domain/repositories/`. It MUST NOT
depend on any SDK.

### Use case

BLoCs MUST depend on use cases only (per `ARCHITECTURE.md`
§"Dependency Rule"). Therefore a thin use case wraps the repository:

```dart
class TrackAnalyticsEventUseCase {
  final AnalyticsRepository _repository;
  const TrackAnalyticsEventUseCase(this._repository);

  Future<void> call(AnalyticsEvent event) =>
      _repository.track(event);
}
```

Future cross-cutting concerns (sampling, filtering, debouncing) MAY be
implemented in this use case without touching BLoCs.

### Default implementation

A `NoOpAnalyticsRepositoryImpl` MUST be implemented and registered in
the composition root from Phase 6 onwards. It accepts every event and
discards it.

```dart
class NoOpAnalyticsRepositoryImpl implements AnalyticsRepository {
  @override
  Future<void> track(AnalyticsEvent event) async {
    // intentionally no-op
  }
}
```

Rationale: BLoCs can fire analytics calls from Phase 7 onwards without
the application depending on a third-party SDK or triggering any
privacy obligation. Swapping providers later is a single line change
in the composition root.

### Instrumentation policy

Each BLoC owns the responsibility of firing the appropriate
`AnalyticsEvent` at the right transition. The minimal initial mapping
is:

| BLoC | Event(s) fired |
|---|---|
| Application bootstrap | `AppOpenedEvent` |
| `AppShell` / router | `ScreenViewedEvent(screenName)` on each route entry |
| `RadioPlayerBloc` | `StationPlayedEvent` on transition to `PlayerPlayingState`; `StationStoppedEvent` on transition out of `PlayerPlayingState` or `PlayerPausedState`; `PlaybackErrorEvent` on transition to `PlayerErrorState` |
| `FavoritesBloc` | `StationFavoritedEvent` / `StationUnfavoritedEvent` after persistence succeeds |
| `StationsBloc` | `SearchPerformedEvent` after a successful search use-case call; `FilterAppliedEvent` after `FilterByCountry` or `FilterByGenre` |

Events that depend on durations (e.g. `StationStoppedEvent.durationSeconds`)
MUST be computed by the bloc from the `PlayerPlayingState` transition
timestamps, not from external clocks.

### Privacy / GDPR

The `NoOpAnalyticsRepositoryImpl` performs no I/O, transmits no data,
and stores no data. It therefore triggers no GDPR obligations.

Any **real** analytics provider implementation triggers GDPR
obligations for the European audience. Therefore:

- A consent flow (opt-in modal at first launch, persisted choice,
  ability to revoke) MUST be implemented **before** any real provider
  adapter is registered in the composition root.
- A user-facing privacy policy MUST be linked from the consent flow
  before any real provider adapter is registered.
- The chosen provider MUST be configurable to respect the user's
  consent state at runtime.

These obligations are tracked in `TODO.md` under "Analytics".

### Out of scope under this ADR

- The choice of analytics provider.
- The implementation of a real provider adapter.
- The consent flow UI and persistence.
- The privacy policy text.
- Server-side proxies, anonymisation pipelines, or DSAR tooling.

## Consequences

### Positive
- BLoCs can be fully instrumented from Phase 7 onwards without
  committing to a provider.
- Swapping providers later is a one-line change in the composition
  root, plus implementing the adapter.
- Typed events provide compile-time guarantees and prevent the
  "magic strings" failure mode of generic interfaces.
- No GDPR exposure during development because the no-op
  implementation transmits no data.

### Negative
- Eight initial event classes add some up-front domain surface.
- Adding a new event requires touching the sealed hierarchy, every
  adapter implementation that exists, and the corresponding BLoC.
- Privacy obligations become explicit and must be addressed before any
  provider is activated. This is documentation cost, not engineering
  cost.

### Neutral
- The catalogue may evolve. Renaming or removing an event after a
  provider has been active in production would require coordinated
  data migration on the provider side; the no-op phase is the right
  moment to refine.

## Alternatives considered

### Option A2 — Generic `logEvent(name, parameters)` interface
Rejected. Reintroduces magic strings, loses compile-time guarantees,
and tends toward divergence ("station_played" vs "stationPlayed").

### Option B2 — BLoCs depend directly on `AnalyticsRepository`
Rejected. Would require an explicit exception to the dependency rule
in `ARCHITECTURE.md`. The use case wrapper costs ~5 lines and keeps the
rule clean.

### Option C2 — `InMemoryAnalyticsRepositoryImpl` for development inspection
Rejected. Adds state without providing meaningful value over the no-op
implementation for v1.

### Option E1 — Consent flow implemented from v1
Rejected. While the application uses the no-op implementation, no
tracking takes place; a consent flow would gate a non-existent
behaviour. The flow is deferred to the moment a real provider is
chosen, ensuring the two pieces of work are kept in sync.

### Pick a provider now and instrument directly
Rejected. The choice of provider is intentionally deferred; locking it
in would force a future refactor.

## Documentation impact

- `ARCHITECTURE.md` §"Repository Contracts" — add `AnalyticsRepository`
  to the required interfaces and `NoOpAnalyticsRepositoryImpl` to the
  required implementations.
- `TECHNICAL_SPEC.md` §4 — note that BLoCs fire `AnalyticsEvent`s
  through `TrackAnalyticsEventUseCase`; reference this ADR for the
  instrumentation table.
- `ROADMAP.md`:
  - Phase 2 — add `AnalyticsEvent` sealed hierarchy under
    `domain/entities/analytics/`.
  - Phase 2 — add `AnalyticsRepository` to the repository interfaces.
  - Phase 3 — add `TrackAnalyticsEventUseCase` to the use case list.
  - Phase 6 — add `NoOpAnalyticsRepositoryImpl` registration in the
    composition root.
  - Phase 7 — add instrumentation calls per the table above to the
    affected BLoCs.
- `TESTING_STRATEGY.md` — add a section on analytics:
  - Unit-test the `NoOpAnalyticsRepositoryImpl` (it MUST accept every
    `AnalyticsEvent` subtype without throwing).
  - Each instrumented BLoC test MUST assert that the expected
    `TrackAnalyticsEventUseCase` call is made on the relevant
    transition, using `mocktail` verifications.
- `TODO.md` — add three items under a new "Analytics" section:
  1. Choose analytics provider (Firebase, Amplitude, Mixpanel,
     PostHog, etc.).
  2. Implement provider-specific adapter against this ADR's contract.
  3. Implement GDPR consent flow and link a privacy policy **before**
     the real adapter is registered.

## Follow-ups

- A future ADR will record the provider choice and supersede the
  no-op registration with the real adapter.
- A future ADR will define the consent-flow UX and persistence shape.
