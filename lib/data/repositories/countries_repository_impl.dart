import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/data/datasources/local/local_countries_data_source.dart';
import 'package:radio_app/data/datasources/remote/remote_countries_data_source.dart';
import 'package:radio_app/domain/entities/country.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/countries_repository.dart';

/// [CountriesRepository] that serves countries network-first with a Hive
/// cache fallback for offline access (per ADR-0013 / `API_SPEC.md` §5.4).
class CountriesRepositoryImpl implements CountriesRepository {
  /// Creates the repository over remote and local country data sources.
  CountriesRepositoryImpl(this._remote, this._local);

  final RemoteCountriesDataSource _remote;
  final LocalCountriesDataSource _local;

  @override
  Future<Result<List<Country>, Failure>> getCountries() async {
    try {
      final countries = await _remote.getCountries();
      await _cacheBestEffort(countries);
      return Success<List<Country>, Failure>(countries);
    } on NetworkException catch (exception) {
      // Network-first failed: fall back to the cache when it has data,
      // otherwise surface the mapped network failure (per ADR-0013).
      return _fallBackToCache(exception);
    }
  }

  /// Refreshes the cache without letting a write failure discard a successful
  /// network fetch: caching is best-effort under the network-first contract
  /// (per ADR-0013 / `API_SPEC.md` §5.4).
  Future<void> _cacheBestEffort(List<Country> countries) async {
    try {
      await _local.cacheCountries(countries);
    } on Object {
      // Swallow storage write errors: the freshly fetched countries are still
      // returned to the caller; only the cache refresh is sacrificed.
    }
  }

  /// Serves cached countries when the network-first fetch failed, mapping any
  /// cache read error to a [StorageReadWriteFailure].
  Future<Result<List<Country>, Failure>> _fallBackToCache(
    NetworkException exception,
  ) async {
    try {
      final cached = await _local.getCachedCountries();
      if (cached.isNotEmpty) {
        return Success<List<Country>, Failure>(cached);
      }
      return FailureResult<List<Country>, Failure>(exception.failure);
    } on Object catch (error) {
      return FailureResult<List<Country>, Failure>(
        StorageReadWriteFailure(error.toString()),
      );
    }
  }
}
