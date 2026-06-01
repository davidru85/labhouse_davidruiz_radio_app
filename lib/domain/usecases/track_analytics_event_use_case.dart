import 'package:radio_app/domain/entities/analytics/analytics_event.dart';
import 'package:radio_app/domain/repositories/analytics_repository.dart';

/// Relays analytics events to the repository for the presentation layer.
///
/// A thin fire-and-forget wrapper (per ADR-0019): it returns the
/// repository future directly, with no `Result` wrapping, because
/// [AnalyticsRepository.track] never propagates analytics failures to
/// callers. Future cross-cutting concerns (sampling, debouncing) MAY be
/// added here without touching BLoCs.
final class TrackAnalyticsEventUseCase {
  /// Creates an analytics tracking use case.
  const TrackAnalyticsEventUseCase(this._repository);

  final AnalyticsRepository _repository;

  /// Tracks [event] through the analytics repository.
  Future<void> call(AnalyticsEvent event) => _repository.track(event);
}
