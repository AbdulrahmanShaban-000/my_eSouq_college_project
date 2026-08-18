// lib/home/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/controllers/categories_controller.dart';
import 'package:zad/controllers/product_controller.dart';
import 'package:zad/controllers/rating_controller.dart';
import 'package:zad/home/widgets/most_popular_products.dart';
import 'package:zad/screens/app_drawer.dart';
import 'package:zad/screens/cart_page.dart';
import 'package:zad/screens/favourites_page.dart';
import 'package:zad/screens/nav_bar.dart';
import 'package:zad/screens/profile_page.dart';
import 'package:zad/home/widgets/home_app_bar.dart';
import 'package:zad/home/widgets/category_list.dart';
import 'package:zad/home/widgets/product_grid.dart';
import 'package:zad/home/widgets/discounts_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductController productController = Get.find();
  final CategoryController categoryController = Get.find();
  final RatingController ratingController = Get.find();

  final RxBool isSearching = false.obs;
  final RxInt selectedCategoryId = 0.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllRatings();
    });
  }

  Future<void> _loadAllRatings() async {
    final products = productController.products.toList(growable: false);
    if (products.isEmpty) return;

    print('🔄 Loading ratings for ${products.length} products...');

    for (final product in products) {
      await ratingController.fetchAverageRating(product.id);
      await ratingController.fetchUserRating(product.id);
    }

    print('✅ All ratings loaded successfully!');
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      productController.refreshProducts(),
      categoryController.fetchCategoriesTree(),
    ]);
    await _loadAllRatings();
  }

  @override
  Widget build(BuildContext context) {
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
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // AppBar
              HomeAppBar(
                products: productController.products,
                isSearching: isSearching,
              ),

              SliverToBoxAdapter(child: DiscountsSlider()),
              SliverToBoxAdapter(child: MostPopularProducts()),

              // قائمة التصنيفات
              SliverToBoxAdapter(
                child: CategoryList(selectedCategoryId: selectedCategoryId),
              ),

              // شبكة المنتجات
              Obx(() {
                return ProductGrid(
                  allProducts: productController.products,
                  selectedCategoryId: selectedCategoryId.value,
                  categoriesTree: categoryController.categoriesTree,
                );
              }),

              // زر تحميل المزيد
              Obx(() {
                final hasMorePages =
                    productController.currentPage.value <=
                    productController.totalPages.value;

                if (productController.isLoadingMore.value) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 80),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (!hasMorePages) {
                  return const SliverToBoxAdapter(child: SizedBox(height: 80));
                }

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: productController.loadMoreProducts,
                        icon: const Icon(Icons.expand_more_rounded),
                        label: Text('lm'.tr),
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
