import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class Token {
  @HiveField(0)
  @JsonKey(name: 'access_token')
  String accessToken;
  @HiveField(1)
  @JsonKey(name: 'refresh_token')
  String refreshToken;

  Token(this.accessToken, this.refreshToken);

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);

  Map<String, dynamic> toJson() => _$TokenToJson(this);
}
