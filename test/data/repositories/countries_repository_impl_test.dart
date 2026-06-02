import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/data/datasources/local/local_countries_data_source.dart';
import 'package:radio_app/data/datasources/remote/remote_countries_data_source.dart';
import 'package:radio_app/data/repositories/countries_repository_impl.dart';
import 'package:radio_app/domain/entities/country.dart';
import 'package:radio_app/domain/failures/failure.dart';

void main() {
  group('CountriesRepositoryImpl', () {
    test('fetches from remote, caches the result, and returns it', () async {
      final countries = [_country('ES'), _country('FR')];
      final remote = _FakeRemoteCountriesDataSource(result: countries);
      final local = _FakeLocalCountriesDataSource();
      final repository = CountriesRepositoryImpl(remote, local);

      final result = await repository.getCountries();

      expect(result, isA<Success<List<Country>, Failure>>());
      expect((result as Success<List<Country>, Failure>).value, countries);
      expect(local.cached, countries);
    });

    test('returns the fetched countries even when caching them '
        'fails', () async {
      final countries = [_country('ES'), _country('FR')];
      final remote = _FakeRemoteCountriesDataSource(result: countries);
      final local = _FakeLocalCountriesDataSource(throwOnCache: true);
      final repository = CountriesRepositoryImpl(remote, local);

      final result = await repository.getCountries();

      expect(result, isA<Success<List<Country>, Failure>>());
      expect((result as Success<List<Country>, Failure>).value, countries);
    });

    test('falls back to cached countries when the remote fails', () async {
      final cached = [_country('DE')];
      final remote = _FakeRemoteCountriesDataSource(
        error: const NetworkException(SocketFailure()),
      );
      final local = _FakeLocalCountriesDataSource(initial: cached);
      final repository = CountriesRepositoryImpl(remote, local);

      final result = await repository.getCountries();

      expect(result, isA<Success<List<Country>, Failure>>());
      expect((result as Success<List<Country>, Failure>).value, cached);
    });

    test('returns the network failure when remote fails and cache '
        'is empty', () async {
      const failure = SocketFailure();
      final remote = _FakeRemoteCountriesDataSource(
        error: const NetworkException(failure),
      );
      final local = _FakeLocalCountriesDataSource();
      final repository = CountriesRepositoryImpl(remote, local);

      final result = await repository.getCountries();

      expect(result, isA<FailureResult<List<Country>, Failure>>());
      expect(
        (result as FailureResult<List<Country>, Failure>).failure,
        failure,
      );
    });

    test('maps a cache read failure to StorageReadWriteFailure when the '
        'remote fails', () async {
      final remote = _FakeRemoteCountriesDataSource(
        error: const NetworkException(SocketFailure()),
      );
      final local = _FakeLocalCountriesDataSource(throwOnRead: true);
      final repository = CountriesRepositoryImpl(remote, local);

      final result = await repository.getCountries();

      expect(result, isA<FailureResult<List<Country>, Failure>>());
      expect(
        (result as FailureResult<List<Country>, Failure>).failure,
        isA<StorageReadWriteFailure>(),
      );
    });
  });
}

class _FakeRemoteCountriesDataSource implements RemoteCountriesDataSource {
  _FakeRemoteCountriesDataSource({List<Country>? result, this.error})
    : result = result ?? const [];

  final List<Country> result;
  final NetworkException? error;

  @override
  Future<List<Country>> getCountries() async {
    final thrown = error;
    if (thrown != null) {
      throw thrown;
    }
    return result;
  }
}

class _FakeLocalCountriesDataSource implements LocalCountriesDataSource {
  _FakeLocalCountriesDataSource({
    List<Country>? initial,
    this.throwOnCache = false,
    this.throwOnRead = false,
  }) : cached = initial ?? const [];

  final bool throwOnCache;
  final bool throwOnRead;
  List<Country> cached;

  @override
  Future<List<Country>> getCachedCountries() async {
    if (throwOnRead) {
      throw Exception('hive read error');
    }
    return cached;
  }

  @override
  Future<void> cacheCountries(List<Country> countries) async {
    if (throwOnCache) {
      throw Exception('hive write error');
    }
    cached = countries;
  }
}

Country _country(String code) =>
    Country(name: code, countryCode: code, stationCount: 1);
