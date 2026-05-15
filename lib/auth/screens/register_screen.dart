import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_esouq/controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool acceptTerms = false;

  File? imageFile;

  final AuthController authController = Get.find<AuthController>();

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!acceptTerms) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Accept terms first")));
      return;
    }

    if (password.text != confirm.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    await authController.setUser(
      name: name.text,
      phone: phone.text,
      email: email.text,
      image: imageFile?.path ?? '',
    );

    setState(() => isLoading = false);

    Navigator.pop(context);
  }

  InputDecoration _input(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      suffixIcon: suffix,
      fillColor: Colors.white.withOpacity(0.08),
      labelStyle: const TextStyle(color: Colors.white70),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
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
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // صورة المستخدم
                  GestureDetector(
                    onTap: pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white24,
                          backgroundImage: imageFile != null
                              ? FileImage(imageFile!)
                              : null,
                          child: imageFile == null
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "create_account".tr,
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
                          controller: name,
                          style: const TextStyle(color: Colors.white),
                          decoration: _input("name".tr, Icons.person),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? "Required" : null,
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: phone,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white),
                          decoration: _input("phone".tr, Icons.phone),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? "Required" : null,
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: email,
                          style: const TextStyle(color: Colors.white),
                          decoration: _input("email".tr, Icons.email),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? "Required" : null,
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: password,
                          obscureText: obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: _input(
                            "password".tr,
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
                          validator: (v) =>
                              (v == null || v.isEmpty) ? "Required" : null,
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: confirm,
                          obscureText: obscureConfirm,
                          style: const TextStyle(color: Colors.white),
                          decoration: _input(
                            "password_confirm".tr,
                            Icons.lock,
                            suffix: IconButton(
                              icon: Icon(
                                obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: () => setState(
                                () => obscureConfirm = !obscureConfirm,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Required";
                            if (v != password.text) return "Not matched";
                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Checkbox(
                              value: acceptTerms,
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
                                    "create_account".tr,
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
