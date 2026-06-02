import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/station_repository.dart';
import 'package:radio_app/domain/usecases/cancel_search_use_case.dart';
import 'package:radio_app/domain/usecases/load_popular_stations_use_case.dart';
import 'package:radio_app/domain/usecases/search_stations_use_case.dart';
import 'package:radio_app/presentation/blocs/stations/stations_bloc.dart';

// Use cases are `final` (unmockable): mock the StationRepository contract and
// build real use cases, keeping the BLoC use-case-only
// (ARCHITECTURE.md §"Dependency Rule").
class _MockStationRepository extends Mock implements StationRepository {}

void main() {
  late _MockStationRepository repository;
  late StationsBloc Function() build;

  setUp(() {
    repository = _MockStationRepository();
    when(
      () => repository.cancelPendingRequests(),
    ).thenAnswer((_) async => const Success<void, Failure>(null));
    when(
      () => repository.loadPopularStations(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async => const Success<List<RadioStation>, Failure>([]));
    build = () => StationsBloc(
      SearchStationsUseCase(repository),
      LoadPopularStationsUseCase(repository),
      CancelSearchUseCase(repository),
    );
  });

  void stubSearch(List<RadioStation> Function() responder) {
    when(
      () => repository.searchStations(
        query: any(named: 'query'),
        countryCode: any(named: 'countryCode'),
        tag: any(named: 'tag'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer(
      (_) async => Success<List<RadioStation>, Failure>(responder()),
    );
  }

  List<RadioStation> page(List<String> uuids) => [
    for (final id in uuids) _station(id),
  ];

  group('StationsBloc search', () {
    blocTest<StationsBloc, StationsState>(
      'emits [loading, success] with results for a query of 3+ chars',
      setUp: () => stubSearch(() => page(['a', 'b'])),
      build: build,
      act: (bloc) => bloc.add(const StationsSearchChanged('rock')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<StationsState>().having(
          (s) => s.status,
          'status',
          StationsStatus.loading,
        ),
        isA<StationsState>()
            .having((s) => s.status, 'status', StationsStatus.success)
            .having((s) => s.stations.length, 'count', 2),
      ],
    );

    blocTest<StationsBloc, StationsState>(
      'does not search for queries under 3 characters (per ADR-0014)',
      build: build,
      act: (bloc) => bloc.add(const StationsSearchChanged('ro')),
      wait: const Duration(milliseconds: 400),
      expect: () => <StationsState>[],
      verify: (_) => verifyNever(
        () => repository.searchStations(
          query: any(named: 'query'),
          countryCode: any(named: 'countryCode'),
          tag: any(named: 'tag'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ),
    );

    blocTest<StationsBloc, StationsState>(
      'collapses rapid search events within 350ms to a single call '
      '(per ADR-0014)',
      setUp: () => stubSearch(() => const []),
      build: build,
      act: (bloc) => bloc
        ..add(const StationsSearchChanged('roc'))
        ..add(const StationsSearchChanged('rock'))
        ..add(const StationsSearchChanged('rocks')),
      wait: const Duration(milliseconds: 400),
      verify: (_) => verify(
        () => repository.searchStations(
          query: any(named: 'query'),
          countryCode: any(named: 'countryCode'),
          tag: any(named: 'tag'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).called(1),
    );

    blocTest<StationsBloc, StationsState>(
      'maps a search API failure to a failure state',
      setUp: () =>
          when(
            () => repository.searchStations(
              query: any(named: 'query'),
              countryCode: any(named: 'countryCode'),
              tag: any(named: 'tag'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ),
          ).thenAnswer(
            (_) async => const FailureResult<List<RadioStation>, Failure>(
              ServerFailure(),
            ),
          ),
      build: build,
      act: (bloc) => bloc.add(const StationsSearchChanged('rock')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<StationsState>().having(
          (s) => s.status,
          'status',
          StationsStatus.loading,
        ),
        isA<StationsState>().having(
          (s) => s.status,
          'status',
          StationsStatus.failure,
        ),
      ],
    );

    blocTest<StationsBloc, StationsState>(
      'an empty query loads popular stations (per ADR-0014)',
      setUp: () =>
          when(
            () => repository.loadPopularStations(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ),
          ).thenAnswer(
            (_) async => Success<List<RadioStation>, Failure>(page(['p'])),
          ),
      build: build,
      act: (bloc) => bloc.add(const StationsSearchChanged('')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<StationsState>().having(
          (s) => s.status,
          'status',
          StationsStatus.loading,
        ),
        isA<StationsState>()
            .having((s) => s.status, 'status', StationsStatus.success)
            .having((s) => s.stations.length, 'count', 1),
      ],
      verify: (_) {
        verify(
          () => repository.loadPopularStations(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).called(1);
      },
    );

    blocTest<StationsBloc, StationsState>(
      'cancels an in-flight search when a new search arrives (per ADR-0014)',
      setUp: () => stubSearch(() => const []),
      build: build,
      act: (bloc) async {
        bloc.add(const StationsSearchChanged('rock'));
        await Future<void>.delayed(const Duration(milliseconds: 400));
        bloc.add(const StationsSearchChanged('jazz'));
        await Future<void>.delayed(const Duration(milliseconds: 400));
      },
      verify: (_) => verify(
        () => repository.cancelPendingRequests(),
      ).called(greaterThan(0)),
    );
  });

  group('StationsBloc filters', () {
    blocTest<StationsBloc, StationsState>(
      'country filter searches by the selected country code',
      setUp: () => stubSearch(() => page(['de'])),
      build: build,
      act: (bloc) => bloc.add(const StationsCountryFilterChanged('DE')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<StationsState>().having(
          (s) => s.status,
          'status',
          StationsStatus.loading,
        ),
        isA<StationsState>().having(
          (s) => s.status,
          'status',
          StationsStatus.success,
        ),
      ],
      verify: (_) => verify(
        () => repository.searchStations(
          query: any(named: 'query'),
          countryCode: 'DE',
          tag: any(named: 'tag'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).called(1),
    );

    blocTest<StationsBloc, StationsState>(
      'tag filter searches by the selected tag',
      setUp: () => stubSearch(() => page(['rock'])),
      build: build,
      act: (bloc) => bloc.add(const StationsTagFilterChanged('rock')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<StationsState>().having(
          (s) => s.status,
          'status',
          StationsStatus.loading,
        ),
        isA<StationsState>().having(
          (s) => s.status,
          'status',
          StationsStatus.success,
        ),
      ],
      verify: (_) => verify(
        () => repository.searchStations(
          query: any(named: 'query'),
          countryCode: any(named: 'countryCode'),
          tag: 'rock',
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).called(1),
    );
  });

  group('StationsBloc pagination', () {
    blocTest<StationsBloc, StationsState>(
      'load more appends and deduplicates the next page by uuid '
      '(per ADR-0031)',
      setUp: () {
        final responses = <List<RadioStation>>[
          page(['a', 'b']),
          page(['b', 'c']),
        ];
        stubSearch(() => responses.removeAt(0));
      },
      build: build,
      act: (bloc) async {
        bloc.add(const StationsSearchChanged('rock'));
        await Future<void>.delayed(const Duration(milliseconds: 400));
        bloc.add(const StationsLoadMoreRequested());
        await Future<void>.delayed(const Duration(milliseconds: 50));
      },
      expect: () => [
        isA<StationsState>().having(
          (s) => s.status,
          'status',
          StationsStatus.loading,
        ),
        isA<StationsState>()
            .having((s) => s.status, 'status', StationsStatus.success)
            .having((s) => s.stations.length, 'count', 2),
        isA<StationsState>()
            .having(
              (s) => s.stations.map((e) => e.stationUuid).toList(),
              'uuids',
              ['a', 'b', 'c'],
            )
            .having((s) => s.hasReachedMax, 'hasReachedMax', true),
      ],
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
