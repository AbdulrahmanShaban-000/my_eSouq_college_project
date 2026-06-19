import 'package:dio/dio.dart';
import 'package:zad/core/errors/error_model.dart';

class ServerException implements Exception {
  final ErrorModel errorModel;
  ServerException({required this.errorModel});
}

void handleDioException(DioException e) {
  String parseServerMessage(dynamic responseData) {
    if (responseData == null) return '';
    if (responseData is String) return responseData;
    if (responseData is Map<String, dynamic>) {
      final message =
          responseData['message']?.toString() ??
          responseData['error']?.toString();
      if (message != null && message.isNotEmpty) return message;

      final errors = responseData['errors'];
      if (errors != null) {
        if (errors is String) return errors;
        if (errors is Map) {
          final messages = errors.entries
              .map((entry) {
                final value = entry.value;
                if (value is List) return value.join(' | ');
                if (value is Map) return value.values.join(' | ');
                return value.toString();
              })
              .where((s) => s.isNotEmpty)
              .join(' | ');
          if (messages.isNotEmpty) return messages;
        }
        if (errors is List)
          return errors.map((item) => item.toString()).join(' | ');
      }

      return responseData.toString();
    }
    if (responseData is List) {
      return responseData.map((item) => item.toString()).join(' | ');
    }
    return responseData.toString();
  }

  final responseData = e.response?.data;
  final serverMessage = parseServerMessage(responseData);

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
      final statusCode = e.response?.statusCode;

      // Debug: يساعدنا نعرف هل السيرفر بيرجع HTML/404/500 بدل JSON
      print('Dio badResponse statusCode=$statusCode');
      print('Dio badResponse responseData=${responseData.runtimeType}');
      print('Dio badResponse responseData=$responseData');

      if (serverMessage.isNotEmpty) {
        throw ServerException(
          errorModel: ErrorModel(
            errorMessage: serverMessage,
            statusCode: statusCode,
          ),
        );
      }

      switch (statusCode) {
        case 400:
          throw ServerException(
            errorModel: ErrorModel(
              errorMessage: 'Bad request',
              statusCode: 400,
            ),
          );
        case 401:
          throw ServerException(
            errorModel: ErrorModel(
              errorMessage: 'Unauthorized',
              statusCode: 401,
            ),
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
            errorModel: ErrorModel(
              errorMessage: 'Internal server error',
              statusCode: 5,
            ),
          );
        default:
          throw ServerException(
            errorModel: ErrorModel(
              errorMessage: 'Request failed',
              statusCode: statusCode,
            ),
          );
      }
    default:
      throw ServerException(
        errorModel: ErrorModel(errorMessage: 'An unexpected error occurred'),
      );
  }
}
