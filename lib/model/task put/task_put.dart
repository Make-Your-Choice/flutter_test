import 'package:json_annotation/json_annotation.dart';

import '../priority/priority.dart';

part 'task_put.g.dart';

@JsonSerializable()
class TaskPutData {
  String sid;
  String title;
  String text;
  DateTime? finishAt;
  bool isDone;
  String tagSid;
  Priority priority;

  TaskPutData(this.sid, this.title, this.text, this.isDone, this.tagSid,
      [this.priority = Priority.LOW, this.finishAt]);

  factory TaskPutData.fromJson(Map<String, dynamic> json) => _$TaskPutDataFromJson(json);

  Map<String, dynamic> toJson() => _$TaskPutDataToJson(this);
}
