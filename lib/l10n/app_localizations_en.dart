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
  String get country_DE => 'Germany';

  @override
  String get country_AT => 'Austria';

  @override
  String get country_NL => 'Netherlands';

  @override
  String get country_FR => 'France';
}
