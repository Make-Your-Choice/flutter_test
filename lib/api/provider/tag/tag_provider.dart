import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../model/tag/tag.dart';
import '../../service/api_service.dart';
import '../connection state/connection_state_provider.dart';

part 'tag_provider.g.dart';

@Riverpod()
class Tag extends _$Tag {
  @override
  Future<List<TagData>> build() async {
    return fetchTags();
  }

  Future<List<TagData>> fetchTags() async {
    var service = await ApiService.create();
    List<TagData> content;
    try {
      content = await service.getTags();
      ref.watch(connectionStateProvider.notifier).fetchNewState(true);
      return content;
    } on DioException catch(e) {
      if(e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout) {
        ref.watch(connectionStateProvider.notifier).fetchNewState(false);
        return Hive.box<TagData>('tagBox').values.toList();
      } else {
        rethrow;
      }
    }
  }
}