import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import '../../model/sync status/sync_status.dart';
import '../../model/tag/tag.dart';
import '../../model/task post/task_post.dart';
import '../../model/task put/task_put.dart';
import '../../model/task/task.dart';

class TaskService {
  final Dio _dio;

  TaskService(this._dio);

  List<TaskData> fetchData(List<TaskData> local, List<TaskData> server) {
    List<TaskData> data = [];
    for (var item in local) {
      item.syncStatus = SyncStatus.LOCAL_ONLY;
    }
    for (var item in server) {
      item.syncStatus = SyncStatus.SERVER_ONLY;
    }
    for (var item1 in local) {
      for (var item2 in server) {
        if (item1.sid == item2.sid) {
          if (item1.equals(item2)) {
            item1.syncStatus = SyncStatus.BOTH;
            item2.syncStatus = SyncStatus.BOTH;
          }
          item2.syncStatus = SyncStatus.LOCAL_ONLY;
        }
      }
    }
    server.removeWhere((item) =>
        item.syncStatus == SyncStatus.BOTH ||
        item.syncStatus == SyncStatus.LOCAL_ONLY);
    data = {...local, ...server}.toList();
    // data = local;
    data.sort((a, b) => a.syncStatus == SyncStatus.BOTH ? 1 : -1);
    return data;
  }

  TaskData postTaskLocal(TaskPostData task) {
    TagData? tag = Hive.box<TagData>('tagBox').get(task.tagSid);
    TaskData localTask = TaskData(
        sid: DateTime.now().toIso8601String(),
        title: task.title,
        text: task.text,
        isDone: false,
        tag: tag!,
        priority: task.priority,
        createdAt: DateTime.now(),
        finishAt: task.finishAt,
        syncStatus: SyncStatus.LOCAL_ONLY);
    Hive.box<TaskData>('taskBox').put(localTask.sid, localTask);
    return localTask;
  }

  TaskData putTaskLocal(TaskPutData task) {
    TagData? tag = Hive.box<TagData>('tagBox').get(task.tagSid);
    TaskData? localTask = Hive.box<TaskData>('taskBox').get(task.sid);

    localTask?.title = task.title;
    localTask?.text = task.text;
    localTask?.finishAt = task.finishAt;
    localTask?.priority = task.priority;
    localTask?.tag = tag!;
    localTask?.isDone = task.isDone;
    localTask?.syncStatus = SyncStatus.LOCAL_ONLY;

    Hive.box<TaskData>('taskBox').put(localTask?.sid, localTask!);
    return localTask;
  }

  Future<List<TaskData>> getTasks() async {
    List<TaskData> tasks;
    Response<dynamic> response;
    try {
      response = await _dio.get(
        '/tasks',
      );
      tasks = (response.data['items'] as List)
          .map((i) => TaskData.fromJson(i))
          .toList();
      if (Hive.box<TaskData>('taskBox').isEmpty) {
        for (var item in tasks) {
          Hive.box<TaskData>('taskBox').put(item.sid, item);
        }
      } else {
        List<TaskData> taskDataList =
            Hive.box<TaskData>('taskBox').values.toList();
        tasks = fetchData(taskDataList, tasks);
      }
      return tasks;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<TaskData> postTask(TaskPostData task) async {
    Response<dynamic> response;
    TaskData newTask;
    try {
      response = await _dio.post('/tasks', data: task);
      newTask = TaskData.fromJson(response.data);
      newTask.syncStatus = SyncStatus.BOTH;
      Hive.box<TaskData>('taskBox').put(newTask.sid, newTask);
      return newTask;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<TaskData> retryPostTask(TaskData task) async {
    Response<dynamic> response;
    TaskData newTask;
    try {
      TaskPostData taskPost = TaskPostData(
          title: task.title,
          text: task.text,
          tagSid: task.tag.sid,
          priority: task.priority);
      response = await _dio.post('/tasks', data: taskPost);
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
          priority: newTask.priority,
          syncStatus: newTask.syncStatus);
      newTask = await putTask(taskPut);
      return newTask;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<TaskData> retryPutTask(TaskData task) async {
    Response<dynamic> response;
    TaskData newTask;
    try {
      TaskPutData taskPut = TaskPutData(
          sid: task.sid!,
          title: task.title,
          text: task.text,
          finishAt: task.finishAt,
          isDone: task.isDone,
          tagSid: task.tag.sid,
          priority: task.priority);
      response = await _dio.put('/tasks', data: taskPut);
      newTask = TaskData.fromJson(response.data);
      newTask.syncStatus = SyncStatus.BOTH;
      Hive.box<TaskData>('taskBox').put(newTask.sid, newTask);
      return newTask;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<TaskData> putTask(TaskPutData task) async {
    Response<dynamic> response;
    TaskData newTask;
    try {
      response = await _dio.put('/tasks', data: task);
      newTask = TaskData.fromJson(response.data);
      Hive.box<TaskData>('taskBox').put(newTask.sid, newTask);
      return newTask;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String sid) async {
    try {
      await _dio.delete('/tasks', queryParameters: {'taskSid': sid});
      Hive.box<TaskData>('taskBox').delete(sid);
    } on DioException catch (e) {
      rethrow;
    }
  }
}
