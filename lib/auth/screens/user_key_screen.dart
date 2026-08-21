import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/controllers/auth_controller.dart';
import 'package:zad/home/screens/home_page.dart';
import 'package:zad/services/storage_service.dart';

class UserKey extends StatefulWidget {
  final String? verificationId;

  const UserKey({super.key, this.verificationId});

  @override
  State<UserKey> createState() => _UserKeyState();
}

class _UserKeyState extends State<UserKey> {
  final _formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  bool isLoading = false;

  String get _verificationId =>
      widget.verificationId ?? authController.verificationId.value;

  void toggleLanguage() async {
    final newLang = Get.locale?.languageCode == 'en' ? 'ar' : 'en';
    await StorageService.setLanguage(newLang);
    Get.updateLocale(Locale(newLang));
  }

  void showAppInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFF122B36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
          ),
          child: AlertDialog(
            backgroundColor: const Color(0xFF122B36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'zad',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'app_description'.tr,
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
                const SizedBox(height: 12),
                Text(
                  '${'developed_by'.tr} Esouq Team',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
                child: const Text('موافق'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// استخراج (verification_id) و (code) من الرابط المنسوخ.
  ///
  /// مثال:
  /// http://localhost:8000/api/register?verification_id=49970073-8858-4c1e-a225-511d95388f62&code=004826
  Map<String, String> _parseVerificationLink(String input) {
    final result = <String, String>{};

    // عزل query string بعد علامة الاستفهام
    final queryStart = input.indexOf('?');
    String query = queryStart >= 0 ? input.substring(queryStart + 1) : input;

    // إن لم يوجد علامة ؟ فقد تكون فقط query params
    if (query.contains('verification_id=') || query.contains('code=')) {
      for (final pair in query.split('&')) {
        final parts = pair.split('=');
        if (parts.length == 2) {
          result[parts[0].trim()] = parts[1].trim();
        }
      }
    }

    return result;
  }

  Future<void> verify() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    authController.errorMessage.value = '';

    // محاولة استخراج verification_id و code من الرابط إن وُجد
    var verificationId = _verificationId;
    var code = codeController.text.trim();

    final parsed = _parseVerificationLink(code);
    if (parsed.containsKey('code')) {
      code = parsed['code']!;
    }
    if (parsed.containsKey('verification_id')) {
      verificationId = parsed['verification_id']!;
    }

    if (verificationId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('verification_id_required'.tr)));
      return;
    }

    setState(() => isLoading = true);

    final success = await authController.verifyRegistration(
      verificationId: verificationId,
      code: code,
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('verification_success'.tr)));
      Get.offAll(() => const HomePage());
      return;
    }

    final msg = authController.errorMessage.value.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg.isEmpty ? 'verify_failed'.tr : msg)),
    );
    
  }

  InputDecoration _input(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffix,
      filled: true,
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
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'title'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: toggleLanguage,
            icon: const Icon(Icons.language, color: Colors.white),
          ),
        ],
        leading: IconButton(
          onPressed: showAppInfoDialog,
          icon: const Icon(Icons.info_outline, color: Colors.white),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    size: 70,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'title'.tr,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'enter_verification_code'.tr,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: codeController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.url,
                          decoration: _input(
                            'verification_code'.tr,
                            Icons.verified,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'key_required'.tr;
                            }
                            return null;
                          },
                        ),
                        if (_verificationId.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${'verification_id'.tr}: $_verificationId',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : verify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'verify_account'.tr,
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
          ),
        ),
      ),
    );
  }
}
