import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as Storage;

import '../model/token/token.dart';

class ApiInterceptor extends Interceptor {
  // Dio dio = Dio(
  //     BaseOptions(baseUrl: 'https://test-mobile.estesis.tech/api/v1', headers: {
  //       HttpHeaders.contentTypeHeader: 'application/json',
  //       HttpHeaders.acceptHeader: 'application/json',
  //     }));

  Future<Token> get authToken async {
    Storage.FlutterSecureStorage storage = const Storage.FlutterSecureStorage();
    String? acsToken = await storage.read(key: 'access_token');
    String? refToken = await storage.read(key: 'refresh_token');
    return Token(acsToken!, refToken!);
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print('onReq: ${options.data}');
    try {
      Token token = await authToken;
      options.headers.addAll({
        'Authorization': 'Bearer ${token.accessToken}',
      });
      return super.onRequest(options, handler);
    } on DioException catch (e) {
      rethrow;
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
    print('onResp: ${response.statusCode}');
    return;
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    super.onError(err, handler);
    print('onErr: ${err.response?.statusCode}');
    if (err.response?.data['code'] == 1 || err.response?.data['code'] == 2 ||
    err.response?.data['code'] == 101) {
      if (err.response?.data['code'] == 1) {
        await disposeToken();
        // handler.next(err);
      } else if (err.response?.data['code'] == 2 || err.response?.data['code'] == 101) {
        try {
          await refreshToken();
          await _retryRequest(err.requestOptions);
        } on DioException catch (e) {
          // handler.reject(err);
          handler.next(err);

        }
      }
      return;
      // return;
    }
    handler.next(err);
  }

  Future<void> disposeToken() async {
    Storage.FlutterSecureStorage storage = const Storage.FlutterSecureStorage();
    await storage.deleteAll();
  }

  Future<Token> refreshToken() async {
    Token token = await authToken;
    Response<dynamic> response;
    Dio dioRefresh = Dio(BaseOptions(
        baseUrl: 'https://test-mobile.estesis.tech/api/v1',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json'
        }));
    // Dio dioRefresh = Dio(BaseOptions(
    //     baseUrl: 'https://test-mobile.estesis.tech/api/v1',
    //     headers: {
    //       HttpHeaders.contentTypeHeader: 'application/json',
    //       HttpHeaders.acceptHeader: 'application/json'
    //     }));

    // dioRefresh.options.baseUrl = 'https://test-mobile.estesis.tech/api/v1';
    // dioRefresh.options.contentType = Headers.formUrlEncodedContentType;
    try {
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
        // } else if (response.statusCode == 500 ||
        //     response.statusCode == 503 ||
        //     response.statusCode == 504) {
        //   throw DioException(
        //       requestOptions: RequestOptions(),
        //       response: Response(
        //           requestOptions: RequestOptions(),
        //           statusCode: 500,
        //           statusMessage: 'Tasks not found'
        //       )
        //   );
      } else {
        throw DioException(
            requestOptions: RequestOptions(),
            response: Response(
                requestOptions: RequestOptions(),
                statusCode: 500,
                statusMessage: 'Could not refresh token'));
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
