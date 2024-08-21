// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskPostData _$TaskPostDataFromJson(Map<String, dynamic> json) => TaskPostData(
      title: json['title'] as String,
      text: json['text'] as String,
      tagSid: json['tagSid'] as String,
      priority: $enumDecode(_$PriorityEnumMap, json['priority']),
      finishAt: json['finishAt'] == null
          ? null
          : DateTime.parse(json['finishAt'] as String),
    );

Map<String, dynamic> _$TaskPostDataToJson(TaskPostData instance) =>
    <String, dynamic>{
      'title': instance.title,
      'text': instance.text,
      'finishAt': instance.finishAt?.toIso8601String(),
      'tagSid': instance.tagSid,
      'priority': _$PriorityEnumMap[instance.priority]!,
    };

const _$PriorityEnumMap = {
  Priority.HIGH: 0,
  Priority.MID: 1,
  Priority.LOW: 2,
};
