import 'package:json_annotation/json_annotation.dart';

part 'user_login.g.dart';

@JsonSerializable()
class UserLogin {
  final String username;
  final String password;

  UserLogin(this.username, this.password);

  factory UserLogin.fromJson(Map<String, dynamic> json) => _$UserLoginFromJson(json);

  Map<String, dynamic> toJson() => _$UserLoginToJson(this);
}