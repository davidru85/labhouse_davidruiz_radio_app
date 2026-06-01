import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:radio_app/data/datasources/local/local_favorites_data_source.dart';
import 'package:radio_app/data/models/station_hive_model.dart';
import 'package:radio_app/domain/entities/radio_station.dart';

void main() {
  group('HiveLocalFavoritesDataSource', () {
    late Directory tempDir;
    late Box<StationHiveModel> box;
    late LocalFavoritesDataSource dataSource;

    setUpAll(() {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(StationHiveModelAdapter());
      }
    });

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('favorites_ds_test');
      Hive.init(tempDir.path);
      box = await Hive.openBox<StationHiveModel>('favorites');
      dataSource = HiveLocalFavoritesDataSource(box);
    });

    tearDown(() async {
      await box.close();
      await tempDir.delete(recursive: true);
    });

    test('returns an empty list when nothing is persisted', () async {
      expect(await dataSource.getFavorites(), isEmpty);
    });

    test('persists a favorite and reads it back through Hive', () async {
      final station = _station(stationUuid: 'a');

      await dataSource.saveFavorite(station);

      expect(await dataSource.getFavorites(), [station]);
    });

    test('re-saving the same stationUuid updates in place', () async {
      await dataSource.saveFavorite(_station(stationUuid: 'a'));

      await dataSource.saveFavorite(
        _station(stationUuid: 'a', lastCheckOk: false),
      );

      final favorites = await dataSource.getFavorites();
      expect(favorites, hasLength(1));
      expect(favorites.single.lastCheckOk, isFalse);
    });

    test('removes a favorite by stationUuid', () async {
      await dataSource.saveFavorite(_station(stationUuid: 'a'));
      await dataSource.saveFavorite(_station(stationUuid: 'b'));

      await dataSource.removeFavorite('a');

      final favorites = await dataSource.getFavorites();
      expect(favorites.map((RadioStation s) => s.stationUuid), ['b']);
    });

    test('returns every persisted favorite', () async {
      await dataSource.saveFavorite(_station(stationUuid: 'a'));
      await dataSource.saveFavorite(_station(stationUuid: 'b'));

      final favorites = await dataSource.getFavorites();
      expect(
        favorites.map((RadioStation s) => s.stationUuid),
        containsAll(<String>['a', 'b']),
      );
    });
  });
}

RadioStation _station({required String stationUuid, bool lastCheckOk = true}) {
  return RadioStation(
    stationUuid: stationUuid,
    name: 'Station $stationUuid',
    streamUrl: 'https://example.com/$stationUuid',
    resolvedStreamUrl: 'https://example.com/$stationUuid.mp3',
    favicon: null,
    homepage: null,
    tags: 'jazz',
    tagList: const <String>['jazz'],
    country: 'Spain',
    countryCode: 'ES',
    language: null,
    codec: null,
    bitrate: null,
    votes: 0,
    clickCount: 0,
    lastCheckOk: lastCheckOk,
    isHLS: false,
  );
}
