import 'package:equatable/equatable.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/failures/failure.dart';

/// Contract implemented by every future-returning use case (per
/// `ARCHITECTURE.md` §4).
// ignore: one_member_abstracts
abstract class UseCase<T, Params> {
  /// Executes the use case with [params].
  Future<Result<T, Failure>> call(Params params);
}

/// Contract implemented by every stream-returning use case (per
/// `ARCHITECTURE.md` §4).
// ignore: one_member_abstracts
abstract class StreamUseCase<T, Params> {
  /// Executes the use case with [params], emitting a stream of values.
  Stream<T> call(Params params);
}

/// Empty parameter object for use cases that do not need input.
final class NoParams extends Equatable {
  /// Creates empty use-case parameters.
  const NoParams();

  @override
  List<Object?> get props => [];
}
