import 'package:dio/dio.dart';
import 'package:radio_app/core/network/network_error_mapper.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/data/models/country_code_dto.dart';
import 'package:radio_app/domain/entities/country.dart';

/// Remote data source for filter countries (Radio Browser
/// `/json/countrycodes`).
// ignore: one_member_abstracts
abstract interface class RemoteCountriesDataSource {
  /// Fetches the available country codes.
  Future<List<Country>> getCountries();
}

/// Dio-based [RemoteCountriesDataSource].
class DioRemoteCountriesDataSource implements RemoteCountriesDataSource {
  /// Creates the data source over a configured Dio client (per ADR-0039).
  DioRemoteCountriesDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<Country>> getCountries() async {
    try {
      final response = await _dio.get<List<dynamic>>('/json/countrycodes');
      final data = response.data ?? const <dynamic>[];
      final countries = <Country>[];
      for (final dynamic item in data) {
        final country = _tryParse(item);
        if (country != null) {
          countries.add(country);
        }
      }
      return countries;
    } on DioException catch (exception) {
      throw NetworkException(mapDioException(exception));
    }
  }

  /// Parses a single `/json/countrycodes` entry, skipping malformed or
  /// non-map items so partial payloads degrade gracefully
  /// (per `API_SPEC.md` §4).
  Country? _tryParse(dynamic item) {
    if (item is! Map<String, dynamic> || item['name'] is! String) {
      return null;
    }
    return CountryCodeDto.fromJson(item).toEntity();
  }
}
