// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genre_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GenreHiveModelAdapter extends TypeAdapter<GenreHiveModel> {
  @override
  final typeId = 1;

  @override
  GenreHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GenreHiveModel(
      name: fields[0] as String,
      stationCount: (fields[1] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, GenreHiveModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.stationCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenreHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
