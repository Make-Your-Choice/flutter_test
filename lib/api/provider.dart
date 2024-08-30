
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:project1/api/api_service.dart';
import 'package:project1/model/sync%20status/sync_status.dart';
import 'package:project1/model/task%20put/task_put.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/tag/tag.dart';
import '../model/task post/task_post.dart';
import '../model/task/task.dart';
import '../model/token/token.dart';

part 'provider.g.dart';

@riverpod
class Task extends _$Task {
  // late ApiService service;

  @override
  Future<List<TaskData>> build() async {
    // service = await ApiService.create();

    // if(isOffline) {
    //   return fetchTasksOffline();
    // }
    return fetchTasks();
  }

  // Future<ApiService> get service async => await ApiService.create();

  Future<List<TaskData>> fetchTasks() async {
    List<TaskData> content;
    try {
      var service = await ApiService.create();
      content = await service.getTasks();
      ref.watch(connectionStateProvider.notifier).fetchNewState(true);
      return content;
    } on DioException catch(e) {
      if(e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
        ref.watch(connectionStateProvider.notifier).fetchNewState(false);
        return Hive.box<TaskData>('taskBox').values.toList();
      } else if (e.response?.statusCode == 401) {
        ref.watch(tokenStateProvider.notifier).checkToken();
        rethrow;
      } else {
        rethrow;
      }
    }
  }

  Future<void> updateTask(TaskPutData task) async {
    var service = await ApiService.create();
    try {
      if(task.syncStatus == SyncStatus.BOTH) {
        await service.putTask(task);
        ref.watch(connectionStateProvider.notifier).fetchNewState(true);
      } else {
        service.putTaskLocal(task);
      }
    } on DioException catch(e) {
      if(e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        service.putTaskLocal(task);
      } else if (e.response?.statusCode == 401) {
        ref.watch(tokenStateProvider.notifier).checkToken();
        rethrow;
      } else {
        rethrow;
      }
    }
    ref.invalidateSelf();
    await future;
  }

  Future<void> createTask(TaskPostData task) async {
    var service = await ApiService.create();
    await service.postTask(task);
    ref.invalidateSelf();
    await future;
  }

  Future<void> retryCreateTask(TaskPostData taskPost, TaskData task) async {
    var service = await ApiService.create();
    try {
      await service.retryPostTask(taskPost, task);
    } on DioException catch(e) {
      if(e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
        rethrow;
      } else if (e.response?.statusCode == 401) {
        ref.watch(tokenStateProvider.notifier).checkToken();
        rethrow;
     } else {
        rethrow;
      }
    }
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteTask(String sid) async {
    var service = await ApiService.create();
    await service.deleteTask(sid);
    ref.invalidateSelf();
    await future;
  }

}

@Riverpod()
class Tag extends _$Tag {
  @override
  Future<List<TagData>> build() async {
    return fetchTags();
  }

  Future<List<TagData>> fetchTags() async {
    var service = await ApiService.create();
    final List<TagData> content = await service.getTags();
    // ref.invalidateSelf();
    // await future;
    return content;
  }
}

@Riverpod()
class TokenState extends _$TokenState {
  @override
  Future<bool> build() async {
    return checkToken();
  }

  Future<bool> checkToken() async {
    try {
      var service = await ApiService.create();
      bool isPresent = await service.checkToken();
      return isPresent;
    } on DioException catch(e) {
      rethrow;
    }
  }

  Future<bool> logOut() async {
    var service = await ApiService.create();
    bool isLoggedOut = await service.logOut();
    return isLoggedOut;
  }
}

@riverpod
class ConnectionState extends _$ConnectionState {
  bool connectionState = true;

@override
  FutureOr<bool> build() {
    return connectionState;
  }

  Future<void> fetchNewState(bool newState) async {
    connectionState = newState;
    ref.invalidateSelf();
    await future;
  }
}