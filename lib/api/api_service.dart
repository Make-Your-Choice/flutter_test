import 'dart:io';

import 'package:dio/dio.dart';
import 'package:collection/collection.dart';
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
  // static ApiInterceptor interceptor = ApiInterceptor();

  ApiService._create();

  static Future<ApiService> create() async {
    var service = ApiService._create();
    // var storage = const FlutterSecureStorage();
    // var token = await storage.read(key: 'access_token');
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
    // DeepCollectionEquality eq = const DeepCollectionEquality();

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

  // List<TaskData> fetchLocalServerData (List<TaskData> local, List<TaskData> server) {
  //   List<TaskData> data = [];
  //   DeepCollectionEquality eq = const DeepCollectionEquality();
  //   for(var item1 in local) {
  //     for(var item2 in server) {
  //       if(item1.sid == item2.sid) {
  //         if(eq.equals(item1, item2)) {
  //           item1.syncStatus = SyncStatus.BOTH;
  //           data.add(item1);
  //         }
  //         item1.syncStatus = SyncStatus.LOCAL_ONLY;
  //         data.add(item1);
  //       }
  //     }
  //   }
  //   return data;
  // }
  //
  // List<TaskData> fetchLocalData(List<TaskData> local, List<TaskData> server) {
  //   List<TaskData> data = [];
  //
  //   DeepCollectionEquality eq = const DeepCollectionEquality();
  //   for(var item1 in local) {
  //     for(var item2 in server) {
  //       if(item1.sid == item2.sid) {
  //         if(eq.equals(item1, item2)) {
  //           item1.syncStatus = SyncStatus.BOTH;
  //         }
  //         item1.syncStatus = SyncStatus.LOCAL_ONLY;
  //         data.add(item1);
  //       } else {
  //         item1.syncStatus = SyncStatus.LOCAL_ONLY;
  //       }
  //     }
  //   }
  //   data.addAll(local);
  //   data.sort((a, b) => a.syncStatus == SyncStatus.LOCAL_ONLY ? 1 : -1);
  //   return data;
  //
  // }
  //
  // List<TaskData> fetchServerData(List<TaskData> local, List<TaskData> server) {
  //   List<TaskData> data = [];
  //
  //   DeepCollectionEquality eq = const DeepCollectionEquality();
  //   for(var item1 in server) {
  //     for(var item2 in local) {
  //       if(item1.sid == item2.sid) {
  //         if(eq.equals(item1, item2)) {
  //           item1.syncStatus = SyncStatus.BOTH;
  //         }
  //         item1.syncStatus = SyncStatus.SERVER_ONLY;
  //         data.add(item1);
  //       } else {
  //         item1.syncStatus = SyncStatus.SERVER_ONLY;
  //       }
  //     }
  //   }
  //   data.addAll(server);
  //   data.sort((a, b) => a.syncStatus == SyncStatus.LOCAL_ONLY ? 1 : -1);
  //   return data;
  // }

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
          // if(taskDataList.length == tasks.length) {
          //   tasks = fetchLocalServerData(taskDataList, tasks);
          // }
          // if (taskDataList.length > tasks.length) {
          //   List<TaskData> localData = [];
          //
          //
          //   for (var item in taskDataList) {
          //     if (!tasks.contains(item)) {
          //       localData.add(item);
          //     }
          //   }
          //
          //
          //   for (var item in tasks) {
          //     item.syncStatus = SyncStatus.BOTH;
          //   }
          //
          //   for (var item in localData) {
          //     item.syncStatus = SyncStatus.LOCAL_ONLY;
          //   }
          //
          //   tasks.addAll(localData);
          //   tasks
          //       .sort((a, b) => a.syncStatus == SyncStatus.LOCAL_ONLY ? 1 : -1);
          // } else if (taskDataList.length < tasks.length) {
          //   List<TaskData> serverData = [];
          //
          //   for (var item in tasks) {
          //     if (!taskDataList.contains(item)) {
          //       serverData.add(item);
          //     }
          //   }
          //
          //   for (var item in taskDataList) {
          //     item.syncStatus = SyncStatus.BOTH;
          //   }
          //
          //   for (var item in serverData) {
          //     item.syncStatus = SyncStatus.SERVER_ONLY;
          //   }
          //   tasks.clear();
          //   tasks.addAll(taskDataList);
          //   tasks.addAll(serverData);
          //   tasks.sort(
          //       (a, b) => a.syncStatus == SyncStatus.SERVER_ONLY ? 1 : -1);
          // }
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
        // Hive.box<TaskData>('taskBox').add(newTask);
        Hive.box<TaskData>('taskBox').delete(task.sid);
        Hive.box<TaskData>('taskBox').put(newTask.sid, newTask);
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

  Future<TaskData> putCompleteTask(TaskPutData task) async {
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
          throw DioException(
              requestOptions: RequestOptions(),
              response: Response(
                  requestOptions: RequestOptions(),
                  statusCode: 500,
                  statusMessage: 'Could not update! Task not found!'));
          // throw Exception('Could not update! Task not found!');
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
        // Hive.box<TaskData>('taskBox').add(newTask);
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
        // throw Exception('Could not create task!');
      }
    } on DioException catch (e) {
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
        // throw Exception('Tags not found!');
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

  Future<Token> getToken(String email, String password) async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    // if(await storage.containsKey(key: 'access_token')) {
    //
    //   String? acs = await storage.read(key: 'access_token');
    //   String? ref = await storage.read(key: 'refresh_token');
    //
    //   return Token(acs!, ref!);
    // }
    UserLogin userLogin = UserLogin(email, password);
    Response<dynamic> response;
    Dio dioLogin = Dio(BaseOptions(
        baseUrl: 'https://test-mobile.estesis.tech/api/v1',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
          HttpHeaders.acceptHeader: 'application/json'
        }));

    // dioLogin.interceptors.add(ApiInterceptor());

    // Dio dioLogin = Dio();
    // dioLogin.options.baseUrl = 'https://test-mobile.estesis.tech/api/v1';
    // dioLogin.options.contentType = Headers.formUrlEncodedContentType;

    try {
      response = await dioLogin.post('/login', data: userLogin.toJson());
      if (response.statusCode == 200) {
        Token token = Token.fromJson(response.data);
        // storage.deleteAll();
        await storage.write(key: 'access_token', value: token.accessToken);
        await storage.write(key: 'refresh_token', value: token.refreshToken);
        return Token.fromJson(response.data);
      } else {
        throw Exception('Login error!');
      }
    } on DioException catch (e) {
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
          // } else if (response.statusCode == 401) {
          //   String? acsToken = await storage.read(key: 'access_token');
          //   String? refToken = await storage.read(key: 'refresh_token');
          //   Token token = Token(acsToken!, refToken!);
          //   Token refreshedToken = await refreshToken(token);
          //   await checkToken();
          // }
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
