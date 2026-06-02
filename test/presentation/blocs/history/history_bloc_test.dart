import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/history_repository.dart';
import 'package:radio_app/domain/usecases/add_to_history_use_case.dart';
import 'package:radio_app/domain/usecases/clear_history_use_case.dart';
import 'package:radio_app/domain/usecases/get_history_use_case.dart';
import 'package:radio_app/presentation/blocs/history/history_bloc.dart';

// Use cases are `final class` (cannot be mocked outside their library), so the
// BLoC tests mock the repository contract and build real use cases — keeping
// the presentation boundary use-case-only (ARCHITECTURE.md §"Dependency Rule").
class _MockHistoryRepository extends Mock implements HistoryRepository {}

void main() {
  late _MockHistoryRepository repository;
  late HistoryBloc Function() build;

  setUpAll(() => registerFallbackValue(_station('fallback')));

  setUp(() {
    repository = _MockHistoryRepository();
    build = () => HistoryBloc(
      GetHistoryUseCase(repository),
      AddToHistoryUseCase(repository),
      ClearHistoryUseCase(repository),
    );
  });

  group('HistoryBloc', () {
    final stations = [_station('a'), _station('b')];

    blocTest<HistoryBloc, HistoryState>(
      'emits [loading, success] with the retrieved history on HistoryStarted',
      setUp: () => when(
        repository.getHistory,
      ).thenAnswer((_) async => Success<List<RadioStation>, Failure>(stations)),
      build: build,
      act: (bloc) => bloc.add(const HistoryStarted()),
      expect: () => [
        const HistoryLoadInProgress(),
        HistoryLoadSuccess(stations),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'emits [loading, failure] when loading history fails',
      setUp: () => when(repository.getHistory).thenAnswer(
        (_) async => const FailureResult<List<RadioStation>, Failure>(
          StorageReadWriteFailure(),
        ),
      ),
      build: build,
      act: (bloc) => bloc.add(const HistoryStarted()),
      expect: () => [const HistoryLoadInProgress(), isA<HistoryLoadFailure>()],
    );

    blocTest<HistoryBloc, HistoryState>(
      'adds a station then reloads the updated history',
      setUp: () {
        when(
          () => repository.addToHistory(any()),
        ).thenAnswer((_) async => const Success<void, Failure>(null));
        when(repository.getHistory).thenAnswer(
          (_) async => Success<List<RadioStation>, Failure>(stations),
        );
      },
      build: build,
      act: (bloc) => bloc.add(HistoryStationAdded(_station('a'))),
      expect: () => [
        const HistoryLoadInProgress(),
        HistoryLoadSuccess(stations),
      ],
      verify: (_) {
        verify(() => repository.addToHistory(any())).called(1);
        verify(repository.getHistory).called(1);
      },
    );

    blocTest<HistoryBloc, HistoryState>(
      'clears history then reloads an empty list',
      setUp: () {
        when(
          repository.clearHistory,
        ).thenAnswer((_) async => const Success<void, Failure>(null));
        when(repository.getHistory).thenAnswer(
          (_) async => const Success<List<RadioStation>, Failure>([]),
        );
      },
      build: build,
      act: (bloc) => bloc.add(const HistoryCleared()),
      expect: () => [
        const HistoryLoadInProgress(),
        const HistoryLoadSuccess([]),
      ],
      verify: (_) => verify(repository.clearHistory).called(1),
    );
  });
}

RadioStation _station(String uuid) => RadioStation(
  stationUuid: uuid,
  name: 'Station $uuid',
  streamUrl: 'https://example.com/$uuid',
  resolvedStreamUrl: 'https://example.com/$uuid/resolved',
  favicon: null,
  homepage: null,
  tags: '',
  tagList: const [],
  country: 'Germany',
  countryCode: 'DE',
  language: null,
  codec: null,
  bitrate: null,
  votes: 0,
  clickCount: 0,
  lastCheckOk: true,
  isHLS: false,
);
