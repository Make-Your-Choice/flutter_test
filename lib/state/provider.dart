import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:project1/api/api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/task/task.dart';
import '../model/token/token.dart';
import '../model/user login/user_login.dart';

part 'provider.g.dart';

// @riverpod
// Future<Token> getToken(GetTokenRef ref, String email, String password) async {
//   UserLogin userLogin = UserLogin(email, password);
//   Response<dynamic> response;
//   try {
//     final dio = Dio(
//         BaseOptions(baseUrl: 'https://test-mobile.estesis.tech/api/v1', headers: {
//           HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
//           HttpHeaders.acceptHeader: 'application/json'
//         }));
//     response = await dio.post('/login', data: userLogin.toJson());
//     if (response.statusCode == 200) {
//       FlutterSecureStorage storage = const FlutterSecureStorage();
//       String accessToken = Token.fromJson(response.data).accessToken;
//       storage.write(key: 'access_token', value: accessToken);
//       return Token.fromJson(response.data);
//     } else {
//       throw Exception('Login error!');
//     }
//   } catch (e) {
//     rethrow;
//   }
// }

@Riverpod()
class Task extends _$Task {
  @override
  Future<List<TaskData>> build() async {
    return fetchTasks();
  }

  Future<List<TaskData>> fetchTasks(
      {String? maxCreatedDate, String? minCreatedDate}) async {
    final List<TaskData> content = await ApiService().getTasks();
    return content;
    // List<TaskData> tasks;
    // FlutterSecureStorage storage = const FlutterSecureStorage();
    // Response<dynamic> response;
    // var token = await storage.read(key: 'access_token');
    // var dio = Dio(BaseOptions(
    //     baseUrl: 'https://test-mobile.estesis.tech/api/v1',
    //     headers: {
    //       HttpHeaders.contentTypeHeader: 'application/json',
    //       HttpHeaders.acceptHeader: 'application/json',
    //       HttpHeaders.authorizationHeader: 'Bearer $token'
    //     }));
    // try {
    //   response = await dio.get(
    //     '/tasks',
    //   );
    //   if (response.statusCode == 200) {
    //     tasks = (response.data['items'] as List)
    //         .map((i) => TaskData.fromJson(i))
    //         .toList();
    //     if (Hive.box<TaskData>('taskBox').isEmpty) {
    //       Hive.box<TaskData>('taskBox').addAll(tasks);
    //     }
    //     return tasks;
    //   } else {
    //     throw Exception('Tasks not found!');
    //   }
    // } catch (e) {
    //   rethrow;
    // }
  }
}
