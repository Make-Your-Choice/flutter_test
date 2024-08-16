import 'package:json_annotation/json_annotation.dart';

part 'user_create.g.dart';

@JsonSerializable()
class UserCreate {

  final String name;
  final String email;

  UserCreate (this.name, this.email);

  factory UserCreate.fromJson(Map<String, dynamic> json) => _$UserCreateFromJson(json);

  Map<String, dynamic> toJson() => _$UserCreateToJson(this);

}