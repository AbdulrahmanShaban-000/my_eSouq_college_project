import 'package:dio/dio.dart';
import 'package:zad/services/storage_service.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // ignore errors reading token and continue without Authorization header
    }

    super.onRequest(options, handler);
  }
}
