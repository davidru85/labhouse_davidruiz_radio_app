import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/data/models/station_hive_model.dart';
import 'package:radio_app/domain/entities/radio_station.dart';

void main() {
  group('StationHiveModel', () {
    test('round-trips a fully populated station through the model', () {
      final station = _station();

      final restored = StationHiveModel.fromEntity(station).toEntity();

      expect(restored, station);
    });

    test('round-trips a station whose optional fields are null', () {
      final station = _station(
        favicon: null,
        homepage: null,
        language: null,
        codec: null,
        bitrate: null,
      );

      final restored = StationHiveModel.fromEntity(station).toEntity();

      expect(restored, station);
    });

    test('preserves an empty tag list', () {
      final station = _station(tags: '', tagList: const <String>[]);

      final restored = StationHiveModel.fromEntity(station).toEntity();

      expect(restored.tagList, isEmpty);
      expect(restored, station);
    });

    test('preserves every scalar field verbatim', () {
      final station = _station();

      final model = StationHiveModel.fromEntity(station);

      expect(model.toEntity().stationUuid, 'station-uuid');
      expect(model.toEntity().votes, 42);
      expect(model.toEntity().clickCount, 7);
      expect(model.toEntity().lastCheckOk, isTrue);
      expect(model.toEntity().isHLS, isFalse);
    });
  });
}

RadioStation _station({
  String stationUuid = 'station-uuid',
  String name = 'Station Name',
  String streamUrl = 'https://example.com/stream',
  String resolvedStreamUrl = 'https://example.com/stream.mp3',
  String? favicon = 'https://example.com/favicon.png',
  String? homepage = 'https://example.com',
  String tags = 'jazz,blues',
  List<String> tagList = const <String>['jazz', 'blues'],
  String country = 'Spain',
  String countryCode = 'ES',
  String? language = 'spanish',
  String? codec = 'MP3',
  int? bitrate = 128,
  int votes = 42,
  int clickCount = 7,
  bool lastCheckOk = true,
  bool isHLS = false,
}) {
  return RadioStation(
    stationUuid: stationUuid,
    name: name,
    streamUrl: streamUrl,
    resolvedStreamUrl: resolvedStreamUrl,
    favicon: favicon,
    homepage: homepage,
    tags: tags,
    tagList: tagList,
    country: country,
    countryCode: countryCode,
    language: language,
    codec: codec,
    bitrate: bitrate,
    votes: votes,
    clickCount: clickCount,
    lastCheckOk: lastCheckOk,
    isHLS: isHLS,
  );
}
