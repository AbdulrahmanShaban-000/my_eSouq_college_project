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
class RecentOrdersController extends GetxController {
  RxList<Map<String, dynamic>> recentOrders = <Map<String, dynamic>>[].obs;

  void addOrder(Map<String, dynamic> product) {
    recentOrders.insert(0, product);

    if (recentOrders.length > 10) {
      recentOrders.removeLast();
    }
  }

  void removeOrder(int id) {
    recentOrders.removeWhere((item) => item['id'] == id);
  }
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController authController = Get.find<AuthController>();

  final RecentOrdersController recentOrdersController = Get.put(
    RecentOrdersController(),
  );

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
              iconTheme: const IconThemeData(color: Colors.white),
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

            /// 🔥 USER INFO
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

            /// 🔹 ORDERS TITLE
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

            /// 🔥 RECENT ORDERS
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
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),

                    child: const Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          color: Colors.white54,
                          size: 50,
                        ),

                        SizedBox(height: 12),

                        Text(
                          'No Recent Orders',

                          style: TextStyle(
                            color: Colors.white70,
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
                  final product = recentOrdersController.recentOrders[index];

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
                            product['image'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                product['name'],

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                product['price'],

                                style: const TextStyle(color: Colors.white70),
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

                      onTap: () {
                        Get.back();

                        authController.logout();

                        Get.offAll(() => const LoginScreen());
                      },
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
