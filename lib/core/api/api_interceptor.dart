import 'package:dio/dio.dart';
import 'package:zad/services/storage_service.dart';
import 'package:get/get.dart';
import 'package:zad/controllers/auth_controller.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final authController = Get.find<AuthController>();
      final isLoggedIn = authController.isLoggedIn.value;

      if (isLoggedIn) {
        StorageService.getToken().then((token) {
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        });
      } else {
        options.headers.remove('Authorization');
      }
    } catch (e) {
      print('⚠️ AuthController not found');
    }

    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      try {
        final authController = Get.find<AuthController>();
        if (authController.isLoggedIn.value) {
          authController.logout();
          print('🔴 User logged out due to 401');
        }
      } catch (e) {
        print('Error handling 401: $e');
      }
    }

    return handler.next(err);
  }
}
