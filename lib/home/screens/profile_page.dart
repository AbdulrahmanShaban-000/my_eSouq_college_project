import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_esouq/controllers/auth_controller.dart';
import 'package:my_esouq/home/screens/app_drawer.dart';
import 'package:my_esouq/auth/screens/login_screen.dart';
import 'package:my_esouq/home/screens/cart_page.dart';
import 'package:my_esouq/home/screens/favourites_page.dart';
import 'package:my_esouq/home/screens/home_page.dart';
import 'package:my_esouq/home/screens/nav_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: const Color(0xFF0F2027),
              elevation: 0,
              centerTitle: true,
              title: Text(
                'profile'.tr,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    if (Get.locale?.languageCode == 'en') {
                      Get.updateLocale(const Locale('ar'));
                    } else {
                      Get.updateLocale(const Locale('en'));
                    }
                  },
                  icon: const Icon(Icons.language, color: Colors.white),
                ),
              ],
            ),

            /// 🔥 USER INFO FROM AUTH CONTROLLER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage:
                              authController.imagePath.value.isNotEmpty
                              ? FileImage(File(authController.imagePath.value))
                              : const NetworkImage(
                                      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
                                    )
                                    as ImageProvider,
                        ),
                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authController.name.value.isNotEmpty
                                    ? authController.name.value
                                    : "User",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                authController.email.value.isNotEmpty
                                    ? authController.email.value
                                    : "No email",
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            Get.snackbar('Edit Profile', 'Coming soon');
                          },
                          icon: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            /// 🔹 ACCOUNT INFO
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'account_info'.tr,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ListTile(
                        leading: const Icon(
                          Icons.phone,
                          color: Colors.blueAccent,
                        ),
                        title: Text(
                          authController.phone.value.isNotEmpty
                              ? authController.phone.value
                              : 'No phone',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'phone'.tr,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),

                      ListTile(
                        leading: const Icon(
                          Icons.email,
                          color: Colors.blueAccent,
                        ),
                        title: Text(
                          authController.email.value.isNotEmpty
                              ? authController.email.value
                              : 'No email',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'email'.tr,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            /// 🔹 ORDERS (كما هي)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'orders'.tr,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=80',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cotton Shirt',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '#ORD100',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        '45 \$',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }, childCount: 5),
            ),

            /// 🔹 SETTINGS
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'settings'.tr,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white.withOpacity(0.05),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.notifications,
                        color: Colors.blueAccent,
                      ),
                      title: Text(
                        'notifications'.tr,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Switch(value: true, onChanged: (v) {}),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        'logout'.tr,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      onTap: () => Get.offAll(() => const LoginScreen()),
                    ),
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
              Get.offAll(() => const HomePage());
              break;
            case 1:
              Get.offAll(() =>   FavouritesPage());
              break;
            case 2:
              Get.offAll(() =>   CartPage());
              break;
          }
        },
      ),
    );
  }
}
