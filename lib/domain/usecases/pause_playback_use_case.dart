import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/audio_player_repository.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Pauses active audio playback.
final class PausePlaybackUseCase implements UseCase<void, NoParams> {
  /// Creates a playback pause use case.
  const PausePlaybackUseCase(this._audioPlayer);

  final AudioPlayerRepository _audioPlayer;

  /// Pauses playback through the repository.
  @override
  Future<Result<void, Failure>> call(NoParams params) {
    return _audioPlayer.pause();
  }
}
