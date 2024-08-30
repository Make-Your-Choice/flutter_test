import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../service/api_service.dart';
import '../connection state/connection_state_provider.dart';

part 'token_state_provider.g.dart';

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
      ref.watch(connectionStateProvider.notifier).fetchNewState(true);
      return isPresent;
    } on DioException catch (e) {
      if(e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout) {
        ref.watch(connectionStateProvider.notifier).fetchNewState(false);
        rethrow;
      } else {
        rethrow;
      }
    }
  }

  Future<bool> logOut() async {
    var service = await ApiService.create();
    bool isLoggedOut = await service.logOut();
    return isLoggedOut;
  }
}