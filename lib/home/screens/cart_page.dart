import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_esouq/controllers/cart_controller.dart';
import 'package:my_esouq/home/screens/app_drawer.dart';
import 'package:my_esouq/home/screens/favourites_page.dart';
import 'package:my_esouq/home/screens/home_page.dart';
import 'package:my_esouq/home/screens/nav_bar.dart';
import 'package:my_esouq/home/screens/profile_page.dart';

class CartPage extends StatelessWidget {
  CartPage({super.key});

  final CartController cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cartItems = cartController.cartItems;

      final subtotal = cartController.subtotal;

      return Scaffold(
        drawer: AppDrawer(),

        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            ),
          ),

          child: CustomScrollView(
            slivers: [
              /// APP BAR
              SliverAppBar(
                iconTheme: const IconThemeData(color: Colors.white),
                expandedHeight: 150,
                floating: true,
                pinned: true,
                backgroundColor: const Color(0xFF0F2027),

                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'cart'.tr,

                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    Text(
                      '${cartItems.length} items',

                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),

                actions: [
                  IconButton(
                    onPressed: cartItems.isEmpty
                        ? null
                        : () {
                            cartItems.clear();

                            Get.snackbar('Cart Cleared', 'All items removed');
                          },

                    icon: const Icon(Icons.clear_all, color: Colors.white),
                  ),
                ],
              ),

              /// EMPTY
              if (cartItems.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(40),

                    child: Column(
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: Colors.white54,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'your_cart_is_empty'.tr,

                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'add_something'.tr,

                          style: const TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 24),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,

                            foregroundColor: Colors.white,

                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),

                          onPressed: () {
                            Get.toNamed('/home');
                          },

                          child: Text('shop_now'.tr),
                        ),
                      ],
                    ),
                  ),
                )
              /// LIST
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
                            color: Colors.white.withOpacity(0.08),

                            borderRadius: BorderRadius.circular(20),

                            border: Border.all(color: Colors.white12),
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

                                errorBuilder: (c, e, st) {
                                  return Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.white12,

                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.white54,
                                    ),
                                  );
                                },
                              ),
                            ),

                            title: Text(
                              item['name'],

                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Text(
                              '\$${itemTotal.toStringAsFixed(2)}',

                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                IconButton(
                                  onPressed: () {
                                    cartController.updateQuantity(
                                      item['id'],
                                      -1,
                                    );
                                  },

                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.white54,
                                  ),
                                ),

                                Text(
                                  '${item['quantity']}',

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),

                                IconButton(
                                  onPressed: () {
                                    cartController.updateQuantity(
                                      item['id'],
                                      1,
                                    );
                                  },

                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.blueAccent,
                                  ),
                                ),

                                IconButton(
                                  onPressed: () {
                                    cartController.removeItem(item['id']);
                                    final RecentOrdersController
                                    recentOrdersController =
                                        Get.find<RecentOrdersController>();

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

              /// CHECKOUT
              SliverToBoxAdapter(
                child: cartItems.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.all(16),

                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),

                          borderRadius: BorderRadius.circular(20),

                          border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.3),
                          ),
                        ),

                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                Text(
                                  'subtotal'.tr,

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),

                                Text(
                                  '\$${subtotal.toStringAsFixed(2)}',

                                  style: const TextStyle(
                                    color: Colors.white,
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
                                  backgroundColor: Colors.blueAccent,

                                  foregroundColor: Colors.white,

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
