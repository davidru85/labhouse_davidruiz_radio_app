import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/favorites_repository.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Loads the persisted favorite stations for the presentation layer.
final class GetFavoritesUseCase
    implements UseCase<List<RadioStation>, NoParams> {
  /// Creates a get-favorites use case.
  const GetFavoritesUseCase(this._repository);

  final FavoritesRepository _repository;

  @override
  Future<Result<List<RadioStation>, Failure>> call(NoParams params) {
    return _repository.getFavorites();
  }
}
