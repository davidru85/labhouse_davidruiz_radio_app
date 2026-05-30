import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/domain/entities/country.dart';
import 'package:radio_app/domain/entities/genre.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/domain/entities/radio_station.dart';

void main() {
  group('RadioStation', () {
    test('exposes the stationuuid as the only stable identifier', () {
      const station = RadioStation(
        stationUuid: '960e57f1-0601-11e8-ae97-52543be04c81',
        name: 'Radio Example',
        streamUrl: 'http://stream.example.test/live',
        resolvedStreamUrl: 'https://cdn.example.test/live.mp3',
        favicon: 'https://example.test/favicon.png',
        homepage: 'https://example.test',
        tags: 'jazz, blues,News',
        tagList: ['jazz', 'blues', 'news'],
        country: 'Germany',
        countryCode: 'DE',
        language: 'german',
        codec: 'MP3',
        bitrate: 128,
        votes: 42,
        clickCount: 1000,
        lastCheckOk: true,
        isHLS: false,
      );

      expect(station.stationUuid, '960e57f1-0601-11e8-ae97-52543be04c81');
      expect(station.tagList, ['jazz', 'blues', 'news']);
      expect(station.lastCheckOk, isTrue);
      expect(station.isHLS, isFalse);
    });

    test('uses value equality for immutable station data', () {
      const first = RadioStation(
        stationUuid: 'station-uuid',
        name: 'Radio Example',
        streamUrl: 'http://stream.example.test/live',
        resolvedStreamUrl: 'https://cdn.example.test/live.mp3',
        favicon: null,
        homepage: null,
        tags: 'rock',
        tagList: ['rock'],
        country: 'Austria',
        countryCode: 'AT',
        language: null,
        codec: null,
        bitrate: null,
        votes: 7,
        clickCount: 11,
        lastCheckOk: true,
        isHLS: false,
      );
      const second = RadioStation(
        stationUuid: 'station-uuid',
        name: 'Radio Example',
        streamUrl: 'http://stream.example.test/live',
        resolvedStreamUrl: 'https://cdn.example.test/live.mp3',
        favicon: null,
        homepage: null,
        tags: 'rock',
        tagList: ['rock'],
        country: 'Austria',
        countryCode: 'AT',
        language: null,
        codec: null,
        bitrate: null,
        votes: 7,
        clickCount: 11,
        lastCheckOk: true,
        isHLS: false,
      );

      expect(first, equals(second));
    });
  });

  group('Genre', () {
    test('uses value equality for immutable genre data', () {
      const genre = Genre(name: 'jazz', stationCount: 12);

      expect(genre, equals(const Genre(name: 'jazz', stationCount: 12)));
    });
  });

  group('Country', () {
    test('uses value equality and keeps the ISO alpha-2 code', () {
      const country = Country(
        name: 'Netherlands',
        countryCode: 'NL',
        stationCount: 25,
      );

      expect(country.countryCode, 'NL');
      expect(
        country,
        equals(
          const Country(
            name: 'Netherlands',
            countryCode: 'NL',
            stationCount: 25,
          ),
        ),
      );
    });
  });

  group('NowPlayingInfo', () {
    test('uses value equality for immutable now-playing data', () {
      const info = NowPlayingInfo(
        raw: 'Artist - Track',
        artist: 'Artist',
        track: 'Track',
      );

      expect(
        info,
        equals(
          const NowPlayingInfo(
            raw: 'Artist - Track',
            artist: 'Artist',
            track: 'Track',
          ),
        ),
      );
    });

    test('defaults all fields to null', () {
      const info = NowPlayingInfo();

      expect(info.raw, isNull);
      expect(info.artist, isNull);
      expect(info.track, isNull);
    });
  });
}
