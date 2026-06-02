import 'package:radio_app/domain/entities/analytics/analytics_event.dart';
import 'package:radio_app/domain/repositories/analytics_repository.dart';

/// Default no-op [AnalyticsRepository] registered in the composition root
/// until a concrete provider adapter is chosen (per ADR-0019).
class NoOpAnalyticsRepositoryImpl implements AnalyticsRepository {
  /// Creates the no-op analytics repository.
  const NoOpAnalyticsRepositoryImpl();

  @override
  Future<void> track(AnalyticsEvent event) async {
    // Intentionally does nothing: analytics events are swallowed by default.
  }
}
