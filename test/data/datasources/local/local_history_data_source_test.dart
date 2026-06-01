import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:radio_app/data/datasources/local/local_history_data_source.dart';
import 'package:radio_app/data/models/station_hive_model.dart';
import 'package:radio_app/domain/entities/radio_station.dart';

void main() {
  group('HiveLocalHistoryDataSource', () {
    late Directory tempDir;
    late Box<StationHiveModel> box;
    late LocalHistoryDataSource dataSource;

    setUpAll(() {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(StationHiveModelAdapter());
      }
    });

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('history_ds_test');
      Hive.init(tempDir.path);
      box = await Hive.openBox<StationHiveModel>('history');
      dataSource = HiveLocalHistoryDataSource(box);
    });

    tearDown(() async {
      await box.close();
      await tempDir.delete(recursive: true);
    });

    test('returns an empty list when no history is persisted', () async {
      expect(await dataSource.getHistory(), isEmpty);
    });

    test('persists an entry and reads it back through Hive', () async {
      final station = _station(stationUuid: 'a');

      await dataSource.addToHistory(station);

      expect(await dataSource.getHistory(), [station]);
    });

    test('preserves insertion order', () async {
      await dataSource.addToHistory(_station(stationUuid: 'a'));
      await dataSource.addToHistory(_station(stationUuid: 'b'));
      await dataSource.addToHistory(_station(stationUuid: 'c'));

      final history = await dataSource.getHistory();
      expect(history.map((RadioStation s) => s.stationUuid), <String>[
        'a',
        'b',
        'c',
      ]);
    });

    test('removes a single entry by stationUuid', () async {
      await dataSource.addToHistory(_station(stationUuid: 'a'));
      await dataSource.addToHistory(_station(stationUuid: 'b'));

      await dataSource.removeFromHistory('a');

      final history = await dataSource.getHistory();
      expect(history.map((RadioStation s) => s.stationUuid), <String>['b']);
    });

    test('clears the whole history', () async {
      await dataSource.addToHistory(_station(stationUuid: 'a'));
      await dataSource.addToHistory(_station(stationUuid: 'b'));

      await dataSource.clearHistory();

      expect(await dataSource.getHistory(), isEmpty);
    });
  });
}

RadioStation _station({required String stationUuid}) {
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
    lastCheckOk: true,
    isHLS: false,
  );
}
