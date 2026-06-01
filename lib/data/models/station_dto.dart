import 'package:radio_app/core/utils/tag_parser.dart';
import 'package:radio_app/domain/entities/radio_station.dart';

/// Data-layer model for a Radio Browser station JSON payload.
class StationDto {
  /// Creates a station DTO.
  StationDto({
    required this.stationUuid,
    required this.name,
    required this.url,
    required this.urlResolved,
    required this.favicon,
    required this.homepage,
    required this.tags,
    required this.country,
    required this.countryCode,
    required this.language,
    required this.codec,
    required this.bitrate,
    required this.votes,
    required this.clickCount,
    required this.lastCheckOk,
    required this.hls,
  });

  /// Parses a Radio Browser station JSON object.
  factory StationDto.fromJson(Map<String, dynamic> json) {
    return StationDto(
      stationUuid: json['stationuuid'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      urlResolved: json['url_resolved'] as String,
      favicon: json['favicon'] as String?,
      homepage: json['homepage'] as String?,
      tags: json['tags'] as String? ?? '',
      country: json['country'] as String,
      countryCode: json['countrycode'] as String,
      language: json['language'] as String?,
      codec: json['codec'] as String?,
      bitrate: json['bitrate'] as int?,
      votes: json['votes'] as int? ?? 0,
      clickCount: json['clickcount'] as int? ?? 0,
      lastCheckOk: json['lastcheckok'] as int? ?? 0,
      hls: json['hls'] as int? ?? 0,
    );
  }

  /// Raw `stationuuid`.
  final String stationUuid;

  /// Raw `name`.
  final String name;

  /// Raw `url` (lowest playback priority).
  final String url;

  /// Raw `url_resolved` (preferred for playback).
  final String urlResolved;

  /// Raw `favicon`.
  final String? favicon;

  /// Raw `homepage`.
  final String? homepage;

  /// Raw comma-separated `tags`.
  final String tags;

  /// Raw `country` name.
  final String country;

  /// Raw `countrycode`.
  final String countryCode;

  /// Raw `language`.
  final String? language;

  /// Raw `codec`.
  final String? codec;

  /// Raw `bitrate` in kbps.
  final int? bitrate;

  /// Raw `votes`.
  final int votes;

  /// Raw `clickcount`.
  final int clickCount;

  /// Raw `lastcheckok` flag (`1` means the last check succeeded).
  final int lastCheckOk;

  /// Raw `hls` flag (`1` means the stream is HLS).
  final int hls;

  /// Maps this DTO to a domain [RadioStation].
  RadioStation toEntity() {
    return RadioStation(
      stationUuid: stationUuid,
      name: name,
      streamUrl: url,
      resolvedStreamUrl: urlResolved,
      favicon: favicon,
      homepage: homepage,
      tags: tags,
      tagList: parseTags(tags),
      country: country,
      countryCode: countryCode,
      language: language,
      codec: codec,
      bitrate: bitrate,
      votes: votes,
      clickCount: clickCount,
      lastCheckOk: lastCheckOk == 1,
      isHLS: hls == 1,
    );
  }
}
