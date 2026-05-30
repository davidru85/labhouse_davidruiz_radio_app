import 'package:equatable/equatable.dart';

/// Immutable domain representation of a Radio Browser station.
final class RadioStation extends Equatable {
  /// Creates a radio station domain entity.
  const RadioStation({
    required this.stationUuid,
    required this.name,
    required this.streamUrl,
    required this.resolvedStreamUrl,
    required this.favicon,
    required this.homepage,
    required this.tags,
    required this.tagList,
    required this.country,
    required this.countryCode,
    required this.language,
    required this.codec,
    required this.bitrate,
    required this.votes,
    required this.clickCount,
    required this.lastCheckOk,
    required this.isHLS,
  });

  /// Stable Radio Browser station UUID from `stationuuid`.
  final String stationUuid;

  /// Human-readable station name.
  final String name;

  /// Raw stream URL from `url`.
  final String streamUrl;

  /// Preferred resolved playback URL from `url_resolved`.
  final String resolvedStreamUrl;

  /// Optional station logo URL.
  final String? favicon;

  /// Optional station homepage URL.
  final String? homepage;

  /// Comma-separated tag string from the API.
  final String tags;

  /// Normalized station tags parsed from [tags].
  final List<String> tagList;

  /// Human-readable country name supplied by Radio Browser.
  final String country;

  /// ISO 3166-1 alpha-2 country code.
  final String countryCode;

  /// Optional station language.
  final String? language;

  /// Optional audio codec.
  final String? codec;

  /// Optional stream bitrate in kbps.
  final int? bitrate;

  /// Radio Browser vote count.
  final int votes;

  /// Radio Browser click count.
  final int clickCount;

  /// Whether the latest Radio Browser station check succeeded.
  final bool lastCheckOk;

  /// Whether the station stream is HLS.
  final bool isHLS;

  @override
  List<Object?> get props => [
    stationUuid,
    name,
    streamUrl,
    resolvedStreamUrl,
    favicon,
    homepage,
    tags,
    tagList,
    country,
    countryCode,
    language,
    codec,
    bitrate,
    votes,
    clickCount,
    lastCheckOk,
    isHLS,
  ];
}
