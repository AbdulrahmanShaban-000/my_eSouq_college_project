import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_esouq/controllers/cart_controller.dart';
import 'package:my_esouq/controllers/favourits_controller.dart';
import 'package:my_esouq/controllers/theme_controller.dart';
import 'package:my_esouq/home/screens/app_drawer.dart';
import 'package:my_esouq/home/screens/nav_bar.dart';
import 'package:my_esouq/theme/app_theme.dart';

class FavouritesPage extends StatelessWidget {
  FavouritesPage({super.key});

  final FavouriteController favouriteController =
      Get.find<FavouriteController>();
  final CartController cartController = Get.find<CartController>();
  final ThemeController themeController = Get.find<ThemeController>();
  void addToCart(Map<String, dynamic> item) {
    cartController.addToCart(item);
  }

  @override
  Widget build(BuildContext context) {
    // 1. استخراج خصائص الثيم الحالي
    final theme = Theme.of(context);

    return Scaffold(
      drawer: AppDrawer(),
      // جعل الخلفية تأخذ لون الـ Surface الخاص بالثيم تلقائياً
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        decoration: AppTheme.background(themeController.isDark.value),
        child: Obx(() {
          final favourites = favouriteController.favourites;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                // 3. جعل ألوان الأيقونات والنصوص متوافقة مع لون الخلفية
                iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
                expandedHeight: 140,
                floating: true,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    'favourites'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface, // ديناميكي
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: favourites.isEmpty
                        ? null
                        : () => favouriteController.clearAll(),
                    // 4. استخدام معيار onSurface للأزرار العلوية
                    icon: Icon(
                      Icons.delete_sweep,
                      color: favourites.isEmpty
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

              if (favourites.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 5. الأيقونة الكبيرة في الشاشة الفارغة
                        Icon(
                          Icons.favorite_border,
                          size: 110,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'no_favourites_yet'.tr,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface, // ديناميكي
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'save_items_you_like'.tr,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
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
                      final item = favourites[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          // 6. كروت المفضلة أصبحت شفافة بناءً على لون الثيم الأساسي (أبيض في الداكن، أسود في الفاتح)
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.onSurface.withValues(
                                alpha: 0.08,
                              ),
                              theme.colorScheme.onSurface.withValues(
                                alpha: 0.03,
                              ),
                            ],
                          ),
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.network(
                                  item['image'],
                                  width: 85,
                                  height: 85,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    width: 85,
                                    height: 85,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.1),
                                    child: Icon(
                                      Icons.broken_image,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: TextStyle(
                                        color: theme
                                            .colorScheme
                                            .onSurface, // ديناميكي
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['category'].toString(),
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
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
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item['price'].toString(),
                                      style: TextStyle(
                                        // 7. استخدام لون الـ primary للأسعار لضمان وضوحه في الوضعين الفاتح والداكن
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      onPressed: () => favouriteController
                                          .removeFavourite(item['id']),
                                      icon: const Icon(
                                        Icons.favorite,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      // 8. لون خلفية زر السلة مأخوذ من ثيم الـ primary الشفاف
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      onPressed: () => addToCart(item),
                                      icon: Icon(
                                        Icons.shopping_bag,
                                        color: theme.colorScheme.primary,
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
          if (index == 0) Get.toNamed('/home');
          if (index == 2) Get.toNamed('/cart');
          if (index == 3) Get.toNamed('/profile');
        },
      ),
    );
  }
}
