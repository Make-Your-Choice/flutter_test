// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_put.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskPutData _$TaskPutDataFromJson(Map<String, dynamic> json) => TaskPutData(
      sid: json['sid'] as String,
      title: json['title'] as String,
      text: json['text'] as String,
      isDone: json['isDone'] as bool,
      tagSid: json['tagSid'] as String,
      priority: $enumDecode(_$PriorityEnumMap, json['priority']),
      syncStatus: $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']),
      finishAt: json['finishAt'] == null
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
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus],
    };

const _$PriorityEnumMap = {
  Priority.HIGH: 0,
  Priority.MID: 1,
  Priority.LOW: 2,
};

const _$SyncStatusEnumMap = {
  SyncStatus.BOTH: 'BOTH',
  SyncStatus.LOCAL_ONLY: 'LOCAL_ONLY',
  SyncStatus.SERVER_ONLY: 'SERVER_ONLY',
};
