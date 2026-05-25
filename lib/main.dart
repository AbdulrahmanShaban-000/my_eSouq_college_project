import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_esouq/auth/screens/login_screen.dart';
import 'package:my_esouq/bindings/app_bindings.dart';
import 'package:my_esouq/home/screens/cart_page.dart';
import 'package:my_esouq/home/screens/checking_out.dart';
import 'package:my_esouq/home/screens/favourites_page.dart';
import 'package:my_esouq/home/screens/home_page.dart';
import 'package:my_esouq/home/screens/profile_page.dart';
import 'package:my_esouq/locale/my_locale.dart';
import 'package:my_esouq/services/storage_service.dart';
import 'package:my_esouq/splash/splash_screen.dart';
import 'package:my_esouq/controllers/theme_controller.dart'; // تأكد من استيراد الـ ThemeController الخاص بك

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final lang = await StorageService.getLanguage();

  runApp(MyApp(lang: lang));
}

class MyApp extends StatelessWidget {
  final String lang;

  const MyApp({super.key, required this.lang});

  // 1. تعريف الثيم الفاتح بشكل صحيح خارج كتل البناء
  static final ThemeData customLightTheme = ThemeData.light().copyWith(
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[50], // اختياري: خلفية الـ Light Mode
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black45,
    ),
  );

  // 2. تعريف الثيم الداكن بشكل صحيح خارج كتل البناء
  static final ThemeData customDarkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.blueAccent,
    scaffoldBackgroundColor: const Color(
      0xFF0F2027,
    ), // نفس لون خلفية الـ Drawer والـ NavBar القديمة لتناسق التصميم
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0F2027),
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.white54,
    ),
  );

  @override
  Widget build(BuildContext context) {
    // جلب الـ ThemeController للتحكم بالوضع بشكل ديناميكي
    final ThemeController themeController = Get.put(ThemeController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'my_esouq',

      // Language configuration
      locale: Locale(lang),
      fallbackLocale: const Locale('en'),
      translations: MyLocale(),

      // Theme configuration (مررنا المتغيرات التي قمنا بتعريفها في الأعلى)
      theme: customLightTheme,
      darkTheme: customDarkTheme,

      // نستخدم Obx هنا ليقوم التطبيق بالتحول فوراً عند تغيير قيمة المفتاح في الـ Controller
      themeMode: themeController.isDark.value
          ? ThemeMode.dark
          : ThemeMode.light,

      initialBinding: AppBinding(),
      initialRoute: '/',

      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/profile', page: () => const ProfilePage()),
        GetPage(name: '/cart', page: () => CartPage()),
        GetPage(name: '/favourites', page: () => FavouritesPage()),
        GetPage(name: '/checkout', page: () => const CheckingOutPage()),
      ],
    );
  }
}
