import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:radio_app/core/di/composition_root.dart';
import 'package:radio_app/data/datasources/audio_playback_data_source.dart';
import 'package:radio_app/data/datasources/local/local_countries_data_source.dart';
import 'package:radio_app/data/datasources/local/local_favorites_data_source.dart';
import 'package:radio_app/data/datasources/local/local_genres_data_source.dart';
import 'package:radio_app/data/datasources/local/local_history_data_source.dart';
import 'package:radio_app/data/datasources/local/mirror_cache_data_source.dart';
import 'package:radio_app/data/datasources/remote/connectivity_data_source.dart';
import 'package:radio_app/data/datasources/remote/remote_countries_data_source.dart';
import 'package:radio_app/data/datasources/remote/remote_genres_data_source.dart';
import 'package:radio_app/data/datasources/remote/remote_playback_url_data_source.dart';
import 'package:radio_app/data/datasources/remote/remote_station_data_source.dart';
import 'package:radio_app/data/models/country_hive_model.dart';
import 'package:radio_app/data/models/genre_hive_model.dart';
import 'package:radio_app/data/models/station_hive_model.dart';
import 'package:radio_app/data/repositories/no_op_analytics_repository_impl.dart';
import 'package:radio_app/domain/repositories/analytics_repository.dart';
import 'package:radio_app/domain/repositories/audio_player_repository.dart';
import 'package:radio_app/domain/repositories/connectivity_repository.dart';
import 'package:radio_app/domain/repositories/countries_repository.dart';
import 'package:radio_app/domain/repositories/favorites_repository.dart';
import 'package:radio_app/domain/repositories/genres_repository.dart';
import 'package:radio_app/domain/repositories/history_repository.dart';
import 'package:radio_app/domain/repositories/playback_url_repository.dart';
import 'package:radio_app/domain/repositories/station_repository.dart';
import 'package:radio_app/domain/usecases/add_to_history_use_case.dart';
import 'package:radio_app/domain/usecases/cancel_search_use_case.dart';
import 'package:radio_app/domain/usecases/clear_history_use_case.dart';
import 'package:radio_app/domain/usecases/get_favorites_use_case.dart';
import 'package:radio_app/domain/usecases/get_history_use_case.dart';
import 'package:radio_app/domain/usecases/get_station_by_uuid_use_case.dart';
import 'package:radio_app/domain/usecases/load_countries_use_case.dart';
import 'package:radio_app/domain/usecases/load_genres_use_case.dart';
import 'package:radio_app/domain/usecases/load_popular_stations_use_case.dart';
import 'package:radio_app/domain/usecases/pause_playback_use_case.dart';
import 'package:radio_app/domain/usecases/play_station_use_case.dart';
import 'package:radio_app/domain/usecases/refresh_favorites_use_case.dart';
import 'package:radio_app/domain/usecases/search_stations_use_case.dart';
import 'package:radio_app/domain/usecases/stop_playback_use_case.dart';
import 'package:radio_app/domain/usecases/toggle_favorite_use_case.dart';
import 'package:radio_app/domain/usecases/track_analytics_event_use_case.dart';
import 'package:radio_app/domain/usecases/watch_connectivity_use_case.dart';
import 'package:radio_app/domain/usecases/watch_now_playing_use_case.dart';
import 'package:radio_app/domain/usecases/watch_player_state_use_case.dart';
import 'package:radio_app/hive_registrar.g.dart';
import 'package:radio_app/presentation/blocs/connectivity/connectivity_bloc.dart';
import 'package:radio_app/presentation/blocs/countries/countries_bloc.dart';
import 'package:radio_app/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:radio_app/presentation/blocs/genres/genres_bloc.dart';
import 'package:radio_app/presentation/blocs/history/history_bloc.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/blocs/stations/stations_bloc.dart';

void main() {
  group('configureDependencies', () {
    late GetIt getIt;
    late Directory tempDir;

    setUp(() async {
      getIt = GetIt.asNewInstance();
      tempDir = Directory.systemTemp.createTempSync();
      Hive.init(tempDir.path);

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapters();
      }

      await Hive.openBox<dynamic>('app_settings');
      await Hive.openBox<StationHiveModel>('favorites');
      await Hive.openBox<StationHiveModel>('history');
      await Hive.openBox<GenreHiveModel>('genres');
      await Hive.openBox<CountryHiveModel>('countries');
    });

    tearDown(() async {
      await getIt.reset();
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('registers every data source, repository, use case, and BLoC', () {
      configureDependencies(getIt);

      expect(getIt.isRegistered<MirrorCacheDataSource>(), isTrue);
      expect(getIt.isRegistered<LocalFavoritesDataSource>(), isTrue);
      expect(getIt.isRegistered<LocalHistoryDataSource>(), isTrue);
      expect(getIt.isRegistered<LocalGenresDataSource>(), isTrue);
      expect(getIt.isRegistered<LocalCountriesDataSource>(), isTrue);
      expect(getIt.isRegistered<RemoteStationDataSource>(), isTrue);
      expect(getIt.isRegistered<RemoteGenresDataSource>(), isTrue);
      expect(getIt.isRegistered<RemoteCountriesDataSource>(), isTrue);
      expect(getIt.isRegistered<RemotePlaybackUrlDataSource>(), isTrue);
      expect(getIt.isRegistered<ConnectivityDataSource>(), isTrue);
      expect(getIt.isRegistered<AudioPlaybackDataSource>(), isTrue);

      expect(getIt.isRegistered<StationRepository>(), isTrue);
      expect(getIt.isRegistered<FavoritesRepository>(), isTrue);
      expect(getIt.isRegistered<GenresRepository>(), isTrue);
      expect(getIt.isRegistered<CountriesRepository>(), isTrue);
      expect(getIt.isRegistered<HistoryRepository>(), isTrue);
      expect(getIt.isRegistered<PlaybackUrlRepository>(), isTrue);
      expect(getIt.isRegistered<AudioPlayerRepository>(), isTrue);
      expect(getIt.isRegistered<ConnectivityRepository>(), isTrue);
      expect(getIt.isRegistered<AnalyticsRepository>(), isTrue);

      expect(getIt.isRegistered<SearchStationsUseCase>(), isTrue);
      expect(getIt.isRegistered<LoadPopularStationsUseCase>(), isTrue);
      expect(getIt.isRegistered<CancelSearchUseCase>(), isTrue);
      expect(getIt.isRegistered<GetStationByUuidUseCase>(), isTrue);
      expect(getIt.isRegistered<GetFavoritesUseCase>(), isTrue);
      expect(getIt.isRegistered<ToggleFavoriteUseCase>(), isTrue);
      expect(getIt.isRegistered<RefreshFavoritesUseCase>(), isTrue);
      expect(getIt.isRegistered<GetHistoryUseCase>(), isTrue);
      expect(getIt.isRegistered<AddToHistoryUseCase>(), isTrue);
      expect(getIt.isRegistered<ClearHistoryUseCase>(), isTrue);
      expect(getIt.isRegistered<LoadGenresUseCase>(), isTrue);
      expect(getIt.isRegistered<LoadCountriesUseCase>(), isTrue);
      expect(getIt.isRegistered<PlayStationUseCase>(), isTrue);
      expect(getIt.isRegistered<PausePlaybackUseCase>(), isTrue);
      expect(getIt.isRegistered<StopPlaybackUseCase>(), isTrue);
      expect(getIt.isRegistered<WatchPlayerStateUseCase>(), isTrue);
      expect(getIt.isRegistered<WatchNowPlayingUseCase>(), isTrue);
      expect(getIt.isRegistered<WatchConnectivityUseCase>(), isTrue);
      expect(getIt.isRegistered<TrackAnalyticsEventUseCase>(), isTrue);

      expect(getIt.isRegistered<RadioPlayerBloc>(), isTrue);
      expect(getIt.isRegistered<StationsBloc>(), isTrue);
      expect(getIt.isRegistered<FavoritesBloc>(), isTrue);
      expect(getIt.isRegistered<HistoryBloc>(), isTrue);
      expect(getIt.isRegistered<GenresBloc>(), isTrue);
      expect(getIt.isRegistered<CountriesBloc>(), isTrue);
      expect(getIt.isRegistered<ConnectivityBloc>(), isTrue);
    });

    test('uses the no-op analytics repository as the default adapter', () {
      configureDependencies(getIt);

      expect(getIt<AnalyticsRepository>(), isA<NoOpAnalyticsRepositoryImpl>());
    });

    test('creates a fresh BLoC instance for every resolution', () async {
      configureDependencies(getIt);

      final first = getIt<GenresBloc>();
      final second = getIt<GenresBloc>();

      expect(identical(first, second), isFalse);

      await first.close();
      await second.close();
    });

    test('keeps GetIt access out of main.dart', () {
      final mainSource = File('lib/main.dart').readAsStringSync();

      expect(mainSource, isNot(contains('GetIt.')));
      expect(mainSource, isNot(contains('GetIt.instance')));
    });
  });
}
