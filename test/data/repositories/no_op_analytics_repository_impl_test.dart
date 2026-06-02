import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/data/repositories/no_op_analytics_repository_impl.dart';
import 'package:radio_app/domain/entities/analytics/analytics_event.dart';
import 'package:radio_app/domain/repositories/analytics_repository.dart';

void main() {
  group('NoOpAnalyticsRepositoryImpl', () {
    test('is an AnalyticsRepository (default no-op registration)', () {
      expect(const NoOpAnalyticsRepositoryImpl(), isA<AnalyticsRepository>());
    });

    test('track completes normally for any event without throwing', () async {
      const repository = NoOpAnalyticsRepositoryImpl();

      await expectLater(repository.track(const AppOpenedEvent()), completes);
      await expectLater(
        repository.track(const ScreenViewedEvent('home')),
        completes,
      );
      await expectLater(
        repository.track(
          const StationPlayedEvent(
            stationUuid: 'uuid',
            stationName: 'Jazz FM',
            countryCode: 'DE',
          ),
        ),
        completes,
      );
    });
  });
}
