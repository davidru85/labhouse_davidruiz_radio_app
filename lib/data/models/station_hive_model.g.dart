// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StationHiveModelAdapter extends TypeAdapter<StationHiveModel> {
  @override
  final typeId = 0;

  @override
  StationHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StationHiveModel(
      stationUuid: fields[0] as String,
      name: fields[1] as String,
      streamUrl: fields[2] as String,
      resolvedStreamUrl: fields[3] as String,
      favicon: fields[4] as String?,
      homepage: fields[5] as String?,
      tags: fields[6] as String,
      tagList: (fields[7] as List).cast<String>(),
      country: fields[8] as String,
      countryCode: fields[9] as String,
      language: fields[10] as String?,
      codec: fields[11] as String?,
      bitrate: (fields[12] as num?)?.toInt(),
      votes: (fields[13] as num).toInt(),
      clickCount: (fields[14] as num).toInt(),
      lastCheckOk: fields[15] as bool,
      isHLS: fields[16] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StationHiveModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.stationUuid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.streamUrl)
      ..writeByte(3)
      ..write(obj.resolvedStreamUrl)
      ..writeByte(4)
      ..write(obj.favicon)
      ..writeByte(5)
      ..write(obj.homepage)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.tagList)
      ..writeByte(8)
      ..write(obj.country)
      ..writeByte(9)
      ..write(obj.countryCode)
      ..writeByte(10)
      ..write(obj.language)
      ..writeByte(11)
      ..write(obj.codec)
      ..writeByte(12)
      ..write(obj.bitrate)
      ..writeByte(13)
      ..write(obj.votes)
      ..writeByte(14)
      ..write(obj.clickCount)
      ..writeByte(15)
      ..write(obj.lastCheckOk)
      ..writeByte(16)
      ..write(obj.isHLS);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StationHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
