import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/player_state.dart';

/// Domain contract for audio playback.
abstract interface class AudioPlayerRepository {
  /// Emits player lifecycle state changes.
  Stream<PlayerState> get playerStateStream;

  /// Emits parsed now-playing metadata while playback is active.
  Stream<NowPlayingInfo?> get nowPlayingStream;

  /// Starts playback for [url] with background metadata.
  Future<Result<void, Failure>> play(
    String url, {
    required String title,
    required String subtitle,
  });

  /// Pauses active playback.
  Future<Result<void, Failure>> pause();

  /// Stops active playback.
  Future<Result<void, Failure>> stop();
}
