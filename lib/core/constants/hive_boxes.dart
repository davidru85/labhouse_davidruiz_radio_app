/// Names of the Hive boxes opened at startup in `main.dart`.
///
/// The `app_settings` box backs the mirror cache (per ADR-0016); the
/// `favorites`, `history`, `genres`, and `countries` entity boxes follow the
/// Hive persistence model design (per ADR-0037). Box opening is centralized in
/// `main.dart`; data sources receive the already-open boxes (per ADR-0037).
abstract final class HiveBoxes {
  /// Favorite stations box.
  static const String favorites = 'favorites';

  /// Recently played history box.
  static const String history = 'history';

  /// Cached filter genres box.
  static const String genres = 'genres';

  /// Cached filter countries box.
  static const String countries = 'countries';

  /// Infrastructure settings box (e.g. last-known-working mirror).
  static const String appSettings = 'app_settings';
}
