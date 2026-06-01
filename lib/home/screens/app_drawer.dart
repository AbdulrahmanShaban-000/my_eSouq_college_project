import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_esouq/auth/screens/login_screen.dart';
import 'package:my_esouq/controllers/auth_controller.dart';
import 'package:my_esouq/controllers/theme_controller.dart';
import 'package:my_esouq/services/storage_service.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final AuthController authController = Get.find<AuthController>();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      /// HEADER (User Profile Summary)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(
                          vertical: 25,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),

                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.04),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Obx(() {
                          final name = authController.name.value;
                          final image = authController.imagePath.value;

                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 15,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: isDark
                                      ? Colors.white24
                                      : Colors.black12,
                                  backgroundImage: image.isNotEmpty
                                      ? FileImage(File(image))
                                      : null,
                                  child: image.isEmpty
                                      ? Icon(
                                          Icons.person_rounded,
                                          size: 42,
                                          color: theme.iconTheme.color,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                '${'hi'.tr} ${name.isEmpty ? 'guest'.tr : name}',
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'my_esouq'.tr,
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(color: theme.dividerColor, thickness: 1),
                      ),

                      const SizedBox(height: 10),

                      /// MENU ITEMS
                      _item(context, Icons.home_rounded, 'home'.tr, '/home'),
                      _item(
                        context,
                        Icons.shopping_cart_rounded,
                        'cart'.tr,
                        '/cart',
                      ),
                      _item(
                        context,
                        Icons.person_rounded,
                        'profile'.tr,
                        '/profile',
                      ),
                      _item(
                        context,
                        Icons.favorite_rounded,
                        'favourites'.tr,
                        '/favourites',
                      ),

                      const SizedBox(height: 10),

                      /// DARK MODE SWITCH
                      Obx(
                        () => ListTile(
                          leading: Icon(
                            themeController.isDark.value
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            color: theme.iconTheme.color,
                          ),
                          title: Text(
                            themeController.isDark.value
                                ? 'Dark Mode'
                                : 'Light Mode',
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          trailing: Switch(
                            value: themeController.isDark.value,
                            onChanged: (value) {
                              themeController.toggleTheme(value);
                            },
                          ),
                        ),
                      ),

                      /// LANGUAGE SWITCHER
                      ListTile(
                        leading: Icon(
                          Icons.language,
                          color: theme.iconTheme.color,
                        ),
                        title: Text(
                          Get.locale?.languageCode == 'ar'
                              ? 'اللغة'
                              : 'Language',
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        trailing: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.05),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            final newLang = Get.locale?.languageCode == 'en'
                                ? 'ar'
                                : 'en';
                            await StorageService.setLanguage(newLang);
                            Get.updateLocale(Locale(newLang));
                          },
                          child: Text(
                            Get.locale?.languageCode == 'en' ? 'AR' : 'EN',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      /// LOGOUT BUTTON
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () async {
                            Get.back();
                            await authController.logout();
                            Get.offAll(() => const LoginScreen());
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.redAccent.withValues(alpha: 0.12),
                              border: Border.all(
                                color: Colors.redAccent.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.logout,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'logout'.tr,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.back();
            Get.toNamed(route);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(icon, color: theme.iconTheme.color, size: 26),
              title: Text(
                title,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: theme.iconTheme.color?.withValues(alpha: 0.5),
                size: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
