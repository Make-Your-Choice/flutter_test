
import 'package:project1/api/api_service.dart';
import 'package:project1/model/task%20put/task_put.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/tag/tag.dart';
import '../model/task post/task_post.dart';
import '../model/task/task.dart';
import '../model/token/token.dart';

part 'provider.g.dart';

@Riverpod()
class Task extends _$Task {
  // late ApiService service;

  @override
  Future<List<TaskData>> build() async {
    // service = await ApiService.create();
    return fetchTasks();
  }

  // Future<ApiService> get service async => await ApiService.create();

  Future<List<TaskData>> fetchTasks(
      {String? maxCreatedDate, String? minCreatedDate}) async {
    var service = await ApiService.create();
    final List<TaskData> content = await service.getTasks();
    // ref.invalidateSelf();
    // await future;
    return content;
  }

  Future<void> updateTask(TaskPutData task) async {
    var service = await ApiService.create();
    await service.putTask(task);
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
    await service.retryPostTask(taskPost, task);
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
    var service = await ApiService.create();
    bool isPresent = await service.checkToken();
    return isPresent;
  }

  Future<bool> logOut() async {
    var service = await ApiService.create();
    bool isLoggedOut = await service.logOut();
    return isLoggedOut;
  }
}
