import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:my_esouq/controllers/favourits_controller.dart';
import 'package:my_esouq/controllers/product_controller.dart';
import 'package:my_esouq/home/screens/app_drawer.dart';
import 'package:my_esouq/home/screens/cart_page.dart';
import 'package:my_esouq/home/screens/favourites_page.dart';
import 'package:my_esouq/home/screens/nav_bar.dart';
import 'package:my_esouq/home/screens/product_details_page.dart';
import 'package:my_esouq/home/screens/profile_page.dart';
import 'package:my_esouq/services/product_search_delegate.dart';
import 'package:my_esouq/services/storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ProductController productController = Get.find<ProductController>();
  final FavouriteController favouriteController =
      Get.find<FavouriteController>();

  int _selectedCategory = 0;

  final List<Map<String, dynamic>> categories = [
    {'name': 'all', 'icon': FontAwesomeIcons.algolia},
    {'name': 'shirts', 'icon': FontAwesomeIcons.shirt},
    {'name': 'trousers', 'icon': FontAwesomeIcons.truckMonster},
    {'name': 'shoes', 'icon': FontAwesomeIcons.shoePrints},
    {'name': 'accessories', 'icon': FontAwesomeIcons.ring},
  ];

  void toggleLanguage() async {
    final newLang = Get.locale?.languageCode == 'en' ? 'ar' : 'en';
    await StorageService.setLanguage(newLang);
    Get.updateLocale(Locale(newLang));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تعريف متغيرات الثيم لتسهيل الاستخدام داخل الـ build
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: AppDrawer(),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 1:
              Get.offAll(() => FavouritesPage());
              break;
            case 2:
              Get.offAll(() => CartPage());
              break;
            case 3:
              Get.offAll(() => const ProfilePage());
              break;
          }
        },
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // تحديد ألوان التدرج بناءً على وضع الثيم الحالي
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
            // APP BAR
            SliverAppBar(
              expandedHeight: 180,
              floating: true,
              pinned: true,
              backgroundColor: isDark
                  ? const Color(0xFF0F2027)
                  : theme.colorScheme.surface,
              elevation: 0,
              iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
              title: Text(
                'my_esouq'.tr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: toggleLanguage,
                  icon: Icon(
                    Icons.language,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.to(() => CartPage()),
                  icon: Icon(
                    Icons.shopping_cart,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: SizedBox(
                    height: 50,
                    child: TextField(
                      controller: _searchController,
                      readOnly: true,
                      onTap: () {
                        showSearch(
                          context: context,
                          delegate: ProductSearchDelegate(
                            productController.products,
                          ),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'search_products'.tr,
                        hintStyle: TextStyle(
                          fontSize: 17,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.colorScheme.onSurface,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.08,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  ),
                ),
              ),
            ),

            // CATEGORIES
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'categories'.tr,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedCategory == index;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = index),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary.withValues(
                                        alpha: 0.3,
                                      )
                                    : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.05,
                                      ),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface.withValues(
                                          alpha: 0.1,
                                        ),
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  children: [
                                    FaIcon(
                                      categories[index]['icon'],
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      categories[index]['name'].toString().tr,
                                      style: TextStyle(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'featured_products'.tr,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // PRODUCTS
            Obx(() {
              if (productController.isLoading.value) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
              }

              if (productController.products.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load products',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: productController.loadProducts,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final filtered = _selectedCategory == 0
                  ? productController.products
                  : productController.products
                        .where(
                          (p) =>
                              p['category'] ==
                              categories[_selectedCategory]['name'],
                        )
                        .toList();

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No products in this category',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = filtered[index];

                    return GestureDetector(
                      onTap: () =>
                          Get.to(() => ProductDetailsPage(product: product)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.05,
                          ),
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(22),
                                  ),
                                  child: Image.network(
                                    product['image'],
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loading) {
                                      if (loading == null) return child;
                                      return Container(
                                        height: 140,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.1),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (c, e, s) => Container(
                                      height: 140,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.1),
                                      child: Icon(
                                        Icons.broken_image,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      product['price'].toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.4,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Obx(() {
                                      final isFav = favouriteController
                                          .isFavourite(product['id']);

                                      return IconButton(
                                        icon: Icon(
                                          isFav
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          size: 23,
                                        ),
                                        color: isFav
                                            ? Colors.red
                                            : Colors.white,
                                        onPressed: () {
                                          if (isFav) {
                                            favouriteController.removeFavourite(
                                              product['id'],
                                            );
                                          } else {
                                            favouriteController.addToFavourite(
                                              product,
                                            );
                                          }
                                        },
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${product['rating']}',
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 12,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.4),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: filtered.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                ),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}
