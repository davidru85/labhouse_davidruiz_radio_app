import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/domain/repositories/audio_player_repository.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Watches parsed now-playing metadata while playback is active.
final class WatchNowPlayingUseCase
    implements StreamUseCase<NowPlayingInfo?, NoParams> {
  /// Creates a now-playing watch use case.
  const WatchNowPlayingUseCase(this._repository);

  final AudioPlayerRepository _repository;

  @override
  Stream<NowPlayingInfo?> call(NoParams params) => _repository.nowPlayingStream;
}
