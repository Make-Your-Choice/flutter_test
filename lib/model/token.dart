class Token {
  int id;
  String accessToken;
  String refreshToken;
  Token(this.id, this.accessToken, this.refreshToken);
  factory Token.fromJson (Map<String, dynamic> json) {
    return switch(json) {
      {
      'id': int id,
      'accessToken': String accessToken,
      'refreshToken': String refreshToken,
      } => Token (id, accessToken, refreshToken),
      _ => throw const FormatException('Не удалось получить токен!')
    };
  }
}