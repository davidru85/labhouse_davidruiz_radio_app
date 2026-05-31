import 'package:equatable/equatable.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/favorites_repository.dart';

/// Toggles the favorite status of a station.
final class ToggleFavoriteUseCase {
  /// Creates a favorite toggle use case.
  const ToggleFavoriteUseCase(this._repository);

  final FavoritesRepository _repository;

  /// Adds or removes the [params] station depending on its current state.
  ///
  /// Reads the current favorites to decide the action and returns the
  /// resulting favorite state: `true` when the station is now favorited,
  /// `false` when it was removed.
  Future<Result<bool, Failure>> call(ToggleFavoriteParams params) async {
    final favorites = await _repository.getFavorites();

    switch (favorites) {
      case FailureResult<List<RadioStation>, Failure>(:final failure):
        return FailureResult<bool, Failure>(failure);
      case Success<List<RadioStation>, Failure>(:final value):
        final isFavorite = value.any(
          (station) => station.stationUuid == params.station.stationUuid,
        );
        final mutation = isFavorite
            ? await _repository.removeFavorite(params.station.stationUuid)
            : await _repository.addFavorite(params.station);

        return mutation.map((_) => !isFavorite);
    }
  }
}

/// Parameters for [ToggleFavoriteUseCase].
final class ToggleFavoriteParams extends Equatable {
  /// Creates favorite toggle parameters.
  const ToggleFavoriteParams({required this.station});

  /// Station whose favorite status is toggled.
  final RadioStation station;

  @override
  List<Object> get props => [station];
}
