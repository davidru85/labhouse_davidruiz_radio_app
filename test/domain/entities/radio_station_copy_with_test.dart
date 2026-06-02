import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/domain/entities/radio_station.dart';

void main() {
  group('RadioStation.copyWith', () {
    test('returns an equal entity when no overrides are provided', () {
      final station = _station();

      expect(station.copyWith(), station);
    });

    test('overrides lastCheckOk while preserving every other field', () {
      final station = _station();

      final updated = station.copyWith(lastCheckOk: false);

      expect(updated.lastCheckOk, isFalse);
      expect(updated.stationUuid, station.stationUuid);
      expect(updated.name, station.name);
      expect(updated.streamUrl, station.streamUrl);
      expect(updated.resolvedStreamUrl, station.resolvedStreamUrl);
      expect(updated.favicon, station.favicon);
      expect(updated.homepage, station.homepage);
      expect(updated.tags, station.tags);
      expect(updated.tagList, station.tagList);
      expect(updated.country, station.country);
      expect(updated.countryCode, station.countryCode);
      expect(updated.language, station.language);
      expect(updated.codec, station.codec);
      expect(updated.bitrate, station.bitrate);
      expect(updated.votes, station.votes);
      expect(updated.clickCount, station.clickCount);
      expect(updated.isHLS, station.isHLS);
    });
  });
}

RadioStation _station({bool lastCheckOk = true}) {
  return RadioStation(
    stationUuid: 'uuid-1',
    name: 'Jazz FM',
    streamUrl: 'http://example.com/stream',
    resolvedStreamUrl: 'https://example.com/stream',
    favicon: 'https://example.com/favicon.png',
    homepage: 'https://example.com',
    tags: 'jazz,swing',
    tagList: const ['jazz', 'swing'],
    country: 'Germany',
    countryCode: 'DE',
    language: 'german',
    codec: 'MP3',
    bitrate: 128,
    votes: 10,
    clickCount: 20,
    lastCheckOk: lastCheckOk,
    isHLS: false,
  );
}
