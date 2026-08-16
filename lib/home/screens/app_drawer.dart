import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/auth/screens/login_screen.dart';
import 'package:zad/controllers/auth_controller.dart';
import 'package:zad/controllers/theme_controller.dart';
import 'package:zad/services/storage_service.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final AuthController authController = Get.find<AuthController>();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF102531) : const Color(0xFFF7F9FC),
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
                          vertical: 22,
                          horizontal: 18,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    const Color(0xFF1C3A4A),
                                    const Color(0xFF203A43),
                                    const Color(0xFF2C5364),
                                  ]
                                : [
                                    const Color(0xFFE8F1FF),
                                    const Color(0xFFF4F7FF),
                                    const Color(0xFFEDECFB),
                                  ],
                          ),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Obx(() {
                          final name = authController.first_name.value;

                          return Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primary.withValues(
                                        alpha: 0.7,
                                      ),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${'hi'.tr} ${name.isEmpty ? 'guest'.tr : name}',
                                      style: TextStyle(
                                        color: theme.textTheme.bodyLarge?.color,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'zad'.tr,
                                      style: TextStyle(
                                        color: theme.textTheme.bodyMedium?.color
                                            ?.withValues(alpha: 0.7),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Divider(color: theme.dividerColor, thickness: 1),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.02)
                              : Colors.black.withValues(alpha: 0.015),
                        ),
                        child: Column(
                          children: [
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
                            _item(context, Icons.settings, 'settings'.tr, '/settings'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// DARK MODE SWITCH
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        child: Obx(
                          () => Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.black.withValues(alpha: 0.04),
                              ),
                            ),
                            child: ListTile(
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
                        ),
                      ),

                      /// LANGUAGE SWITCHER
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.03)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04),
                          ),
                        ),
                        child: ListTile(
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
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.04),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
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
                      ),

                      const Spacer(),

                      /// AUTH BUTTONS
                      Obx(() {
                        if (authController.isLoggedIn.value) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () async {
                                Get.back();
                                await authController.logout();
                                Get.offAll(() => const LoginScreen());
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.12,
                                  ),
                                  border: Border.all(
                                    color: Colors.redAccent.withValues(
                                      alpha: 0.35,
                                    ),
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Get.back();
                                      Get.to(() => const LoginScreen());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'login'.tr,
                                      style: TextStyle(
                                        color: theme.colorScheme.onPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Get.back();
                                      Get.toNamed('/register');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          theme.colorScheme.primary,
                                      side: BorderSide(
                                        color: theme.colorScheme.primary,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'register'.tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }),
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

    final isSelected = route == Get.currentRoute;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Get.back();
            Get.toNamed(route);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              border: isSelected
                  ? Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    )
                  : null,
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.12)
                      : (theme.brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.03)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.iconTheme.color,
                  size: 22,
                ),
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.iconTheme.color?.withValues(alpha: 0.5),
                size: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
