import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as Storage;
import 'package:project1/api/api_service.dart';

import '../model/token/token.dart';

class ApiInterceptor extends Interceptor {

  Future<Token> get authToken async {
    Storage.FlutterSecureStorage storage = const Storage.FlutterSecureStorage();
    String? acsToken = await storage.read(key: 'access_token');
    String? refToken = await storage.read(key: 'refresh_token');
    return Token(acsToken!, refToken!);
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      Storage.FlutterSecureStorage storage = const Storage
          .FlutterSecureStorage();
      String? acsToken = await storage.read(key: 'access_token');
      String? refToken = await storage.read(key: 'refresh_token');
      if(acsToken != null && refToken != null) {
        Token token = Token(acsToken, refToken);
        // Token token = await authToken;
        options.headers.addAll({
          'Authorization': 'Bearer ${token.accessToken}',
        });
        return super.onRequest(options, handler);
      } else {
        throw DioException(requestOptions: options, response: Response(
                requestOptions: options,
                statusCode: 500,
                statusMessage: 'Token does not exist!'));
        // throw DioException(
        //     requestOptions: RequestOptions(),
        //     response: Response(
        //         requestOptions: RequestOptions(),
        //         statusCode: 500,
        //         statusMessage: 'Token does not exist!'));
      }
    } on DioException catch (e) {
      print(e.response);
      rethrow;
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
    print('Response: ${response.statusCode} - ${response.statusMessage}');
    return;
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    super.onError(err, handler);
    print('onErr: ${err.response!}');
    if (err.response?.data['code'] == 1 ||
        err.response?.data['code'] == 2 ||
        err.response?.data['code'] == 101 ||
        err.response?.statusCode == 401) {
      if (err.response?.data['code'] == 1) {
        await disposeToken();
      }else if(err.response?.data['code'] == 101 ||
          err.response?.statusCode == 401) {
        ApiService service = await ApiService.create();
        await service.logOut();
        // handler.next(err);
      } else if (err.response?.data['code'] == 2) {
        try {
          await refreshToken();
          return handler.resolve(await _retryRequest(err.requestOptions));
        } on DioException catch (e) {
          print('onErrErr: ${e.response?.statusCode}');
          // handler.reject(err);
          // handler.next(e);
        }
      }
      return;
    }
    handler.next(err);
  }

  Future<void> disposeToken() async {
    Storage.FlutterSecureStorage storage = const Storage.FlutterSecureStorage();
    await storage.deleteAll();
  }

  Future<Token> refreshToken() async {
    try {
      // Token token = await authToken;
      Storage.FlutterSecureStorage storage = const Storage
          .FlutterSecureStorage();
      String? acsToken = await storage.read(key: 'access_token');
      String? refToken = await storage.read(key: 'refresh_token');
      if(acsToken != null && refToken != null) {
        Token token = Token(acsToken, refToken);
        Response<dynamic> response;
        Dio dioRefresh = Dio(BaseOptions(
            baseUrl: 'https://test-mobile.estesis.tech/api/v1',
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              HttpHeaders.acceptHeader: 'application/json'
            }));

        response = await dioRefresh
            .post('/refresh_token', queryParameters: {'refresh_token': token.refreshToken});
        if (response.statusCode == 200) {
          Token newToken = Token.fromJson(response.data);
          Storage.FlutterSecureStorage storage =
          const Storage.FlutterSecureStorage();
          await storage.deleteAll();
          await storage.write(key: 'access_token', value: newToken.accessToken);
          await storage.write(key: 'refresh_token', value: newToken.refreshToken);
          return Token.fromJson(response.data);
        } else {
          throw DioException(
              requestOptions: RequestOptions(),
              response: Response(
                  requestOptions: RequestOptions(),
                  statusCode: 500,
                  statusMessage: 'Could not refresh token'));
        }
      } else {
        throw DioException(
            requestOptions: RequestOptions(),
            response: Response(
                requestOptions: RequestOptions(),
                statusCode: 500,
                statusMessage: 'Token does not exist'));
      }
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    Token token = await authToken;
    final options = Options(
        method: requestOptions.method,
        headers: {'Authorization': 'Bearer $token'});
    Dio dio = Dio(BaseOptions(
        baseUrl: 'https://test-mobile.estesis.tech/api/v1',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        }));
    return dio.request<dynamic>(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options);
  }
}
