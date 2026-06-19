import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/controllers/auth_controller.dart';

import 'package:zad/home/screens/home_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstName = TextEditingController();
  final phone = TextEditingController();
  final lastName = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  bool acceptTerms = false;

  File? imageFile;

  final AuthController authController = Get.find<AuthController>();

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    authController.errorMessage.value = '';

    if (!acceptTerms) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('accept_terms_first'.tr)));
      return;
    }

    setState(() => isLoading = true);

    final success = await authController.register(
      firstName: firstName.text.trim(),
      lastName: lastName.text.trim(),
      mobileNumber: phone.text.trim(),
      password: password.text.trim(),
      passwordConfirmation: confirmPassword.text.trim(),
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('welcome'.tr)));
      Get.offAll(() => const HomePage());
      return;
    }

    final msg = authController.errorMessage.value.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg.isEmpty ? 'حدث خطأ غير متوقع' : msg)),
    );
  }

  InputDecoration _input(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      suffixIcon: suffix,
      fillColor: Colors.white.withValues(alpha: 0.08),
      labelStyle: const TextStyle(color: Colors.white70),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(color: Colors.orangeAccent),
    );
  }

  @override
  void dispose() {
    firstName.dispose();
    phone.dispose();
    lastName.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'create_account'.tr,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: firstName,
                          style: const TextStyle(color: Colors.white),
                          decoration: _input('first_name'.tr, Icons.person),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: lastName,
                          style: const TextStyle(color: Colors.white),
                          decoration: _input('last_name'.tr, Icons.person),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: phone,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white),
                          decoration: _input('phone'.tr, Icons.phone),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: password,
                          obscureText: obscurePassword,

                          style: const TextStyle(color: Colors.white),
                          decoration: _input(
                            'password'.tr,
                            Icons.lock,
                            suffix: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: () => setState(
                                () => obscurePassword = !obscurePassword,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v.length < 6) return 'Min 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: confirmPassword,
                          obscureText: obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: _input(
                            'password_confirm'.tr,
                            Icons.lock_outline,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v != password.text.trim()) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Checkbox(
                              value: acceptTerms,
                              activeColor: Colors.blueAccent,
                              onChanged: (v) =>
                                  setState(() => acceptTerms = v ?? false),
                            ),
                            Expanded(
                              child: Text(
                                'terms'.tr,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'create_account'.tr,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
