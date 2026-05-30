part of 'failure.dart';

/// Sealed class grouping all network-related domain failures.
sealed class NetworkFailure extends Failure {
  /// Creates a network failure with an optional message.
  const NetworkFailure([super.message]);
}

/// Failure representing a connection, send, or receive timeout.
final class ConnectionTimeoutFailure extends NetworkFailure {
  /// Creates a [ConnectionTimeoutFailure] with an optional message.
  const ConnectionTimeoutFailure([super.message]);

  @override
  String get localizationKey => 'error_network_timeout';
}

/// Failure representing a socket or DNS resolution error.
final class SocketFailure extends NetworkFailure {
  /// Creates a [SocketFailure] with an optional message.
  const SocketFailure([super.message]);

  @override
  String get localizationKey => 'error_network_socket';
}

/// Failure representing exhausted mirror attempts.
final class MirrorFailure extends NetworkFailure {
  /// Creates a [MirrorFailure] with an optional message.
  const MirrorFailure([super.message]);

  @override
  String get localizationKey => 'error_network_mirror';
}
