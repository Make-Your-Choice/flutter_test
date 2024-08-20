import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:project1/model/tag/tag.dart';

import '../model/task put/task_put.dart';
import '../model/task/task.dart';
import '../model/token/token.dart';
import '../model/user create/user_create.dart';
import '../model/user login/user_login.dart';
import '../model/user/user.dart';

class ApiService {
  static late Dio dio;

  ApiService._create();

  static Future<ApiService> create() async {
    var service = ApiService._create();
    var storage = const FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    dio = Dio(BaseOptions(
        baseUrl: 'https://test-mobile.estesis.tech/api/v1',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token'
        }));
    return service;
  }

  Future<List<TaskData>> getTasks() async {
    List<TaskData> tasks;
    Response<dynamic> response;
    try {
      response = await dio.get(
        '/tasks',
      );
      if (response.statusCode == 200) {
        tasks = (response.data['items'] as List)
            .map((i) => TaskData.fromJson(i))
            .toList();

        if (Hive.box<TaskData>('taskBox').isEmpty) {
          Hive.box<TaskData>('taskBox').addAll(tasks);
        } else {
          Hive.box<TaskData>('taskBox').values.forEach((item) => item.isSynchronized = false);
          for (var localItem in Hive.box<TaskData>('taskBox').values.toList()) {
            for (var serverItem in tasks) {
              if (localItem.sid == serverItem.sid) {
                localItem.isSynchronized = true;
              }
            }
          }
        }

        // if (Hive.box<TaskData>('taskBox').isEmpty) {
        //   Hive.box<TaskData>('taskBox').addAll(tasks);
        // }

        tasks = Hive.box<TaskData>('taskBox').values.toList();
        return tasks;

      } else if (response.statusCode == 500 ||
          response.statusCode == 503 ||
          response.statusCode == 504) {
        tasks = Hive.box<TaskData>('taskBox').values.toList();
        return tasks;
      } else {
        throw Exception('Tasks not found!');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskData> postCompleteTask(TaskPutData task) async {
    Response<dynamic> response;
    TaskData newTask;
    try {
      response = await dio.put('/tasks', data: task);
      if (response.statusCode == 200) {
        newTask = TaskData.fromJson(response.data);
        return newTask;
        // if (Hive.box<TaskData>('taskBox').isEmpty) {
        //   Hive.box<TaskData>('taskBox').addAll(tasks);
        // }
        // return tasks;
      } else {
        throw Exception('Could not update! Task not found!');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TagData>> getTags() async {
    List<TagData> tags;
    // FlutterSecureStorage storage = const FlutterSecureStorage();
    Response<dynamic> response;
    try {
      response = await dio.get(
        '/tags',
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        tags = (response.data['items'] as List)
            .map((i) => TagData.fromJson(i))
            .toList();
        if (Hive.box<TagData>('tagBox').isEmpty) {
          Hive.box<TagData>('tagBox').addAll(tags);
        }
        return tags;
      } else {
        throw Exception('Tags not found!');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCreate> postUser(
      String name, String email, String password) async {
    User user = User(name, email, password);
    Response<dynamic> response;
    Dio dioRegister = Dio(BaseOptions(
        baseUrl: 'https://test-mobile.estesis.tech/api/v1',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json'
        }));
    try {
      response = await dioRegister.post('/register', data: user);
      if (response.statusCode == 200) {
        return UserCreate.fromJson(response.data);
      } else {
        throw Exception('Registration error!');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Token> getToken(String email, String password) async {
    UserLogin userLogin = UserLogin(email, password);
    Response<dynamic> response;
    Dio dioLogin = dio = Dio(BaseOptions(
        baseUrl: 'https://test-mobile.estesis.tech/api/v1',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
          HttpHeaders.acceptHeader: 'application/json'
        }));
    try {
      response = await dioLogin.post('/login', data: userLogin.toJson());
      if (response.statusCode == 200) {
        FlutterSecureStorage storage = const FlutterSecureStorage();
        String accessToken = Token.fromJson(response.data).accessToken;
        storage.deleteAll();
        storage.write(key: 'access_token', value: accessToken);
        return Token.fromJson(response.data);
      } else {
        throw Exception('Login error!');
      }
    } catch (e) {
      rethrow;
    }
  }
}
