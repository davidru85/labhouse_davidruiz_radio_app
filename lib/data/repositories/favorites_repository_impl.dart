import 'dart:async';

import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/data/datasources/local/local_favorites_data_source.dart';
import 'package:radio_app/data/datasources/remote/remote_station_data_source.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/favorites_repository.dart';

/// [FavoritesRepository] backed by local persistence and remote sync
/// (per ADR-0020 / `API_SPEC.md` §8).
class FavoritesRepositoryImpl implements FavoritesRepository {
  /// Creates the repository over local and remote data sources.
  FavoritesRepositoryImpl(this._local, this._remote);

  final LocalFavoritesDataSource _local;
  final RemoteStationDataSource _remote;

  final StreamController<List<RadioStation>> _favoritesController =
      StreamController<List<RadioStation>>.broadcast();

  @override
  Stream<List<RadioStation>> get favoritesStream => _favoritesController.stream;

  @override
  Future<Result<List<RadioStation>, Failure>> getFavorites() {
    return _guard(_local.getFavorites);
  }

  @override
  Future<Result<void, Failure>> addFavorite(RadioStation station) {
    return _guard(() async {
      await _local.saveFavorite(station);
      await _emitFavorites();
    });
  }

  @override
  Future<Result<void, Failure>> removeFavorite(String stationUuid) {
    return _guard(() async {
      await _local.removeFavorite(stationUuid);
      await _emitFavorites();
    });
  }

  @override
  Future<Result<void, Failure>> synchronizeFavorites() async {
    try {
      final favorites = await _local.getFavorites();
      if (favorites.isEmpty) {
        return const Success<void, Failure>(null);
      }

      final uuids = favorites.map((station) => station.stationUuid).toList();
      final fresh = await _remote.getStationsByUuids(uuids);
      final freshByUuid = <String, RadioStation>{
        for (final station in fresh) station.stationUuid: station,
      };

      for (final favorite in favorites) {
        // Refresh still-present favorites; retain orphaned ones as inactive
        // instead of deleting them (per ADR-0020).
        final updated =
            freshByUuid[favorite.stationUuid] ??
            favorite.copyWith(lastCheckOk: false);
        await _local.saveFavorite(updated);
      }

      await _emitFavorites();
      return const Success<void, Failure>(null);
    } on NetworkException catch (exception) {
      return FailureResult<void, Failure>(
        FavoritesSyncFailure(exception.failure.message),
      );
    } on Object catch (error) {
      return FailureResult<void, Failure>(
        StorageReadWriteFailure(error.toString()),
      );
    }
  }

  /// Reads the current favorites and pushes them onto [favoritesStream].
  Future<void> _emitFavorites() async {
    _favoritesController.add(await _local.getFavorites());
  }

  /// Runs [operation], wrapping its value in [Success] and mapping any
  /// local-storage error to a [StorageReadWriteFailure].
  Future<Result<T, Failure>> _guard<T>(Future<T> Function() operation) async {
    try {
      return Success<T, Failure>(await operation());
    } on Object catch (error) {
      return FailureResult<T, Failure>(
        StorageReadWriteFailure(error.toString()),
      );
    }
  }
}
