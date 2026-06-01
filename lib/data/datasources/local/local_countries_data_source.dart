import 'package:hive_ce/hive.dart';
import 'package:radio_app/data/models/country_hive_model.dart';
import 'package:radio_app/domain/entities/country.dart';

/// Local cache boundary for filter countries (per ADR-0037).
///
/// Exposes domain entities; the [CountryHiveModel] persistence type never
/// crosses this boundary.
abstract interface class LocalCountriesDataSource {
  /// Returns the cached countries.
  Future<List<Country>> getCachedCountries();

  /// Replaces the whole cache with [countries].
  Future<void> cacheCountries(List<Country> countries);
}

/// Hive-backed [LocalCountriesDataSource] over the `countries` box.
class HiveLocalCountriesDataSource implements LocalCountriesDataSource {
  /// Creates the data source over an already-open Hive box.
  HiveLocalCountriesDataSource(this._box);

  final Box<CountryHiveModel> _box;

  @override
  Future<List<Country>> getCachedCountries() async {
    return _box.values
        .map((CountryHiveModel model) => model.toEntity())
        .toList();
  }

  @override
  Future<void> cacheCountries(List<Country> countries) async {
    await _box.clear();
    await _box.putAll(<String, CountryHiveModel>{
      for (final Country country in countries)
        country.countryCode: CountryHiveModel.fromEntity(country),
    });
  }
}
