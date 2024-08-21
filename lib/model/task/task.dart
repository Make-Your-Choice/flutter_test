import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:project1/model/tag/tag.dart';

import '../priority/priority.dart';
import '../sync status/sync_status.dart';

part 'task.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class TaskData {
  @HiveField(0)
  String? sid;

  @HiveField(1)
  String title;

  @HiveField(2)
  String text;

  @HiveField(3)
  DateTime? finishAt;

  @HiveField(4)
  bool isDone;

  @HiveField(5)
  TagData tag;

  @HiveField(6)
  DateTime? createdAt;

  @HiveField(7)
  Priority priority;

  @JsonKey(ignore: true)
  SyncStatus? syncStatus;

  // TaskData(this.sid, this.title, this.text, this.isDone, this.tag,
  //     [this.createdAt, this.priority = Priority.LOW, this.finishAt, this.isSynchronized = true]);
  TaskData({this.sid, required this.title, required this.text, required this.isDone, required this.tag,
      this.createdAt, this.priority = Priority.LOW, this.finishAt, this.syncStatus = SyncStatus.BOTH});

  factory TaskData.fromJson(Map<String, dynamic> json) => _$TaskDataFromJson(json);

  Map<String, dynamic> toJson() => _$TaskDataToJson(this);
}


