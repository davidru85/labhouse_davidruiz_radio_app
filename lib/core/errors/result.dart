/// Functional result type for operations that can either succeed or fail.
sealed class Result<S, F> {
  /// Creates a result.
  const Result();

  /// Transforms the success value while preserving failures.
  Result<T, F> map<T>(T Function(S value) transform);

  /// Transforms the failure value while preserving successes.
  Result<S, T> mapFailure<T>(T Function(F failure) transform);
}

/// Successful operation result.
final class Success<S, F> extends Result<S, F> {
  /// Creates a successful result containing [value].
  const Success(this.value);

  /// Success payload.
  final S value;

  @override
  Result<T, F> map<T>(T Function(S value) transform) {
    return Success<T, F>(transform(value));
  }

  @override
  Result<S, T> mapFailure<T>(T Function(F failure) transform) {
    return Success<S, T>(value);
  }
}

/// Failed operation result.
final class FailureResult<S, F> extends Result<S, F> {
  /// Creates a failed result containing [failure].
  const FailureResult(this.failure);

  /// Failure payload.
  final F failure;

  @override
  Result<T, F> map<T>(T Function(S value) transform) {
    return FailureResult<T, F>(failure);
  }

  @override
  Result<S, T> mapFailure<T>(T Function(F failure) transform) {
    return FailureResult<S, T>(transform(failure));
  }
}
