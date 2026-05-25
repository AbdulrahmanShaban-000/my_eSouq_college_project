import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_esouq/controllers/cart_controller.dart';
import 'package:my_esouq/controllers/recent_orders_controller.dart';
import 'package:my_esouq/home/screens/app_drawer.dart';
import 'package:my_esouq/home/screens/favourites_page.dart';
import 'package:my_esouq/home/screens/home_page.dart';
import 'package:my_esouq/home/screens/nav_bar.dart';
import 'package:my_esouq/home/screens/profile_page.dart';

class CartPage extends StatelessWidget {
  CartPage({super.key});

  final CartController cartController = Get.find<CartController>();
  final RecentOrdersController recentOrdersController =
      Get.find<RecentOrdersController>();

  @override
  Widget build(BuildContext context) {
    // استخراج خصائص الثيم الحالي
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final cartItems = cartController.cartItems;
      final subtotal = cartController.subtotal;

      return Scaffold(
        drawer: AppDrawer(),
        // الخلفية تعتمد على لون الـ surface الخاص بالثيم
        backgroundColor: theme.colorScheme.surface,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              // تدرج لوني يتغير تلقائياً حسب وضع التطبيق
              colors: isDark
                  ? [
                      const Color(0xFF0F2027),
                      const Color(0xFF203A43),
                      const Color(0xFF2C5364),
                    ]
                  : [Colors.grey[50]!, Colors.grey[200]!, Colors.grey[300]!],
            ),
          ),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
                expandedHeight: 150,
                floating: true,
                pinned: true,
                backgroundColor: Colors
                    .transparent, // جعلها شفافة لتظهر الخلفية المتدرجة بسلاسة
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'cart'.tr,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface, // ديناميكي
                      ),
                    ),
                    Text(
                      '${cartItems.length} items',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ), // ديناميكي شفاف
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: cartItems.isEmpty
                        ? null
                        : () {
                            cartController.clearCart();
                            Get.snackbar(
                              'Cart Cleared',
                              'All items removed',
                              backgroundColor: theme.colorScheme.inverseSurface,
                              colorText: theme.colorScheme.onInverseSurface,
                            );
                          },
                    icon: Icon(
                      Icons.clear_all,
                      color: cartItems.isEmpty
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

              if (cartItems.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'your_cart_is_empty'.tr,
                          style: TextStyle(
                            fontSize: 20,
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'add_something'.tr,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme
                                .colorScheme
                                .primary, // يعتمد على لون الثيم الأساسي
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: () => Get.toNamed('/home'),
                          child: Text('shop_now'.tr),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: cartItems.length,
                      (context, index) {
                        final item = cartItems[index];
                        final priceNum =
                            double.tryParse(
                              item['price'].toString().replaceAll('\$', ''),
                            ) ??
                            0;
                        final itemTotal = priceNum * item['quantity'];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            // كرت شفاف يتكيف مع الخلفية الفاتحة أو الداكنة
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.06,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.08,
                              ),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item['image'],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, st) => Container(
                                  width: 70,
                                  height: 70,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              item['name'],
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '\$${itemTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: theme
                                    .colorScheme
                                    .primary, // لون السعر متناسق مع الهوية البراندية للثيم
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => cartController
                                      .updateQuantity(item['id'], -1),
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                Text(
                                  '${item['quantity']}',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => cartController
                                      .updateQuantity(item['id'], 1),
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    color: theme
                                        .colorScheme
                                        .primary, // استخدام لون الثيم الأساسي للزيادة
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    cartController.removeItem(item['id']);
                                    recentOrdersController.removeOrder(
                                      item['id'],
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: cartItems.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'subtotal'.tr,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  '\$${subtotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                onPressed: () {
                                  Get.snackbar(
                                    'Checkout',
                                    'Order placed successfully',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                  Get.toNamed('/checkout');
                                },
                                child: Text(
                                  'checkout'.tr,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
        bottomNavigationBar: NavBar(
          currentIndex: 2,
          onTap: (index) {
            switch (index) {
              case 0:
                Get.offAll(() => const HomePage());
                break;
              case 1:
                Get.offAll(() => FavouritesPage());
                break;
              case 3:
                Get.offAll(() => const ProfilePage());
                break;
            }
          },
        ),
      );
    });
  }
}
