import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/data/models/station_dto.dart';

void main() {
  group('StationDto', () {
    test('maps a fully populated payload to a domain station', () {
      final station = StationDto.fromJson(_json()).toEntity();

      expect(station.stationUuid, 'uuid-1');
      expect(station.name, 'Jazz FM');
      expect(station.streamUrl, 'https://example.com/raw');
      expect(station.resolvedStreamUrl, 'https://example.com/resolved');
      expect(station.favicon, 'https://example.com/favicon.png');
      expect(station.homepage, 'https://example.com');
      expect(station.tags, 'jazz,blues');
      expect(station.tagList, <String>['jazz', 'blues']);
      expect(station.country, 'Spain');
      expect(station.countryCode, 'ES');
      expect(station.language, 'spanish');
      expect(station.codec, 'MP3');
      expect(station.bitrate, 128);
      expect(station.votes, 42);
      expect(station.clickCount, 7);
      expect(station.lastCheckOk, isTrue);
      expect(station.isHLS, isFalse);
    });

    test('maps lastcheckok and hls integer flags to booleans', () {
      final station = StationDto.fromJson(
        _json(lastcheckok: 0, hls: 1),
      ).toEntity();

      expect(station.lastCheckOk, isFalse);
      expect(station.isHLS, isTrue);
    });

    test('parses the comma-separated tags into a normalized tagList', () {
      final station = StationDto.fromJson(
        _json(tags: ' jazz , jazz , blues '),
      ).toEntity();

      expect(station.tagList, <String>['jazz', 'blues']);
    });

    test('maps an empty tags string to an empty tagList', () {
      final station = StationDto.fromJson(_json(tags: '')).toEntity();

      expect(station.tagList, isEmpty);
    });

    test('maps absent optional fields to null', () {
      final json = _json()
        ..remove('favicon')
        ..remove('homepage')
        ..remove('language')
        ..remove('codec')
        ..remove('bitrate');

      final station = StationDto.fromJson(json).toEntity();

      expect(station.favicon, isNull);
      expect(station.homepage, isNull);
      expect(station.language, isNull);
      expect(station.codec, isNull);
      expect(station.bitrate, isNull);
    });
  });
}

Map<String, dynamic> _json({
  Object? tags = 'jazz,blues',
  int lastcheckok = 1,
  int hls = 0,
}) {
  return <String, dynamic>{
    'stationuuid': 'uuid-1',
    'name': 'Jazz FM',
    'url': 'https://example.com/raw',
    'url_resolved': 'https://example.com/resolved',
    'favicon': 'https://example.com/favicon.png',
    'homepage': 'https://example.com',
    'tags': tags,
    'country': 'Spain',
    'countrycode': 'ES',
    'language': 'spanish',
    'codec': 'MP3',
    'bitrate': 128,
    'votes': 42,
    'clickcount': 7,
    'lastcheckok': lastcheckok,
    'hls': hls,
  };
}
