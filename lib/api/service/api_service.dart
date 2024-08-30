import 'dart:io';

import 'package:dio/dio.dart';
import 'package:project1/api/service/tag_service.dart';
import 'package:project1/api/service/task_service.dart';
import 'package:project1/api/service/token_service.dart';
import 'package:project1/api/service/user_service.dart';
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
  static late Dio _dio;
  static late TaskService _taskService;
  static late TagService _tagService;
  static late UserService _userService;
  static late TokenService _tokenService;

  ApiService._create();

  static Future<ApiService> create() async {
    var service = ApiService._create();
    _dio = Dio(BaseOptions(
      // connectTimeout: const Duration(seconds: 10),
        // sendTimeout: const Duration(seconds: 5),
        // receiveTimeout: const Duration(seconds: 5),
        baseUrl: 'https://test-mobile.estesis.tech/api/v1',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        }));
    _dio.interceptors.add(RequestInterceptor());

    _taskService = TaskService(_dio);
    _tagService = TagService(_dio);
    _userService = UserService();
    _tokenService = TokenService(_dio);

    return service;
  }

  Future<List<TaskData>> getTasks() async {
    List<TaskData> tasks;
    try {
      tasks = await _taskService.getTasks();
      return tasks;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<TaskData> postTask(TaskPostData task) async {
    TaskData newTask;
    try {
      newTask = await _taskService.postTask(task);
      return newTask;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<TaskData> retryPostTask(TaskData task) async {
    TaskData newTask;
    try {
      newTask = await _taskService.retryPostTask(task);
      return newTask;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<TaskData> retryPutTask(TaskData task) async {
    TaskData newTask;
    try {
      newTask = await _taskService.retryPutTask(task);
      return newTask;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<TaskData> putTask(TaskPutData task) async {
    TaskData newTask;
      try {
        newTask = await _taskService.putTask(task);
          return newTask;
      } on DioException catch (e) {
        rethrow;
      }
  }

  Future<void> deleteTask(String sid) async {
    try {
      await _taskService.deleteTask(sid);
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<List<TagData>> getTags() async {
    List<TagData> tags;
    try {
      tags = await _tagService.getTags();
      return tags;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<UserCreate> postUser(User user) async {
    UserCreate userCreate;
    try {
        userCreate = await _userService.postUser(user);
      return userCreate;
    } catch (e) {
      rethrow;
    }
  }

  Future<Token> logIn(UserLogin userLogin) async {
    Token token;
    try {
      token = await _tokenService.logIn(userLogin);
      return token;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<bool> logOut() async {
    bool response;
    try {
      response = await _tokenService.logOut();
      return response;
    } on DioException catch(e) {
      rethrow;
    }
  }

  Future<bool> checkToken() async {
    bool response;
    try {
      response = await _tokenService.checkToken();
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
    return _taskService.postTaskLocal(task);
  }

  TaskData putTaskLocal(TaskPutData task) {
    return _taskService.putTaskLocal(task);
  }
}
