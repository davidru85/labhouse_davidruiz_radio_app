import 'package:radio_app/core/errors/result.dart';
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

  // ignore: unused_field
  final LocalFavoritesDataSource _local;
  // ignore: unused_field
  final RemoteStationDataSource _remote;

  @override
  Stream<List<RadioStation>> get favoritesStream => throw UnimplementedError();

  @override
  Future<Result<List<RadioStation>, Failure>> getFavorites() {
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Failure>> addFavorite(RadioStation station) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Failure>> removeFavorite(String stationUuid) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Failure>> synchronizeFavorites() {
    throw UnimplementedError();
  }
}
