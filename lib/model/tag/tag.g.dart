// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TagDataAdapter extends TypeAdapter<TagData> {
  @override
  final int typeId = 1;

  @override
  TagData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TagData(
      fields[0] as String,
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TagData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.sid)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagData _$TagDataFromJson(Map<String, dynamic> json) => TagData(
      json['sid'] as String,
      json['name'] as String,
    );

Map<String, dynamic> _$TagDataToJson(TagData instance) => <String, dynamic>{
      'sid': instance.sid,
      'name': instance.name,
    };
