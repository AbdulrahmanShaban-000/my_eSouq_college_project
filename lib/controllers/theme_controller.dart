import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final isDark = true.obs;

  void toggleTheme(bool value) {
    isDark.value = value;

    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }
}
