import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_esouq/controllers/auth_controller.dart';
import 'package:my_esouq/controllers/profile_controller.dart';
import 'package:my_esouq/controllers/theme_controller.dart';
import 'package:my_esouq/theme/app_theme.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final ProfileController controller;
  late final AuthController authController;
  late final ThemeController themeController;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
    controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(authController: authController));

        themeController= Get.find<ThemeController>();
  }

  @override
  void dispose() {
    if (Get.isRegistered<ProfileController>()) {
      Get.delete<ProfileController>();
    }
    super.dispose();
  }

  Future<void> _pickLocalImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    controller.pickedImagePath.value = picked.path;
  }

  @override
  Widget build(BuildContext context) {
    // استخراج خصائص الثيم الحالي
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        decoration: AppTheme.background(themeController.isDark.value),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor:
                    Colors.transparent, // شفافة لتظهر الخلفية المتدرجة
                elevation: 0,
                centerTitle: true,
                title: Text(
                  'edit_profile'.tr,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface, // ديناميكي
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Obx(() {
                    final hasLocalImage =
                        controller.pickedImagePath.value.isNotEmpty;
                    final imageValue = hasLocalImage
                        ? File(controller.pickedImagePath.value)
                        : null;

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        // خلفية الحاوية تتكيف تلقائياً مع النص لتعطي تباين ممتاز
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.05,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                backgroundImage: hasLocalImage
                                    ? FileImage(imageValue!)
                                    : (authController.imagePath.value.isNotEmpty
                                          ? FileImage(
                                              File(
                                                authController.imagePath.value,
                                              ),
                                            )
                                          : const NetworkImage(
                                                  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
                                                )
                                                as ImageProvider),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      authController.name.value.isNotEmpty
                                          ? authController.name.value
                                          : 'User',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    OutlinedButton.icon(
                                      onPressed: _pickLocalImage,
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.2),
                                        ),
                                        foregroundColor:
                                            theme.colorScheme.onSurface,
                                      ),
                                      icon: const Icon(Icons.image_outlined),
                                      label: Text('choose_image'.tr),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Form(
                            key: controller.formKey,
                            child: Column(
                              children: [
                                // حقل الاسم
                                TextFormField(
                                  controller: controller.nameController,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'name'.tr,
                                    labelStyle: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.03),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  validator: controller.validateName,
                                ),
                                const SizedBox(height: 12),
                                // حقل الهاتف
                                TextFormField(
                                  controller: controller.phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'phone'.tr,
                                    labelStyle: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.03),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  validator: controller.validatePhone,
                                ),
                                const SizedBox(height: 12),
                                // حقل البريد الإلكتروني
                                TextFormField(
                                  controller: controller.emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'email'.tr,
                                    labelStyle: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.03),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  validator: controller.validateEmail,
                                ),
                                const SizedBox(height: 20),
                                // زر الحفظ
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      if (controller.formKey.currentState
                                              ?.validate() ??
                                          false) {
                                        try {
                                          await controller.saveProfile();
                                          Get.back();
                                          Get.snackbar(
                                            'Edit Profile',
                                            'Profile updated',
                                            backgroundColor: theme
                                                .colorScheme
                                                .inverseSurface,
                                            colorText: theme
                                                .colorScheme
                                                .onInverseSurface,
                                          );
                                        } catch (_) {
                                          Get.snackbar(
                                            'Edit Profile',
                                            'Failed to update profile',
                                            backgroundColor: theme
                                                .colorScheme
                                                .errorContainer,
                                            colorText: theme
                                                .colorScheme
                                                .onErrorContainer,
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.save_outlined),
                                    label: Text('save'.tr),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor:
                                          theme.colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // زر الإلغاء
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: OutlinedButton.icon(
                                    onPressed: () => Get.back(),
                                    icon: const Icon(Icons.cancel_outlined),
                                    label: Text('cancel'.tr),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.2),
                                      ),
                                      foregroundColor:
                                          theme.colorScheme.onSurface,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
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
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}
