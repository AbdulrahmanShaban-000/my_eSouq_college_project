import 'package:dio/dio.dart';
import 'package:my_esouq/core/errors/error_model.dart';

class ServerException implements Exception {
  final ErrorModel errorModel;
  ServerException({required this.errorModel});
}

void handleDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      throw ServerException(
        errorModel: ErrorModel(errorMessage: 'Connection timeout'),
      );
    case DioExceptionType.sendTimeout:
      throw ServerException(
        errorModel: ErrorModel(errorMessage: 'Send timeout'),
      );
    case DioExceptionType.receiveTimeout:
      throw ServerException(
        errorModel: ErrorModel(errorMessage: 'Receive timeout'),
      );
    case DioExceptionType.badResponse:
      switch (e.response?.statusCode) {
        case 400:
          throw ServerException(
            errorModel: ErrorModel(errorMessage: 'Bad request', statusCode: 400),
          );
        case 401:
          throw ServerException(
            errorModel: ErrorModel(errorMessage: 'Unauthorized', statusCode: 401),
          );
        case 403:
          throw ServerException(
            errorModel: ErrorModel(errorMessage: 'Forbidden', statusCode: 403),
          );
        case 404:
          throw ServerException(
            errorModel: ErrorModel(errorMessage: 'Not found', statusCode: 404),
          );
        case 500:
          throw ServerException(
            errorModel: ErrorModel(errorMessage: 'Internal server error', statusCode: 500),
          );
      
      }
    default:
      throw ServerException(
        errorModel: ErrorModel(errorMessage: 'An unexpected error occurred'),
      );
  }
}
