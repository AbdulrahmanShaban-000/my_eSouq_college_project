import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/controllers/cart_controller.dart';
import 'package:zad/controllers/favourits_controller.dart';
import 'package:zad/controllers/rating_controller.dart';
import 'package:zad/controllers/recent_orders_controller.dart';
import 'package:zad/models/Product.dart';
import 'package:zad/home/screens/cart_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zad/home/screens/favourites_page.dart';
import 'package:zad/home/screens/home_page.dart';
import 'package:zad/home/screens/nav_bar.dart';
import 'package:zad/home/screens/profile_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

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
  final RatingController ratingController = Get.find<RatingController>();

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

  @override
  void initState() {
    super.initState();
   
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRatings();
    });
  }

 
  Future<void> _loadRatings() async {
    try {
      final productId = widget.product.id;
      await ratingController.fetchAverageRating(productId);
      await ratingController.fetchUserRating(productId);
      print(
        '✅ Product $productId - User rating: ${ratingController.getUserRating(productId)}',
      );
    } catch (e) {
      print('❌ Error loading ratings: $e');
    }
  }

  void addToCart() {
    cartController.addToCart(widget.product, quantity.value);
    recentOrdersController.addOrder(widget.product);

    Get.snackbar(
      'cart_title'.tr,
      'Added successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

 
  void _submitRating(int rating) async {
    if (rating < 0 || rating > 5) return;

    final productId = widget.product.id;

    try {
      
      if (rating == 0) {
        if (ratingController.getUserRating(productId) == 0) return;

        
        ratingController.userRatings[productId] = 0;

       
        await ratingController.deleteRating(productId);
        await ratingController.fetchAverageRating(productId);

        Get.snackbar(
          'Rating',
          'تم إلغاء التقييم',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

    
      ratingController.userRatings[productId] = rating;

     
      await ratingController.addOrUpdateRating(
        productId: productId,
        rating: rating,
      );

      
      await ratingController.fetchAverageRating(productId);

     
      print('✅ Rating updated for product $productId to: $rating');

      Get.snackbar(
        'Rating',
        'تم حفظ التقييم بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
    
      await ratingController.fetchUserRating(productId);

      Get.snackbar(
        'Error',
        'فشل في حفظ التقييم: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ✅ Widget التقييم المحسن
  Widget _buildRatingSection(ThemeData theme, bool isDark) {
    final productId = widget.product.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان والمتوسط
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rating & Reviews',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
             
              Obx(() {
                final avg = ratingController.getAverageRating(productId);
                final isLoading = ratingController.isLoadingProduct(productId);

                if (isLoading) {
                  return const SizedBox(
                    width: 60,
                    height: 20,
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                return Row(
                  children: [
                    Text(
                      avg > 0 ? avg.toStringAsFixed(1) : '0.0',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.star, color: Colors.amber.shade600, size: 20),
                  ],
                );
              }),
            ],
          ),

          const SizedBox(height: 12),

      
          Obx(() {
            final currentRating = ratingController.getUserRating(productId);
            final isLoading = ratingController.isLoadingProduct(productId);

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starNumber = index + 1;
                final isSelected = currentRating >= starNumber;

                return GestureDetector(
                  onTap: isLoading ? null : () => _submitRating(starNumber),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      isSelected ? Icons.star : Icons.star_border,
                      color: isSelected
                          ? Colors.amber.shade600
                          : theme.colorScheme.onSurface.withOpacity(0.2),
                      size: 32,
                    ),
                  ),
                );
              }),
            );
          }),

          const SizedBox(height: 8),

          // ✅ نص تعليمي محسن
          Obx(() {
            final currentRating = ratingController.getUserRating(productId);
            final isLoading = ratingController.isLoadingProduct(productId);

            if (isLoading) {
              return const Center(
                child: SizedBox(height: 20, child: Text('جاري التحميل...')),
              );
            }

            return Center(
              child: Text(
                currentRating > 0
                    ? '⭐ تقييمك: $currentRating من 5'
                    : '👆 اضغط على النجمة لتقييم المنتج',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }),

          // ✅ زر إلغاء التقييم
          Obx(() {
            if (ratingController.getUserRating(productId) > 0 &&
                !ratingController.isLoadingProduct(productId)) {
              return Center(
                child: TextButton(
                  onPressed: () => _submitRating(0),
                  child: Text(
                    '🗑️ إلغاء تقييمي',
                    style: TextStyle(color: Colors.red.shade400, fontSize: 12),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final product = widget.product;
    final productId = product.id;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                : [Colors.grey[50]!, Colors.grey[200]!, Colors.grey[300]!],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            /// APP BAR مع عرض متوسط التقييم على الصورة
            SliverAppBar(
              expandedHeight: 320,
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
                  final isFav = favouriteController.isFavourite(product.id);
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : theme.colorScheme.onSurface,
                    ),
                    onPressed: () => isFav
                        ? favouriteController.removeFavourite(product.id)
                        : favouriteController.addToFavourite(product),
                  );
                }),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // صورة المنتج
                    Positioned.fill(
                      child: Hero(
                        tag: 'product_${product.id}',
                        child: CachedNetworkImage(
                          imageUrl: product.getImageUrl(),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            child: Center(
                              child: SizedBox(
                                width: 36,
                                height: 36,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 100,
                              color: theme.colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ✅ عرض متوسط التقييم على الصورة
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Obx(() {
                          final avg = ratingController.getAverageRating(
                            productId,
                          );
                          final isLoading = ratingController.isLoadingProduct(
                            productId,
                          );

                          if (isLoading) {
                            return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            );
                          }

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                avg > 0 ? avg.toStringAsFixed(1) : '0.0',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),

                    // تدرج أسفل الصورة
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
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
                    /// TITLE + PRICE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // SKU
                    if (product.sku != null && product.sku!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'SKU: ${product.sku}',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.primary.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    const SizedBox(height: 8),

                    // حالة المخزون
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: product.stock > 0
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: product.stock > 0
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                product.stock > 0
                                    ? Icons.check_circle_outline
                                    : Icons.cancel_outlined,
                                size: 16,
                                color: product.stock > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                product.stock > 0
                                    ? '${'in_stock'.tr} (${product.stock})'
                                    : 'out_of_stock'.tr,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: product.stock > 0
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// ✅ SECTION: RATING
                    _buildRatingSection(theme, isDark),

                    const SizedBox(height: 20),

                    /// DESCRIPTION
                    if (product.description != null &&
                        product.description!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description!,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.8,
                                ),
                                height: 1.6,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    /// SIZE
                    if (sizes.isNotEmpty) ...[
                      Text(
                        'Select Size',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(
                        () => Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(sizes.length, (i) {
                            final selected = selectedSize.value == i;
                            return GestureDetector(
                              onTap: () => selectedSize.value = i,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface.withOpacity(
                                          0.05,
                                        ),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.transparent
                                        : theme.colorScheme.onSurface
                                              .withOpacity(0.1),
                                    width: 2,
                                  ),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: theme.colorScheme.primary
                                                .withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
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
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    /// COLOR
                    if (colors.isNotEmpty) ...[
                      Text(
                        'Select Color',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(
                        () => Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: List.generate(colors.length, (i) {
                            final selected = selectedColor.value == i;
                            return GestureDetector(
                              onTap: () => selectedColor.value = i,
                              child: Column(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: colors[i]['color'],
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: selected
                                            ? (colors[i]['name'] == 'White' &&
                                                      !isDark
                                                  ? Colors.black
                                                  : theme.colorScheme.onSurface)
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                      boxShadow: selected
                                          ? [
                                              BoxShadow(
                                                color: theme.colorScheme.primary
                                                    .withOpacity(0.4),
                                                blurRadius: 12,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: selected
                                        ? Icon(
                                            Icons.check,
                                            color:
                                                colors[i]['name'] == 'White' &&
                                                    !isDark
                                                ? Colors.black
                                                : Colors.white,
                                            size: 20,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    colors[i]['name'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: selected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface
                                                .withOpacity(0.5),
                                      fontWeight: selected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    /// QUANTITY & TOTAL
                    Obx(() {
                      final total = product.price * quantity.value;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.08,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Quantity',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(16),
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
                                          size: 20,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 40,
                                          minHeight: 40,
                                        ),
                                      ),
                                      Text(
                                        '${quantity.value}',
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          if (quantity.value < product.stock) {
                                            quantity.value++;
                                          } else {
                                            Get.snackbar(
                                              'Out of Stock',
                                              'Max available: ${product.stock}',
                                              backgroundColor: Colors.orange,
                                              colorText: Colors.white,
                                              snackPosition: SnackPosition.TOP,
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          Icons.add,
                                          color: theme.colorScheme.onSurface,
                                          size: 20,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 40,
                                          minHeight: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  '\$${total.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.green.shade600,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    /// ADD TO CART
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: product.isActive == 1 && product.stock > 0
                            ? addToCart
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_checkout_rounded,
                              color: product.isActive == 1 && product.stock > 0
                                  ? theme.colorScheme.onPrimary
                                  : Colors.grey.shade600,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              product.isActive == 1 && product.stock > 0
                                  ? 'add_to_cart'.tr
                                  : 'unavailable'.tr,
                              style: TextStyle(
                                color:
                                    product.isActive == 1 && product.stock > 0
                                    ? theme.colorScheme.onPrimary
                                    : Colors.grey.shade600,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// ADD TO WISH LIST
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton(
                        onPressed: () {
                          if (favouriteController.isFavourite(product.id)) {
                            Get.snackbar(
                              'Already in Wish List',
                              'This product is already in your wish list.',
                              backgroundColor: Colors.orange,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                            );
                          } else {
                            favouriteController.addToFavourite(product);
                            Get.snackbar(
                              'Wish List',
                              'Added to wish list successfully.',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(
                            color: theme.colorScheme.primary.withOpacity(0.5),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(() {
                              final isFav = favouriteController.isFavourite(
                                product.id,
                              );
                              return Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav
                                    ? Colors.red.shade500
                                    : theme.colorScheme.primary,
                                size: 22,
                              );
                            }),
                            const SizedBox(width: 10),
                            Obx(() {
                              final isFav = favouriteController.isFavourite(
                                product.id,
                              );
                              return Text(
                                isFav
                                    ? 'remove_from_wish_list'.tr
                                    : 'add_to_wish_list'.tr,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              );
                            }),
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
