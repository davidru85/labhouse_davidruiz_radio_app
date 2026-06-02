import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/data/datasources/remote/remote_playback_url_data_source.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/playback_url_repository.dart';

/// [PlaybackUrlRepository] resolving the preferred stream URL through the
/// fallback chain defined in `API_SPEC.md` §5.3: resolved click URL ->
/// `resolvedStreamUrl` -> `streamUrl`.
class PlaybackUrlRepositoryImpl implements PlaybackUrlRepository {
  /// Creates the repository over the remote playback URL data source.
  PlaybackUrlRepositoryImpl(this._remote);

  final RemotePlaybackUrlDataSource _remote;

  @override
  Future<Result<String, Failure>> resolvePlaybackUrl(
    RadioStation station,
  ) async {
    final clickUrl = await _resolveClickUrl(station.stationUuid);
    final url = clickUrl ?? _stationFallback(station);
    if (url == null || url.isEmpty) {
      return const FailureResult<String, Failure>(StreamUnreachableFailure());
    }
    return Success<String, Failure>(url);
  }

  /// Registers the click and returns the resolved URL, degrading to `null`
  /// when click registration fails: playback MUST NOT fail solely because
  /// click registration failed (per `API_SPEC.md` §5.3).
  Future<String?> _resolveClickUrl(String stationUuid) async {
    try {
      return await _remote.resolvePlaybackUrl(stationUuid);
    } on NetworkException {
      return null;
    }
  }

  /// Returns the station's own preferred URL: `resolvedStreamUrl` when set,
  /// otherwise `streamUrl`, otherwise `null`.
  String? _stationFallback(RadioStation station) {
    if (station.resolvedStreamUrl.isNotEmpty) {
      return station.resolvedStreamUrl;
    }
    if (station.streamUrl.isNotEmpty) {
      return station.streamUrl;
    }
    return null;
  }
}
