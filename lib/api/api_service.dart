import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:project1/model/sync%20status/sync_status.dart';
import 'package:project1/model/tag/tag.dart';

import '../model/task post/task_post.dart';
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
          for (var item in tasks) {
            Hive.box<TaskData>('taskBox').put(item.sid, item);
          }
          // Hive.box<TaskData>('taskBox').addAll(tasks);
        } else {
          List<TaskData> taskDataList =
              Hive.box<TaskData>('taskBox').values.toList();
          if (taskDataList.length > tasks.length) {
            List<TaskData> localData = [];

            for (var item in taskDataList) {
              if (!tasks.contains(item)) {
                localData.add(item);
              }
            }

            for (var item in tasks) {
              item.syncStatus = SyncStatus.BOTH;
            }

            for (var item in localData) {
              item.syncStatus = SyncStatus.LOCAL_ONLY;
            }

            tasks.addAll(localData);
            tasks
                .sort((a, b) => a.syncStatus == SyncStatus.LOCAL_ONLY ? 1 : -1);
          } else if (taskDataList.length < tasks.length) {
            List<TaskData> serverData = [];

            for (var item in tasks) {
              if (!taskDataList.contains(item)) {
                serverData.add(item);
              }
            }

            for (var item in taskDataList) {
              item.syncStatus = SyncStatus.BOTH;
            }

            for (var item in serverData) {
              item.syncStatus = SyncStatus.SERVER_ONLY;
            }
            tasks.clear();
            tasks.addAll(taskDataList);
            tasks.addAll(serverData);
            tasks.sort(
                (a, b) => a.syncStatus == SyncStatus.SERVER_ONLY ? 1 : -1);
          }
        }

        // if (Hive.box<TaskData>('taskBox').isEmpty) {
        //   Hive.box<TaskData>('taskBox').addAll(tasks);
        // }

        // tasks = Hive.box<TaskData>('taskBox').values.toList();

        return tasks;
      } else if (response.statusCode == 500 ||
          response.statusCode == 503 ||
          response.statusCode == 504) {
        return Hive.box<TaskData>('taskBox').values.toList();
      } else {
        throw Exception('Tasks not found!');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskData> postTask(TaskPostData task) async {
    Response<dynamic> response;
    TaskData newTask;
    try {
      response = await dio.post('/tasks', data: task);
      if (response.statusCode == 200) {
        newTask = TaskData.fromJson(response.data);
        // Hive.box<TaskData>('taskBox').add(newTask);
        Hive.box<TaskData>('taskBox').put(newTask.sid, newTask);
        return newTask;
        // if (Hive.box<TaskData>('taskBox').isEmpty) {
        //   Hive.box<TaskData>('taskBox').addAll(tasks);
        // }
        // return tasks;
      } else if (response.statusCode == 500 ||
          response.statusCode == 503 ||
          response.statusCode == 504) {
        TagData? tag = Hive.box<TagData>('tagBox').get(task.tagSid);
        // TagData tag = Hive.box<TagData>('tagBox')
        //     .values
        //     .firstWhere((item) => item.sid == task.tagSid);
        TaskData localTask = TaskData(
            title: task.title,
            text: task.text,
            isDone: false,
            tag: tag!,
            priority: task.priority,
            finishAt: task.finishAt,
            syncStatus: SyncStatus.LOCAL_ONLY);
        Hive.box<TaskData>('taskData').put(localTask.sid, localTask);
        // Hive.box<TaskData>('taskBox').add(localTask);
        return localTask;
      } else {
        throw Exception('Could not create task!');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskData> putCompleteTask(TaskPutData task) async {
    Response<dynamic> response;
    TaskData newTask;
    try {
      response = await dio.put('/tasks', data: task);
      if (response.statusCode == 200) {
        newTask = TaskData.fromJson(response.data);

        Hive.box<TaskData>('taskBox').put(newTask.sid, newTask);

        return newTask;
      } else if (response.statusCode == 500 ||
          response.statusCode == 503 ||
          response.statusCode == 504) {

        TagData? tag = Hive.box<TagData>('tagBox').get(task.tagSid);

        // TagData tag = Hive.box<TagData>('tagBox')
        //     .values
        //     .firstWhere((item) => item.sid == task.tagSid);

        // TaskData localTask = Hive.box<TaskData>('taskBox')
        //     .values
        //     .firstWhere((item) => item.sid == task.sid);

        TaskData? localTask = Hive.box<TaskData>('taskBox').get(task.sid);

        // int index = Hive.box<TaskData>('taskBox')

        localTask?.title = task.title;
        localTask?.text = task.text;
        localTask?.finishAt = task.finishAt;
        localTask?.priority = task.priority;
        localTask?.tag = tag!;
        localTask?.isDone = task.isDone;

        Hive.box<TaskData>('taskBox').put(localTask?.sid, localTask!);
        // Hive.box<TaskData>('taskBox').add(localTask);
        return localTask;
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
      // print(response.statusCode);
      if (response.statusCode == 200) {
        tags = (response.data['items'] as List)
            .map((i) => TagData.fromJson(i))
            .toList();
        if (Hive.box<TagData>('tagBox').isEmpty) {
          // Hive.box<TagData>('tagBox').addAll(tags);
          for(var item in tags) {
            Hive.box<TagData>('tagBox').put(item.sid, item);
          }
        }
        return tags;
      } else if (response.statusCode == 500 ||
          response.statusCode == 503 ||
          response.statusCode == 504) {
        return Hive.box<TagData>('tagBox').values.toList();
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
    Dio dioLogin = Dio(BaseOptions(
        baseUrl: 'https://test-mobile.estesis.tech/api/v1',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
          HttpHeaders.acceptHeader: 'application/json'
        }));

    // Dio dioLogin = Dio();
    // dioLogin.options.baseUrl = 'https://test-mobile.estesis.tech/api/v1';
    // dioLogin.options.contentType = Headers.formUrlEncodedContentType;
    try {
      response = await dioLogin.post('/login', data: userLogin.toJson());
      if (response.statusCode == 200) {
        FlutterSecureStorage storage = const FlutterSecureStorage();
        Token token = Token.fromJson(response.data);
        // String accessToken = Token.fromJson(response.data).accessToken;
        // String refresh_token = Token.fromJson(response.data)
        storage.deleteAll();
        storage.write(key: 'access_token', value: token.accessToken);
        storage.write(key: 'refresh_token', value: token.refreshToken);
        return Token.fromJson(response.data);
      } else {
        throw Exception('Login error!');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Token> refreshToken(Token token) async {
    Response<dynamic> response;
    Dio dioRefresh = Dio(BaseOptions(
        baseUrl: 'https://test-mobile.estesis.tech/api/v1',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json'
        }));

    // dioRefresh.options.baseUrl = 'https://test-mobile.estesis.tech/api/v1';
    // dioRefresh.options.contentType = Headers.formUrlEncodedContentType;
    try {
      response = await dioRefresh
          .post('/refresh_token', queryParameters: {'refresh_token': token});
      if (response.statusCode == 200) {
        FlutterSecureStorage storage = const FlutterSecureStorage();
        Token newToken = Token.fromJson(response.data);
        // String accessToken = Token.fromJson(response.data).accessToken;
        // String refresh_token = Token.fromJson(response.data)
        storage.deleteAll();
        storage.write(key: 'access_token', value: newToken.accessToken);
        storage.write(key: 'refresh_token', value: newToken.refreshToken);
        return Token.fromJson(response.data);
      } else {
        throw Exception('Token refresh error!');
      }
    } catch (e) {
      rethrow;
    }
  }
}
