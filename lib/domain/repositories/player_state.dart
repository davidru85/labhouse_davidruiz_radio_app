/// Opaque playback state marker exposed by the audio player repository.
///
/// Concrete `RadioPlayerBloc` states are intentionally deferred to Phase 7.
sealed class PlayerState {
  /// Creates a playback state marker.
  const PlayerState();
}
