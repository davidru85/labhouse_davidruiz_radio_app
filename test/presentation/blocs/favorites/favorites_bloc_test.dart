import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/analytics/analytics_event.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/analytics_repository.dart';
import 'package:radio_app/domain/repositories/favorites_repository.dart';
import 'package:radio_app/domain/usecases/get_favorites_use_case.dart';
import 'package:radio_app/domain/usecases/refresh_favorites_use_case.dart';
import 'package:radio_app/domain/usecases/toggle_favorite_use_case.dart';
import 'package:radio_app/domain/usecases/track_analytics_event_use_case.dart';
import 'package:radio_app/presentation/blocs/favorites/favorites_bloc.dart';

// Use cases are `final` (unmockable outside their library): mock the
// repository contract and build real use cases, keeping the BLoC use-case-only.
class _MockFavoritesRepository extends Mock implements FavoritesRepository {}

class _MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  late _MockFavoritesRepository repository;
  late _MockAnalyticsRepository analytics;

  setUpAll(() {
    registerFallbackValue(_station('fallback'));
    registerFallbackValue(const AppOpenedEvent());
  });

  setUp(() {
    repository = _MockFavoritesRepository();
    analytics = _MockAnalyticsRepository();
    when(() => analytics.track(any())).thenAnswer((_) async {});
  });

  FavoritesBloc build() => FavoritesBloc(
    GetFavoritesUseCase(repository),
    ToggleFavoriteUseCase(repository),
    RefreshFavoritesUseCase(repository),
    TrackAnalyticsEventUseCase(analytics),
  );

  group('FavoritesBloc', () {
    final favorites = [_station('a'), _station('b')];

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [loading, success] with persisted favorites on FavoritesStarted',
      setUp: () => when(repository.getFavorites).thenAnswer(
        (_) async => Success<List<RadioStation>, Failure>(favorites),
      ),
      build: build,
      act: (bloc) => bloc.add(const FavoritesStarted()),
      expect: () => [
        const FavoritesLoadInProgress(),
        FavoritesLoadSuccess(favorites),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [loading, failure] when loading favorites fails',
      setUp: () => when(repository.getFavorites).thenAnswer(
        (_) async => const FailureResult<List<RadioStation>, Failure>(
          StorageReadWriteFailure(),
        ),
      ),
      build: build,
      act: (bloc) => bloc.add(const FavoritesStarted()),
      expect: () => [
        const FavoritesLoadInProgress(),
        isA<FavoritesLoadFailure>(),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'toggling an existing favorite removes it then reloads the list',
      setUp: () {
        when(repository.getFavorites).thenAnswer(
          (_) async => Success<List<RadioStation>, Failure>([_station('a')]),
        );
        when(
          () => repository.removeFavorite(any()),
        ).thenAnswer((_) async => const Success<void, Failure>(null));
      },
      build: build,
      act: (bloc) => bloc.add(FavoriteToggled(_station('a'))),
      expect: () => [
        const FavoritesLoadInProgress(),
        isA<FavoritesLoadSuccess>(),
      ],
      verify: (_) => verify(() => repository.removeFavorite('a')).called(1),
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'toggling a new favorite adds it then reloads the list',
      setUp: () {
        when(repository.getFavorites).thenAnswer(
          (_) async => const Success<List<RadioStation>, Failure>([]),
        );
        when(
          () => repository.addFavorite(any()),
        ).thenAnswer((_) async => const Success<void, Failure>(null));
      },
      build: build,
      act: (bloc) => bloc.add(FavoriteToggled(_station('c'))),
      expect: () => [
        const FavoritesLoadInProgress(),
        isA<FavoritesLoadSuccess>(),
      ],
      verify: (_) => verify(() => repository.addFavorite(any())).called(1),
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits failure when toggling a favorite fails',
      setUp: () => when(repository.getFavorites).thenAnswer(
        (_) async => const FailureResult<List<RadioStation>, Failure>(
          StorageReadWriteFailure(),
        ),
      ),
      build: build,
      act: (bloc) => bloc.add(FavoriteToggled(_station('a'))),
      expect: () => [
        const FavoritesLoadInProgress(),
        isA<FavoritesLoadFailure>(),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'fires StationFavoritedEvent after adding a favorite succeeds '
      '(per ADR-0019)',
      setUp: () {
        when(repository.getFavorites).thenAnswer(
          (_) async => const Success<List<RadioStation>, Failure>([]),
        );
        when(
          () => repository.addFavorite(any()),
        ).thenAnswer((_) async => const Success<void, Failure>(null));
      },
      build: build,
      act: (bloc) => bloc.add(FavoriteToggled(_station('c'))),
      verify: (_) => verify(
        () => analytics.track(const StationFavoritedEvent('c')),
      ).called(1),
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'fires StationUnfavoritedEvent after removing a favorite succeeds '
      '(per ADR-0019)',
      setUp: () {
        when(repository.getFavorites).thenAnswer(
          (_) async => Success<List<RadioStation>, Failure>([_station('a')]),
        );
        when(
          () => repository.removeFavorite(any()),
        ).thenAnswer((_) async => const Success<void, Failure>(null));
      },
      build: build,
      act: (bloc) => bloc.add(FavoriteToggled(_station('a'))),
      verify: (_) => verify(
        () => analytics.track(const StationUnfavoritedEvent('a')),
      ).called(1),
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'does not fire favorite analytics when the toggle fails (per ADR-0019)',
      setUp: () => when(repository.getFavorites).thenAnswer(
        (_) async => const FailureResult<List<RadioStation>, Failure>(
          StorageReadWriteFailure(),
        ),
      ),
      build: build,
      act: (bloc) => bloc.add(FavoriteToggled(_station('a'))),
      verify: (_) => verifyNever(() => analytics.track(any())),
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'refreshing syncs then reloads the favorites',
      setUp: () {
        when(
          repository.synchronizeFavorites,
        ).thenAnswer((_) async => const Success<void, Failure>(null));
        when(repository.getFavorites).thenAnswer(
          (_) async => Success<List<RadioStation>, Failure>(favorites),
        );
      },
      build: build,
      act: (bloc) => bloc.add(const FavoritesRefreshed()),
      expect: () => [
        const FavoritesLoadInProgress(),
        FavoritesLoadSuccess(favorites),
      ],
      verify: (_) => verify(repository.synchronizeFavorites).called(1),
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
