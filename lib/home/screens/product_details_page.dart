import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:my_esouq/controllers/cart_controller.dart';
import 'package:my_esouq/controllers/favourits_controller.dart';
import 'package:my_esouq/controllers/recent_orders_controller.dart';

import 'package:my_esouq/home/screens/cart_page.dart';
import 'package:my_esouq/home/screens/favourites_page.dart';
import 'package:my_esouq/home/screens/home_page.dart';
import 'package:my_esouq/home/screens/nav_bar.dart';
import 'package:my_esouq/home/screens/profile_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final FavouriteController favouriteController =
      Get.find<FavouriteController>();
  final CartController cartController = Get.find<CartController>();
  final RecentOrdersController recentOrdersController =
      Get.find<RecentOrdersController>();

  // متغيرات تفاعلية لـ GetX
  final RxInt selectedSize = 0.obs;
  final RxInt selectedColor = 0.obs;
  final RxInt quantity = 1.obs;

  final List<String> sizes = ['S', 'M', 'L', 'XL', 'XXL'];

  final List<Map<String, dynamic>> colors = [
    {'name': 'Blue', 'color': Colors.blue},
    {'name': 'Black', 'color': Colors.black},
    {'name': 'White', 'color': Colors.white},
    {'name': 'Green', 'color': Colors.green},
  ];

  late final List<String> images;
  late final double priceNum;

  @override
  void initState() {
    super.initState();
    images = [widget.product['image']];

    final priceText = widget.product['price']
        .toString()
        .replaceAll('\$', '')
        .trim();
    priceNum = double.tryParse(priceText) ?? 0.0;
  }

  void addToCart() {
    final productToAdd = {
      ...widget.product,
      'quantity': quantity.value,
      'selected_size': sizes[selectedSize.value],
      'selected_color': colors[selectedColor.value]['name'],
    };

    cartController.addToCart(productToAdd);
    recentOrdersController.addOrder(widget.product);

    Get.snackbar(
      'cart_title'.tr,
      'Added successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  Widget build(BuildContext context) {
    // جلب خصائص الثيم الحالي ديناميكياً
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // التدرج اللوني يعتمد بالكامل على لوحة ألوان الثيم النشط
            colors: isDark
                ? [
                    theme.scaffoldBackgroundColor,
                    theme.colorScheme.surfaceContainerHighest,
                    theme.colorScheme.surface,
                  ]
                : [
                    theme.scaffoldBackgroundColor,
                    theme.colorScheme.surfaceContainerLow,
                    theme.colorScheme.surfaceContainerHighest,
                  ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            /// APP BAR + IMAGE
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () => Get.back(),
              ),
              actions: [
                Obx(() {
                  final isFav = favouriteController.isFavourite(
                    widget.product['id'],
                  );
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : theme.colorScheme.onSurface,
                    ),
                    onPressed: () {
                      isFav
                          ? favouriteController.removeFavourite(
                              widget.product['id'],
                            )
                          : favouriteController.addToFavourite(widget.product);
                    },
                  );
                }),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    PageView.builder(
                      itemCount: images.length,
                      itemBuilder: (_, i) =>
                          Image.network(images[i], fit: BoxFit.cover),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// CONTENT
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE + PRICE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product['name'],
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          widget.product['price'],
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.product['rating']}',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// DESCRIPTION
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.05,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                      child: Text(
                        widget.product['description'] ?? '',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// SIZE SECTION
                    Text(
                      'Size',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => Wrap(
                        spacing: 10,
                        children: List.generate(sizes.length, (i) {
                          final selected = selectedSize.value == i;
                          return GestureDetector(
                            onTap: () => selectedSize.value = i,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.05,
                                      ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? Colors.transparent
                                      : theme.colorScheme.onSurface.withValues(
                                          alpha: 0.1,
                                        ),
                                ),
                              ),
                              child: Text(
                                sizes[i],
                                style: TextStyle(
                                  color: selected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// COLOR SECTION
                    Text(
                      'Color',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => Row(
                        children: List.generate(colors.length, (i) {
                          final selected = selectedColor.value == i;
                          return GestureDetector(
                            onTap: () => selectedColor.value = i,
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: colors[i]['color'],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? (colors[i]['name'] == 'White' && !isDark
                                            ? Colors.black
                                            : theme.colorScheme.onSurface)
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: theme.colorScheme.shadow
                                              .withValues(alpha: 0.2),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// QUANTITY & TOTAL
                    Obx(() {
                      final total = priceNum * quantity.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Quantity',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (quantity.value > 1)
                                          quantity.value--;
                                      },
                                      icon: Icon(
                                        Icons.remove,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      '${quantity.value}',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => quantity.value++,
                                      icon: Icon(
                                        Icons.add,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          /// TOTAL PRICE
                          Text(
                            'Total: \$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 24),

                    /// ADD TO CART BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: addToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_checkout_rounded,
                              color: theme.colorScheme.onPrimary,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'add_to_cart'.tr,
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offAll(() => HomePage());
              break;
            case 1:
              Get.offAll(() => FavouritesPage());
              break;
            case 2:
              Get.offAll(() => CartPage());
              break;
            case 3:
              Get.offAll(() => ProfilePage());
              break;
          }
        },
      ),
    );
  }
}
