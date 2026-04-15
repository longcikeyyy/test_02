import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../errors/app_exception.dart';

class ApiClient {
  ApiClient({required String? token})
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

  final Dio _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data;
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  AppException _mapException(DioException error) {
    final statusCode = error.response?.statusCode;
    final serverMessage = _extractServerMessage(error.response?.data);

    if (statusCode == 400) {
      return AppException(
        serverMessage ?? 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.',
        statusCode: statusCode,
      );
    }
    if (statusCode == 401) {
      return const AppException(
        'Phiên đăng nhập hết hạn hoặc thông tin đăng nhập không đúng.',
        statusCode: 401,
      );
    }
    if (statusCode == 404) {
      return AppException(
        serverMessage ?? 'Không tìm thấy dữ liệu yêu cầu.',
        statusCode: statusCode,
      );
    }
    if (statusCode == 500) {
      return const AppException(
        'Hệ thống tạm thời gián đoạn. Vui lòng thử lại sau.',
        statusCode: 500,
      );
    }

    return AppException(
      serverMessage ?? error.message ?? 'Không thể kết nối đến máy chủ.',
      statusCode: statusCode,
    );
  }

  String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }
}
