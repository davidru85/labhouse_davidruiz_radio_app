import 'package:dio/dio.dart';
import 'package:radio_app/core/network/network_error_mapper.dart';
import 'package:radio_app/core/network/network_exception.dart';

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

  final Dio _dio;

  @override
  Future<String?> resolvePlaybackUrl(String stationUuid) async {
    try {
      final response = await _dio.get<dynamic>('/json/url/$stationUuid');
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return null;
      }
      // Radio Browser reports `ok` as the string "false"; tolerate the
      // boolean form too in case of API drift (per review N1).
      if (data['ok'] == false || data['ok'] == 'false') {
        return null;
      }
      final url = data['url'];
      if (url is! String || url.isEmpty) {
        return null;
      }
      return url;
    } on DioException catch (exception) {
      throw NetworkException(mapDioException(exception));
    }
  }
}
