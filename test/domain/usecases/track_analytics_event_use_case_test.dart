import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/domain/entities/analytics/analytics_event.dart';
import 'package:radio_app/domain/repositories/analytics_repository.dart';
import 'package:radio_app/domain/usecases/track_analytics_event_use_case.dart';

void main() {
  group('TrackAnalyticsEventUseCase', () {
    test('delegates the event to the repository', () async {
      const event = AppOpenedEvent();
      final repository = _FakeAnalyticsRepository();
      final useCase = TrackAnalyticsEventUseCase(repository);

      await useCase(event);

      expect(repository.trackedEvents, [event]);
    });

    test('forwards every event in call order', () async {
      const events = <AnalyticsEvent>[
        ScreenViewedEvent('home'),
        StationFavoritedEvent('station-uuid'),
        SearchPerformedEvent(queryLength: 4, resultCount: 12),
      ];
      final repository = _FakeAnalyticsRepository();
      final useCase = TrackAnalyticsEventUseCase(repository);

      for (final event in events) {
        await useCase(event);
      }

      expect(repository.trackedEvents, events);
    });

    test('returns the repository future without swallowing its completion', () {
      const event = AppOpenedEvent();
      final repository = _FakeAnalyticsRepository();
      final useCase = TrackAnalyticsEventUseCase(repository);

      expect(useCase(event), completes);
    });

    test('does not propagate analytics repository failures to the caller '
        '(per TESTING_STRATEGY §Analytics / ADR-0019)', () {
      const event = AppOpenedEvent();
      final useCase = TrackAnalyticsEventUseCase(
        _ThrowingAnalyticsRepository(),
      );

      // A failing `track` (e.g. a real provider's network error) MUST be
      // swallowed at the use-case level so it never surfaces as an
      // unhandled async error in the calling BLoC.
      expect(useCase(event), completes);
    });
  });
}

class _FakeAnalyticsRepository implements AnalyticsRepository {
  final List<AnalyticsEvent> trackedEvents = <AnalyticsEvent>[];

  @override
  Future<void> track(AnalyticsEvent event) async {
    trackedEvents.add(event);
  }
}

class _ThrowingAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<void> track(AnalyticsEvent event) async {
    throw Exception('analytics backend unavailable');
  }
}
