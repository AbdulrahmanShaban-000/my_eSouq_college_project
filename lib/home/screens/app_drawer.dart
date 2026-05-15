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
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ================= HEADER =================
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(
                  vertical: 25,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Obx(() {
                  final name = authController.name.value;
                  final image = authController.imagePath.value;

                  return Column(
                    children: [
                      // صورة المستخدم
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white24,
                          backgroundImage: image.isNotEmpty
                              ? FileImage(File(image))
                              : null,
                          child: image.isEmpty
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 42,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        "hi".tr + (name.isEmpty ? " Guest" : " $name"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "my_esouq".tr,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                }),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  color: Colors.white.withOpacity(0.12),
                  thickness: 1,
                ),
              ),

              const SizedBox(height: 10),

              // ================= ITEMS =================
              _item(Icons.home_rounded, 'home'.tr, '/home'),
              _item(Icons.shopping_cart_rounded, 'cart'.tr, '/cart'),
              _item(Icons.person_rounded, 'profile'.tr, '/profile'),
              _item(Icons.favorite_rounded, 'favourites'.tr, '/favourites'),

              const Spacer(),

              // ================= LOGOUT =================
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async {
                    Get.back();
                    authController.logout();
                    Get.offAll(() => const LoginScreen());
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.redAccent.withOpacity(0.12),
                      border: Border.all(
                        color: Colors.redAccent.withOpacity(0.35),
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
      ),
    );
  }

  Widget _item(IconData icon, String title, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white10,
          highlightColor: Colors.white10,
          onTap: () {
            Get.back();
            Get.toNamed(route);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: EdgeInsets.zero,

              // ✅ لون أيقونات الـ Drawer أبيض
              leading: Icon(icon, color: Colors.white, size: 26),

              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white54,
                size: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
