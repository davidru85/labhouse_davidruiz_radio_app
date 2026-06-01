import 'package:hive_ce/hive.dart';

/// Persistence boundary for the last-known-working Radio Browser mirror
/// (per ADR-0016).
///
/// The cached mirror is an infrastructure detail of the networking layer,
/// not a domain entity; it is a bare hostname (no scheme, no path).
abstract interface class MirrorCacheDataSource {
  /// Returns the cached mirror host, or `null` if none is cached.
  Future<String?> getLastKnownMirror();

  /// Caches [host] as the last-known-working mirror.
  Future<void> setLastKnownMirror(String host);
}

/// Hive-backed [MirrorCacheDataSource] over the `app_settings` box.
class HiveMirrorCacheDataSource implements MirrorCacheDataSource {
  /// Creates the data source over an already-open Hive box.
  HiveMirrorCacheDataSource(this._box);

  /// Key under which the mirror host is stored (per ADR-0016).
  static const String mirrorKey = 'last_known_mirror';

  final Box<dynamic> _box;

  @override
  Future<String?> getLastKnownMirror() async => _box.get(mirrorKey) as String?;

  @override
  Future<void> setLastKnownMirror(String host) => _box.put(mirrorKey, host);
}
