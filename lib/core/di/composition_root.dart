import 'package:audio_service/audio_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:radio_app/core/constants/hive_boxes.dart';
import 'package:radio_app/core/network/dio_client_factory.dart';
import 'package:radio_app/data/datasources/audio_playback_data_source.dart';
import 'package:radio_app/data/datasources/just_audio_playback_data_source.dart';
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
import 'package:radio_app/data/repositories/audio_player_repository_impl.dart';
import 'package:radio_app/data/repositories/connectivity_repository_impl.dart';
import 'package:radio_app/data/repositories/countries_repository_impl.dart';
import 'package:radio_app/data/repositories/favorites_repository_impl.dart';
import 'package:radio_app/data/repositories/genres_repository_impl.dart';
import 'package:radio_app/data/repositories/history_repository_impl.dart';
import 'package:radio_app/data/repositories/no_op_analytics_repository_impl.dart';
import 'package:radio_app/data/repositories/playback_url_repository_impl.dart';
import 'package:radio_app/data/repositories/station_repository_impl.dart';
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
import 'package:radio_app/presentation/blocs/connectivity/connectivity_bloc.dart';
import 'package:radio_app/presentation/blocs/countries/countries_bloc.dart';
import 'package:radio_app/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:radio_app/presentation/blocs/genres/genres_bloc.dart';
import 'package:radio_app/presentation/blocs/history/history_bloc.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/blocs/stations/stations_bloc.dart';

/// Configures and registers all global dependencies inside the [getIt] locator
/// (per `ARCHITECTURE.md` §"Dependency Injection").
void configureDependencies(
  GetIt getIt, {
  Dio? dio,
  AudioPlayer? audioPlayer,
  BaseAudioHandler? audioHandler,
}) {
  // Networking
  if (!getIt.isRegistered<Dio>()) {
    getIt.registerLazySingleton<Dio>(() => dio ?? Dio());
  }

  getIt
    ..registerLazySingleton<MirrorCacheDataSource>(
      () => HiveMirrorCacheDataSource(Hive.box<dynamic>(HiveBoxes.appSettings)),
    )
    ..registerLazySingleton<LocalFavoritesDataSource>(
      () => HiveLocalFavoritesDataSource(
        Hive.box<StationHiveModel>(HiveBoxes.favorites),
      ),
    )
    ..registerLazySingleton<LocalHistoryDataSource>(
      () => HiveLocalHistoryDataSource(
        Hive.box<StationHiveModel>(HiveBoxes.history),
      ),
    )
    ..registerLazySingleton<LocalGenresDataSource>(
      () =>
          HiveLocalGenresDataSource(Hive.box<GenreHiveModel>(HiveBoxes.genres)),
    )
    ..registerLazySingleton<LocalCountriesDataSource>(
      () => HiveLocalCountriesDataSource(
        Hive.box<CountryHiveModel>(HiveBoxes.countries),
      ),
    )
    ..registerLazySingleton<RemoteStationDataSource>(
      () => DioRemoteStationDataSource(getIt<Dio>()),
    )
    ..registerLazySingleton<RemoteGenresDataSource>(
      () => DioRemoteGenresDataSource(getIt<Dio>()),
    )
    ..registerLazySingleton<RemoteCountriesDataSource>(
      () => DioRemoteCountriesDataSource(getIt<Dio>()),
    )
    ..registerLazySingleton<RemotePlaybackUrlDataSource>(
      () => DioRemotePlaybackUrlDataSource(getIt<Dio>()),
    )
    ..registerLazySingleton<ConnectivityDataSource>(
      () => ConnectivityPlusDataSource(Connectivity()),
    )
    ..registerLazySingleton<AudioPlaybackDataSource>(() {
      final player = audioPlayer ?? AudioPlayer();
      final handler = audioHandler ?? RadioAudioHandler(player);
      return JustAudioPlaybackDataSource(player, handler);
    })
    ..registerLazySingleton<StationRepository>(
      () => StationRepositoryImpl(getIt<RemoteStationDataSource>()),
    )
    ..registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(
        getIt<LocalFavoritesDataSource>(),
        getIt<RemoteStationDataSource>(),
      ),
    )
    ..registerLazySingleton<GenresRepository>(
      () => GenresRepositoryImpl(
        getIt<RemoteGenresDataSource>(),
        getIt<LocalGenresDataSource>(),
      ),
    )
    ..registerLazySingleton<CountriesRepository>(
      () => CountriesRepositoryImpl(
        getIt<RemoteCountriesDataSource>(),
        getIt<LocalCountriesDataSource>(),
      ),
    )
    ..registerLazySingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(getIt<LocalHistoryDataSource>()),
    )
    ..registerLazySingleton<PlaybackUrlRepository>(
      () => PlaybackUrlRepositoryImpl(getIt<RemotePlaybackUrlDataSource>()),
    )
    ..registerLazySingleton<AudioPlayerRepository>(
      () => AudioPlayerRepositoryImpl(
        getIt<AudioPlaybackDataSource>(),
        getIt<ConnectivityRepository>(),
      ),
    )
    ..registerLazySingleton<ConnectivityRepository>(
      () => ConnectivityRepositoryImpl(getIt<ConnectivityDataSource>()),
    )
    ..registerLazySingleton<AnalyticsRepository>(
      () => const NoOpAnalyticsRepositoryImpl(),
    )
    ..registerLazySingleton<SearchStationsUseCase>(
      () => SearchStationsUseCase(getIt<StationRepository>()),
    )
    ..registerLazySingleton<LoadPopularStationsUseCase>(
      () => LoadPopularStationsUseCase(getIt<StationRepository>()),
    )
    ..registerLazySingleton<CancelSearchUseCase>(
      () => CancelSearchUseCase(getIt<StationRepository>()),
    )
    ..registerLazySingleton<GetStationByUuidUseCase>(
      () => GetStationByUuidUseCase(getIt<StationRepository>()),
    )
    ..registerLazySingleton<GetFavoritesUseCase>(
      () => GetFavoritesUseCase(getIt<FavoritesRepository>()),
    )
    ..registerLazySingleton<ToggleFavoriteUseCase>(
      () => ToggleFavoriteUseCase(getIt<FavoritesRepository>()),
    )
    ..registerLazySingleton<RefreshFavoritesUseCase>(
      () => RefreshFavoritesUseCase(getIt<FavoritesRepository>()),
    )
    ..registerLazySingleton<GetHistoryUseCase>(
      () => GetHistoryUseCase(getIt<HistoryRepository>()),
    )
    ..registerLazySingleton<AddToHistoryUseCase>(
      () => AddToHistoryUseCase(getIt<HistoryRepository>()),
    )
    ..registerLazySingleton<ClearHistoryUseCase>(
      () => ClearHistoryUseCase(getIt<HistoryRepository>()),
    )
    ..registerLazySingleton<LoadGenresUseCase>(
      () => LoadGenresUseCase(getIt<GenresRepository>()),
    )
    ..registerLazySingleton<LoadCountriesUseCase>(
      () => LoadCountriesUseCase(getIt<CountriesRepository>()),
    )
    ..registerLazySingleton<PlayStationUseCase>(
      () => PlayStationUseCase(
        getIt<PlaybackUrlRepository>(),
        getIt<AudioPlayerRepository>(),
      ),
    )
    ..registerLazySingleton<PausePlaybackUseCase>(
      () => PausePlaybackUseCase(getIt<AudioPlayerRepository>()),
    )
    ..registerLazySingleton<StopPlaybackUseCase>(
      () => StopPlaybackUseCase(getIt<AudioPlayerRepository>()),
    )
    ..registerLazySingleton<WatchPlayerStateUseCase>(
      () => WatchPlayerStateUseCase(getIt<AudioPlayerRepository>()),
    )
    ..registerLazySingleton<WatchNowPlayingUseCase>(
      () => WatchNowPlayingUseCase(getIt<AudioPlayerRepository>()),
    )
    ..registerLazySingleton<WatchConnectivityUseCase>(
      () => WatchConnectivityUseCase(getIt<ConnectivityRepository>()),
    )
    ..registerLazySingleton<TrackAnalyticsEventUseCase>(
      () => TrackAnalyticsEventUseCase(getIt<AnalyticsRepository>()),
    )
    ..registerFactory<RadioPlayerBloc>(
      () => RadioPlayerBloc(
        getIt<PlayStationUseCase>(),
        getIt<PausePlaybackUseCase>(),
        getIt<StopPlaybackUseCase>(),
        getIt<WatchPlayerStateUseCase>(),
        getIt<WatchNowPlayingUseCase>(),
        getIt<TrackAnalyticsEventUseCase>(),
      ),
    )
    ..registerFactory<StationsBloc>(
      () => StationsBloc(
        getIt<SearchStationsUseCase>(),
        getIt<LoadPopularStationsUseCase>(),
        getIt<CancelSearchUseCase>(),
        getIt<TrackAnalyticsEventUseCase>(),
      ),
    )
    ..registerFactory<FavoritesBloc>(
      () => FavoritesBloc(
        getIt<GetFavoritesUseCase>(),
        getIt<ToggleFavoriteUseCase>(),
        getIt<RefreshFavoritesUseCase>(),
        getIt<TrackAnalyticsEventUseCase>(),
      ),
    )
    ..registerFactory<HistoryBloc>(
      () => HistoryBloc(
        getIt<GetHistoryUseCase>(),
        getIt<AddToHistoryUseCase>(),
        getIt<ClearHistoryUseCase>(),
      ),
    )
    ..registerFactory<GenresBloc>(() => GenresBloc(getIt<LoadGenresUseCase>()))
    ..registerFactory<CountriesBloc>(
      () => CountriesBloc(getIt<LoadCountriesUseCase>()),
    )
    ..registerFactory<ConnectivityBloc>(
      () => ConnectivityBloc(getIt<WatchConnectivityUseCase>()),
    );
}

/// Global helper to initialize the locator without exposing GetIt references
/// to main.dart.
Future<void> setupLocator({
  Dio? dio,
  AudioPlayer? audioPlayer,
  BaseAudioHandler? audioHandler,
}) async {
  final cache = HiveMirrorCacheDataSource(
    Hive.box<dynamic>(HiveBoxes.appSettings),
  );
  final resolvedDio = dio ?? await DioClientFactory.create(cache);

  final player = audioPlayer ?? AudioPlayer();
  final resolvedHandler =
      audioHandler ??
      await AudioService.init(
        builder: () => RadioAudioHandler(player),
        config: const AudioServiceConfig(
          androidNotificationChannelId:
              'com.labhouse.davidruizassessment.radioapp.channel.audio',
          androidNotificationChannelName: 'Radio Playback',
          androidNotificationOngoing: true,
        ),
      );

  configureDependencies(
    GetIt.instance,
    dio: resolvedDio,
    audioPlayer: player,
    audioHandler: resolvedHandler,
  );
}

/// Resolves the root [RadioPlayerBloc] from the locator.
///
/// `MyApp` provides this single instance above the router so both the shell
/// (mini-player) and the out-of-shell `/player` route share one player bloc,
/// without `MyApp` referencing `GetIt` directly (per ARCHITECTURE.md
/// §"Dependency Injection").
RadioPlayerBloc resolveRootPlayerBloc() => GetIt.instance<RadioPlayerBloc>();

/// Builds the shell-scoped BLoC providers shared across the shell tabs.
///
/// Wired into `createAppRouter` as its `shellScopeBuilder` so [StationsBloc]
/// and [FavoritesBloc] live in the routing shell and are disposed when the
/// shell leaves the tree (the sub-task 8.3 mechanism). Resolving from the
/// locator keeps `GetIt` confined to the composition root.
Widget buildShellScope(BuildContext context, Widget child) => MultiBlocProvider(
  providers: [
    BlocProvider<StationsBloc>(create: (_) => GetIt.instance<StationsBloc>()),
    BlocProvider<FavoritesBloc>(create: (_) => GetIt.instance<FavoritesBloc>()),
  ],
  child: child,
);
