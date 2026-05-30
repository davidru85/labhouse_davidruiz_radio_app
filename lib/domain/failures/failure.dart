import 'package:equatable/equatable.dart';

part 'api_failure.dart';
part 'network_failure.dart';
part 'playback_failure.dart';
part 'storage_failure.dart';

/// Base sealed class for all domain failures.
sealed class Failure extends Equatable {
  /// Creates a [Failure] with an optional descriptive message.
  const Failure([this.message]);

  /// Optional descriptive message about the failure.
  final String? message;

  /// Localization key associated with the failure type.
  String get localizationKey;

  @override
  List<Object?> get props => [message];
}
