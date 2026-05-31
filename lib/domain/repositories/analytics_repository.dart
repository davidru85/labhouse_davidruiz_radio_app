import 'package:radio_app/domain/entities/analytics/analytics_event.dart';

/// Domain contract for privacy-preserving analytics events.
// ignore: one_member_abstracts
abstract interface class AnalyticsRepository {
  /// Tracks [event] without propagating analytics failures to callers.
  Future<void> track(AnalyticsEvent event);
}
