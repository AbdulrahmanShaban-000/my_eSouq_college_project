import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/services/storage_service.dart';

class ThemeController extends GetxController {
  final isDark = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    isDark.value = await StorageService.getThemeMode();
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme(bool value) {
    isDark.value = value;
    StorageService.setThemeMode(value); // حفظ الثيم في SharedPreferences
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  // دالة لعكس الثيم (تبديل)
  void switchTheme() {
    toggleTheme(!isDark.value);
  }

  // دالة للحصول على حالة الثيم الحالية
  bool get isDarkMode => isDark.value;
}
