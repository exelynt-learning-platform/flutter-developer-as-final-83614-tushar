import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:employee_management/domain/core/constants/api_constants.dart';
import 'package:employee_management/domain/core/error/exceptions.dart';

class HttpService {
  late Dio _dio;

  Dio get dio => _dio;

  HttpService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  HttpService.withDio(Dio dio) : _dio = dio;

  Future<Response> get(String path) async {
    try {
      return await _dio.get(path);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    if (e.error is SocketException) {
      return NetworkException(message: 'No internet connection');
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return NetworkException(message: 'Connection timed out');
    }
    if (e.type == DioExceptionType.connectionError) {
      return NetworkException(message: 'No internet connection');
    }
    if (e.type == DioExceptionType.badResponse) {
      return ServerException(
        message: e.response?.statusMessage ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
    return ServerException(message: e.message ?? 'Unknown error');
  }
}
