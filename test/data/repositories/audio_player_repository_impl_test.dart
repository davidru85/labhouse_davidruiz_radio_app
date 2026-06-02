import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/data/datasources/audio_playback_data_source.dart';
import 'package:radio_app/data/repositories/audio_player_repository_impl.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/connectivity_repository.dart';
import 'package:radio_app/domain/repositories/player_state.dart';

void main() {
  group('AudioPlayerRepositoryImpl', () {
    test('play forwards the url and notification metadata, then starts '
        'playback', () async {
      final playback = _FakeAudioPlaybackDataSource();
      addTearDown(playback.close);
      final repository = AudioPlayerRepositoryImpl(
        playback,
        _FakeConnectivityRepository()..registerTearDown(addTearDown),
      );

      final result = await repository.play(
        'https://stream.example.com',
        title: 'Jazz FM',
        subtitle: 'jazz • Germany',
      );

      expect(result, isA<Success<void, Failure>>());
      expect(playback.url, 'https://stream.example.com');
      expect(playback.title, 'Jazz FM');
      expect(playback.subtitle, 'jazz • Germany');
      expect(playback.playCalls, 1);
    });

    test(
      'play maps a playback engine error to StreamUnreachableFailure',
      () async {
        final playback = _FakeAudioPlaybackDataSource(throwOnPlay: true);
        addTearDown(playback.close);
        final repository = AudioPlayerRepositoryImpl(
          playback,
          _FakeConnectivityRepository()..registerTearDown(addTearDown),
        );

        final result = await repository.play(
          'https://stream.example.com',
          title: 't',
          subtitle: 's',
        );

        expect(result, isA<FailureResult<void, Failure>>());
        expect(
          (result as FailureResult<void, Failure>).failure,
          isA<StreamUnreachableFailure>(),
        );
      },
    );

    test('pause forwards to the playback engine', () async {
      final playback = _FakeAudioPlaybackDataSource();
      addTearDown(playback.close);
      final repository = AudioPlayerRepositoryImpl(
        playback,
        _FakeConnectivityRepository()..registerTearDown(addTearDown),
      );

      final result = await repository.pause();

      expect(result, isA<Success<void, Failure>>());
      expect(playback.pauseCalls, 1);
    });

    test('stop forwards to the playback engine', () async {
      final playback = _FakeAudioPlaybackDataSource();
      addTearDown(playback.close);
      final repository = AudioPlayerRepositoryImpl(
        playback,
        _FakeConnectivityRepository()..registerTearDown(addTearDown),
      );

      final result = await repository.stop();

      expect(result, isA<Success<void, Failure>>());
      expect(playback.stopCalls, 1);
    });

    test(
      'nowPlayingStream maps Icy metadata to NowPlayingInfo and null',
      () async {
        final playback = _FakeAudioPlaybackDataSource();
        addTearDown(playback.close);
        final repository = AudioPlayerRepositoryImpl(
          playback,
          _FakeConnectivityRepository()..registerTearDown(addTearDown),
        );

        final emissions = <NowPlayingInfo?>[];
        final sub = repository.nowPlayingStream.listen(emissions.add);

        playback
          ..emitIcy('Daft Punk - Get Lucky')
          ..emitIcy(null);
        await pumpEventQueue();

        expect(emissions[0], isNotNull);
        expect(
          emissions[0],
          const NowPlayingInfo(
            raw: 'Daft Punk - Get Lucky',
            artist: 'Daft Punk',
            track: 'Get Lucky',
          ),
        );
        expect(emissions[1], isNull);
        await sub.cancel();
      },
    );

    test(
      'playerStateStream maps the engine status to domain player states',
      () async {
        final playback = _FakeAudioPlaybackDataSource();
        addTearDown(playback.close);
        final repository = AudioPlayerRepositoryImpl(
          playback,
          _FakeConnectivityRepository()..registerTearDown(addTearDown),
        );

        final states = <PlayerState>[];
        final sub = repository.playerStateStream.listen(states.add);

        playback
          ..emitStatus(PlaybackStatus.buffering)
          ..emitStatus(PlaybackStatus.playing);
        await pumpEventQueue();

        expect(states[0], isA<PlayerBufferingState>());
        expect(states[1], isA<PlayerPlayingState>());
        await sub.cancel();
      },
    );

    test('playerStateStream surfaces a connectivity loss during active '
        'playback as a ConnectivityLostFailure error state', () async {
      final playback = _FakeAudioPlaybackDataSource();
      addTearDown(playback.close);
      final connectivity = _FakeConnectivityRepository()
        ..registerTearDown(addTearDown);
      final repository = AudioPlayerRepositoryImpl(playback, connectivity);

      final states = <PlayerState>[];
      final sub = repository.playerStateStream.listen(states.add);

      playback.emitStatus(PlaybackStatus.playing);
      await pumpEventQueue();
      connectivity.emitOnline(isOnline: false);
      await pumpEventQueue();

      expect(states.last, isA<PlayerErrorState>());
      expect(
        (states.last as PlayerErrorState).failure,
        isA<ConnectivityLostFailure>(),
      );
      await sub.cancel();
    });

    test('playerStateStream still surfaces a connectivity loss after the '
        'stream rebuffers mid-session', () async {
      final playback = _FakeAudioPlaybackDataSource();
      addTearDown(playback.close);
      final connectivity = _FakeConnectivityRepository()
        ..registerTearDown(addTearDown);
      final repository = AudioPlayerRepositoryImpl(playback, connectivity);

      final states = <PlayerState>[];
      final sub = repository.playerStateStream.listen(states.add);

      playback
        ..emitStatus(PlaybackStatus.playing)
        ..emitStatus(PlaybackStatus.buffering);
      await pumpEventQueue();
      connectivity.emitOnline(isOnline: false);
      await pumpEventQueue();

      expect(states.last, isA<PlayerErrorState>());
      expect(
        (states.last as PlayerErrorState).failure,
        isA<ConnectivityLostFailure>(),
      );
      await sub.cancel();
    });
  });
}

class _FakeAudioPlaybackDataSource implements AudioPlaybackDataSource {
  _FakeAudioPlaybackDataSource({this.throwOnPlay = false});

  final bool throwOnPlay;
  String? url;
  String? title;
  String? subtitle;
  int playCalls = 0;
  int pauseCalls = 0;
  int stopCalls = 0;

  final StreamController<PlaybackStatus> _status =
      StreamController<PlaybackStatus>.broadcast();
  final StreamController<String?> _icy = StreamController<String?>.broadcast();

  void emitStatus(PlaybackStatus status) => _status.add(status);
  void emitIcy(String? raw) => _icy.add(raw);

  Future<void> close() async {
    await _status.close();
    await _icy.close();
  }

  @override
  Stream<PlaybackStatus> get statusStream => _status.stream;

  @override
  Stream<String?> get icyMetadataStream => _icy.stream;

  @override
  Future<void> setUrl(
    String url, {
    required String title,
    required String subtitle,
  }) async {
    this.url = url;
    this.title = title;
    this.subtitle = subtitle;
  }

  @override
  Future<void> play() async {
    playCalls++;
    if (throwOnPlay) {
      throw Exception('stream unreachable');
    }
  }

  @override
  Future<void> pause() async => pauseCalls++;

  @override
  Future<void> stop() async => stopCalls++;
}

class _FakeConnectivityRepository implements ConnectivityRepository {
  final StreamController<bool> _online = StreamController<bool>.broadcast();

  void emitOnline({required bool isOnline}) => _online.add(isOnline);

  void registerTearDown(void Function(dynamic Function()) addTearDown) {
    addTearDown(_online.close);
  }

  @override
  Stream<bool> get connectivityStream => _online.stream;

  @override
  Future<Result<bool, Failure>> checkConnectivity() async =>
      const Success<bool, Failure>(true);
}
