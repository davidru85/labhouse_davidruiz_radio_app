import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/audio_player_repository.dart';
import 'package:radio_app/domain/repositories/playback_url_repository.dart';
import 'package:radio_app/domain/repositories/player_state.dart';
import 'package:radio_app/domain/usecases/pause_playback_use_case.dart';
import 'package:radio_app/domain/usecases/play_station_use_case.dart';
import 'package:radio_app/domain/usecases/stop_playback_use_case.dart';
import 'package:radio_app/domain/usecases/watch_now_playing_use_case.dart';
import 'package:radio_app/domain/usecases/watch_player_state_use_case.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';

// Use cases are `final` (unmockable): mock the repository contracts and build
// real use cases, keeping the BLoC use-case-only
// (ARCHITECTURE.md §"Dependency Rule").
class _MockPlaybackUrlRepository extends Mock
    implements PlaybackUrlRepository {}

class _MockAudioPlayerRepository extends Mock
    implements AudioPlayerRepository {}

void main() {
  late _MockPlaybackUrlRepository urlRepository;
  late _MockAudioPlayerRepository audioPlayer;
  late StreamController<PlayerState> stateController;
  late StreamController<NowPlayingInfo?> nowPlayingController;

  final station = _station('a');

  setUpAll(() => registerFallbackValue(_station('fallback')));

  setUp(() {
    urlRepository = _MockPlaybackUrlRepository();
    audioPlayer = _MockAudioPlayerRepository();
    stateController = StreamController<PlayerState>.broadcast();
    nowPlayingController = StreamController<NowPlayingInfo?>.broadcast();
    when(
      () => audioPlayer.playerStateStream,
    ).thenAnswer((_) => stateController.stream);
    when(
      () => audioPlayer.nowPlayingStream,
    ).thenAnswer((_) => nowPlayingController.stream);
    when(() => urlRepository.resolvePlaybackUrl(any())).thenAnswer(
      (_) async => const Success<String, Failure>('https://resolved'),
    );
    when(
      () => audioPlayer.play(
        any(),
        title: any(named: 'title'),
        subtitle: any(named: 'subtitle'),
      ),
    ).thenAnswer((_) async => const Success<void, Failure>(null));
    when(
      audioPlayer.pause,
    ).thenAnswer((_) async => const Success<void, Failure>(null));
    when(
      audioPlayer.stop,
    ).thenAnswer((_) async => const Success<void, Failure>(null));
  });

  tearDown(() {
    stateController.close();
    nowPlayingController.close();
  });

  RadioPlayerBloc build() => RadioPlayerBloc(
    PlayStationUseCase(urlRepository, audioPlayer),
    PausePlaybackUseCase(audioPlayer),
    StopPlaybackUseCase(audioPlayer),
    WatchPlayerStateUseCase(audioPlayer),
    WatchNowPlayingUseCase(audioPlayer),
  );

  Future<void> tick() => Future<void>.delayed(Duration.zero);

  // A play request optimistically emits Buffering before the engine reports
  // its first state, so every request transitions through Buffering before
  // Playing or Error (per ADR-0015 / ADR-0025). The engine's own Buffering is
  // deduplicated against this optimistic one.
  group('RadioPlayerBloc', () {
    blocTest<RadioPlayerBloc, RadioPlayerState>(
      'PlayRequested emits [Buffering, Playing] as the engine reports state '
      '(per ADR-0015)',
      build: build,
      act: (bloc) async {
        bloc.add(RadioPlayerPlayRequested(station));
        await tick();
        stateController
          ..add(const PlayerBufferingState())
          ..add(const PlayerPlayingState());
        await tick();
      },
      expect: () => [
        RadioPlayerBuffering(station),
        RadioPlayerPlaying(station, null),
      ],
    );

    blocTest<RadioPlayerBloc, RadioPlayerState>(
      'a failed play request emits [Buffering, Error] (per ADR-0025)',
      setUp: () =>
          when(() => urlRepository.resolvePlaybackUrl(any())).thenAnswer(
            (_) async => const FailureResult<String, Failure>(
              StreamUnreachableFailure(),
            ),
          ),
      build: build,
      act: (bloc) => bloc.add(RadioPlayerPlayRequested(station)),
      expect: () => [
        RadioPlayerBuffering(station),
        isA<RadioPlayerError>().having(
          (s) => s.failure,
          'failure',
          isA<StreamUnreachableFailure>(),
        ),
      ],
    );

    blocTest<RadioPlayerBloc, RadioPlayerState>(
      'a valid Icy emission updates the playing nowPlaying (per ADR-0012)',
      build: build,
      act: (bloc) async {
        bloc.add(RadioPlayerPlayRequested(station));
        await tick();
        stateController.add(const PlayerPlayingState());
        await tick();
        nowPlayingController.add(
          const NowPlayingInfo(
            raw: 'Daft Punk - Get Lucky',
            artist: 'Daft Punk',
            track: 'Get Lucky',
          ),
        );
        await tick();
      },
      expect: () => [
        RadioPlayerBuffering(station),
        RadioPlayerPlaying(station, null),
        RadioPlayerPlaying(
          station,
          const NowPlayingInfo(
            raw: 'Daft Punk - Get Lucky',
            artist: 'Daft Punk',
            track: 'Get Lucky',
          ),
        ),
      ],
    );

    blocTest<RadioPlayerBloc, RadioPlayerState>(
      'pause mid-stream emits Paused as the engine reports it',
      build: build,
      act: (bloc) async {
        bloc.add(RadioPlayerPlayRequested(station));
        await tick();
        stateController.add(const PlayerPlayingState());
        await tick();
        bloc.add(const RadioPlayerPauseRequested());
        await tick();
        stateController.add(const PlayerPausedState());
        await tick();
      },
      expect: () => [
        RadioPlayerBuffering(station),
        RadioPlayerPlaying(station, null),
        RadioPlayerPaused(station),
      ],
      verify: (_) => verify(audioPlayer.pause).called(1),
    );

    blocTest<RadioPlayerBloc, RadioPlayerState>(
      'stop emits Stopped as the engine reports it',
      build: build,
      act: (bloc) async {
        bloc.add(RadioPlayerPlayRequested(station));
        await tick();
        stateController.add(const PlayerPlayingState());
        await tick();
        bloc.add(const RadioPlayerStopRequested());
        await tick();
        stateController.add(const PlayerStoppedState());
        await tick();
      },
      expect: () => [
        RadioPlayerBuffering(station),
        RadioPlayerPlaying(station, null),
        isA<RadioPlayerStopped>(),
      ],
      verify: (_) => verify(audioPlayer.stop).called(1),
    );

    blocTest<RadioPlayerBloc, RadioPlayerState>(
      'connectivity loss during playback emits Error (per ADR-0013)',
      build: build,
      act: (bloc) async {
        bloc.add(RadioPlayerPlayRequested(station));
        await tick();
        stateController
          ..add(const PlayerPlayingState())
          ..add(const PlayerErrorState(ConnectivityLostFailure()));
        await tick();
      },
      expect: () => [
        RadioPlayerBuffering(station),
        RadioPlayerPlaying(station, null),
        isA<RadioPlayerError>().having(
          (s) => s.failure,
          'failure',
          isA<ConnectivityLostFailure>(),
        ),
      ],
    );

    blocTest<RadioPlayerBloc, RadioPlayerState>(
      'playback requested while offline emits [Buffering, Error] '
      '(per ADR-0025)',
      build: build,
      act: (bloc) async {
        bloc.add(RadioPlayerPlayRequested(station));
        await tick();
        stateController
          ..add(const PlayerBufferingState())
          ..add(const PlayerErrorState(ConnectivityLostFailure()));
        await tick();
      },
      expect: () => [RadioPlayerBuffering(station), isA<RadioPlayerError>()],
    );

    blocTest<RadioPlayerBloc, RadioPlayerState>(
      'play-pause-play transitions emit Buffering, Playing, Paused, '
      'Buffering, Playing',
      build: build,
      act: (bloc) async {
        bloc.add(RadioPlayerPlayRequested(station));
        await tick();
        stateController.add(const PlayerPlayingState());
        await tick();
        bloc.add(const RadioPlayerPauseRequested());
        await tick();
        stateController.add(const PlayerPausedState());
        await tick();
        bloc.add(RadioPlayerPlayRequested(station));
        await tick();
        stateController.add(const PlayerPlayingState());
        await tick();
      },
      expect: () => [
        RadioPlayerBuffering(station),
        RadioPlayerPlaying(station, null),
        RadioPlayerPaused(station),
        RadioPlayerBuffering(station),
        RadioPlayerPlaying(station, null),
      ],
    );

    blocTest<RadioPlayerBloc, RadioPlayerState>(
      'a mid-playback stall re-emits [Buffering, Playing] (per ADR-0015)',
      build: build,
      act: (bloc) async {
        bloc.add(RadioPlayerPlayRequested(station));
        await tick();
        stateController.add(const PlayerPlayingState());
        await tick();
        stateController.add(const PlayerBufferingState());
        await tick();
        stateController.add(const PlayerPlayingState());
        await tick();
      },
      expect: () => [
        RadioPlayerBuffering(station),
        RadioPlayerPlaying(station, null),
        RadioPlayerBuffering(station),
        RadioPlayerPlaying(station, null),
      ],
    );

    blocTest<RadioPlayerBloc, RadioPlayerState>(
      'a station without Icy metadata keeps nowPlaying null (per ADR-0012)',
      build: build,
      act: (bloc) async {
        bloc.add(RadioPlayerPlayRequested(station));
        await tick();
        stateController.add(const PlayerPlayingState());
        await tick();
        nowPlayingController.add(null);
        await tick();
      },
      expect: () => [
        RadioPlayerBuffering(station),
        RadioPlayerPlaying(station, null),
      ],
    );

    blocTest<RadioPlayerBloc, RadioPlayerState>(
      'malformed Icy metadata does not destroy player state (per ADR-0012)',
      build: build,
      act: (bloc) async {
        bloc.add(RadioPlayerPlayRequested(station));
        await tick();
        stateController.add(const PlayerPlayingState());
        await tick();
        nowPlayingController.add(
          const NowPlayingInfo(raw: 'garbled-no-separator'),
        );
        await tick();
      },
      expect: () => [
        RadioPlayerBuffering(station),
        RadioPlayerPlaying(station, null),
        RadioPlayerPlaying(
          station,
          const NowPlayingInfo(raw: 'garbled-no-separator'),
        ),
      ],
    );

    blocTest<RadioPlayerBloc, RadioPlayerState>(
      'a track change emits a fresh Playing with updated nowPlaying '
      '(per ADR-0012)',
      build: build,
      act: (bloc) async {
        bloc.add(RadioPlayerPlayRequested(station));
        await tick();
        stateController.add(const PlayerPlayingState());
        await tick();
        nowPlayingController.add(
          const NowPlayingInfo(raw: 'A - 1', artist: 'A', track: '1'),
        );
        await tick();
        nowPlayingController.add(
          const NowPlayingInfo(raw: 'A - 2', artist: 'A', track: '2'),
        );
        await tick();
      },
      expect: () => [
        RadioPlayerBuffering(station),
        RadioPlayerPlaying(station, null),
        RadioPlayerPlaying(
          station,
          const NowPlayingInfo(raw: 'A - 1', artist: 'A', track: '1'),
        ),
        RadioPlayerPlaying(
          station,
          const NowPlayingInfo(raw: 'A - 2', artist: 'A', track: '2'),
        ),
      ],
    );
  });
}

RadioStation _station(String uuid) => RadioStation(
  stationUuid: uuid,
  name: 'Station $uuid',
  streamUrl: 'https://example.com/$uuid',
  resolvedStreamUrl: 'https://example.com/$uuid/resolved',
  favicon: null,
  homepage: null,
  tags: '',
  tagList: const [],
  country: 'Germany',
  countryCode: 'DE',
  language: null,
  codec: null,
  bitrate: null,
  votes: 0,
  clickCount: 0,
  lastCheckOk: true,
  isHLS: false,
);
