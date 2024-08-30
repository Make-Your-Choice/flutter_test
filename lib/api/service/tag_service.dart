import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import '../../model/tag/tag.dart';

class TagService {
  final Dio _dio;
  TagService(this._dio);

  Future<List<TagData>> getTags() async {
    List<TagData> tags;
    Response<dynamic> response;
    try {
      response = await _dio.get(
        '/tags',
      );
      tags = (response.data['items'] as List)
          .map((i) => TagData.fromJson(i))
          .toList();
      if (Hive.box<TagData>('tagBox').isEmpty) {
        for (var item in tags) {
          Hive.box<TagData>('tagBox').put(item.sid, item);
        }
      }
      return tags;
    } on DioException catch (e) {
      rethrow;
    }
  }
}