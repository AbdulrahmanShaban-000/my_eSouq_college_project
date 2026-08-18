// lib/product/widgets/product_wishlist_button.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/controllers/auth_controller.dart';
import 'package:zad/controllers/favourits_controller.dart';
import 'package:zad/models/Product.dart';

/// زر المفضلة (Wishlist) القابل لإعادة الاستخدام
/// يمكن استخدامه في أي مكان: AppBar، قائمة المنتجات، صفحة التفاصيل
class ProductWishlistButton extends StatelessWidget {
  final Product product;
  final double size;
  final bool showLabel;
  final VoidCallback? onToggle;

  const ProductWishlistButton({
    super.key,
    required this.product,
    this.size = 24,
    this.showLabel = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final favouriteController = Get.find<FavouriteController>();

    return Obx(() {
      // إذا لم يكن المستخدم مسجلاً، لا نعرض الزر
      if (!authController.isLoggedIn.value) {
        return const SizedBox.shrink();
      }

      final isFav = favouriteController.isFavourite(product.id);

      return GestureDetector(
        onTap: () {
          if (isFav) {
            favouriteController.removeFavourite(product.id);
          } else {
            favouriteController.addToFavourite(product);
          }
          onToggle?.call();
        },
        child: showLabel
            ? _buildButtonWithLabel(theme: Theme.of(context), isFav: isFav)
            : _buildIconOnly(theme: Theme.of(context), isFav: isFav),
      );
    });
  }

  // ==================== أيقونة فقط ====================
  Widget _buildIconOnly({required ThemeData theme, required bool isFav}) {
    return Container(
      width: size + 12,
      height: size + 12,
      decoration: BoxDecoration(
        color: isFav
            ? Colors.red.withOpacity(0.1)
            : theme.colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        color: isFav ? Colors.red : theme.colorScheme.primary,
        size: size,
      ),
    );
  }

  // ==================== زر مع نص ====================
  Widget _buildButtonWithLabel({
    required ThemeData theme,
    required bool isFav,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isFav
            ? Colors.red.withOpacity(0.1)
            : theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFav
              ? Colors.red.withOpacity(0.3)
              : theme.colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            color: isFav ? Colors.red : theme.colorScheme.primary,
            size: size,
          ),
          const SizedBox(width: 8),
          Text(
            isFav ? 'remove_from_wish_list'.tr : 'add_to_wish_list'.tr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isFav ? Colors.red : theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
