import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../model/sync status/sync_status.dart';
import '../../../model/task post/task_post.dart';
import '../../../model/task put/task_put.dart';
import '../../../model/task/task.dart';
import '../../service/api_service.dart';
import '../connection state/connection_state_provider.dart';
import '../token state/token_state_provider.dart';

part 'task_provider.g.dart';

@Riverpod()
class Task extends _$Task {
  // late ApiService service;

  @override
  Future<List<TaskData>> build() async {
    return fetchTasks();
  }

  Future<List<TaskData>> fetchTasks() async {
    List<TaskData> content;
    var service = await ApiService.create();
    try {
      content = await service.getTasks();
      ref.watch(connectionStateProvider.notifier).fetchNewState(true);
      return content;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
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
      if (task.syncStatus == SyncStatus.BOTH) {
        await service.putTask(task);
        ref.watch(connectionStateProvider.notifier).fetchNewState(true);
      } else {
        service.putTaskLocal(task);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        ref.watch(connectionStateProvider.notifier).fetchNewState(false);
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
    try {
      await service.postTask(task);
      ref.watch(connectionStateProvider.notifier).fetchNewState(true);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        ref.watch(connectionStateProvider.notifier).fetchNewState(false);
        service.postTaskLocal(task);
      }
    }
    ref.invalidateSelf();
    await future;
  }

  Future<void> retryTask(TaskData task) async {
    try {
      if(task.sid!.length < 32) {
        await retryCreateTask(task);
      } else {
        await retryUpdateTask(task);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        ref.watch(connectionStateProvider.notifier).fetchNewState(false);
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

  Future<void> retryCreateTask(TaskData task) async {
    var service = await ApiService.create();
    try {
      await service.retryPostTask(task);
      ref.watch(connectionStateProvider.notifier).fetchNewState(true);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        ref.watch(connectionStateProvider.notifier).fetchNewState(false);
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

  Future<void> retryUpdateTask(TaskData task) async {
    var service = await ApiService.create();
    try {
      await service.retryPutTask(task);
      ref.watch(connectionStateProvider.notifier).fetchNewState(true);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        ref.watch(connectionStateProvider.notifier).fetchNewState(false);
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
    try {
      await service.deleteTask(sid);
      ref.watch(connectionStateProvider.notifier).fetchNewState(true);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        ref.watch(connectionStateProvider.notifier).fetchNewState(false);
        Hive.box<TaskData>('taskBox').delete(sid);
      }
    }
    ref.invalidateSelf();
    await future;
  }
}