import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';

/// Domain contract for resolving playable stream URLs.
// ignore: one_member_abstracts
abstract interface class PlaybackUrlRepository {
  /// Resolves the preferred playback URL for [station].
  Future<Result<String, Failure>> resolvePlaybackUrl(RadioStation station);
}
