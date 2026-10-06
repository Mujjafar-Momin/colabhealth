import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:colabhealth/data/src/network/api_config.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (ApiConfig.hasKey) {
      options.headers['X-Api-Key'] = ApiConfig.apiNinjasKey;
    }
    _log('➡️ [${options.method}] ${options.uri}');
    if (options.data != null) _log('   body: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log('⬅️ (${response.statusCode}) ${response.requestOptions.uri}');
    _log('   data: ${jsonEncode(response.data)}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log('❌ (${err.response?.statusCode}) ${err.requestOptions.uri} → ${err.message}');
    super.onError(err, handler);
  }

  void _log(String message) {
    if (kDebugMode) log(message, name: '📘 ApiClient');
  }
}
