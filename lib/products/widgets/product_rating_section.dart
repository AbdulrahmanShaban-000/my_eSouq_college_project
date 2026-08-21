// lib/product/widgets/product_rating_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/products/mixins/rating_mixin.dart';

class ProductRatingSection extends StatefulWidget {
  final int productId;

  const ProductRatingSection({super.key, required this.productId});

  @override
  State<ProductRatingSection> createState() => _ProductRatingSectionState();
}

class _ProductRatingSectionState extends State<ProductRatingSection>
    with RatingMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productId = widget.productId;

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
          _buildHeader(theme, productId),
          const SizedBox(height: 12),
          _buildStars(theme, productId),
          const SizedBox(height: 8),
          _buildHintText(theme, productId),
          _buildRemoveButton(theme, productId),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, int productId) {
    return Row(
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
    );
  }

  Widget _buildStars(ThemeData theme, int productId) {
    return Obx(() {
      final currentRating = ratingController.getUserRating(productId);
      final isLoading = ratingController.isLoadingProduct(productId);

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final starNumber = index + 1;
          final isSelected = currentRating >= starNumber;

          return GestureDetector(
            onTap: isLoading ? null : () => submitRating(productId, starNumber),
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
    });
  }

  Widget _buildHintText(ThemeData theme, int productId) {
    return Obx(() {
      final isLoading = ratingController.isLoadingProduct(productId);

      if (isLoading) {
        return const Center(
          child: SizedBox(height: 20, child: Text('جاري التحميل...')),
        );
      }

      return Center(
        child: Text(
          'rate'.tr,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    });
  }

  Widget _buildRemoveButton(ThemeData theme, int productId) {
    return Obx(() {
      if (ratingController.getUserRating(productId) > 0 &&
          !ratingController.isLoadingProduct(productId)) {
        return Center(
          child: TextButton(
            onPressed: () => submitRating(productId, 0),
            child: Text(
              'rmr'.tr,
              style: TextStyle(color: Colors.red.shade400, fontSize: 12),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}
