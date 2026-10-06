import 'package:dio/dio.dart';

import 'package:colabhealth/core/src/utils/app_logger.dart';
import 'package:colabhealth/data/src/model/res_base_model.dart';
import 'package:colabhealth/data/src/network/interceptor/logging_interceptor.dart';

typedef JsonPayLoad = Map<String, dynamic>;

class ApiClient {
  ApiClient._();

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
    ),
  );

  static void initialize() {
    _dio.interceptors.clear();
    _dio.interceptors.add(LoggingInterceptor());
  }

  static Future<ResBaseModel<T>> get<T>({
    required String url,
    T Function(dynamic)? fromJson,
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await _dio.get(url, queryParameters: query);
      return _ok(res, fromJson);
    } catch (e) {
      return _fail<T>(e);
    }
  }

  static Future<ResBaseModel<T>> post<T>({
    required String url,
    JsonPayLoad? body,
    T Function(dynamic)? fromJson,
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await _dio.post(url, data: body, queryParameters: query);
      return _ok(res, fromJson);
    } catch (e) {
      return _fail<T>(e);
    }
  }

  static ResBaseModel<T> _ok<T>(Response res, T Function(dynamic)? fromJson) {
    final code = res.statusCode ?? 0;
    if (code >= 200 && code < 300) {
      return ResBaseModel<T>(
        success: true,
        statusCode: code,
        data: fromJson != null ? fromJson(res.data) : res.data as T?,
      );
    }
    return ResBaseModel<T>(
      success: false,
      statusCode: code,
      error: 'Request failed ($code)',
    );
  }

  static ResBaseModel<T> _fail<T>(Object e) {
    AppLogger.error('ApiClient error', error: e);
    if (e is DioException) {
      final code = e.response?.statusCode ?? 0;
      final String message;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          message = 'Connection timed out. Please try again.';
          break;
        case DioExceptionType.connectionError:
          message = "You're not connected to the internet.";
          break;
        default:
          if (code == 401 || code == 403) {
            message = 'Invalid or missing API key.';
          } else if (code == 429) {
            message = 'Rate limit reached. Please try again later.';
          } else if (code >= 500) {
            message = 'Server error. Please try again later.';
          } else {
            message = 'Something went wrong. Please try again.';
          }
      }
      return ResBaseModel<T>(success: false, statusCode: code, error: message);
    }
    return ResBaseModel<T>(
      success: false,
      statusCode: 0,
      error: 'Something went wrong. Please try again.',
    );
  }
}
