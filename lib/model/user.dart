import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class User {

  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String password;

  User (this.id, this.name, this.email, this.password);

  factory User.fromJson (Map<String, dynamic> json) {
    return switch(json) {
      {
        'id': int id,
        'name': String name,
        'email': String email,
        'password': String password,
      } => User (id, name, email, password),
      _ => throw const FormatException('Не удалось зарегистирировать пользователя!')
    };
  }
}