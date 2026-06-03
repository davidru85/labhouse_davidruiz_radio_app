import 'package:radio_app/core/utils/country_name_resolver.dart';
import 'package:radio_app/l10n/app_localizations.dart';

/// Adapts [AppLocalizations] into the `String? Function(String key)` lookup
/// that [resolveCountryName] expects (per ADR-0032, amended 2026-06-01).
///
/// `gen-l10n` exposes one named getter per ARB key and no dynamic
/// `lookup(String)`, so the presentation layer maps each `country_XX` key to
/// its generated getter here. Unknown keys return `null`, letting the resolver
/// fall back to the uppercase ISO code.
String? Function(String key) countryNameLookup(AppLocalizations l10n) {
  return (key) => switch (key) {
    'country_DE' => l10n.country_DE,
    'country_AT' => l10n.country_AT,
    'country_NL' => l10n.country_NL,
    'country_FR' => l10n.country_FR,
    _ => null,
  };
}
