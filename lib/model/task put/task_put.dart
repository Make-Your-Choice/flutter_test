import 'package:json_annotation/json_annotation.dart';
import 'package:project1/model/sync%20status/sync_status.dart';

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
  SyncStatus? syncStatus;

  TaskPutData({
    required this.sid,
    required this.title,
    required this.text,
    required this.isDone,
    required this.tagSid,
    required this.priority,
    this.syncStatus,
    this.finishAt});

  factory TaskPutData.fromJson(Map<String, dynamic> json) => _$TaskPutDataFromJson(json);

  Map<String, dynamic> toJson() => _$TaskPutDataToJson(this);
}
