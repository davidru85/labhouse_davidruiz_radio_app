import 'package:radio_app/domain/repositories/audio_player_repository.dart';
import 'package:radio_app/domain/repositories/player_state.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Watches audio player lifecycle state changes for the presentation layer.
final class WatchPlayerStateUseCase
    implements StreamUseCase<PlayerState, NoParams> {
  /// Creates a player-state watch use case.
  const WatchPlayerStateUseCase(this._repository);

  final AudioPlayerRepository _repository;

  @override
  Stream<PlayerState> call(NoParams params) => _repository.playerStateStream;
}
