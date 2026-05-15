import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:my_esouq/controllers/product_controller.dart';
import 'package:my_esouq/home/screens/app_drawer.dart';
import 'package:my_esouq/home/screens/cart_page.dart';
import 'package:my_esouq/home/screens/favourites_page.dart';
import 'package:my_esouq/home/screens/nav_bar.dart';
import 'package:my_esouq/home/screens/product_details_page.dart';
import 'package:my_esouq/home/screens/profile_page.dart';
import 'package:my_esouq/services/product_search_delegate.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  final ProductController productController = Get.find<ProductController>();

  final int _currentIndex = 0;

  int _selectedCategory = 0;

  final List<Map<String, dynamic>> categories = [
    {'name': 'all', 'icon': FontAwesomeIcons.algolia},
    {'name': 'shirts', 'icon': FontAwesomeIcons.shirt},
    {'name': 'trousers', 'icon': FontAwesomeIcons.truckMonster},
    {'name': 'shoes', 'icon': FontAwesomeIcons.shoePrints},
    {'name': 'accessories', 'icon': FontAwesomeIcons.ring},
  ];

  void toggleLanguage() {
    if (Get.locale?.languageCode == 'en') {
      Get.updateLocale(const Locale('ar'));
    } else {
      Get.updateLocale(const Locale('en'));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offAll(() => const HomePage());
              break;

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
              expandedHeight: 180,
              floating: true,
              pinned: true,
              backgroundColor: const Color(0xFF0F2027),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),

              title: Text(
                'my_esouq'.tr,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              actions: [
                IconButton(
                  onPressed: toggleLanguage,
                  icon: const Icon(Icons.language, color: Colors.white),
                ),

                IconButton(
                  onPressed: () {
                    Get.to(() => CartPage());
                  },
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
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
                        hintStyle: const TextStyle(
                          fontSize: 17,
                          color: Colors.white70,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),

                        filled: true,

                        fillColor: Colors.white.withOpacity(0.1),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),

                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),

            /// CATEGORIES
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const SizedBox(height: 10),

                    Text(
                      'categories'.tr,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 50,

                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,

                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = index;
                              });
                            },

                            child: Container(
                              margin: const EdgeInsets.only(right: 10),

                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),

                              decoration: BoxDecoration(
                                color: _selectedCategory == index
                                    ? Colors.blueAccent.withOpacity(0.4)
                                    : Colors.white10,

                                borderRadius: BorderRadius.circular(25),

                                border: Border.all(color: Colors.white24),
                              ),

                              child: Center(
                                child: Row(
                                  children: [
                                    FaIcon(
                                      categories[index]['icon'],
                                      color: Colors.white,
                                      size: 18,
                                    ),

                                    const SizedBox(width: 8),

                                    Text(
                                      categories[index]['name'].toString().tr,
                                      style: const TextStyle(
                                        color: Colors.white,
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
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// PRODUCTS
            Obx(() {
              final products = productController.products;

              final filteredProducts = _selectedCategory == 0
                  ? products
                  : products.where((p) {
                      return p['category'] ==
                          categories[_selectedCategory]['name'];
                    }).toList();

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = filteredProducts[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),

                        borderRadius: BorderRadius.circular(20),

                        border: Border.all(color: Colors.white10),
                      ),

                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),

                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(15),

                          child: Image.network(
                            product['image'],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,

                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }

                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.white10,

                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },

                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.white10,

                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.white38,
                                ),
                              );
                            },
                          ),
                        ),

                        title: Text(
                          product['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const SizedBox(height: 5),

                            Text(
                              product['price'].toString(),
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

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
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        trailing: IconButton(
                          icon: const Icon(
                            Icons.add_shopping_cart,
                            size: 35,
                            color: Colors.blueAccent,
                          ),

                          onPressed: () {
                            Get.to(() => ProductDetailsPage(product: product));
                          },
                        ),
                      ),
                    );
                  }, childCount: filteredProducts.length),
                ),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
