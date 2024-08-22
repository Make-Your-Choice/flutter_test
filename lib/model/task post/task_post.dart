import 'package:json_annotation/json_annotation.dart';

import '../priority/priority.dart';

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
