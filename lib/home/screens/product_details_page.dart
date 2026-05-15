import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:my_esouq/controllers/cart_controller.dart';
import 'package:my_esouq/controllers/favourits_controller.dart';
import 'package:my_esouq/home/screens/profile_page.dart';

import 'package:my_esouq/home/screens/app_drawer.dart';
import 'package:my_esouq/home/screens/cart_page.dart';
import 'package:my_esouq/home/screens/favourites_page.dart';
import 'package:my_esouq/home/screens/home_page.dart';
import 'package:my_esouq/home/screens/nav_bar.dart';

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

  final RecentOrdersController recentOrdersController = Get.put(
    RecentOrdersController(),
  );

  int selectedSize = 0;
  int selectedColor = 0;
  int quantity = 1;

  final List<String> sizes = ['S', 'M', 'L', 'XL', 'XXL'];

  final List<Map<String, dynamic>> colors = [
    {'name': 'Blue', 'color': Colors.blue},
    {'name': 'Black', 'color': Colors.black},
    {'name': 'White', 'color': Colors.white},
    {'name': 'Green', 'color': Colors.green},
  ];

  late final List<String> images;

  int currentImage = 0;

  @override
  void initState() {
    super.initState();

    images = [
      widget.product['image'] ?? '',
      'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500',
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500',
    ];
  }

  void incrementQuantity() => setState(() => quantity++);

  void decrementQuantity() {
    if (quantity > 1) {
      setState(() => quantity--);
    }
  }

  /// ✅ ADD TO CART + RECENT ORDERS
  void addToCart() {
    final product = {...widget.product, 'quantity': quantity};

    cartController.addToCart(product);

    // ✅ إضافة للطلبات الأخيرة
    recentOrdersController.addOrder(product);

    Get.snackbar(
      'Cart',
      '${widget.product['name']} added to cart',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final priceText = widget.product['price'].toString().replaceAll('\$', '');

    final priceNum = double.tryParse(priceText) ?? 0;

    final total = priceNum * quantity;

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
              expandedHeight: 350,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF0F2027),

              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),

              actions: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {},
                ),

                /// ❤️ FAVORITE
                Obx(() {
                  final isFav = favouriteController.isFavourite(
                    widget.product['id'],
                  );

                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.white,
                    ),

                    onPressed: () {
                      if (isFav) {
                        favouriteController.removeFavourite(
                          widget.product['id'],
                        );
                      } else {
                        favouriteController.addToFavourite(widget.product);
                      }
                    },
                  );
                }),
              ],

              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.product['name'],

                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                background: Stack(
                  children: [
                    PageView.builder(
                      itemCount: images.length,

                      onPageChanged: (i) => setState(() => currentImage = i),

                      itemBuilder: (_, i) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(images[i]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: List.generate(
                          images.length,
                          (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),

                            width: currentImage == i ? 24 : 8,

                            height: 8,

                            decoration: BoxDecoration(
                              color: currentImage == i
                                  ? Colors.white
                                  : Colors.white54,

                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
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
                    /// PRICE + RATING
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text(
                          widget.product['price'],

                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),

                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),

                            const SizedBox(width: 5),

                            Text(
                              '${widget.product['rating']}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '${widget.product['category'] ?? ''} • Premium Quality',

                      style: const TextStyle(color: Colors.blueAccent),
                    ),

                    const SizedBox(height: 24),

                    /// DESCRIPTION
                    Text(
                      widget.product['description'] ??
                          'Premium quality product.',

                      style: const TextStyle(color: Colors.white, height: 1.5),
                    ),

                    const SizedBox(height: 24),

                    /// SIZE
                    const Text(
                      'Size',

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 45,

                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,

                        itemCount: sizes.length,

                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () => setState(() => selectedSize = index),

                          child: Container(
                            margin: const EdgeInsets.only(right: 12),

                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),

                            decoration: BoxDecoration(
                              color: selectedSize == index
                                  ? Colors.blueAccent.withOpacity(0.3)
                                  : Colors.white10,

                              borderRadius: BorderRadius.circular(25),

                              border: Border.all(color: Colors.white30),
                            ),

                            child: Text(
                              sizes[index],

                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// COLORS
                    const Text(
                      'Color',

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 50,

                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,

                        itemCount: colors.length,

                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () => setState(() => selectedColor = index),

                          child: Container(
                            margin: const EdgeInsets.only(right: 12),

                            width: 40,
                            height: 40,

                            decoration: BoxDecoration(
                              color: colors[index]['color'],

                              shape: BoxShape.circle,

                              border: Border.all(
                                color: selectedColor == index
                                    ? Colors.white
                                    : Colors.transparent,

                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// QUANTITY
                    Row(
                      children: [
                        const Text(
                          'Quantity',

                          style: TextStyle(color: Colors.white),
                        ),

                        const Spacer(),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),

                            borderRadius: BorderRadius.circular(25),
                          ),

                          child: Row(
                            children: [
                              IconButton(
                                onPressed: decrementQuantity,

                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                ),
                              ),

                              Text(
                                '$quantity',

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),

                              IconButton(
                                onPressed: incrementQuantity,

                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// TOTAL
                    Text(
                      'Total: ${total.toStringAsFixed(2)} \$',

                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// BUTTON
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 58,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: addToCart,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.shopping_cart_checkout_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),

                                  const SizedBox(width: 10),

                                  Text(
                                    'add_to_cart'.tr,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavBar(
        currentIndex: 3,

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
          }
        },
      ),
    );
  }
}
