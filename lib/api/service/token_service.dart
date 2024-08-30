import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

import '../../model/task/task.dart';
import '../../model/token/token.dart';
import '../../model/user login/user_login.dart';

class TokenService {
  final Dio _dio;
  TokenService(this._dio);

  Future<Token> logIn(UserLogin userLogin) async {
    FlutterSecureStorage storage = const FlutterSecureStorage();

    // UserLogin userLogin = UserLogin(email, password);
    Response<dynamic> response;
    Dio dioLogin = Dio(BaseOptions(
        baseUrl: 'https://test-mobile.estesis.tech/api/v1',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
          HttpHeaders.acceptHeader: 'application/json'
        }));

    try {
      response = await dioLogin.post('/login', data: userLogin.toJson());
      if (response.statusCode == 200) {
        Token token = Token.fromJson(response.data);
        await storage.deleteAll();
        await storage.write(key: 'access_token', value: token.accessToken);
        await storage.write(key: 'refresh_token', value: token.refreshToken);
        Hive.box<TaskData>('taskBox').clear();
        return Token.fromJson(response.data);
      } else {
        throw DioException(
            requestOptions: RequestOptions(),
            response: Response(
                requestOptions: RequestOptions(),
                statusCode: 405,
                statusMessage: 'Login error!'));
      }
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<bool> logOut() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    Response<dynamic> response;
    try {
      response = await _dio.post(
          '/logout'
      );
      if (response.statusCode == 200) {
        await storage.deleteAll();
        return true;
      }
      return false;
    } on DioException catch(e) {
      rethrow;
    }
  }

  Future<bool> checkToken() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    Response<dynamic> response;
    try {
      if (await storage.containsKey(key: 'access_token')) {
        response = await _dio.get('/users/me');
        if (response.statusCode == 200) {
          return true;
        } else {
          throw DioException(
              requestOptions: RequestOptions(),
              response: Response(
                  requestOptions: RequestOptions(),
                  statusCode: 500,
                  statusMessage: 'Could not check token!'));
        }
      }
      return false;
    } on DioException catch (e) {
      rethrow;
    }
  }
}