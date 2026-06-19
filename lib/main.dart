import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/auth/screens/login_screen.dart';
import 'package:zad/bindings/app_bindings.dart';
import 'package:zad/home/screens/cart_page.dart';
import 'package:zad/home/screens/checking_out.dart';
import 'package:zad/home/screens/favourites_page.dart';
import 'package:zad/home/screens/home_page.dart';
import 'package:zad/home/screens/profile_page.dart';
import 'package:zad/locale/my_locale.dart';
import 'package:zad/services/storage_service.dart';
import 'package:zad/splash/splash_screen.dart';
import 'package:zad/controllers/theme_controller.dart'; 
import 'package:zad/home/screens/track_order_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final lang = await StorageService.getLanguage();

  runApp(MyApp(lang: lang));
}

class MyApp extends StatelessWidget {
  final String lang;

  const MyApp({super.key, required this.lang});

  
  static final ThemeData customLightTheme = ThemeData.light().copyWith(
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[50], 
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
   
    final ThemeController themeController = Get.put(ThemeController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'zad',

      // Language configuration
      locale: Locale(lang),
      fallbackLocale: const Locale('en'),
      translations: MyLocale(),

     
      theme: customLightTheme,
      darkTheme: customDarkTheme,

      
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
        GetPage(name: '/track-order', page: () => const TrackOrderPage()),
      ],
    );
  }
}
