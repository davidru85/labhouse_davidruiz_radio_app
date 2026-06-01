import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:radio_app/data/datasources/local/local_countries_data_source.dart';
import 'package:radio_app/data/models/country_hive_model.dart';
import 'package:radio_app/domain/entities/country.dart';

void main() {
  group('HiveLocalCountriesDataSource', () {
    late Directory tempDir;
    late Box<CountryHiveModel> box;
    late LocalCountriesDataSource dataSource;

    setUpAll(() {
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(CountryHiveModelAdapter());
      }
    });

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('countries_ds_test');
      Hive.init(tempDir.path);
      box = await Hive.openBox<CountryHiveModel>('countries');
      dataSource = HiveLocalCountriesDataSource(box);
    });

    tearDown(() async {
      await box.close();
      await tempDir.delete(recursive: true);
    });

    test('returns an empty list when nothing is cached', () async {
      expect(await dataSource.getCachedCountries(), isEmpty);
    });

    test('caches countries and reads them back through Hive', () async {
      const countries = <Country>[
        Country(name: 'Spain', countryCode: 'ES', stationCount: 540),
        Country(name: 'France', countryCode: 'FR', stationCount: 320),
      ];

      await dataSource.cacheCountries(countries);

      expect(await dataSource.getCachedCountries(), countries);
    });

    test('replaces the previous cache on every write', () async {
      await dataSource.cacheCountries(const <Country>[
        Country(name: 'Spain', countryCode: 'ES', stationCount: 540),
      ]);

      await dataSource.cacheCountries(const <Country>[
        Country(name: 'France', countryCode: 'FR', stationCount: 320),
      ]);

      final cached = await dataSource.getCachedCountries();
      expect(cached.map((Country c) => c.countryCode), <String>['FR']);
    });

    test('caching an empty list clears the cache', () async {
      await dataSource.cacheCountries(const <Country>[
        Country(name: 'Spain', countryCode: 'ES', stationCount: 540),
      ]);

      await dataSource.cacheCountries(const <Country>[]);

      expect(await dataSource.getCachedCountries(), isEmpty);
    });
  });
}
