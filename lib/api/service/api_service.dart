import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:project1/api/provider/task/task_provider.dart';
import 'package:project1/api/service/tag_service.dart';
import 'package:project1/api/service/task_service.dart';
import 'package:project1/api/service/token_service.dart';
import 'package:project1/api/service/user_service.dart';
import 'package:project1/model/sync%20status/sync_status.dart';
import 'package:project1/model/tag/tag.dart';
import 'package:project1/api/interceptor/request_interceptor.dart';

import '../../model/task post/task_post.dart';
import '../../model/task put/task_put.dart';
import '../../model/task/task.dart';
import '../../model/token/token.dart';
import '../../model/user create/user_create.dart';
import '../../model/user login/user_login.dart';
import '../../model/user/user.dart';

class ApiService {
  static late Dio dio;
  static late TaskService taskService;
  static late TagService tagService;
  static late UserService userService;
  static late TokenService tokenService;

  ApiService._create();

  static Future<ApiService> create() async {
    var service = ApiService._create();
    dio = Dio(BaseOptions(
      // connectTimeout: const Duration(seconds: 10),
        // sendTimeout: const Duration(seconds: 5),
        // receiveTimeout: const Duration(seconds: 5),
        baseUrl: 'https://test-mobile.estesis.tech/api/v1',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        }));
    dio.interceptors.add(RequestInterceptor());

    taskService = TaskService(dio);
    tagService = TagService(dio);
    userService = UserService();
    tokenService = TokenService(dio);

    return service;
  }

  Future<List<TaskData>> getTasks() async {
    List<TaskData> tasks;
    try {
      tasks = await taskService.getTasks();
      return tasks;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<TaskData> postTask(TaskPostData task) async {
    TaskData newTask;
    try {
      newTask = await taskService.postTask(task);
      return newTask;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<TaskData> retryPostTask(TaskData task) async {
    TaskData newTask;
    try {
      newTask = await taskService.retryPostTask(task);
      return newTask;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<TaskData> retryPutTask(TaskData task) async {
    TaskData newTask;
    try {
      newTask = await taskService.retryPutTask(task);
      return newTask;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<TaskData> putTask(TaskPutData task) async {
    TaskData newTask;
      try {
        newTask = await taskService.putTask(task);
          return newTask;
      } on DioException catch (e) {
        rethrow;
      }
  }

  Future<void> deleteTask(String sid) async {
    try {
      await taskService.deleteTask(sid);
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<List<TagData>> getTags() async {
    List<TagData> tags;
    try {
      tags = await tagService.getTags();
      return tags;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<UserCreate> postUser(User user) async {
    UserCreate userCreate;
    try {
        userCreate = await userService.postUser(user);
      return userCreate;
    } catch (e) {
      rethrow;
    }
  }

  Future<Token> logIn(UserLogin userLogin) async {
    Token token;
    try {
      token = await tokenService.logIn(userLogin);
      return token;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<bool> logOut() async {
    bool response;
    try {
      response = await tokenService.logOut();
      return response;
    } on DioException catch(e) {
      rethrow;
    }
  }

  Future<bool> checkToken() async {
    bool response;
    try {
      response = await tokenService.checkToken();
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  // Future<Token> getCurrentToken() async {
  //   FlutterSecureStorage storage = const FlutterSecureStorage();
  //   String? acsToken = await storage.read(key: 'access_token');
  //   String? refToken = await storage.read(key: 'refresh_token');
  //   return Token(acsToken!, refToken!);
  // }

  TaskData postTaskLocal(TaskPostData task) {
    return taskService.postTaskLocal(task);
  }

  TaskData putTaskLocal(TaskPutData task) {
    return taskService.putTaskLocal(task);
  }
}
