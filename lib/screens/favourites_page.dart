import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/auth/screens/login_screen.dart';
import 'package:zad/controllers/auth_controller.dart';
import 'package:zad/controllers/cart_controller.dart';
import 'package:zad/controllers/favourits_controller.dart';
import 'package:zad/controllers/theme_controller.dart';
import 'package:zad/screens/app_drawer.dart';
import 'package:zad/screens/nav_bar.dart';
import 'package:zad/product/screens/product_details_page.dart';
import 'package:zad/models/Product.dart';

import 'package:cached_network_image/cached_network_image.dart';

class FavouritesPage extends StatelessWidget {
  FavouritesPage({super.key});

  final FavouriteController favouriteController =
      Get.find<FavouriteController>();
  final CartController cartController = Get.find<CartController>();
  final ThemeController themeController = Get.find<ThemeController>();
final AuthController authController = Get.find<AuthController>();
  void addToCart(Product item) {
    cartController.addToCart(item, 1);
    Get.snackbar(
      'Added to Cart',
      '${item.name} has been added to your cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
    );
  }

  Widget _buildProductImage(Product item, ThemeData theme, bool isDark) {
    final imageUrl = item.getImageUrl();

    print('🔍 Product: ${item.name}');
    print('📸 Image URL: $imageUrl');
    print('━━━━━━━━━━━━━━━━━━━━');

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            print('❌ Error loading image: $url');
            print('Error: $error');
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 30,
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.shade300,
                ),
                const SizedBox(height: 4),
                Text(
                  'No Image',
                  style: TextStyle(
                    fontSize: 8,
                    color: isDark
                        ? Colors.white.withOpacity(0.3)
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = themeController.isDark.value;

    return Scaffold(
      drawer: AppDrawer(),
      backgroundColor: theme.colorScheme.surface,
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
                    const Color(0xFFF0F4FF),
                    const Color(0xFFE8EDF5),
                    const Color(0xFFDCE3EF),
                  ],
          ),
        ),
        child: Obx(() {
          final favourites = favouriteController.favourites;
          final isLoading = favouriteController.isLoading.value;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              // ===== AppBar =====
              SliverAppBar(
                expandedHeight: 160,
                floating: true,
                pinned: true,
                backgroundColor: isDark
                    ? const Color(0xFF0F2027).withOpacity(0.95)
                    : Colors.white.withOpacity(0.92),
                elevation: 0,
                iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.red.shade400,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'favourites'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xFF0F2027), const Color(0xFF203A43)]
                            : [Colors.white, const Color(0xFFF0F4FF)],
                      ),
                    ),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.red.shade400,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${favourites.length}',
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: favourites.isEmpty
                          ? theme.colorScheme.onSurface.withOpacity(0.05)
                          : Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: favourites.isEmpty
                          ? null
                          : () async {
                              await favouriteController.clearAll();
                              Get.snackbar(
                                'Cleared',
                                'All favourites have been cleared',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 16,
                              );
                            },
                      icon: Icon(
                        Icons.delete_sweep,
                        color: favourites.isEmpty
                            ? theme.colorScheme.onSurface.withOpacity(0.3)
                            : Colors.red.shade400,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),

              // ===== حالة عدم وجود مفضلة =====
              if (favourites.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.withOpacity(0.1),
                                Colors.red.withOpacity(0.05),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite_border,
                            size: 70,
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'no_favourites_yet'.tr,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'save_items_you_like'.tr,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.3,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Obx(() {
                            if (authController.isLoggedIn.value) {
                              return ElevatedButton(
                                onPressed: () => Get.toNamed('/home'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.shopping_bag_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'browse_products'.tr,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          Get.to(() => const LoginScreen()),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFAABB),
                                        foregroundColor: Colors.white,
                                        elevation: 0,

                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        minimumSize: const Size(50, 50),
                                      ),
                                      child: Text(
                                        'login'.tr,
                                        style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              );
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final Product item = favourites[index];

                      return GestureDetector(
                        onTap: () {
                          Get.to(() => ProductDetailsPage(product: item));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                                spreadRadius: -2,
                              ),
                            ],
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.grey.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                _buildProductImage(item, theme, isDark),

                                const SizedBox(width: 14),

                                // ===== معلومات المنتج =====
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),

                                      if (item.sku != null &&
                                          item.sku!.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary
                                                .withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            'SKU: ${item.sku}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: theme.colorScheme.primary
                                                  .withOpacity(0.7),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 6),

                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: item.stock > 0
                                                  ? Colors.green.withOpacity(
                                                      0.1,
                                                    )
                                                  : Colors.red.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  item.stock > 0
                                                      ? Icons
                                                            .check_circle_outline
                                                      : Icons.cancel_outlined,
                                                  size: 12,
                                                  color: item.stock > 0
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  item.stock > 0
                                                      ? '${'in_stock'.tr} (${item.stock})'
                                                      : 'out_of_stock'.tr,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: item.stock > 0
                                                        ? Colors.green.shade700
                                                        : Colors.red.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              theme.colorScheme.primary,
                                              theme.colorScheme.primary
                                                  .withOpacity(0.8),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '\$${item.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ===== أزرار الإجراءات =====
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        onPressed: () async {
                                          await favouriteController
                                              .removeFavourite(item.id);
                                          Get.snackbar(
                                            'Removed',
                                            '${item.name} removed from favourites',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.orange,
                                            colorText: Colors.white,
                                            margin: const EdgeInsets.all(16),
                                            borderRadius: 16,
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.favorite,
                                          color: Colors.redAccent,
                                          size: 22,
                                        ),
                                        tooltip: 'Remove from favourites',
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    Container(
                                      decoration: BoxDecoration(
                                        color: item.stock > 0
                                            ? theme.colorScheme.primary
                                                  .withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.05),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        onPressed: item.stock > 0
                                            ? () => addToCart(item)
                                            : null,
                                        icon: Icon(
                                          Icons.shopping_bag,
                                          color: item.stock > 0
                                              ? theme.colorScheme.primary
                                              : Colors.grey.shade400,
                                          size: 22,
                                        ),
                                        tooltip: item.stock > 0
                                            ? 'Add to cart'
                                            : 'Out of stock',
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }, childCount: favourites.length),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        }),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Get.toNamed('/home');
          if (index == 2) Get.toNamed('/cart');
          if (index == 3) Get.toNamed('/profile');
        },
      ),
    );
  }
}
