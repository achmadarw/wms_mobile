import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:wms_mobile/config/api_config.dart';

class ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger();

  ApiClient({String? token}) {
    _dio = ApiConfig.createDio();

    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }

    // Add logging interceptor
    _dio.interceptors.add(
      LoggingInterceptor(logger: _logger),
    );
  }

  // Generic GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return fromJson != null ? fromJson(response.data) : response.data as T;
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('GET Error: $path', error: e);
      throw _handleError(e);
    }
  }

  // Generic POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return fromJson != null ? fromJson(response.data) : response.data as T;
      } else {
        throw Exception('Failed to post data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('POST Error: $path', error: e);
      throw _handleError(e);
    }
  }

  // Generic PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return fromJson != null ? fromJson(response.data) : response.data as T;
      } else {
        throw Exception('Failed to update data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('PUT Error: $path', error: e);
      throw _handleError(e);
    }
  }

  // Generic DELETE request
  Future<bool> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      _logger.e('DELETE Error: $path', error: e);
      throw _handleError(e);
    }
  }

  // Handle errors
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      if (statusCode == 401) {
        return Exception('Unauthorized - Please login again');
      } else if (statusCode == 403) {
        return Exception('Forbidden - Access denied');
      } else if (statusCode == 404) {
        return Exception('Not found');
      } else if (statusCode == 500) {
        return Exception('Server error - Please try again');
      } else {
        return Exception('Error: ${error.response!.data}');
      }
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return Exception('Connection timeout - Check your internet connection');
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return Exception('Response timeout - Try again');
    } else {
      return Exception('Connection error - ${error.message}');
    }
  }

  // Update token
  void updateToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear token
  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }
}

/// Logging Interceptor
class LoggingInterceptor extends Interceptor {
  final Logger logger;

  LoggingInterceptor({required this.logger});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.d(
      'REQUEST: ${options.method} ${options.path}',
      error: options.data,
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d(
      'RESPONSE: ${response.statusCode} ${response.requestOptions.path}',
      error: response.data,
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e(
      'ERROR: ${err.message}',
      error: err.response?.data,
    );
    super.onError(err, handler);
  }
}
