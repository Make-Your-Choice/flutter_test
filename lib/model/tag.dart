import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Tag {

  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  Tag (this.id, this.name);
}