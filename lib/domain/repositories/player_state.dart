import 'package:radio_app/domain/failures/failure.dart';

/// Playback state marker exposed by the audio player repository.
///
/// Concrete `RadioPlayerBloc` UI states remain deferred to Phase 7; these
/// repository-level states describe the audio engine lifecycle only.
sealed class PlayerState {
  /// Creates a playback state marker.
  const PlayerState();
}

/// No media is loaded or playback has not started.
final class PlayerIdleState extends PlayerState {
  /// Creates an idle player state.
  const PlayerIdleState();
}

/// Media is loading or rebuffering (per ADR-0015).
final class PlayerBufferingState extends PlayerState {
  /// Creates a buffering player state.
  const PlayerBufferingState();
}

/// Media is actively playing.
final class PlayerPlayingState extends PlayerState {
  /// Creates a playing player state.
  const PlayerPlayingState();
}

/// Playback is paused.
final class PlayerPausedState extends PlayerState {
  /// Creates a paused player state.
  const PlayerPausedState();
}

/// Playback is stopped.
final class PlayerStoppedState extends PlayerState {
  /// Creates a stopped player state.
  const PlayerStoppedState();
}

/// Playback failed; carries the originating [Failure].
final class PlayerErrorState extends PlayerState {
  /// Creates an error player state wrapping [failure].
  const PlayerErrorState(this.failure);

  /// The failure that interrupted or prevented playback.
  final Failure failure;
}
