import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_esouq/controllers/favourits_controller.dart';

import 'package:my_esouq/home/screens/app_drawer.dart';
import 'package:my_esouq/home/screens/nav_bar.dart';

class FavouritesPage extends StatelessWidget {
  FavouritesPage({super.key});
  final FavouriteController favouriteController =
      Get.find<FavouriteController>();

  void addToCart(Map<String, dynamic> item) {
    Get.snackbar('Added', item['name']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),

      backgroundColor: const Color(0xFF0F2027),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),

        child: Obx(() {
          final favourites = favouriteController.favourites;

          return CustomScrollView(
            slivers: [
              /// APP BAR
              SliverAppBar(
                iconTheme: const IconThemeData(color: Colors.white),
                expandedHeight: 140,
                floating: true,
                pinned: true,
                backgroundColor: Colors.transparent,

                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,

                  title: Text(
                    'favourites'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                actions: [
                  IconButton(
                    onPressed: () {
                      favouriteController.favourites.clear();

                      Get.snackbar('Cleared', 'All favourites removed');
                    },

                    icon: const Icon(Icons.delete_sweep, color: Colors.white),
                  ),
                ],
              ),

              /// EMPTY
              if (favourites.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        const Icon(
                          Icons.favorite_border,
                          size: 110,
                          color: Colors.white24,
                        ),

                        const SizedBox(height: 15),

                        Text(
                          'no_favourites_yet'.tr,

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'save_items_you_like'.tr,

                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                )
              /// LIST
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),

                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = favourites[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),

                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.10),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),

                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(12),

                          child: Row(
                            children: [
                              /// IMAGE
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18),

                                child: Image.network(
                                  item['image'],

                                  width: 85,
                                  height: 85,

                                  fit: BoxFit.cover,
                                ),
                              ),

                              const SizedBox(width: 14),

                              /// INFO
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      item['name'],

                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      item['category'].toString(),

                                      style: const TextStyle(
                                        color: Colors.white60,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),

                                        const SizedBox(width: 4),

                                        Text(
                                          '${item['rating']}',

                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      item['price'].toString(),

                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// ACTIONS
                              Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.15),

                                      shape: BoxShape.circle,
                                    ),

                                    child: IconButton(
                                      onPressed: () {
                                        favouriteController.removeFavourite(
                                          item['id'],
                                        );
                                      },

                                      icon: const Icon(
                                        Icons.favorite,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.15),

                                      shape: BoxShape.circle,
                                    ),

                                    child: IconButton(
                                      onPressed: () => addToCart(item),

                                      icon: const Icon(
                                        Icons.shopping_bag,
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: favourites.length),
                  ),
                ),
            ],
          );
        }),
      ),

      bottomNavigationBar: NavBar(
        currentIndex: 1,

        onTap: (index) {
          if (index == 0) {
            Get.toNamed('/home');
          }

          if (index == 2) {
            Get.toNamed('/cart');
          }

          if (index == 3) {
            Get.toNamed('/profile');
          }
        },
      ),
    );
  }
}
