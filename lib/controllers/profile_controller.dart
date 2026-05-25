import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:my_esouq/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  ProfileController({required this.authController});

  final AuthController authController;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final RxString pickedImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    syncFromAuth();
  }

  void syncFromAuth() {
    nameController.text = authController.name.value;
    phoneController.text = authController.phone.value;
    emailController.text = authController.email.value;
    pickedImagePath.value = authController.imagePath.value;
  }

  String? validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Name is required';
    if (v.length < 2) return 'Name is too short';
    return null;
  }

  String? validatePhone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Phone is required';
    if (v.length < 8) return 'Phone is invalid';
    return null;
  }

  String? validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(v)) return 'Email is invalid';
    return null;
  }

  Future<void> saveProfile() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final image = pickedImagePath.value;

    await authController.setUser(
      name: name,
      phone: phone,
      email: email,
      image: image,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
