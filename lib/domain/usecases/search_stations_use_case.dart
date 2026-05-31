import 'package:equatable/equatable.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/station_repository.dart';

/// Searches stations by name and optional filter metadata.
final class SearchStationsUseCase {
  /// Creates a station search use case.
  const SearchStationsUseCase(this._repository);

  final StationRepository _repository;

  /// Executes a station search with [params].
  Future<Result<List<RadioStation>, Failure>> call(
    SearchStationsParams params,
  ) {
    return _repository.searchStations(
      query: params.query,
      countryCode: params.countryCode,
      tag: params.tag,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

/// Parameters for [SearchStationsUseCase].
final class SearchStationsParams extends Equatable {
  /// Creates station search parameters.
  const SearchStationsParams({
    this.query,
    this.countryCode,
    this.tag,
    this.limit = 30,
    this.offset = 0,
  });

  /// Optional station name search term.
  final String? query;

  /// Optional ISO country code filter.
  final String? countryCode;

  /// Optional Radio Browser tag filter.
  final String? tag;

  /// Maximum number of stations requested.
  final int limit;

  /// Result offset for pagination.
  final int offset;

  @override
  List<Object?> get props => [query, countryCode, tag, limit, offset];
}
