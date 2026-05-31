import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/favorites_repository.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Refreshes locally stored favorites against remote station state.
final class RefreshFavoritesUseCase implements UseCase<void, NoParams> {
  /// Creates a favorites refresh use case.
  const RefreshFavoritesUseCase(this._repository);

  final FavoritesRepository _repository;

  /// Triggers favorites synchronization through the repository.
  @override
  Future<Result<void, Failure>> call(NoParams params) {
    return _repository.synchronizeFavorites();
  }
}
