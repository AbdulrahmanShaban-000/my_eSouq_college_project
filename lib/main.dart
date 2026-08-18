import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/auth/screens/login_screen.dart';
import 'package:zad/bindings/app_bindings.dart';
import 'package:zad/screens/cart_page.dart';
import 'package:zad/screens/checking_out.dart';
import 'package:zad/screens/favourites_page.dart';
import 'package:zad/home/screens/home_page.dart';
import 'package:zad/screens/profile_page.dart';
import 'package:zad/screens/settings_page.dart';
import 'package:zad/locale/my_locale.dart';
import 'package:zad/services/storage_service.dart';
import 'package:zad/splash/splash_screen.dart';
import 'package:zad/controllers/theme_controller.dart';
import 'package:zad/screens/track_order_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final lang = await StorageService.getLanguage();
  final isDark = await StorageService.getThemeMode();

  runApp(MyApp(lang: lang, isDark: isDark));
}

class MyApp extends StatelessWidget {
  final String lang;
  final bool isDark;

  const MyApp({super.key, required this.lang, required this.isDark});

  static final ThemeData customLightTheme = ThemeData.light().copyWith(
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[50],
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black45,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),

    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );

  static final ThemeData customDarkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.blueAccent,
    scaffoldBackgroundColor: const Color(0xFF0F2027),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0F2027),
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.white54,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F2027),
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    cardTheme: const CardThemeData(
      color: Color(0xFF1A2A3A),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());

    themeController.isDark.value = isDark;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'zad',

      // Language configuration
      locale: Locale(lang),
      fallbackLocale: const Locale('en'),
      translations: MyLocale(),

      // Theme configuration
      theme: customLightTheme,
      darkTheme: customDarkTheme,

      // Theme mode from controller
      themeMode: themeController.isDark.value
          ? ThemeMode.dark
          : ThemeMode.light,

      initialBinding: AppBinding(),
      initialRoute: '/',

      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/profile', page: () => const ProfilePage()),
        GetPage(name: '/settings', page: () => const SettingsPage()),
        GetPage(name: '/cart', page: () => CartPage()),
        GetPage(name: '/favourites', page: () => FavouritesPage()),
        GetPage(name: '/checkout', page: () => const CheckingOutPage()),
        GetPage(name: '/track-order', page: () => const TrackOrderPage()),
      ],
    );
  }
}
