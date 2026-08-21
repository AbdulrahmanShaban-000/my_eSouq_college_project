import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/controllers/auth_controller.dart';
import 'package:zad/controllers/recent_orders_controller.dart';
import 'package:zad/screens/app_drawer.dart';
import 'package:zad/auth/screens/login_screen.dart';
import 'package:zad/screens/cart_page.dart';
import 'package:zad/screens/favourites_page.dart';
import 'package:zad/home/screens/home_page.dart';
import 'package:zad/screens/nav_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEnabled = true;

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final RecentOrdersController recentOrdersController =
        Get.find<RecentOrdersController>();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: AppDrawer(),
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0F2027),
                    const Color(0xFF203A43),
                    const Color(0xFF2C5364),
                  ]
                : [Colors.grey[50]!, Colors.grey[200]!, Colors.grey[300]!],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'profile'.tr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    final newLang = Get.locale?.languageCode == 'en'
                        ? 'ar'
                        : 'en';
                    Get.updateLocale(Locale(newLang));
                  },
                  icon: Icon(
                    Icons.language,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            // USER INFO
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.05,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.08,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authController.first_name.value.isNotEmpty
                                    ? authController.first_name.value
                                    : 'User',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                authController.last_name.value.isNotEmpty
                                    ? authController.last_name.value
                                    : 'No email',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            // ACCOUNT INFO
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
                child: Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'account_info'.tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.phone,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          authController.phone.value.isNotEmpty
                              ? authController.phone.value
                              : 'No phone',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        subtitle: Text(
                          'phone'.tr,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.email,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          authController.last_name.value.isNotEmpty
                              ? '${authController.first_name.value} ${authController.last_name.value}'
                              : 'No email',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            if (authController.isLoggedIn.value)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.toNamed('/settings'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.settings_outlined),
                      label: Text('settings'.tr),
                    ),
                  ),
                ),
              ),

            // ORDERS TITLE
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'orders'.tr,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),

            // RECENT ORDERS
            Obx(() {
              if (recentOrdersController.recentOrders.isEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.05,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.08,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                          size: 50,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Recent Orders',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = recentOrdersController.recentProducts[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.05,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.08,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: product.getImageUrl(),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            placeholder: (c, url) => Container(
                              width: 60,
                              height: 60,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.1,
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (c, url, e) => Container(
                              width: 60,
                              height: 60,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.1,
                              ),
                              child: Icon(
                                Icons.broken_image,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Price: ${product.price} USD',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }, childCount: recentOrdersController.recentOrders.length),
              );
            }),

            // SETTINGS TITLE
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'settings'.tr,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.notifications,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        'notifications'.tr,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                      trailing: Switch(
                        value: isEnabled,
                        activeThumbColor: theme.colorScheme.primary,
                        onChanged: (value) {
                          setState(() {
                            isEnabled = value;
                          });
                        },
                      ),
                    ),
                    Divider(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.08,
                      ),
                      height: 1,
                    ),
                    Obx(() {
                      if (authController.isLoggedIn.value) {
                        return ListTile(
                          leading: const Icon(
                            Icons.logout,
                            color: Colors.redAccent,
                          ),
                          title: Text(
                            'logout'.tr,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          onTap: () async {
                            await authController.logout();
                            Get.offAll(() => const LoginScreen());
                          },
                        );
                      } else {
                        return Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.login,
                                color: theme.colorScheme.primary,
                              ),
                              title: Text(
                                'login'.tr,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              onTap: () {
                                Get.to(() => const LoginScreen());
                              },
                            ),
                          ],
                        );
                      }
                    }),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offAll(() => HomePage());
              break;
            case 1:
              Get.offAll(() => FavouritesPage());
              break;
            case 2:
              Get.offAll(() => CartPage());
              break;
          }
        },
      ),
    );
  }
}
