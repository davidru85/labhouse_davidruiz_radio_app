import 'package:equatable/equatable.dart';

/// Base sealed type for all analytics events.
sealed class AnalyticsEvent extends Equatable {
  /// Creates an analytics event.
  const AnalyticsEvent();
}

/// Event emitted when the application opens.
final class AppOpenedEvent extends AnalyticsEvent {
  /// Creates an app-opened event.
  const AppOpenedEvent();

  @override
  List<Object?> get props => [];
}

/// Event emitted when a screen is viewed.
final class ScreenViewedEvent extends AnalyticsEvent {
  /// Creates a screen-viewed event.
  const ScreenViewedEvent(this.screenName);

  /// Logical screen name.
  final String screenName;

  @override
  List<Object?> get props => [screenName];
}

/// Event emitted when station playback starts.
final class StationPlayedEvent extends AnalyticsEvent {
  /// Creates a station-played event.
  const StationPlayedEvent({
    required this.stationUuid,
    required this.stationName,
    required this.countryCode,
  });

  /// Stable Radio Browser station UUID.
  final String stationUuid;

  /// Human-readable station name.
  final String stationName;

  /// ISO 3166-1 alpha-2 country code.
  final String countryCode;

  @override
  List<Object?> get props => [stationUuid, stationName, countryCode];
}

/// Event emitted when station playback stops.
final class StationStoppedEvent extends AnalyticsEvent {
  /// Creates a station-stopped event.
  const StationStoppedEvent({
    required this.stationUuid,
    required this.durationSeconds,
  });

  /// Stable Radio Browser station UUID.
  final String stationUuid;

  /// Playback duration in seconds.
  final int durationSeconds;

  @override
  List<Object?> get props => [stationUuid, durationSeconds];
}

/// Event emitted when a station is favorited.
final class StationFavoritedEvent extends AnalyticsEvent {
  /// Creates a station-favorited event.
  const StationFavoritedEvent(this.stationUuid);

  /// Stable Radio Browser station UUID.
  final String stationUuid;

  @override
  List<Object?> get props => [stationUuid];
}

/// Event emitted when a station is removed from favorites.
final class StationUnfavoritedEvent extends AnalyticsEvent {
  /// Creates a station-unfavorited event.
  const StationUnfavoritedEvent(this.stationUuid);

  /// Stable Radio Browser station UUID.
  final String stationUuid;

  @override
  List<Object?> get props => [stationUuid];
}

/// Event emitted after a successful search.
final class SearchPerformedEvent extends AnalyticsEvent {
  /// Creates a search-performed event.
  const SearchPerformedEvent({
    required this.queryLength,
    required this.resultCount,
  });

  /// Length of the search query, without storing the literal query.
  final int queryLength;

  /// Number of results returned by the search.
  final int resultCount;

  @override
  List<Object?> get props => [queryLength, resultCount];
}

/// Event emitted when a filter is applied.
final class FilterAppliedEvent extends AnalyticsEvent {
  /// Creates a filter-applied event.
  const FilterAppliedEvent({required this.filterType, required this.value});

  /// Filter type, such as `country` or `genre`.
  final String filterType;

  /// Applied filter value.
  final String value;

  @override
  List<Object?> get props => [filterType, value];
}

/// Event emitted when playback fails.
final class PlaybackErrorEvent extends AnalyticsEvent {
  /// Creates a playback-error event.
  const PlaybackErrorEvent({
    required this.stationUuid,
    required this.failureType,
  });

  /// Stable Radio Browser station UUID.
  final String stationUuid;

  /// Failure class name or stable failure type.
  final String failureType;

  @override
  List<Object?> get props => [stationUuid, failureType];
}
