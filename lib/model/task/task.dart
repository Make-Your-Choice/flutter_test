import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:project1/model/tag/tag.dart';

part 'task.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class TaskData {
  @HiveField(0)
  String sid;

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
  DateTime createdAt;

  @HiveField(7)
  Priority priority;

  @JsonKey(ignore: true)
  bool? isSynchronized;

  TaskData(this.sid, this.title, this.text, this.isDone, this.tag,
      this.createdAt,
      [this.priority = Priority.LOW, this.finishAt, this.isSynchronized = true]);

  factory TaskData.fromJson(Map<String, dynamic> json) => _$TaskDataFromJson(json);

  Map<String, dynamic> toJson() => _$TaskDataToJson(this);
}

@JsonEnum()
@HiveType(typeId: 4)
enum Priority { 
  @JsonValue(0)
  @HiveField(0)
  HIGH,
  @JsonValue(1)
  @HiveField(1)
  MID, 
  @JsonValue(2)
  @HiveField(2)
  LOW }
