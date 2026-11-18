import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/error/expentions.dart';
import 'package:fantasy/core/config/app_config.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'application/json',
        },
      ),
    );

    if (kDebugMode && AppConfig.isDevelopment) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          error: true,
          requestHeader: false,
          responseBody: false,
          responseHeader: false,
          request: true,
        ),
      );
    }
  }

  Future get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParams);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  Future<List<Map<String, dynamic>>> getList(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParams);
      final data = response.data;
      if (data is! List) {
        throw const FormatException('Expected a list response from the API.');
      }
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } on DioException catch (e) {
      handleDioException(e);
      rethrow;
    }
  }

  void debugPrint(String s) {
    // ignore: avoid_print
    print('[FPL] $s');
  }
}
