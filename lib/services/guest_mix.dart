
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

 
  Future<String?> getToken() async {
    try {
      final authController = Get.find<AuthController>();
      return await authController.getToken();
    } catch (e) {
      return null;
    }
  }

  
  Future<bool> hasValidToken() async {
    try {
      final authController = Get.find<AuthController>();
      return await authController.checkValidToken();
    } catch (e) {
      return false;
    }
  }

  
  Future<bool> checkLoginStatus() async {
    return await StorageService.isLoggedIn();
  }

 
  Future<String?> getStoredToken() async {
    return await StorageService.getToken();
  }
}
