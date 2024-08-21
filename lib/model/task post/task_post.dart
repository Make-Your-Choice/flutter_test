import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:project1/model/tag/tag.dart';

import '../priority/priority.dart';
import '../task/task.dart';

part 'task_post.g.dart';

@JsonSerializable()
class TaskPostData {
  String title;
  String text;
  DateTime? finishAt;
  String tagSid;
  Priority priority;

  TaskPostData(
      {required this.title,
      required this.text,
      required this.tagSid,
      required this.priority,
      this.finishAt});

  factory TaskPostData.fromJson(Map<String, dynamic> json) =>
      _$TaskPostDataFromJson(json);

  Map<String, dynamic> toJson() => _$TaskPostDataToJson(this);
}
