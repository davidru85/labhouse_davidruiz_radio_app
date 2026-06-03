import 'package:radio_app/core/utils/country_name_resolver.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/l10n/country_name_lookup.dart';

/// Builds the "primary tag • country" subtitle shared by the station rows and
/// favorite cards.
///
/// The country is resolved to its localized name from the station's ISO code
/// via [resolveCountryName] (per ADR-0032); the primary tag is the first entry
/// of [RadioStation.tagList] when present. Falls back to the country alone
/// when the station has no tags.
String stationSubtitle(RadioStation station, AppLocalizations l10n) {
  final country = resolveCountryName(
    station.countryCode,
    countryNameLookup(l10n),
  );
  final primaryTag = station.tagList.isNotEmpty ? station.tagList.first : null;
  return primaryTag == null ? country : '$primaryTag • $country';
}
