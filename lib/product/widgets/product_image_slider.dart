// lib/product/widgets/product_image_slider.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:zad/controllers/rating_controller.dart';
import 'package:zad/product/widgets/product_images_viewer.dart';

class ProductImageSlider extends StatefulWidget {
  final int productId;
  final List<String> images;
  final String heroTag;

  const ProductImageSlider({
    super.key,
    required this.productId,
    required this.images,
    required this.heroTag,
  });

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openImageViewer(int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (_) =>
          ProductImagesViewer(images: widget.images, initialIndex: index),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: Hero(
            tag: widget.heroTag,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openImageViewer(_currentImageIndex),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _openImageViewer(index),
                    child: CachedNetworkImage(
                      imageUrl: widget.images[index],
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
                  );
                },
              ),
            ),
          ),
        ),
        if (widget.images.length > 1) _buildDotsIndicator(),
        _buildRatingBadge(theme),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDotsIndicator() {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.images.length, (index) {
          final isActive = index == _currentImageIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 18 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRatingBadge(ThemeData theme) {
    final ratingController = Get.find<RatingController>();
    final productId = widget.productId;

    return Positioned(
      bottom: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
        ),
        child: Obx(() {
          final avg = ratingController.getAverageRating(productId);
          final isLoading = ratingController.isLoadingProduct(productId);

          if (isLoading) {
            return const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
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
    );
  }
}
