// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskDataAdapter extends TypeAdapter<TaskData> {
  @override
  final int typeId = 0;

  @override
  TaskData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskData(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[4] as bool,
      fields[5] as Tag,
      fields[6] as DateTime,
      fields[7] as Priority,
      fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskData obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.sid)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.finishAt)
      ..writeByte(4)
      ..write(obj.isDone)
      ..writeByte(5)
      ..write(obj.tag)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.priority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PriorityAdapter extends TypeAdapter<Priority> {
  @override
  final int typeId = 4;

  @override
  Priority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Priority.HIGH;
      case 1:
        return Priority.MID;
      case 2:
        return Priority.LOW;
      default:
        return Priority.HIGH;
    }
  }

  @override
  void write(BinaryWriter writer, Priority obj) {
    switch (obj) {
      case Priority.HIGH:
        writer.writeByte(0);
        break;
      case Priority.MID:
        writer.writeByte(1);
        break;
      case Priority.LOW:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskData _$TaskDataFromJson(Map<String, dynamic> json) => TaskData(
      json['sid'] as String,
      json['title'] as String,
      json['text'] as String,
      json['isDone'] as bool,
      Tag.fromJson(json['tag'] as Map<String, dynamic>),
      DateTime.parse(json['createdAt'] as String),
      $enumDecodeNullable(_$PriorityEnumMap, json['priority']) ?? Priority.LOW,
      json['finishAt'] == null
          ? null
          : DateTime.parse(json['finishAt'] as String),
    );

Map<String, dynamic> _$TaskDataToJson(TaskData instance) => <String, dynamic>{
      'sid': instance.sid,
      'title': instance.title,
      'text': instance.text,
      'finishAt': instance.finishAt?.toIso8601String(),
      'isDone': instance.isDone,
      'tag': instance.tag,
      'createdAt': instance.createdAt.toIso8601String(),
      'priority': _$PriorityEnumMap[instance.priority]!,
    };

const _$PriorityEnumMap = {
  Priority.HIGH: 0,
  Priority.MID: 1,
  Priority.LOW: 2,
};
