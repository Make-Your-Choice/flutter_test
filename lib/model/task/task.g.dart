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
      sid: fields[0] as String?,
      title: fields[1] as String,
      text: fields[2] as String,
      isDone: fields[4] as bool,
      tag: fields[5] as TagData,
      createdAt: fields[6] as DateTime?,
      priority: fields[7] as Priority,
      finishAt: fields[3] as DateTime?,
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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskData _$TaskDataFromJson(Map<String, dynamic> json) => TaskData(
      sid: json['sid'] as String?,
      title: json['title'] as String,
      text: json['text'] as String,
      isDone: json['isDone'] as bool,
      tag: TagData.fromJson(json['tag'] as Map<String, dynamic>),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      priority: $enumDecodeNullable(_$PriorityEnumMap, json['priority']) ??
          Priority.LOW,
      finishAt: json['finishAt'] == null
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
      'createdAt': instance.createdAt?.toIso8601String(),
      'priority': _$PriorityEnumMap[instance.priority]!,
    };

const _$PriorityEnumMap = {
  Priority.HIGH: 0,
  Priority.MID: 1,
  Priority.LOW: 2,
};
