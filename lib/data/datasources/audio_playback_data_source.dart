/// Reduced playback lifecycle status exposed by [AudioPlaybackDataSource].
///
/// The concrete adapter derives this from `just_audio`'s `processingState`
/// and `playing` flag so the repository maps a single stream to domain
/// player states.
enum PlaybackStatus {
  /// No media loaded or playback not started.
  idle,

  /// Media is loading or rebuffering.
  buffering,

  /// Media is actively playing.
  playing,

  /// Playback is paused.
  paused,

  /// Playback is stopped or completed.
  stopped,
}

/// Audio engine boundary over `just_audio` + `audio_service` (per ADR-0012/
/// 0022).
///
/// This port exposes only what the repository needs so it can be faked in
/// tests; the concrete plugin adapter (notification controls, `MediaItem`
/// wiring) is untested glue configured in the composition root.
abstract interface class AudioPlaybackDataSource {
  /// Emits the current playback lifecycle status.
  Stream<PlaybackStatus> get statusStream;

  /// Emits the raw Icy `StreamTitle` metadata, or `null` when absent.
  Stream<String?> get icyMetadataStream;

  /// Loads [url] and sets the background notification [title] and [subtitle].
  Future<void> setUrl(
    String url, {
    required String title,
    required String subtitle,
  });

  /// Starts playback of the loaded media.
  Future<void> play();

  /// Pauses playback.
  Future<void> pause();

  /// Stops playback.
  Future<void> stop();
}
