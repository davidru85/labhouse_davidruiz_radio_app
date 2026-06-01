import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:radio_app/data/datasources/local/local_genres_data_source.dart';
import 'package:radio_app/data/models/genre_hive_model.dart';
import 'package:radio_app/domain/entities/genre.dart';

void main() {
  group('HiveLocalGenresDataSource', () {
    late Directory tempDir;
    late Box<GenreHiveModel> box;
    late LocalGenresDataSource dataSource;

    setUpAll(() {
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(GenreHiveModelAdapter());
      }
    });

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('genres_ds_test');
      Hive.init(tempDir.path);
      box = await Hive.openBox<GenreHiveModel>('genres');
      dataSource = HiveLocalGenresDataSource(box);
    });

    tearDown(() async {
      await box.close();
      await tempDir.delete(recursive: true);
    });

    test('returns an empty list when nothing is cached', () async {
      expect(await dataSource.getCachedGenres(), isEmpty);
    });

    test('caches genres and reads them back through Hive', () async {
      const genres = <Genre>[
        Genre(name: 'jazz', stationCount: 12),
        Genre(name: 'rock', stationCount: 34),
      ];

      await dataSource.cacheGenres(genres);

      expect(await dataSource.getCachedGenres(), genres);
    });

    test('replaces the previous cache on every write', () async {
      await dataSource.cacheGenres(const <Genre>[
        Genre(name: 'jazz', stationCount: 12),
      ]);

      await dataSource.cacheGenres(const <Genre>[
        Genre(name: 'rock', stationCount: 34),
      ]);

      final cached = await dataSource.getCachedGenres();
      expect(cached.map((Genre g) => g.name), <String>['rock']);
    });

    test('caching an empty list clears the cache', () async {
      await dataSource.cacheGenres(const <Genre>[
        Genre(name: 'jazz', stationCount: 12),
      ]);

      await dataSource.cacheGenres(const <Genre>[]);

      expect(await dataSource.getCachedGenres(), isEmpty);
    });
  });
}
