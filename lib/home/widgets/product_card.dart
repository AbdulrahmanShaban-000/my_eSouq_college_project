// lib/home/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zad/controllers/auth_controller.dart';
import 'package:zad/controllers/favourits_controller.dart';
import 'package:zad/controllers/rating_controller.dart';
import 'package:zad/product/screens/product_details_page.dart';
import 'package:zad/models/Product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
            _buildImageSection(theme, imageUrl, inStock, unavailable),
            _buildInfoSection(theme, inStock, unavailable),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(
    ThemeData theme,
    String imageUrl,
    bool inStock,
    bool unavailable,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      flex: 6,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
            _buildGradientOverlay(),
            if (unavailable) _buildUnavailableOverlay(),
            _buildPriceTag(theme),
            _buildRatingBadge(theme),
            _buildFavoriteButton(),
            if (inStock && product.stock < 10) _buildLowStockBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
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
    );
  }

  Widget _buildUnavailableOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 15),
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
    );
  }

  Widget _buildPriceTag(ThemeData theme) {
    return Positioned(
      bottom: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    );
  }

  Widget _buildRatingBadge(ThemeData theme) {
    final ratingController = Get.find<RatingController>();

    return Positioned(
      top: 16,
      left: 16,
      child: Obx(() {
        final avg = ratingController.getAverageRating(product.id);
        final isLoading = ratingController.isLoadingProduct(product.id);

        if (isLoading) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              const Icon(Icons.star, color: Colors.amber, size: 18),
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
    );
  }

  Widget _buildFavoriteButton() {
    final favouriteController = Get.find<FavouriteController>();

    return Positioned(
      top: 12,
      right: 12,
      child: Obx(() {
        if (!Get.find<AuthController>().isLoggedIn.value) {
          return const SizedBox();
        }

        final isFav = favouriteController.isFavourite(product.id);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => isFav
                ? favouriteController.removeFavourite(product.id)
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
                color: isFav ? Colors.red.shade500 : Colors.grey.shade600,
                size: 18,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLowStockBadge() {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade500, Colors.orange.shade700],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 10),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flash_on, color: Colors.white, size: 12),
            const SizedBox(width: 4),
            Text(
              '${product.stock} left',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, bool inStock, bool unavailable) {
    return Expanded(
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            if (product.sku != null && product.sku!.isNotEmpty)
              Text(
                'SKU: ${product.sku}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  fontWeight: FontWeight.w500,
                ),
              ),
            const Spacer(),
            Row(
              children: [
                _buildStockStatus(theme, unavailable),
                const SizedBox(width: 6),
                if (!unavailable) _buildViewButton(theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStatus(ThemeData theme, bool unavailable) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                color: unavailable ? Colors.red : Colors.green,
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
    );
  }

  Widget _buildViewButton(ThemeData theme) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => ProductDetailsPage(product: product)),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
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
    );
  }
}
