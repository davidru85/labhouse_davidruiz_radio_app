import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/audio_player_repository.dart';
import 'package:radio_app/domain/repositories/playback_url_repository.dart';
import 'package:radio_app/domain/repositories/player_state.dart';
import 'package:radio_app/domain/usecases/play_station_use_case.dart';

void main() {
  group('PlayStationUseCase', () {
    test(
      'resolves the URL and starts playback with station metadata',
      () async {
        final station = _station(stationUuid: 'station-uuid');
        final urlRepository = _FakePlaybackUrlRepository(
          resolveResult: const Success<String, Failure>(
            'https://resolved.example.com/stream',
          ),
        );
        final player = _FakeAudioPlayerRepository();
        final useCase = PlayStationUseCase(urlRepository, player);

        final result = await useCase(PlayStationParams(station: station));

        expect(result, isA<Success<void, Failure>>());
        expect(urlRepository.resolvedStation, station);
        expect(player.playedUrl, 'https://resolved.example.com/stream');
        expect(player.playedTitle, 'Jazz FM');
        expect(player.playedSubtitle, 'jazz • Germany');
      },
    );

    test(
      'falls back to the country subtitle when the station has no tags',
      () async {
        final station = _station(
          stationUuid: 'station-uuid',
          tagList: const [],
        );
        final urlRepository = _FakePlaybackUrlRepository(
          resolveResult: const Success<String, Failure>(
            'https://resolved.example.com/stream',
          ),
        );
        final player = _FakeAudioPlayerRepository();
        final useCase = PlayStationUseCase(urlRepository, player);

        await useCase(PlayStationParams(station: station));

        expect(player.playedSubtitle, 'Germany');
      },
    );

    test('forwards the failure raised while resolving the URL', () async {
      const failure = StreamUnreachableFailure('unreachable');
      final urlRepository = _FakePlaybackUrlRepository(
        resolveResult: const FailureResult<String, Failure>(failure),
      );
      final player = _FakeAudioPlayerRepository();
      final useCase = PlayStationUseCase(urlRepository, player);

      final result = await useCase(
        PlayStationParams(station: _station(stationUuid: 'station-uuid')),
      );

      expect(result, isA<FailureResult<void, Failure>>());
      expect((result as FailureResult<void, Failure>).failure, failure);
      expect(player.playCalls, 0);
    });

    test('forwards the failure raised while starting playback', () async {
      const failure = PlaybackInterruptedFailure('stalled');
      final urlRepository = _FakePlaybackUrlRepository(
        resolveResult: const Success<String, Failure>(
          'https://resolved.example.com/stream',
        ),
      );
      final player = _FakeAudioPlayerRepository(
        playResult: const FailureResult<void, Failure>(failure),
      );
      final useCase = PlayStationUseCase(urlRepository, player);

      final result = await useCase(
        PlayStationParams(station: _station(stationUuid: 'station-uuid')),
      );

      expect(result, isA<FailureResult<void, Failure>>());
      expect((result as FailureResult<void, Failure>).failure, failure);
      expect(player.playCalls, 1);
    });
  });
}

class _FakePlaybackUrlRepository implements PlaybackUrlRepository {
  _FakePlaybackUrlRepository({required this.resolveResult});

  final Result<String, Failure> resolveResult;
  RadioStation? resolvedStation;

  @override
  Future<Result<String, Failure>> resolvePlaybackUrl(
    RadioStation station,
  ) async {
    resolvedStation = station;

    return resolveResult;
  }
}

class _FakeAudioPlayerRepository implements AudioPlayerRepository {
  _FakeAudioPlayerRepository({
    this.playResult = const Success<void, Failure>(null),
  });

  final Result<void, Failure> playResult;

  String? playedUrl;
  String? playedTitle;
  String? playedSubtitle;
  int playCalls = 0;

  @override
  Stream<PlayerState> get playerStateStream =>
      const Stream<PlayerState>.empty();

  @override
  Stream<NowPlayingInfo?> get nowPlayingStream =>
      const Stream<NowPlayingInfo?>.empty();

  @override
  Future<Result<void, Failure>> play(
    String url, {
    required String title,
    required String subtitle,
  }) async {
    playCalls++;
    playedUrl = url;
    playedTitle = title;
    playedSubtitle = subtitle;

    return playResult;
  }

  @override
  Future<Result<void, Failure>> pause() async {
    return const Success<void, Failure>(null);
  }

  @override
  Future<Result<void, Failure>> stop() async {
    return const Success<void, Failure>(null);
  }
}

RadioStation _station({
  required String stationUuid,
  List<String> tagList = const ['jazz', 'swing'],
}) {
  return RadioStation(
    stationUuid: stationUuid,
    name: 'Jazz FM',
    streamUrl: 'http://example.com/stream',
    resolvedStreamUrl: 'https://example.com/stream',
    favicon: null,
    homepage: null,
    tags: tagList.join(','),
    tagList: tagList,
    country: 'Germany',
    countryCode: 'DE',
    language: 'german',
    codec: 'MP3',
    bitrate: 128,
    votes: 10,
    clickCount: 20,
    lastCheckOk: true,
    isHLS: false,
  );
}
