// lib/home/widgets/most_popular.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:zad/controllers/product_controller.dart';
import 'package:zad/controllers/rating_controller.dart';

class MostPopularProducts extends StatefulWidget {
  const MostPopularProducts({super.key});

  @override
  State<MostPopularProducts> createState() => _MostPopularProductsState();
}

class _MostPopularProductsState extends State<MostPopularProducts> {
  final ProductController productController = Get.find();
  final RatingController ratingController = Get.find();

  // الحد الأدنى للتقييم عشان المنتج يعتبر "الأكثر شعبية"
  static const double _minRating = 3.0;

  // نسبة عرض كل بطاقة من عرض الشاشة (بدل الرقم الثابت 150)
  static const double _viewportFraction = 0.42;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _viewportFraction);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // فلترة المنتجات: بس اللي تقييمها المتوسط أكبر من 3
      final popularProducts = productController.products.where((product) {
        final rating = ratingController.getAverageRating(product.id);
        return rating > _minRating;
      }).toList();

      // لو ما فيه منتجات مطابقة، ما نعرض شي
      if (popularProducts.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'most_popular'.tr, // أضف المفتاح هذا لملفات الترجمة عندك
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 250,
            child: PageView.builder(
              controller: _pageController,
              padEnds: false,
              itemCount: popularProducts.length,
              itemBuilder: (context, index) {
                final product = popularProducts[index];
                final rating = ratingController.getAverageRating(product.id);

                // نفس منطق الأنيميشن المستخدم في DiscountsSlider:
                // نراقب PageController ونحسب scale/opacity حسب بعد
                // البطاقة عن مركز الشاشة.
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double scale = 1.0;
                    double opacity = 1.0;

                    if (_pageController.position.haveDimensions) {
                      final page = _pageController.page ?? index.toDouble();
                      final delta = (page - index).abs();
                      scale = (1 - (delta * 0.12)).clamp(0.88, 1.0);
                      opacity = (1 - (delta * 0.4)).clamp(0.6, 1.0);
                    }

                    return Center(
                      child: Opacity(
                        opacity: opacity,
                        child: Transform.scale(scale: scale, child: child),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: CachedNetworkImage(
                              imageUrl: product.getImageUrl(),
                              fit: BoxFit.cover,
                              fadeInDuration: const Duration(milliseconds: 200),
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${product.price}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
