import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/audio_player_repository.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Stops active audio playback.
final class StopPlaybackUseCase implements UseCase<void, NoParams> {
  /// Creates a playback stop use case.
  const StopPlaybackUseCase(this._audioPlayer);

  final AudioPlayerRepository _audioPlayer;

  /// Stops playback through the repository.
  @override
  Future<Result<void, Failure>> call(NoParams params) {
    return _audioPlayer.stop();
  }
}
