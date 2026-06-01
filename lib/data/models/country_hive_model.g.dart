// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CountryHiveModelAdapter extends TypeAdapter<CountryHiveModel> {
  @override
  final typeId = 2;

  @override
  CountryHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CountryHiveModel(
      name: fields[0] as String,
      countryCode: fields[1] as String,
      stationCount: (fields[2] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, CountryHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.countryCode)
      ..writeByte(2)
      ..write(obj.stationCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
