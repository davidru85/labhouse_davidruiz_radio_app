/// Resolves a localized country name for [isoCode] using [lookup].
///
/// Builds the key `country_${isoCode.toUpperCase()}` and returns the value
/// [lookup] provides, falling back to the uppercase ISO code when [lookup]
/// returns null (per ADR-0032, amended 2026-06-01).
///
/// Pure and domain-free (per ADR-0034): the [lookup] callback is supplied by
/// the presentation layer, which adapts the generated `AppLocalizations`.
String resolveCountryName(String isoCode, String? Function(String key) lookup) {
  final upperCode = isoCode.toUpperCase();
  return lookup('country_$upperCode') ?? upperCode;
}
