import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';

/// Domain contract for persisted favorite stations.
abstract interface class FavoritesRepository {
  /// Emits favorite station list updates.
  Stream<List<RadioStation>> get favoritesStream;

  /// Returns the current favorite stations.
  Future<Result<List<RadioStation>, Failure>> getFavorites();

  /// Persists [station] as a favorite.
  Future<Result<void, Failure>> addFavorite(RadioStation station);

  /// Removes a favorite station by stable UUID.
  Future<Result<void, Failure>> removeFavorite(String stationUuid);

  /// Refreshes favorites against remote station state.
  Future<Result<void, Failure>> synchronizeFavorites();
}
