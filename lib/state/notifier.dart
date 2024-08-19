import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/task/task.dart';

part 'notifier.g.dart';

@riverpod
class TasksNotifier extends _$TasksNotifier {
  @override
  Future<List<TaskData>> build() async {
    List<TaskData> tasks;
    FlutterSecureStorage storage = const FlutterSecureStorage();
    Response<dynamic> response;
    var token = await storage.read(key: 'access_token');
    var dio = Dio(BaseOptions(
        baseUrl: 'https://test-mobile.estesis.tech/api/v1',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token'
        }));
    try {
      response = await dio.get(
        '/tasks',
      );
      if (response.statusCode == 200) {
        tasks = (response.data['items'] as List)
            .map((i) => TaskData.fromJson(i))
            .toList();
        if (Hive.box<TaskData>('taskBox').isEmpty) {
          Hive.box<TaskData>('taskBox').addAll(tasks);
        }
        return tasks;
      } else {
        throw Exception('Tasks not found!');
      }
    } catch (e) {
      rethrow;
    }
  }
}