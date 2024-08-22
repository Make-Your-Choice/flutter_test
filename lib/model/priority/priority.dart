import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'priority.g.dart';

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
  LOW
}
