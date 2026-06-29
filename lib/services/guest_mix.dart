// lib/core/mixins/guest_mixin.dart
import 'package:get/get.dart';
import 'package:zad/controllers/auth_controller.dart';
import 'package:zad/services/storage_service.dart';

mixin GuestMixin {
  bool get isLoggedIn {
    try {
      final authController = Get.find<AuthController>();
      return authController.isLoggedIn.value;
    } catch (e) {
      return false;
    }
  }

  // ✅ تعديل: استخدام الدالة getToken() بدلاً من token
  Future<String?> getToken() async {
    try {
      final authController = Get.find<AuthController>();
      return await authController.getToken();
    } catch (e) {
      return null;
    }
  }

  // ✅ تعديل: استخدام الدالة checkValidToken() بدلاً من hasValidToken
  Future<bool> hasValidToken() async {
    try {
      final authController = Get.find<AuthController>();
      return await authController.checkValidToken();
    } catch (e) {
      return false;
    }
  }

  // ✅ دالة للتحقق من حالة المستخدم من SharedPreferences مباشرة
  Future<bool> checkLoginStatus() async {
    return await StorageService.isLoggedIn();
  }

  // ✅ دالة للحصول على Token من SharedPreferences مباشرة
  Future<String?> getStoredToken() async {
    return await StorageService.getToken();
  }
}
