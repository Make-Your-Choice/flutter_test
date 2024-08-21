import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:project1/api/api_service.dart';
import 'package:project1/model/task%20put/task_put.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/tag/tag.dart';
import '../model/task post/task_post.dart';
import '../model/task/task.dart';
import '../model/token/token.dart';
import '../model/user login/user_login.dart';

part 'provider.g.dart';


@Riverpod()
class Task extends _$Task {
  late ApiService service;
  @override
  Future<List<TaskData>> build() async {
    service = await ApiService.create();
    return fetchTasks();
  }

  Future<List<TaskData>> fetchTasks(
      {String? maxCreatedDate, String? minCreatedDate}) async {
    // var service = await ApiService.create();
    final List<TaskData> content = await service.getTasks();
    return content;
  }

  Future<void> completeTask(TaskPutData task) async {
    // var service = await ApiService.create();
    await service.putCompleteTask(task);
  }

  Future<void> createTask(TaskPostData task) async {
    // var service = await ApiService.create();
    await service.postTask(task);
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
    return content;
  }
}
