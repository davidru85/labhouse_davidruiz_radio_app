import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/data/datasources/local/local_favorites_data_source.dart';
import 'package:radio_app/data/datasources/remote/remote_station_data_source.dart';
import 'package:radio_app/data/datasources/remote/station_sort.dart';
import 'package:radio_app/data/repositories/favorites_repository_impl.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';

void main() {
  group('FavoritesRepositoryImpl', () {
    group('getFavorites', () {
      test('returns the persisted favorites from local storage', () async {
        final stations = [_station(uuid: 'a'), _station(uuid: 'b')];
        final local = _FakeLocalFavoritesDataSource(initial: stations);
        final repository = _repository(local: local);

        final result = await repository.getFavorites();

        expect(result, isA<Success<List<RadioStation>, Failure>>());
        expect(
          (result as Success<List<RadioStation>, Failure>).value,
          stations,
        );
      });

      test('maps a storage error to StorageReadWriteFailure', () async {
        final local = _FakeLocalFavoritesDataSource(throwOnGet: true);
        final repository = _repository(local: local);

        final result = await repository.getFavorites();

        expect(result, isA<FailureResult<List<RadioStation>, Failure>>());
        expect(
          (result as FailureResult<List<RadioStation>, Failure>).failure,
          isA<StorageReadWriteFailure>(),
        );
      });
    });

    group('addFavorite', () {
      test('persists the station and emits the updated list', () async {
        final local = _FakeLocalFavoritesDataSource();
        final repository = _repository(local: local);
        final station = _station(uuid: 'a');
        final emissions = <List<RadioStation>>[];
        final subscription = repository.favoritesStream.listen(emissions.add);

        final result = await repository.addFavorite(station);
        await Future<void>.delayed(Duration.zero);

        expect(result, isA<Success<void, Failure>>());
        expect(local.saved, contains(station));
        expect(emissions, isNotEmpty);
        expect(emissions.last, contains(station));
        await subscription.cancel();
      });

      test('maps a storage error to StorageReadWriteFailure', () async {
        final local = _FakeLocalFavoritesDataSource(throwOnSave: true);
        final repository = _repository(local: local);

        final result = await repository.addFavorite(_station(uuid: 'a'));

        expect(result, isA<FailureResult<void, Failure>>());
        expect(
          (result as FailureResult<void, Failure>).failure,
          isA<StorageReadWriteFailure>(),
        );
      });
    });

    group('removeFavorite', () {
      test('deletes the station and emits the updated list', () async {
        final local = _FakeLocalFavoritesDataSource(
          initial: [
            _station(uuid: 'a'),
            _station(uuid: 'b'),
          ],
        );
        final repository = _repository(local: local);
        final emissions = <List<RadioStation>>[];
        final subscription = repository.favoritesStream.listen(emissions.add);

        final result = await repository.removeFavorite('a');
        await Future<void>.delayed(Duration.zero);

        expect(result, isA<Success<void, Failure>>());
        expect(local.removed, contains('a'));
        expect(emissions.last.map((s) => s.stationUuid), isNot(contains('a')));
        await subscription.cancel();
      });

      test('maps a storage error to StorageReadWriteFailure', () async {
        final local = _FakeLocalFavoritesDataSource(throwOnRemove: true);
        final repository = _repository(local: local);

        final result = await repository.removeFavorite('a');

        expect(result, isA<FailureResult<void, Failure>>());
        expect(
          (result as FailureResult<void, Failure>).failure,
          isA<StorageReadWriteFailure>(),
        );
      });
    });

    group('synchronizeFavorites', () {
      test('refreshes still-present favorites with remote metadata', () async {
        final stale = _station(uuid: 'a', name: 'Old Name');
        final fresh = _station(uuid: 'a', name: 'New Name');
        final local = _FakeLocalFavoritesDataSource(initial: [stale]);
        final remote = _FakeRemoteStationDataSource(byUuidsResult: [fresh]);
        final repository = _repository(local: local, remote: remote);

        final result = await repository.synchronizeFavorites();

        expect(result, isA<Success<void, Failure>>());
        expect(remote.lastByUuids, ['a']);
        expect(local.store['a']!.name, 'New Name');
        expect(local.store['a']!.lastCheckOk, isTrue);
      });

      test(
        'retains an orphaned favorite as lastCheckOk=false (ADR-0020)',
        () async {
          final orphan = _station(uuid: 'gone');
          final local = _FakeLocalFavoritesDataSource(initial: [orphan]);
          // Remote no longer returns the station.
          final remote = _FakeRemoteStationDataSource(byUuidsResult: const []);
          final repository = _repository(local: local, remote: remote);

          final result = await repository.synchronizeFavorites();

          expect(result, isA<Success<void, Failure>>());
          expect(local.removed, isEmpty);
          expect(local.store.containsKey('gone'), isTrue);
          expect(local.store['gone']!.lastCheckOk, isFalse);
        },
      );

      test('does not hit the remote when there are no favorites', () async {
        final local = _FakeLocalFavoritesDataSource();
        final remote = _FakeRemoteStationDataSource();
        final repository = _repository(local: local, remote: remote);

        final result = await repository.synchronizeFavorites();

        expect(result, isA<Success<void, Failure>>());
        expect(remote.byUuidsCallCount, 0);
      });

      test('maps a remote failure to FavoritesSyncFailure', () async {
        final local = _FakeLocalFavoritesDataSource(
          initial: [_station(uuid: 'a')],
        );
        final remote = _FakeRemoteStationDataSource(
          byUuidsError: const NetworkException(SocketFailure()),
        );
        final repository = _repository(local: local, remote: remote);

        final result = await repository.synchronizeFavorites();

        expect(result, isA<FailureResult<void, Failure>>());
        expect(
          (result as FailureResult<void, Failure>).failure,
          isA<FavoritesSyncFailure>(),
        );
        // The orphaned favorite must NOT be deleted on failure.
        expect(local.removed, isEmpty);
      });
    });
  });
}

FavoritesRepositoryImpl _repository({
  _FakeLocalFavoritesDataSource? local,
  _FakeRemoteStationDataSource? remote,
}) {
  return FavoritesRepositoryImpl(
    local ?? _FakeLocalFavoritesDataSource(),
    remote ?? _FakeRemoteStationDataSource(),
  );
}

class _FakeLocalFavoritesDataSource implements LocalFavoritesDataSource {
  _FakeLocalFavoritesDataSource({
    List<RadioStation>? initial,
    this.throwOnGet = false,
    this.throwOnSave = false,
    this.throwOnRemove = false,
  }) {
    for (final station in initial ?? const <RadioStation>[]) {
      store[station.stationUuid] = station;
    }
  }

  final Map<String, RadioStation> store = <String, RadioStation>{};
  final List<RadioStation> saved = <RadioStation>[];
  final List<String> removed = <String>[];
  final bool throwOnGet;
  final bool throwOnSave;
  final bool throwOnRemove;

  @override
  Future<List<RadioStation>> getFavorites() async {
    if (throwOnGet) {
      throw Exception('hive read error');
    }
    return store.values.toList();
  }

  @override
  Future<void> saveFavorite(RadioStation station) async {
    if (throwOnSave) {
      throw Exception('hive write error');
    }
    saved.add(station);
    store[station.stationUuid] = station;
  }

  @override
  Future<void> removeFavorite(String stationUuid) async {
    if (throwOnRemove) {
      throw Exception('hive delete error');
    }
    removed.add(stationUuid);
    store.remove(stationUuid);
  }
}

class _FakeRemoteStationDataSource implements RemoteStationDataSource {
  _FakeRemoteStationDataSource({
    List<RadioStation>? byUuidsResult,
    this.byUuidsError,
  }) : byUuidsResult = byUuidsResult ?? const [];

  final List<RadioStation> byUuidsResult;
  final NetworkException? byUuidsError;
  List<String>? lastByUuids;
  int byUuidsCallCount = 0;

  @override
  Future<List<RadioStation>> getStationsByUuids(List<String> uuids) async {
    byUuidsCallCount++;
    lastByUuids = uuids;
    final error = byUuidsError;
    if (error != null) {
      throw error;
    }
    return byUuidsResult;
  }

  @override
  Future<List<RadioStation>> searchStations({
    String? query,
    String? countryCode,
    String? tag,
    StationSort sort = StationSort.clickCount,
    int limit = 30,
    int offset = 0,
  }) => throw UnimplementedError();

  @override
  Future<List<RadioStation>> getPopularStations({
    StationSort sort = StationSort.clickCount,
    int limit = 30,
  }) => throw UnimplementedError();

  @override
  void cancelSearch() => throw UnimplementedError();
}

RadioStation _station({
  required String uuid,
  String name = 'Jazz FM',
  bool lastCheckOk = true,
}) {
  return RadioStation(
    stationUuid: uuid,
    name: name,
    streamUrl: 'http://example.com/stream',
    resolvedStreamUrl: 'https://example.com/stream',
    favicon: null,
    homepage: null,
    tags: 'jazz,swing',
    tagList: const ['jazz', 'swing'],
    country: 'Germany',
    countryCode: 'DE',
    language: 'german',
    codec: 'MP3',
    bitrate: 128,
    votes: 10,
    clickCount: 20,
    lastCheckOk: lastCheckOk,
    isHLS: false,
  );
}
