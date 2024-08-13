import 'package:hive_flutter/hive_flutter.dart';
import 'package:project1/model/tag.dart';

@HiveType(typeId: 0)
class Task {

  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime? finishAt;

  @HiveField(4)
  bool isDone;

  @HiveField(5)
  Tag tag;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  Priority priority;

  Task(
      this.id,
      this.name,
      this.description,
      this.isDone,
      this.tag,
      this.createdAt,
      this.priority,
      [this.finishAt]);
}

enum Priority {HIGH, MID, LOW}