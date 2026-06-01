import 'package:hive_ce/hive.dart';
import 'package:radio_app/domain/entities/country.dart';

part 'country_hive_model.g.dart';

/// Hive persistence model for a cached [Country] (per ADR-0037, `typeId` 2).
@HiveType(typeId: 2)
class CountryHiveModel {
  /// Creates a Hive persistence model.
  CountryHiveModel({
    required this.name,
    required this.countryCode,
    required this.stationCount,
  });

  /// Projects a domain [country] into its persistence model.
  factory CountryHiveModel.fromEntity(Country country) {
    return CountryHiveModel(
      name: country.name,
      countryCode: country.countryCode,
      stationCount: country.stationCount,
    );
  }

  /// Localized human-readable country name.
  @HiveField(0)
  final String name;

  /// ISO 3166-1 alpha-2 country code.
  @HiveField(1)
  final String countryCode;

  /// Optional number of stations associated with this country.
  @HiveField(2)
  final int? stationCount;

  /// Rebuilds the domain entity from the persisted model.
  Country toEntity() {
    return Country(
      name: name,
      countryCode: countryCode,
      stationCount: stationCount,
    );
  }
}
