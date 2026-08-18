import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/auth/screens/login_screen.dart';
import 'package:zad/controllers/auth_controller.dart';
import 'package:zad/core/api/api_consumer.dart';
import 'package:zad/core/api/end_points.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthController authController = Get.find<AuthController>();
  final ApiConsumer api = Get.find<ApiConsumer>();

  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isSavingProfile = false;
  bool _isChangingPassword = false;
  bool _isDeletingAccount = false;

  @override
  void initState() {
    super.initState();
    _syncProfileFields();
  }

  void _syncProfileFields() {
    _firstNameController.text = authController.first_name.value;
    _lastNameController.text = authController.last_name.value;
    _phoneController.text = authController.phone.value;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;

    setState(() => _isSavingProfile = true);

    try {
      final response = await api.put(
        EndPoints.updateProfile,
        data: {
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'mobile_number': _phoneController.text.trim(),
        },
      );

      final message =
          response?['message']?.toString() ?? 'Profile updated successfully';

      await authController.setUser(
        first_name: _firstNameController.text.trim(),
        last_name: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      Get.snackbar('Success', message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('Update profile error: $e');
    } finally {
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  Future<void> _changePassword() async {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Error',
        'New password and confirmation do not match',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isChangingPassword = true);

    try {
      final response = await api.post(
        EndPoints.changePassword,
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
      );

      final message =
          response?['message']?.toString() ?? 'Password changed successfully';
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      Get.snackbar('Success', message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update password',
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('Change password error: $e');
    } finally {
      if (mounted) setState(() => _isChangingPassword = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete account'),
        content: Text('delete_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeletingAccount = true);

    try {
      final response = await api.delete(EndPoints.deleteUser);
      final message =
          response?['message']?.toString() ?? 'Account deleted successfully';
      await authController.logout();
      Get.offAll(() => const LoginScreen());
      Get.snackbar('Success', message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete account',
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('Delete account error: $e');
    } finally {
      if (mounted) setState(() => _isDeletingAccount = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0F2027),
                    const Color(0xFF203A43),
                    const Color(0xFF2C5364),
                  ]
                : [
                    const Color(0xFFF4F7FF),
                    const Color(0xFFEAF0FF),
                    const Color(0xFFE3EAFB),
                  ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              expandedHeight: 120,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'settings_title'.tr,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _buildCard(
                  context: context,
                  title: 'profile_title'.tr,
                  icon: Icons.person_outline,
                  child: Form(
                    key: _profileFormKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _firstNameController,
                          hint: 'first_name_hint'.tr,
                          prefixIcon: Icons.person,
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'required'.tr
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _lastNameController,
                          hint: 'last_name_hint'.tr,
                          prefixIcon: Icons.person_outline,
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'required'.tr
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _phoneController,
                          hint: 'phone_number_hint'.tr,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'required'.tr
                              : null,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSavingProfile ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: _isSavingProfile
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(
                              _isSavingProfile
                                  ? 'saving'.tr
                                  : 'save_changes'.tr,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildCard(
                  context: context,
                  title: 'security_title'.tr,
                  icon: Icons.lock_outline,
                  child: Form(
                    key: _passwordFormKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _currentPasswordController,
                          hint: 'current_password_hint'.tr,
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'required'.tr
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _newPasswordController,
                          hint: 'new_password_hint'.tr,
                          prefixIcon: Icons.vpn_key_outlined,
                          obscureText: true,
                          validator: (value) =>
                              (value == null || value.trim().length < 6)
                              ? 'minimum_6_characters'.tr
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hint: 'confirm_password_hint'.tr,
                          prefixIcon: Icons.check_circle_outline,
                          obscureText: true,
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'confirm_password_required'.tr
                              : (value.trim() !=
                                    _newPasswordController.text.trim())
                              ? 'passwords_do_not_match'.tr
                              : null,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isChangingPassword
                                ? null
                                : _changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: _isChangingPassword
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.lock_reset),
                            label: Text(
                              _isChangingPassword
                                  ? 'updating_password'.tr
                                  : 'change_password'.tr,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildCard(
                  context: context,
                  title: 'danger_zone'.tr,
                  icon: Icons.warning_amber_rounded,
                  cardColor: Colors.red.withValues(alpha: 0.08),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isDeletingAccount ? null : _deleteAccount,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: _isDeletingAccount
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.red,
                              ),
                            )
                          : const Icon(Icons.delete_outline),
                      label: Text(
                        _isDeletingAccount
                            ? 'deleting_account'.tr
                            : 'delete_account'.tr,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
    Color? cardColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            cardColor ??
            (isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.75)),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(prefixIcon, color: theme.colorScheme.primary),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}
