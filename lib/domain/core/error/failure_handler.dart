import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:employee_management/domain/core/error/exceptions.dart';
import 'package:employee_management/domain/core/error/failures.dart';

class FailureHandler {
  static AppFailure handleFailure(Object error) {
    if (error is ServerException) {
      return ServerFailure(error.message);
    }
    if (error is NetworkException) {
      return NetworkFailure(error.message);
    }
    if (error is CacheException) {
      return CacheFailure(error.message);
    }
    if (error is AuthException) {
      return AuthFailure(error.message);
    }
    if (error is SocketException) {
      return const NetworkFailure();
    }
    if (error is TimeoutException) {
      return const NetworkFailure('Connection timed out');
    }
    if (error is DioException) {
      return _handleDioError(error);
    }
    return UnknownFailure(error.toString());
  }

  static AppFailure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timed out');
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        final message = error.response?.statusMessage ?? 'Server error';
        return ServerFailure('$message ($statusCode)');
      default:
        return const UnknownFailure();
    }
  }
}
