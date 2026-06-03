// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Labhouse David Radio';

  @override
  String get stationsEmptyResults => 'No stations found';

  @override
  String get stationsSearchHint => 'Search stations, genres, or frequencies…';

  @override
  String get genericError => 'Something went wrong';

  @override
  String get favoritesTitle => 'Your Favorites';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesEmptyMessage =>
      'Your favorite stations will appear here.';

  @override
  String get favoritesExplore => 'Explore Stations';

  @override
  String get favoritesRemoveLabel => 'Remove from favorites';

  @override
  String get navStations => 'Stations';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get stationsOfflineMessage =>
      'You\'re offline. Connect to discover stations. Your favorites and history remain available.';

  @override
  String get retryLabel => 'Retry';

  @override
  String get playerNowPlaying => 'Now Playing';

  @override
  String get playerPlayLabel => 'Play';

  @override
  String get playerPauseLabel => 'Pause';

  @override
  String get playerCollapseLabel => 'Collapse player';

  @override
  String get miniPlayerOpenLabel => 'Open player';

  @override
  String get offlineBanner => 'You\'re offline';

  @override
  String get backOnlineBanner => 'Back online';

  @override
  String get country_DE => 'Germany';

  @override
  String get country_AT => 'Austria';

  @override
  String get country_NL => 'Netherlands';

  @override
  String get country_FR => 'France';
}
