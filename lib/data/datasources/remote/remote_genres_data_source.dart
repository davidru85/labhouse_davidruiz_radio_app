import 'package:dio/dio.dart';
import 'package:radio_app/core/network/network_error_mapper.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/data/models/genre_dto.dart';
import 'package:radio_app/domain/entities/genre.dart';

/// Remote data source for filter genres (Radio Browser `/json/tags`).
// ignore: one_member_abstracts
abstract interface class RemoteGenresDataSource {
  /// Fetches the available genres/tags.
  Future<List<Genre>> getGenres();
}

/// Dio-based [RemoteGenresDataSource].
class DioRemoteGenresDataSource implements RemoteGenresDataSource {
  /// Creates the data source over a configured Dio client (per ADR-0039).
  DioRemoteGenresDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<Genre>> getGenres() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/json/tags',
        queryParameters: const <String, dynamic>{
          'hidebroken': true,
          'order': 'stationcount',
          'reverse': true,
          'limit': 50,
        },
      );
      final data = response.data ?? const <dynamic>[];
      final genres = <Genre>[];
      for (final dynamic item in data) {
        final genre = _tryParse(item);
        if (genre != null) {
          genres.add(genre);
        }
      }
      return genres;
    } on DioException catch (exception) {
      throw NetworkException(mapDioException(exception));
    }
  }

  /// Parses a single `/json/tags` entry, skipping malformed or non-map
  /// items so partial payloads degrade gracefully (per `API_SPEC.md` §4).
  Genre? _tryParse(dynamic item) {
    if (item is! Map<String, dynamic> || item['name'] is! String) {
      return null;
    }
    return GenreDto.fromJson(item).toEntity();
  }
}
