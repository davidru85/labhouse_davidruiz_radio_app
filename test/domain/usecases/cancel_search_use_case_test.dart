import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/station_repository.dart';
import 'package:radio_app/domain/usecases/cancel_search_use_case.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

void main() {
  group('CancelSearchUseCase', () {
    test('cancels pending repository requests', () async {
      final repository = _FakeStationRepository();
      final useCase = CancelSearchUseCase(repository);

      final result = await useCase(const NoParams());

      expect(result, isA<Success<void, Failure>>());
      expect(repository.cancelPendingRequestsCallCount, 1);
    });

    test('forwards cancellation failures', () async {
      const failure = SocketFailure('offline');
      final repository = _FakeStationRepository(
        cancelResult: const FailureResult<void, Failure>(failure),
      );
      final useCase = CancelSearchUseCase(repository);

      final result = await useCase(const NoParams());

      expect(result, isA<FailureResult<void, Failure>>());
      expect((result as FailureResult<void, Failure>).failure, failure);
      expect(repository.cancelPendingRequestsCallCount, 1);
    });
  });
}

class _FakeStationRepository implements StationRepository {
  _FakeStationRepository({Result<void, Failure>? cancelResult})
    : cancelResult = cancelResult ?? const Success<void, Failure>(null);

  final Result<void, Failure> cancelResult;
  int cancelPendingRequestsCallCount = 0;

  @override
  Future<Result<void, Failure>> cancelPendingRequests() async {
    cancelPendingRequestsCallCount += 1;

    return cancelResult;
  }

  @override
  Future<Result<List<RadioStation>, Failure>> loadPopularStations({
    int limit = 30,
    int offset = 0,
  }) async {
    return const Success<List<RadioStation>, Failure>([]);
  }

  @override
  Future<Result<List<RadioStation>, Failure>> searchStations({
    String? query,
    String? countryCode,
    String? tag,
    int limit = 30,
    int offset = 0,
  }) async {
    return const Success<List<RadioStation>, Failure>([]);
  }

  @override
  Future<Result<RadioStation?, Failure>> getStationByUuid(
    String stationUuid,
  ) async {
    return const Success<RadioStation?, Failure>(null);
  }
}
