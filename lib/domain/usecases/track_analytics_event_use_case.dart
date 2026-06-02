import 'package:radio_app/domain/entities/analytics/analytics_event.dart';
import 'package:radio_app/domain/repositories/analytics_repository.dart';

/// Relays analytics events to the repository for the presentation layer.
///
/// A thin fire-and-forget wrapper (per ADR-0019): it returns no `Result`
/// and swallows any error from [AnalyticsRepository.track] so an analytics
/// backend failure (e.g. a real provider's network error) never propagates
/// to the calling BLoC as an unhandled async error. Future cross-cutting
/// concerns (sampling, debouncing) MAY be added here without touching BLoCs.
final class TrackAnalyticsEventUseCase {
  /// Creates an analytics tracking use case.
  const TrackAnalyticsEventUseCase(this._repository);

  final AnalyticsRepository _repository;

  /// Tracks [event] through the analytics repository, isolating any failure
  /// (per ADR-0019 / TESTING_STRATEGY §Analytics).
  Future<void> call(AnalyticsEvent event) async {
    try {
      await _repository.track(event);
    } on Object {
      // Analytics is best-effort: failures MUST NOT surface to callers.
    }
  }
}
