import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/data/datasources/local/local_genres_data_source.dart';
import 'package:radio_app/data/datasources/remote/remote_genres_data_source.dart';
import 'package:radio_app/domain/entities/genre.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/genres_repository.dart';

/// [GenresRepository] that serves genres network-first with a Hive cache
/// fallback for offline access (per ADR-0013 / `API_SPEC.md` §5.4).
class GenresRepositoryImpl implements GenresRepository {
  /// Creates the repository over remote and local genre data sources.
  GenresRepositoryImpl(this._remote, this._local);

  final RemoteGenresDataSource _remote;
  final LocalGenresDataSource _local;

  @override
  Future<Result<List<Genre>, Failure>> getGenres({int limit = 50}) async {
    try {
      final genres = await _remote.getGenres();
      await _cacheBestEffort(genres);
      return Success<List<Genre>, Failure>(_limited(genres, limit));
    } on NetworkException catch (exception) {
      // Network-first failed: fall back to the cache when it has data,
      // otherwise surface the mapped network failure (per ADR-0013).
      return _fallBackToCache(exception, limit);
    }
  }

  /// Refreshes the cache without letting a write failure discard a successful
  /// network fetch: caching is best-effort under the network-first contract
  /// (per ADR-0013 / `API_SPEC.md` §5.4).
  Future<void> _cacheBestEffort(List<Genre> genres) async {
    try {
      await _local.cacheGenres(genres);
    } on Object {
      // Swallow storage write errors: the freshly fetched genres are still
      // returned to the caller; only the cache refresh is sacrificed.
    }
  }

  /// Serves cached genres when the network-first fetch failed, mapping any
  /// cache read error to a [StorageReadWriteFailure].
  Future<Result<List<Genre>, Failure>> _fallBackToCache(
    NetworkException exception,
    int limit,
  ) async {
    try {
      final cached = await _local.getCachedGenres();
      if (cached.isNotEmpty) {
        return Success<List<Genre>, Failure>(_limited(cached, limit));
      }
      return FailureResult<List<Genre>, Failure>(exception.failure);
    } on Object catch (error) {
      return FailureResult<List<Genre>, Failure>(
        StorageReadWriteFailure(error.toString()),
      );
    }
  }

  /// Returns at most [limit] genres, preserving order.
  List<Genre> _limited(List<Genre> genres, int limit) {
    if (genres.length <= limit) {
      return genres;
    }
    return genres.sublist(0, limit);
  }
}
