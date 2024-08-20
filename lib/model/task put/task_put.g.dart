// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_put.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskPutData _$TaskPutDataFromJson(Map<String, dynamic> json) => TaskPutData(
      json['sid'] as String,
      json['title'] as String,
      json['text'] as String,
      json['isDone'] as bool,
      json['tagSid'] as String,
      $enumDecodeNullable(_$PriorityEnumMap, json['priority']) ?? Priority.LOW,
      json['finishAt'] == null
          ? null
          : DateTime.parse(json['finishAt'] as String),
    );

Map<String, dynamic> _$TaskPutDataToJson(TaskPutData instance) =>
    <String, dynamic>{
      'sid': instance.sid,
      'title': instance.title,
      'text': instance.text,
      'finishAt': instance.finishAt?.toIso8601String(),
      'isDone': instance.isDone,
      'tagSid': instance.tagSid,
      'priority': _$PriorityEnumMap[instance.priority]!,
    };

const _$PriorityEnumMap = {
  Priority.HIGH: 0,
  Priority.MID: 1,
  Priority.LOW: 2,
};
