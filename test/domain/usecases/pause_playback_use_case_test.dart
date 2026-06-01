import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/audio_player_repository.dart';
import 'package:radio_app/domain/repositories/player_state.dart';
import 'package:radio_app/domain/usecases/pause_playback_use_case.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

void main() {
  group('PausePlaybackUseCase', () {
    test('delegates pausing to the repository', () async {
      final player = _FakeAudioPlayerRepository(
        pauseResult: const Success<void, Failure>(null),
      );
      final useCase = PausePlaybackUseCase(player);

      final result = await useCase(const NoParams());

      expect(result, isA<Success<void, Failure>>());
      expect(player.pauseCalls, 1);
    });

    test('forwards repository failures', () async {
      const failure = PlaybackInterruptedFailure('cannot pause');
      final player = _FakeAudioPlayerRepository(
        pauseResult: const FailureResult<void, Failure>(failure),
      );
      final useCase = PausePlaybackUseCase(player);

      final result = await useCase(const NoParams());

      expect(result, isA<FailureResult<void, Failure>>());
      expect((result as FailureResult<void, Failure>).failure, failure);
      expect(player.pauseCalls, 1);
    });
  });
}

class _FakeAudioPlayerRepository implements AudioPlayerRepository {
  _FakeAudioPlayerRepository({required this.pauseResult});

  final Result<void, Failure> pauseResult;
  int pauseCalls = 0;

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
    return const Success<void, Failure>(null);
  }

  @override
  Future<Result<void, Failure>> pause() async {
    pauseCalls++;

    return pauseResult;
  }

  @override
  Future<Result<void, Failure>> stop() async {
    return const Success<void, Failure>(null);
  }
}
