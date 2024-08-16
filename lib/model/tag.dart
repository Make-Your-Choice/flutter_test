import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class Tag {
  @HiveField(0)
  String sid;

  @HiveField(1)
  String name;

  Tag(this.sid, this.name);

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);
}
