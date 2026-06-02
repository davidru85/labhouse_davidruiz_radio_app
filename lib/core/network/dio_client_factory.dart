import 'package:dio/dio.dart';
import 'package:radio_app/core/constants/mirrors.dart';
import 'package:radio_app/core/network/dio_client.dart';
import 'package:radio_app/core/network/mirror_failover_interceptor.dart';
import 'package:radio_app/data/datasources/local/mirror_cache_data_source.dart';

/// Builds the mirror-aware [Dio] client (per ADR-0016, ADR-0039).
abstract final class DioClientFactory {
  /// Creates a [Dio] whose initial `baseUrl` is the cached mirror (when it is
  /// in [mirrors]) or the first whitelist mirror, with a
  /// [MirrorFailoverInterceptor] attached.
  static Future<Dio> create(
    MirrorCacheDataSource cache, {
    List<String> mirrors = defaultApiMirrors,
  }) async {
    final cachedHost = await cache.getLastKnownMirror();
    final ordered = _orderMirrors(cachedHost, mirrors);
    final dio = DioClient.create()..options.baseUrl = ordered.first;
    dio.interceptors.add(
      MirrorFailoverInterceptor(
        dio: dio,
        cache: cache,
        mirrors: ordered,
        cachedHost: cachedHost,
      ),
    );
    return dio;
  }

  static List<String> _orderMirrors(String? cachedHost, List<String> mirrors) {
    if (cachedHost == null) {
      return mirrors;
    }
    final index = mirrors.indexWhere(
      (String mirror) => Uri.parse(mirror).host == cachedHost,
    );
    if (index <= 0) {
      return mirrors;
    }
    return <String>[
      mirrors[index],
      ...mirrors.sublist(0, index),
      ...mirrors.sublist(index + 1),
    ];
  }
}
