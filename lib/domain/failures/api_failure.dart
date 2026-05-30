part of 'failure.dart';

/// Sealed class grouping all API-related domain failures.
sealed class ApiFailure extends Failure {
  /// Creates an API failure with an optional message.
  const ApiFailure([super.message]);
}

/// Failure representing an HTTP 5xx or server-side error.
final class ServerFailure extends ApiFailure {
  /// Creates a [ServerFailure] with an optional message.
  const ServerFailure([super.message]);

  @override
  String get localizationKey => 'error_server';
}

/// Failure representing an HTTP 422 or query validation error.
final class ValidationErrorFailure extends ApiFailure {
  /// Creates a [ValidationErrorFailure] with an optional message.
  const ValidationErrorFailure([super.message]);

  @override
  String get localizationKey => 'error_validation';
}

/// Failure representing an HTTP 401/403 or authorization error.
final class UnauthorizedFailure extends ApiFailure {
  /// Creates an [UnauthorizedFailure] with an optional message.
  const UnauthorizedFailure([super.message]);

  @override
  String get localizationKey => 'error_unauthorized';
}
