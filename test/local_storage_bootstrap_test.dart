import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:radio_app/core/constants/hive_boxes.dart';
import 'package:radio_app/data/models/country_hive_model.dart';
import 'package:radio_app/data/models/genre_hive_model.dart';
import 'package:radio_app/data/models/station_hive_model.dart';
import 'package:radio_app/main.dart';

void main() {
  group('bootstrapLocalStorage', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('bootstrap_test');
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    test('opens every persisted app box', () async {
      await bootstrapLocalStorage();

      expect(Hive.isBoxOpen(HiveBoxes.favorites), isTrue);
      expect(Hive.isBoxOpen(HiveBoxes.history), isTrue);
      expect(Hive.isBoxOpen(HiveBoxes.genres), isTrue);
      expect(Hive.isBoxOpen(HiveBoxes.countries), isTrue);
      expect(Hive.isBoxOpen(HiveBoxes.appSettings), isTrue);
    });

    test('registers the station, genre and country adapters', () async {
      await bootstrapLocalStorage();

      expect(Hive.isAdapterRegistered(0), isTrue);
      expect(Hive.isAdapterRegistered(1), isTrue);
      expect(Hive.isAdapterRegistered(2), isTrue);
    });

    test('opens favorites and history as StationHiveModel boxes', () async {
      await bootstrapLocalStorage();

      expect(
        Hive.box<StationHiveModel>(HiveBoxes.favorites),
        isA<Box<StationHiveModel>>(),
      );
      expect(
        Hive.box<StationHiveModel>(HiveBoxes.history),
        isA<Box<StationHiveModel>>(),
      );
    });

    test('opens genres and countries as their cache-model boxes', () async {
      await bootstrapLocalStorage();

      expect(
        Hive.box<GenreHiveModel>(HiveBoxes.genres),
        isA<Box<GenreHiveModel>>(),
      );
      expect(
        Hive.box<CountryHiveModel>(HiveBoxes.countries),
        isA<Box<CountryHiveModel>>(),
      );
    });

    test('is idempotent when adapters are already registered', () async {
      await bootstrapLocalStorage();

      await bootstrapLocalStorage();

      expect(Hive.isBoxOpen(HiveBoxes.favorites), isTrue);
    });
  });
}
