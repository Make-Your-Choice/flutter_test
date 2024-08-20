import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class TagData {
  @HiveField(0)
  String sid;

  @HiveField(1)
  String name;

  TagData(this.sid, this.name);

  factory TagData.fromJson(Map<String, dynamic> json) => _$TagDataFromJson(json);

  Map<String, dynamic> toJson() => _$TagDataToJson(this);
}
