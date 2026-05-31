import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/analytics/analytics_event.dart';
import 'package:radio_app/domain/entities/country.dart';
import 'package:radio_app/domain/entities/genre.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/analytics_repository.dart';
import 'package:radio_app/domain/repositories/audio_player_repository.dart';
import 'package:radio_app/domain/repositories/connectivity_repository.dart';
import 'package:radio_app/domain/repositories/countries_repository.dart';
import 'package:radio_app/domain/repositories/favorites_repository.dart';
import 'package:radio_app/domain/repositories/genres_repository.dart';
import 'package:radio_app/domain/repositories/history_repository.dart';
import 'package:radio_app/domain/repositories/playback_url_repository.dart';
import 'package:radio_app/domain/repositories/player_state.dart';
import 'package:radio_app/domain/repositories/station_repository.dart';

void main() {
  group('Repository contracts', () {
    test('define every required domain repository interface', () {
      final repositories = <Object>[
        _FakeStationRepository(),
        _FakeFavoritesRepository(),
        _FakeGenresRepository(),
        _FakeCountriesRepository(),
        _FakeHistoryRepository(),
        _FakePlaybackUrlRepository(resolvedUrl: _station().resolvedStreamUrl),
        _FakeAudioPlayerRepository(),
        _FakeConnectivityRepository(),
        _FakeAnalyticsRepository(),
      ];

      expect(repositories[0], isA<StationRepository>());
      expect(repositories[1], isA<FavoritesRepository>());
      expect(repositories[2], isA<GenresRepository>());
      expect(repositories[3], isA<CountriesRepository>());
      expect(repositories[4], isA<HistoryRepository>());
      expect(repositories[5], isA<PlaybackUrlRepository>());
      expect(repositories[6], isA<AudioPlayerRepository>());
      expect(repositories[7], isA<ConnectivityRepository>());
      expect(repositories[8], isA<AnalyticsRepository>());
    });

    test('return domain entities through Result-based contracts', () async {
      final station = _station();
      final stationRepository = _FakeStationRepository(stations: [station]);
      final favoritesRepository = _FakeFavoritesRepository(
        favorites: [station],
      );
      final genresRepository = _FakeGenresRepository(
        genres: const [Genre(name: 'jazz', stationCount: 12)],
      );
      final countriesRepository = _FakeCountriesRepository(
        countries: const [
          Country(name: 'Germany', countryCode: 'DE', stationCount: 25),
        ],
      );
      final historyRepository = _FakeHistoryRepository(history: [station]);
      final playbackUrlRepository = _FakePlaybackUrlRepository(
        resolvedUrl: station.resolvedStreamUrl,
      );

      final searchResult = await stationRepository.searchStations(
        query: 'jazz',
        countryCode: 'DE',
        tag: 'jazz',
      );
      final popularResult = await stationRepository.loadPopularStations();
      final stationByUuidResult = await stationRepository.getStationByUuid(
        station.stationUuid,
      );
      final cancelResult = await stationRepository.cancelPendingRequests();
      final favoriteResult = await favoritesRepository.getFavorites();
      final genreResult = await genresRepository.getGenres();
      final countryResult = await countriesRepository.getCountries();
      final historyResult = await historyRepository.getHistory();
      final playbackUrlResult = await playbackUrlRepository.resolvePlaybackUrl(
        station,
      );

      expect(searchResult, isA<Result<List<RadioStation>, Failure>>());
      expect(popularResult, isA<Result<List<RadioStation>, Failure>>());
      expect(stationByUuidResult, isA<Result<RadioStation?, Failure>>());
      expect(cancelResult, isA<Result<void, Failure>>());
      expect(favoriteResult, isA<Result<List<RadioStation>, Failure>>());
      expect(genreResult, isA<Result<List<Genre>, Failure>>());
      expect(countryResult, isA<Result<List<Country>, Failure>>());
      expect(historyResult, isA<Result<List<RadioStation>, Failure>>());
      expect(playbackUrlResult, isA<Result<String, Failure>>());
      expect(
        favoritesRepository.favoritesStream,
        isA<Stream<List<RadioStation>>>(),
      );
      expect(
        historyRepository.historyStream,
        isA<Stream<List<RadioStation>>>(),
      );
    });

    test('expose playback, connectivity, and analytics boundaries', () async {
      final station = _station();
      final audioPlayerRepository = _FakeAudioPlayerRepository(
        nowPlaying: const NowPlayingInfo(raw: 'Artist - Track'),
      );
      final connectivityRepository = _FakeConnectivityRepository(
        isOnlineValue: true,
      );
      final analyticsRepository = _FakeAnalyticsRepository();

      final playResult = await audioPlayerRepository.play(
        station.resolvedStreamUrl,
        title: station.name,
        subtitle: station.country,
      );
      final pauseResult = await audioPlayerRepository.pause();
      final stopResult = await audioPlayerRepository.stop();
      final connectivityResult = await connectivityRepository
          .checkConnectivity();
      await analyticsRepository.track(const AppOpenedEvent());

      expect(playResult, isA<Result<void, Failure>>());
      expect(pauseResult, isA<Result<void, Failure>>());
      expect(stopResult, isA<Result<void, Failure>>());
      expect(
        audioPlayerRepository.playerStateStream,
        isA<Stream<PlayerState>>(),
      );
      expect(
        audioPlayerRepository.nowPlayingStream,
        isA<Stream<NowPlayingInfo?>>(),
      );
      expect(connectivityRepository.connectivityStream, isA<Stream<bool>>());
      expect(connectivityResult, isA<Result<bool, Failure>>());
      expect(analyticsRepository.trackedEvents, [const AppOpenedEvent()]);
    });
  });
}

final class _FakeStationRepository implements StationRepository {
  _FakeStationRepository({this.stations = const []});

  final List<RadioStation> stations;

  @override
  Future<Result<List<RadioStation>, Failure>> searchStations({
    String? query,
    String? countryCode,
    String? tag,
    int limit = 30,
    int offset = 0,
  }) async {
    return Success<List<RadioStation>, Failure>(stations);
  }

  @override
  Future<Result<List<RadioStation>, Failure>> loadPopularStations({
    int limit = 30,
    int offset = 0,
  }) async {
    return Success<List<RadioStation>, Failure>(stations);
  }

  @override
  Future<Result<RadioStation?, Failure>> getStationByUuid(
    String stationUuid,
  ) async {
    final matches = stations.where(
      (station) => station.stationUuid == stationUuid,
    );
    return Success<RadioStation?, Failure>(
      matches.isEmpty ? null : matches.first,
    );
  }

  @override
  Future<Result<void, Failure>> cancelPendingRequests() async {
    return const Success<void, Failure>(null);
  }
}

final class _FakeFavoritesRepository implements FavoritesRepository {
  _FakeFavoritesRepository({this.favorites = const []})
    : favoritesStream = Stream<List<RadioStation>>.value(favorites);

  final List<RadioStation> favorites;

  @override
  final Stream<List<RadioStation>> favoritesStream;

  @override
  Future<Result<void, Failure>> addFavorite(RadioStation station) async {
    return const Success<void, Failure>(null);
  }

  @override
  Future<Result<List<RadioStation>, Failure>> getFavorites() async {
    return Success<List<RadioStation>, Failure>(favorites);
  }

  @override
  Future<Result<void, Failure>> removeFavorite(String stationUuid) async {
    return const Success<void, Failure>(null);
  }

  @override
  Future<Result<void, Failure>> synchronizeFavorites() async {
    return const Success<void, Failure>(null);
  }
}

final class _FakeGenresRepository implements GenresRepository {
  _FakeGenresRepository({this.genres = const []});

  final List<Genre> genres;

  @override
  Future<Result<List<Genre>, Failure>> getGenres({int limit = 50}) async {
    return Success<List<Genre>, Failure>(genres);
  }
}

final class _FakeCountriesRepository implements CountriesRepository {
  _FakeCountriesRepository({this.countries = const []});

  final List<Country> countries;

  @override
  Future<Result<List<Country>, Failure>> getCountries() async {
    return Success<List<Country>, Failure>(countries);
  }
}

final class _FakeHistoryRepository implements HistoryRepository {
  _FakeHistoryRepository({this.history = const []})
    : historyStream = Stream<List<RadioStation>>.value(history);

  final List<RadioStation> history;

  @override
  final Stream<List<RadioStation>> historyStream;

  @override
  Future<Result<void, Failure>> addToHistory(RadioStation station) async {
    return const Success<void, Failure>(null);
  }

  @override
  Future<Result<void, Failure>> clearHistory() async {
    return const Success<void, Failure>(null);
  }

  @override
  Future<Result<List<RadioStation>, Failure>> getHistory() async {
    return Success<List<RadioStation>, Failure>(history);
  }
}

final class _FakePlaybackUrlRepository implements PlaybackUrlRepository {
  _FakePlaybackUrlRepository({required this.resolvedUrl});

  final String resolvedUrl;

  @override
  Future<Result<String, Failure>> resolvePlaybackUrl(
    RadioStation station,
  ) async {
    return Success<String, Failure>(resolvedUrl);
  }
}

final class _FakeAudioPlayerRepository implements AudioPlayerRepository {
  _FakeAudioPlayerRepository({NowPlayingInfo? nowPlaying})
    : playerStateStream = const Stream<PlayerState>.empty(),
      nowPlayingStream = Stream<NowPlayingInfo?>.value(nowPlaying);

  @override
  final Stream<PlayerState> playerStateStream;

  @override
  final Stream<NowPlayingInfo?> nowPlayingStream;

  @override
  Future<Result<void, Failure>> pause() async {
    return const Success<void, Failure>(null);
  }

  @override
  Future<Result<void, Failure>> play(
    String url, {
    required String title,
    required String subtitle,
  }) async {
    return const Success<void, Failure>(null);
  }

  @override
  Future<Result<void, Failure>> stop() async {
    return const Success<void, Failure>(null);
  }
}

final class _FakeConnectivityRepository implements ConnectivityRepository {
  _FakeConnectivityRepository({this.isOnlineValue = false})
    : connectivityStream = Stream<bool>.value(isOnlineValue);

  final bool isOnlineValue;

  @override
  final Stream<bool> connectivityStream;

  @override
  Future<Result<bool, Failure>> checkConnectivity() async {
    return Success<bool, Failure>(isOnlineValue);
  }
}

final class _FakeAnalyticsRepository implements AnalyticsRepository {
  final trackedEvents = <AnalyticsEvent>[];

  @override
  Future<void> track(AnalyticsEvent event) async {
    trackedEvents.add(event);
  }
}

RadioStation _station() {
  return const RadioStation(
    stationUuid: 'station-uuid',
    name: 'Radio Example',
    streamUrl: 'http://stream.example.test/live',
    resolvedStreamUrl: 'https://cdn.example.test/live.mp3',
    favicon: 'https://example.test/favicon.png',
    homepage: 'https://example.test',
    tags: 'jazz,news',
    tagList: ['jazz', 'news'],
    country: 'Germany',
    countryCode: 'DE',
    language: 'german',
    codec: 'MP3',
    bitrate: 128,
    votes: 42,
    clickCount: 1000,
    lastCheckOk: true,
    isHLS: false,
  );
}
