import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:radio_app/data/datasources/local/mirror_cache_data_source.dart';

void main() {
  group('HiveMirrorCacheDataSource', () {
    late Directory tempDir;
    late Box<dynamic> box;
    late MirrorCacheDataSource dataSource;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('mirror_cache_test');
      Hive.init(tempDir.path);
      box = await Hive.openBox<dynamic>('app_settings');
      dataSource = HiveMirrorCacheDataSource(box);
    });

    tearDown(() async {
      await box.close();
      await tempDir.delete(recursive: true);
    });

    test('returns null when no mirror has been cached', () async {
      expect(await dataSource.getLastKnownMirror(), isNull);
    });

    test('persists a mirror host and reads it back through Hive', () async {
      await dataSource.setLastKnownMirror('de1.api.radio-browser.info');

      expect(
        await dataSource.getLastKnownMirror(),
        'de1.api.radio-browser.info',
      );
    });

    test('overwrites the previously cached mirror', () async {
      await dataSource.setLastKnownMirror('de1.api.radio-browser.info');

      await dataSource.setLastKnownMirror('nl1.api.radio-browser.info');

      expect(
        await dataSource.getLastKnownMirror(),
        'nl1.api.radio-browser.info',
      );
    });

    test('stores the bare hostname under the last_known_mirror key', () async {
      await dataSource.setLastKnownMirror('fr1.api.radio-browser.info');

      expect(box.get('last_known_mirror'), 'fr1.api.radio-browser.info');
    });
  });
}
