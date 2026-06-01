import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/audio_player_repository.dart';
import 'package:radio_app/domain/repositories/player_state.dart';
import 'package:radio_app/domain/usecases/stop_playback_use_case.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

void main() {
  group('StopPlaybackUseCase', () {
    test('delegates stopping to the repository', () async {
      final player = _FakeAudioPlayerRepository(
        stopResult: const Success<void, Failure>(null),
      );
      final useCase = StopPlaybackUseCase(player);

      final result = await useCase(const NoParams());

      expect(result, isA<Success<void, Failure>>());
      expect(player.stopCalls, 1);
    });

    test('forwards repository failures', () async {
      const failure = PlaybackInterruptedFailure('cannot stop');
      final player = _FakeAudioPlayerRepository(
        stopResult: const FailureResult<void, Failure>(failure),
      );
      final useCase = StopPlaybackUseCase(player);

      final result = await useCase(const NoParams());

      expect(result, isA<FailureResult<void, Failure>>());
      expect((result as FailureResult<void, Failure>).failure, failure);
      expect(player.stopCalls, 1);
    });
  });
}

class _FakeAudioPlayerRepository implements AudioPlayerRepository {
  _FakeAudioPlayerRepository({required this.stopResult});

  final Result<void, Failure> stopResult;
  int stopCalls = 0;

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
    return const Success<void, Failure>(null);
  }

  @override
  Future<Result<void, Failure>> stop() async {
    stopCalls++;

    return stopResult;
  }
}
