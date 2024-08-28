import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:project1/model/sync%20status/sync_status.dart';
import 'package:project1/model/tag/tag.dart';
import 'package:project1/api/api_interceptor.dart';

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
    dio = Dio(BaseOptions(
        baseUrl: 'https://test-mobile.estesis.tech/api/v1',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        }));
    dio.interceptors.add(ApiInterceptor());
    return service;
  }

  List<TaskData> fetchData (List<TaskData> local, List<TaskData> server) {
    List<TaskData> data = [];

    for (var item in local) {
      item.syncStatus = SyncStatus.LOCAL_ONLY;
    }

    for (var item in server) {
      item.syncStatus = SyncStatus.SERVER_ONLY;
    }

    for(var item1 in local) {
      for(var item2 in server) {
        if(item1.sid == item2.sid) {
          if(item1.equals(item2)) {
            item1.syncStatus = SyncStatus.BOTH;
            item2.syncStatus = SyncStatus.BOTH;
          }
        }
      }
    }
    server.removeWhere((item) => item.syncStatus == SyncStatus.BOTH);
    data = {...local, ...server}.toList();
    data.sort((a, b) => a.syncStatus == SyncStatus.BOTH ? 1 : -1);
    return data;
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
          tasks = fetchData(taskDataList, tasks);
        }

        return tasks;
      } else if (response.statusCode == 500 ||
          response.statusCode == 503 ||
          response.statusCode == 504) {
        return Hive.box<TaskData>('taskBox').values.toList();
      } else {
        // throw Exception('Tasks not found!');
        throw DioException(
            requestOptions: RequestOptions(),
            response: Response(
                requestOptions: RequestOptions(),
                statusCode: 404,
                statusMessage: 'Tasks not found'));
      }
    } on DioException catch (e) {
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
        newTask.syncStatus = SyncStatus.BOTH;
        // Hive.box<TaskData>('taskBox').add(newTask);
        Hive.box<TaskData>('taskBox').put(newTask.sid, newTask);
        return newTask;
      } else if (response.statusCode == 500 ||
          response.statusCode == 503 ||
          response.statusCode == 504) {
        TagData? tag = Hive.box<TagData>('tagBox').get(task.tagSid);
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
        throw DioException(
            requestOptions: RequestOptions(),
            response: Response(
                requestOptions: RequestOptions(),
                statusCode: 500,
                statusMessage: 'Could not create task'));
        // throw Exception('Could not create task!');
      }
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<TaskData> retryPostTask(TaskPostData taskPost, TaskData task) async {
    Response<dynamic> response;
    TaskData newTask;
    try {
      response = await dio.post('/tasks', data: taskPost);
      if (response.statusCode == 200) {
        newTask = TaskData.fromJson(response.data);
        newTask.syncStatus = SyncStatus.BOTH;
        Hive.box<TaskData>('taskBox').delete(task.sid);
        Hive.box<TaskData>('taskBox').put(newTask.sid, newTask);
        TaskPutData taskPut = TaskPutData(
            sid: newTask.sid!,
            title: newTask.title,
            text: newTask.text,
            isDone: newTask.isDone,
            tagSid: newTask.tag.sid,
            priority: newTask.priority);
        newTask = await putTask(taskPut);
        // TaskPutData taskPut = TaskPutData(sid, title, text, isDone, tagSid, syncStatus)
        return newTask;
      } else {
        throw DioException(
            requestOptions: RequestOptions(),
            response: Response(
                requestOptions: RequestOptions(),
                statusCode: 500,
                statusMessage: 'Could not repost task'));
        // throw Exception('Could not create task!');
      }
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<TaskData> putTask(TaskPutData task) async {
    Response<dynamic> response;
    TaskData newTask;
    if(task.syncStatus == SyncStatus.BOTH) {
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

          TaskData? localTask = Hive.box<TaskData>('taskBox').get(task.sid);

          localTask?.title = task.title;
          localTask?.text = task.text;
          localTask?.finishAt = task.finishAt;
          localTask?.priority = task.priority;
          localTask?.tag = tag!;
          localTask?.isDone = task.isDone;

          Hive.box<TaskData>('taskBox').put(localTask?.sid, localTask!);
          return localTask;
        } else {
          throw DioException(
              requestOptions: RequestOptions(),
              response: Response(
                  requestOptions: RequestOptions(),
                  statusCode: 500,
                  statusMessage: 'Could not update! Task not found!'));
        }
      } on DioException catch (e) {
        rethrow;
      }
    } else {
      TagData? tag = Hive.box<TagData>('tagBox').get(task.tagSid);
      TaskData? localTask = Hive.box<TaskData>('taskBox').get(task.sid);

      localTask?.title = task.title;
      localTask?.text = task.text;
      localTask?.finishAt = task.finishAt;
      localTask?.priority = task.priority;
      localTask?.tag = tag!;
      localTask?.isDone = task.isDone;

      Hive.box<TaskData>('taskBox').put(localTask?.sid, localTask!);
      return localTask;
    }
  }

  Future<void> deleteTask(String sid) async {
    Response<dynamic> response;
    try {
      response = await dio.delete('/tasks', queryParameters: {'taskSid' : sid});
      if (response.statusCode == 200) {
        Hive.box<TaskData>('taskBox').delete(sid);
      } else if (response.statusCode == 500 ||
          response.statusCode == 503 ||
          response.statusCode == 504) {
        Hive.box<TaskData>('taskData').delete(sid);
      } else {
        throw DioException(
            requestOptions: RequestOptions(),
            response: Response(
                requestOptions: RequestOptions(),
                statusCode: 500,
                statusMessage: 'Could not delete task'));
      }
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<List<TagData>> getTags() async {
    List<TagData> tags;
    Response<dynamic> response;
    try {
      response = await dio.get(
        '/tags',
      );
      if (response.statusCode == 200) {
        tags = (response.data['items'] as List)
            .map((i) => TagData.fromJson(i))
            .toList();
        if (Hive.box<TagData>('tagBox').isEmpty) {
          for (var item in tags) {
            Hive.box<TagData>('tagBox').put(item.sid, item);
          }
        }
        return tags;
      } else if (response.statusCode == 500 ||
          response.statusCode == 503 ||
          response.statusCode == 504) {
        return Hive.box<TagData>('tagBox').values.toList();
      } else {
        throw DioException(
            requestOptions: RequestOptions(),
            response: Response(
                requestOptions: RequestOptions(),
                statusCode: 500,
                statusMessage: 'Tags not found!'));
      }
    } on DioException catch (e) {
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

  Future<Token> logIn(String email, String password) async {
    FlutterSecureStorage storage = const FlutterSecureStorage();

    UserLogin userLogin = UserLogin(email, password);
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
      response = await dio.post(
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
        response = await dio.get('/users/me');
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

  Future<Token> getCurrentToken() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    String? acsToken = await storage.read(key: 'access_token');
    String? refToken = await storage.read(key: 'refresh_token');
    return Token(acsToken!, refToken!);
  }
}
