import 'package:equatable/equatable.dart';

/// Immutable domain representation of a country filter option.
final class Country extends Equatable {
  /// Creates a country domain entity.
  const Country({
    required this.name,
    required this.countryCode,
    required this.stationCount,
  });

  /// Localized human-readable country name.
  final String name;

  /// ISO 3166-1 alpha-2 country code.
  final String countryCode;

  /// Optional number of stations associated with this country.
  final int? stationCount;

  @override
  List<Object?> get props => [name, countryCode, stationCount];
}
