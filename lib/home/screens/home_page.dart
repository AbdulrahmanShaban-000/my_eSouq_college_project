import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/controllers/auth_controller.dart';
import 'package:zad/controllers/categories_controller.dart';
import 'package:zad/controllers/favourits_controller.dart';
import 'package:zad/controllers/product_controller.dart';
import 'package:zad/controllers/cart_controller.dart';
import 'package:zad/controllers/rating_controller.dart';
import 'package:zad/home/screens/app_drawer.dart';
import 'package:zad/home/screens/cart_page.dart';
import 'package:zad/home/screens/favourites_page.dart';
import 'package:zad/home/screens/nav_bar.dart';
import 'package:zad/home/screens/product_details_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zad/home/screens/profile_page.dart';
import 'package:zad/models/Product.dart';
import 'package:zad/models/categories.dart';
import 'package:zad/services/product_search_delegate.dart';
import 'package:zad/services/storage_service.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductController productController = Get.find();
  final FavouriteController favouriteController = Get.find();
  final CartController cartController = Get.find();
  final RatingController ratingController = Get.find();
  Set<int> _categoryIdsIncludingChildren(Category category) {
    final ids = <int>{category.catid};
    if (category.children != null) {
      for (final child in category.children!) {
        ids.addAll(_categoryIdsIncludingChildren(child));
      }
    }
    return ids;
  }

  Category? _findCategoryById(List<Category> tree, int id) {
    for (final c in tree) {
      if (c.catid == id) return c;
      if (c.children != null) {
        final found = _findCategoryById(c.children!, id);
        if (found != null) return found;
      }
    }
    return null;
  }

  // إضافة متحكم الأقسام
  final CategoryController categoryController = Get.put(CategoryController());

  final RxBool isSearching = false.obs;

  // متغير لتتبع القسم المختار (0 يعني عرض الكل)
  final RxInt selectedCategoryId = 0.obs;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllRatings();
    });
  }

  Future<void> _loadAllRatings() async {
    final products = productController.products;
    if (products.isEmpty) return;

    print('🔄 Loading ratings for ${products.length} products...');

    for (final product in products) {
      await ratingController.fetchAverageRating(product.id);
      await ratingController.fetchUserRating(product.id);
    }

    print('✅ All ratings loaded successfully!');
  }

  void toggleLanguage() async {
    final newLang = Get.locale?.languageCode == 'en' ? 'ar' : 'en';
    await StorageService.setLanguage(newLang);
    Get.updateLocale(Locale(newLang));
  }

  void _openSearch() {
    FocusScope.of(context).unfocus();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchPage(products: productController.products),
        fullscreenDialog: true,
      ),
    );
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
        child: CustomScrollView(
          slivers: [
            // ===== AppBar Modern =====
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: isDark
                  ? const Color(0xFF0F2027).withOpacity(0.95)
                  : Colors.white.withOpacity(0.92),
              elevation: 0,
              iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
              flexibleSpace: FlexibleSpaceBar(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_bag,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'zad'.tr,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
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
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => isSearching.value = !isSearching.value,
                    icon: Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: toggleLanguage,
                    icon: Icon(
                      Icons.translate_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Obx(() {
                    final itemCount = cartController.totalItems;
                    return Stack(
                      children: [
                        IconButton(
                          onPressed: () => Get.to(() => CartPage()),
                          icon: Icon(
                            Icons.shopping_cart_outlined,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                        ),
                        if (itemCount > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? Colors.black : Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  itemCount > 99 ? '99+' : '$itemCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Obx(
                  () => isSearching.value
                      ? Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 16,
                          ),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.2,
                                ),
                                width: 1.5,
                              ),
                            ),
                            child: TextField(
                              onTap: () => _openSearch(),
                              decoration: InputDecoration(
                                hintText: 'search_products'.tr,
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.4),
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.6,
                                  ),
                                  size: 20,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),

            // ===== قائمة الأقسام (Categories) =====
            SliverToBoxAdapter(
              child: Obx(() {
                if (categoryController.isLoading.value) {
                  return const SizedBox(
                    height: 55,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final categories = categoryController.categoriesTree;
                if (categories.isEmpty) return const SizedBox.shrink();

                return Container(
                  height: 55,
                  margin: const EdgeInsets.only(top: 16, bottom: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Obx(() {
                          final isSelected = selectedCategoryId.value == 0;
                          return _buildAnimatedCategoryButton(
                            title: 'All',
                            isSelected: isSelected,
                            onTap: () => selectedCategoryId.value = 0,
                            theme: theme,
                            isDark: isDark,
                          );
                        });
                      }

                      final category = categories[index - 1];
                      return Obx(() {
                        final isSelected =
                            selectedCategoryId.value == category.catid;
                        return _buildAnimatedCategoryButton(
                          title: category.name,
                          isSelected: isSelected,
                          onTap: () =>
                              selectedCategoryId.value = category.catid,
                          theme: theme,
                          isDark: isDark,
                        );
                      });
                    },
                  ),
                );
              }),
            ),

            // ===== قائمة المنتجات =====
            Obx(() {
              if (productController.isLoading.value) {
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildShimmerCard(theme),
                      childCount: 6,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.75,
                        ),
                  ),
                );
              }

              if (productController.hasError.value) {
                return _buildErrorState(theme);
              }

              final allProducts = productController.products;

              final products = selectedCategoryId.value == 0
                  ? allProducts
                  : allProducts.where((p) {
                      final selectedCategory = _findCategoryById(
                        categoryController.categoriesTree,
                        selectedCategoryId.value,
                      );
                      if (selectedCategory == null) return false;

                      final validIds = _categoryIdsIncludingChildren(
                        selectedCategory,
                      );
                      return p.categoryIds.any((id) => validIds.contains(id));
                    }).toList();

              if (products.isEmpty) {
                return _buildEmptyState(theme);
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildProductCard(products[index], theme, isDark),
                    childCount: products.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
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

  // ===================================================================
  // ✅ كرت المنتج - مع Hero Animation
  // ===================================================================
  Widget _buildProductCard(Product product, ThemeData theme, bool isDark) {
    final imageUrl = product.getImageUrl();
    final bool inStock = product.stock > 0;
    final bool unavailable = product.isActive == 0;

    return GestureDetector(
      onTap: unavailable
          ? null
          : () => Get.to(() => ProductDetailsPage(product: product)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'product_${product.id}',
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.shade100,
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: isDark
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.grey.shade300,
                              size: 40,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.shade100,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: isDark
                                ? Colors.white.withOpacity(0.3)
                                : Colors.grey.shade400,
                            size: 40,
                          ),
                        ),
                      ),
                    ),

                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                              stops: const [0.0, 0.6, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // حالة عدم التوفر
                    if (unavailable)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.6),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.4),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                              child: const Text(
                                'OUT OF STOCK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // 💰 السعر
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product.price.toStringAsFixed(2),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      top: 16,
                      left: 16,
                      child: Obx(() {
                        final avg = ratingController.getAverageRating(
                          product.id,
                        );
                        final isLoading = ratingController.isLoadingProduct(
                          product.id,
                        );

                        if (isLoading) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          );
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.black.withOpacity(0.75),
                                Colors.black.withOpacity(0.55),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                avg > 0 ? avg.toStringAsFixed(1) : '0.0',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),

                    Positioned(
                      top: 12,
                      right: 12,
                      child: Obx(() {
                        if (!Get.find<AuthController>().isLoggedIn.value) {
                          return const SizedBox();
                        }

                        final isFav = favouriteController.isFavourite(
                          product.id,
                        );
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => isFav
                                ? favouriteController.removeFavourite(
                                    product.id,
                                  )
                                : favouriteController.addToFavourite(product),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav
                                    ? Colors.red.shade500
                                    : Colors.grey.shade600,
                                size: 18,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    if (inStock && product.stock < 10)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.shade500,
                                Colors.orange.shade700,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.flash_on,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${product.stock} left',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ----- معلومات المنتج -----
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // اسم المنتج
                    Row(
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // SKU
                    if (product.sku != null && product.sku!.isNotEmpty)
                      Text(
                        'SKU: ${product.sku}',
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    const Spacer(),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: unavailable
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: unavailable
                                        ? Colors.red
                                        : Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    unavailable ? 'Unavailable' : 'in Stock',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: unavailable
                                          ? Colors.red.shade700
                                          : Colors.green.shade700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        // زر التفاصيل
                        if (!unavailable)
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Get.to(
                                  () => ProductDetailsPage(product: product),
                                ),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary,
                                        theme.colorScheme.primary.withOpacity(
                                          0.8,
                                        ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.visibility_outlined,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        'View',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
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
    );
  }

  // ===================================================================
  // ⏳ Shimmer Loading
  // ===================================================================
  Widget _buildShimmerCard(ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // ===================================================================
  // ❌ Error State
  // ===================================================================
  Widget _buildErrorState(ThemeData theme) {
    return SliverFillRemaining(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                's_w_r'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                productController.errorMessage.value.isEmpty
                    ? 'Failed to load products'
                    : productController.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => productController.retryFetch(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: Text(
                  'try_again'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================================================================
  // 📭 Empty State
  // ===================================================================
  Widget _buildEmptyState(ThemeData theme) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Products Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new items',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================================
  // ✨ Animated Category Button (Implicit Animation)
  // ===================================================================
  Widget _buildAnimatedCategoryButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 28.0 : 20.0),
        margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : (isDark ? Colors.white.withOpacity(0.08) : Colors.white),
          borderRadius: BorderRadius.circular(isSelected ? 16 : 25),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.2)),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : theme.colorScheme.onSurface),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: isSelected ? 15 : 14,
            fontFamily: Get.locale?.languageCode == 'ar' ? 'Cairo' : null,
          ),
          child: Text(title),
        ),
      ),
    );
  }
}
