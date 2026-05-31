import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';

/// Domain contract for station discovery and search.
abstract interface class StationRepository {
  /// Searches stations using optional query and filter parameters.
  Future<Result<List<RadioStation>, Failure>> searchStations({
    String? query,
    String? countryCode,
    String? tag,
    int limit = 30,
    int offset = 0,
  });

  /// Loads popular stations using the configured popularity strategy.
  Future<Result<List<RadioStation>, Failure>> loadPopularStations({
    int limit = 30,
    int offset = 0,
  });

  /// Cancels any pending station requests.
  Future<Result<void, Failure>> cancelPendingRequests();
}
