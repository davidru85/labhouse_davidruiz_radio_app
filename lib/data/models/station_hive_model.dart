import 'package:hive_ce/hive.dart';
import 'package:radio_app/domain/entities/radio_station.dart';

part 'station_hive_model.g.dart';

/// Hive persistence model for a [RadioStation] (per ADR-0037).
///
/// A single model (`typeId` 0) backs both the `favorites` and `history`
/// boxes. It round-trips the full domain entity; `tagList` is persisted
/// directly rather than re-derived.
@HiveType(typeId: 0)
class StationHiveModel {
  /// Creates a Hive persistence model.
  StationHiveModel({
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

  /// Projects a domain [station] into its persistence model.
  factory StationHiveModel.fromEntity(RadioStation station) {
    return StationHiveModel(
      stationUuid: station.stationUuid,
      name: station.name,
      streamUrl: station.streamUrl,
      resolvedStreamUrl: station.resolvedStreamUrl,
      favicon: station.favicon,
      homepage: station.homepage,
      tags: station.tags,
      tagList: station.tagList,
      country: station.country,
      countryCode: station.countryCode,
      language: station.language,
      codec: station.codec,
      bitrate: station.bitrate,
      votes: station.votes,
      clickCount: station.clickCount,
      lastCheckOk: station.lastCheckOk,
      isHLS: station.isHLS,
    );
  }

  /// Stable Radio Browser station UUID.
  @HiveField(0)
  final String stationUuid;

  /// Human-readable station name.
  @HiveField(1)
  final String name;

  /// Raw stream URL.
  @HiveField(2)
  final String streamUrl;

  /// Preferred resolved playback URL.
  @HiveField(3)
  final String resolvedStreamUrl;

  /// Optional station logo URL.
  @HiveField(4)
  final String? favicon;

  /// Optional station homepage URL.
  @HiveField(5)
  final String? homepage;

  /// Comma-separated tag string.
  @HiveField(6)
  final String tags;

  /// Normalized station tags.
  @HiveField(7)
  final List<String> tagList;

  /// Human-readable country name.
  @HiveField(8)
  final String country;

  /// ISO 3166-1 alpha-2 country code.
  @HiveField(9)
  final String countryCode;

  /// Optional station language.
  @HiveField(10)
  final String? language;

  /// Optional audio codec.
  @HiveField(11)
  final String? codec;

  /// Optional stream bitrate in kbps.
  @HiveField(12)
  final int? bitrate;

  /// Radio Browser vote count.
  @HiveField(13)
  final int votes;

  /// Radio Browser click count.
  @HiveField(14)
  final int clickCount;

  /// Whether the latest Radio Browser station check succeeded.
  @HiveField(15)
  final bool lastCheckOk;

  /// Whether the station stream is HLS.
  @HiveField(16)
  final bool isHLS;

  /// Rebuilds the domain entity from the persisted model.
  RadioStation toEntity() {
    return RadioStation(
      stationUuid: stationUuid,
      name: name,
      streamUrl: streamUrl,
      resolvedStreamUrl: resolvedStreamUrl,
      favicon: favicon,
      homepage: homepage,
      tags: tags,
      tagList: tagList,
      country: country,
      countryCode: countryCode,
      language: language,
      codec: codec,
      bitrate: bitrate,
      votes: votes,
      clickCount: clickCount,
      lastCheckOk: lastCheckOk,
      isHLS: isHLS,
    );
  }
}
