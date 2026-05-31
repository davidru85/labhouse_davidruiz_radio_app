import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/favorites_repository.dart';
import 'package:radio_app/domain/usecases/refresh_favorites_use_case.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

void main() {
  group('RefreshFavoritesUseCase', () {
    test('delegates synchronization to the repository', () async {
      final repository = _FakeFavoritesRepository(
        synchronizeResult: const Success<void, Failure>(null),
      );
      final useCase = RefreshFavoritesUseCase(repository);

      final result = await useCase(const NoParams());

      expect(result, isA<Success<void, Failure>>());
      expect(repository.synchronizeCalls, 1);
    });

    test('forwards repository synchronization failures', () async {
      const failure = FavoritesSyncFailure('sync error');
      final repository = _FakeFavoritesRepository(
        synchronizeResult: const FailureResult<void, Failure>(failure),
      );
      final useCase = RefreshFavoritesUseCase(repository);

      final result = await useCase(const NoParams());

      expect(result, isA<FailureResult<void, Failure>>());
      expect((result as FailureResult<void, Failure>).failure, failure);
      expect(repository.synchronizeCalls, 1);
    });
  });
}

class _FakeFavoritesRepository implements FavoritesRepository {
  _FakeFavoritesRepository({required this.synchronizeResult});

  final Result<void, Failure> synchronizeResult;
  int synchronizeCalls = 0;

  @override
  Stream<List<RadioStation>> get favoritesStream =>
      const Stream<List<RadioStation>>.empty();

  @override
  Future<Result<List<RadioStation>, Failure>> getFavorites() async {
    return const Success<List<RadioStation>, Failure>(<RadioStation>[]);
  }

  @override
  Future<Result<void, Failure>> addFavorite(RadioStation station) async {
    return const Success<void, Failure>(null);
  }

  @override
  Future<Result<void, Failure>> removeFavorite(String stationUuid) async {
    return const Success<void, Failure>(null);
  }

  @override
  Future<Result<void, Failure>> synchronizeFavorites() async {
    synchronizeCalls++;

    return synchronizeResult;
  }
}
