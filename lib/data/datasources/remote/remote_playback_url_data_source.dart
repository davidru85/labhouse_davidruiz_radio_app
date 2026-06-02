import 'package:dio/dio.dart';

/// Remote data source resolving playable stream URLs via the Radio Browser
/// `/json/url/{stationuuid}` endpoint (per `API_SPEC.md` §5.3, ADR-0039).
// ignore: one_member_abstracts
abstract interface class RemotePlaybackUrlDataSource {
  /// Registers a click and resolves the playback URL for [stationUuid].
  ///
  /// Returns the resolved click URL when the endpoint yields a usable one,
  /// or `null` when click registration does not produce a usable URL so the
  /// repository can fall back to the station's own URLs (per `API_SPEC.md`
  /// §5.3). Transport/HTTP errors are mapped and thrown as a
  /// `NetworkException`; the repository degrades gracefully from there so
  /// that playback never fails solely because click registration failed.
  Future<String?> resolvePlaybackUrl(String stationUuid);
}

/// Dio-based [RemotePlaybackUrlDataSource].
class DioRemotePlaybackUrlDataSource implements RemotePlaybackUrlDataSource {
  /// Creates the data source over a configured Dio client (per ADR-0039).
  DioRemotePlaybackUrlDataSource(this._dio);

  // RED scaffolding — wired up at the GREEN checkpoint.
  // ignore: unused_field
  final Dio _dio;

  @override
  Future<String?> resolvePlaybackUrl(String stationUuid) {
    // RED scaffolding — implemented at the GREEN checkpoint.
    throw UnimplementedError();
  }
}
