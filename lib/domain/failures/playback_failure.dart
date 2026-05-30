part of 'failure.dart';

/// Sealed class grouping all playback-related domain failures.
sealed class PlaybackFailure extends Failure {
  /// Creates a playback failure with an optional message.
  const PlaybackFailure([super.message]);
}

/// Failure representing an unreachable stream URL.
final class StreamUnreachableFailure extends PlaybackFailure {
  /// Creates a [StreamUnreachableFailure] with an optional message.
  const StreamUnreachableFailure([super.message]);

  @override
  String get localizationKey => 'error_playback_unreachable';
}

/// Failure representing an unsupported audio codec or stream format.
final class CodecUnsupportedFailure extends PlaybackFailure {
  /// Creates a [CodecUnsupportedFailure] with an optional message.
  const CodecUnsupportedFailure([super.message]);

  @override
  String get localizationKey => 'error_playback_codec';
}

/// Failure representing a playback stream that was aborted
/// or stalled mid-stream.
final class PlaybackInterruptedFailure extends PlaybackFailure {
  /// Creates a [PlaybackInterruptedFailure] with an optional message.
  const PlaybackInterruptedFailure([super.message]);

  @override
  String get localizationKey => 'error_playback_interrupted';
}

/// Failure representing active playback that is cut off due to connection loss.
final class ConnectivityLostFailure extends PlaybackFailure {
  /// Creates a [ConnectivityLostFailure] with an optional message.
  const ConnectivityLostFailure([super.message]);

  @override
  String get localizationKey => 'error_playback_connectivity';
}
