import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_esouq/controllers/auth_controller.dart';
import 'package:my_esouq/auth/screens/login_screen.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Column(
          children: [
            // 🔥 HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 20),
              child: Obx(() {
                final name = authController.name.value;
                final image = authController.imagePath.value;

                return Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white24,
                      backgroundImage: image.isNotEmpty
                          ? FileImage(File(image))
                          : null,
                      child: image.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            )
                          : null,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "hi".tr + " ${name.isEmpty ? ' Guest ' : name}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "my_esouq".tr,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                );
              }),
            ),

            const Divider(color: Colors.white24, thickness: 0.5),

            // 🔹 ITEMS
            _item(Icons.home, 'home'.tr, '/home'),
            _item(Icons.shopping_cart, 'cart'.tr, '/cart'),
            _item(Icons.person, 'profile'.tr, '/profile'),
            _item(Icons.favorite, 'favourites'.tr, '/favourites'),

            const Spacer(),

            // 🔴 LOGOUT
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 60),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  Get.back();
                  authController.logout();
                  Get.offAll(() => const LoginScreen());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.redAccent.withOpacity(0.15),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text(
                        "logout".tr,
                        style: TextStyle(
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
    );
  }

  Widget _item(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        Get.back();
        Get.toNamed(route);
      },
    );
  }
}
