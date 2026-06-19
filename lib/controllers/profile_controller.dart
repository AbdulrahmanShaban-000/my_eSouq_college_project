import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:zad/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  ProfileController({required this.authController});

  final AuthController authController;

  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final phoneController = TextEditingController();
  final lastNameController = TextEditingController();

  final RxString pickedImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    syncFromAuth();
  }

  void syncFromAuth() {
    firstNameController.text = authController.first_name.value;
    phoneController.text = authController.phone.value;
    lastNameController.text = authController.last_name.value;
   
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

    final firstName = firstNameController.text.trim();
    final phone = phoneController.text.trim();
    final lastName = lastNameController.text.trim();
 

    await authController.setUser(
      first_name: firstName,
      phone: phone,
      last_name: lastName,
      
    );
  }

  @override
  void onClose() {
    firstNameController.dispose();
    phoneController.dispose();
    lastNameController.dispose();
    super.onClose();
  }
}
