import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/data/datasources/local/local_genres_data_source.dart';
import 'package:radio_app/data/datasources/remote/remote_genres_data_source.dart';
import 'package:radio_app/data/repositories/genres_repository_impl.dart';
import 'package:radio_app/domain/entities/genre.dart';
import 'package:radio_app/domain/failures/failure.dart';

void main() {
  group('GenresRepositoryImpl', () {
    test('fetches from remote, caches the result, and returns it', () async {
      final genres = [_genre('rock'), _genre('jazz')];
      final remote = _FakeRemoteGenresDataSource(result: genres);
      final local = _FakeLocalGenresDataSource();
      final repository = GenresRepositoryImpl(remote, local);

      final result = await repository.getGenres();

      expect(result, isA<Success<List<Genre>, Failure>>());
      expect((result as Success<List<Genre>, Failure>).value, genres);
      expect(local.cached, genres);
    });

    test('returns the fetched genres even when caching them fails', () async {
      final genres = [_genre('rock'), _genre('jazz')];
      final remote = _FakeRemoteGenresDataSource(result: genres);
      final local = _FakeLocalGenresDataSource(throwOnCache: true);
      final repository = GenresRepositoryImpl(remote, local);

      final result = await repository.getGenres();

      expect(result, isA<Success<List<Genre>, Failure>>());
      expect((result as Success<List<Genre>, Failure>).value, genres);
    });

    test('truncates the result to the requested limit', () async {
      final genres = [_genre('a'), _genre('b'), _genre('c')];
      final remote = _FakeRemoteGenresDataSource(result: genres);
      final local = _FakeLocalGenresDataSource();
      final repository = GenresRepositoryImpl(remote, local);

      final result = await repository.getGenres(limit: 2);

      expect((result as Success<List<Genre>, Failure>).value, [
        genres[0],
        genres[1],
      ]);
    });

    test('falls back to cached genres when the remote fails', () async {
      final cached = [_genre('cached')];
      final remote = _FakeRemoteGenresDataSource(
        error: const NetworkException(SocketFailure()),
      );
      final local = _FakeLocalGenresDataSource(initial: cached);
      final repository = GenresRepositoryImpl(remote, local);

      final result = await repository.getGenres();

      expect(result, isA<Success<List<Genre>, Failure>>());
      expect((result as Success<List<Genre>, Failure>).value, cached);
    });

    test('returns the network failure when remote fails and cache '
        'is empty', () async {
      const failure = SocketFailure();
      final remote = _FakeRemoteGenresDataSource(
        error: const NetworkException(failure),
      );
      final local = _FakeLocalGenresDataSource();
      final repository = GenresRepositoryImpl(remote, local);

      final result = await repository.getGenres();

      expect(result, isA<FailureResult<List<Genre>, Failure>>());
      expect((result as FailureResult<List<Genre>, Failure>).failure, failure);
    });
  });
}

class _FakeRemoteGenresDataSource implements RemoteGenresDataSource {
  _FakeRemoteGenresDataSource({List<Genre>? result, this.error})
    : result = result ?? const [];

  final List<Genre> result;
  final NetworkException? error;

  @override
  Future<List<Genre>> getGenres() async {
    final thrown = error;
    if (thrown != null) {
      throw thrown;
    }
    return result;
  }
}

class _FakeLocalGenresDataSource implements LocalGenresDataSource {
  _FakeLocalGenresDataSource({List<Genre>? initial, this.throwOnCache = false})
    : cached = initial ?? const [];

  final bool throwOnCache;
  List<Genre> cached;

  @override
  Future<List<Genre>> getCachedGenres() async => cached;

  @override
  Future<void> cacheGenres(List<Genre> genres) async {
    if (throwOnCache) {
      throw Exception('hive write error');
    }
    cached = genres;
  }
}

Genre _genre(String name) => Genre(name: name, stationCount: 1);
