// lib/product/widgets/product_add_to_cart_button.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/auth/screens/login_screen.dart';
import 'package:zad/controllers/auth_controller.dart';
import 'package:zad/models/Product.dart';
import 'package:zad/products/widgets/product_wishlist_button.dart';

class ProductAddToCartButton extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductAddToCartButton({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();

    return Obx(() {
      if (!authController.isLoggedIn.value) {
        return _buildLoginButton(theme);
      }

      return Column(
        children: [
          _buildAddToCartButton(theme),
          const SizedBox(height: 12),
          // ✅ استخدام Widget المخصص بدلاً من كتابة الكود مكرراً
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ProductWishlistButton(
              product: product,
              size: 22,
              showLabel: true,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLoginButton(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () => Get.to(() => const LoginScreen()),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              'login'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const SizedBox(width: double.infinity, height: 55),
      ],
    );
  }

  Widget _buildAddToCartButton(ThemeData theme) {
    final bool isAvailable = product.isActive == 1 && product.stock > 0;

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isAvailable ? onAddToCart : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_checkout_rounded,
              color: isAvailable
                  ? theme.colorScheme.onPrimary
                  : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              isAvailable ? 'add_to_cart'.tr : 'unavailable'.tr,
              style: TextStyle(
                color: isAvailable
                    ? theme.colorScheme.onPrimary
                    : Colors.grey.shade600,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
