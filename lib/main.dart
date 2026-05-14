import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_esouq/bindings/app_bindings.dart';
import 'package:my_esouq/locale/my_locale.dart';
import 'package:my_esouq/services/storage_service.dart';
import 'package:my_esouq/home/screens/home_page.dart';
import 'package:my_esouq/auth/screens/login_screen.dart';
import 'package:my_esouq/splash/splash_screen.dart';
import 'package:my_esouq/home/screens/cart_page.dart';
import 'package:my_esouq/home/screens/favourites_page.dart';
import 'package:my_esouq/home/screens/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isLoggedIn = await StorageService.isLoggedIn();
  final lang = await StorageService.getLanguage();

  runApp(MyApp(isLoggedIn: isLoggedIn, lang: lang));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String lang;

  const MyApp({super.key, required this.isLoggedIn, required this.lang});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // 🌍 Language
      locale: Locale(lang),
      fallbackLocale: const Locale('en'),
      translations: MyLocale(),

      title: "my_esouq",

      
      initialBinding: AppBinding(),

      initialRoute: '/',

      getPages: [
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/profile', page: () => const ProfilePage()),
        GetPage(name: '/cart', page: () =>   CartPage()),
        GetPage(name: '/favourites', page: () =>   FavouritesPage()),
      ],
    );
  }
}
