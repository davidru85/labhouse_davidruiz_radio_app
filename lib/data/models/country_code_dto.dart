import 'package:radio_app/domain/entities/country.dart';

/// Data-layer model for a Radio Browser country-code JSON payload.
///
/// `/json/countrycodes` returns the ISO code in the `name` field; the
/// localized display name is resolved at the presentation boundary
/// (per ADR-0032, amended 2026-06-01).
class CountryCodeDto {
  /// Creates a country-code DTO.
  CountryCodeDto({required this.code, required this.stationCount});

  /// Parses a Radio Browser `/json/countrycodes` JSON object.
  factory CountryCodeDto.fromJson(Map<String, dynamic> json) {
    return CountryCodeDto(
      code: json['name'] as String,
      stationCount: json['stationcount'] as int?,
    );
  }

  /// ISO 3166-1 alpha-2 code (the API's `name` field).
  final String code;

  /// Raw `stationcount`.
  final int? stationCount;

  /// Maps this DTO to a domain [Country].
  ///
  /// The name is left as the raw ISO code; presentation localizes it.
  Country toEntity() {
    return Country(name: code, countryCode: code, stationCount: stationCount);
  }
}
