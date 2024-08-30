import 'dart:io';

import 'package:dio/dio.dart';

import '../../model/user create/user_create.dart';
import '../../model/user/user.dart';

class UserService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://test-mobile.estesis.tech/api/v1',
    headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.acceptHeader: 'application/json'
    }));

  Future<UserCreate> postUser(User user) async {
    Response<dynamic> response;
    try {
      response = await _dio.post('/register', data: user);
      if (response.statusCode == 200) {
        return UserCreate.fromJson(response.data);
      } else {
        throw Exception('Registration error!');
      }
    } catch (e) {
      rethrow;
    }
  }
}