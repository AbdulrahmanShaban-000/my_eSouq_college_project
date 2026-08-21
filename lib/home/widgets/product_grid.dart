// lib/home/widgets/product_grid.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/controllers/product_controller.dart';
import 'package:zad/home/mixins/category_helpers.dart';
import 'package:zad/home/widgets/empty_state.dart';
import 'package:zad/home/widgets/error_state.dart';
import 'package:zad/home/widgets/product_card.dart';
import 'package:zad/home/widgets/shimmer_card.dart';
import 'package:zad/models/Product.dart';
import 'package:zad/models/categories.dart';

class ProductGrid extends StatelessWidget with CategoryHelpers {
  final List<Product> allProducts;
  final int selectedCategoryId;
  final List<Category> categoriesTree;

  const ProductGrid({
    super.key,
    required this.allProducts,
    required this.selectedCategoryId,
    required this.categoriesTree,
  });

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();

    return Obx(() {
      if (productController.isLoading.value) {
        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const ShimmerCard(),
              childCount: 6,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.75,
            ),
          ),
        );
      }

      if (productController.hasError.value) {
        return SliverToBoxAdapter(
          child: ErrorState(
            errorMessage: productController.errorMessage.value,
            onRetry: () => productController.retryFetch(),
          ),
        );
      }

      final products = _filterProducts();

      if (products.isEmpty) {
        return SliverToBoxAdapter(
          child: EmptyState(
            title: 'no_products_found'.tr,
            subtitle: 'try_again'.tr,
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate((context, index) {
            final hasMorePages =
                productController.currentPage.value <=
                productController.totalPages.value;

            if (index >= products.length - 2 &&
                hasMorePages &&
                !productController.isLoadingMore.value) {
              Future.microtask(() => productController.loadMoreProducts());
            }

            return ProductCard(product: products[index]);
          }, childCount: products.length),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
        ),
      );
    });
  }

  List<Product> _filterProducts() {
    if (selectedCategoryId == 0) {
      return allProducts;
    }

    final selectedCategory = findCategoryById(
      categoriesTree,
      selectedCategoryId,
    );
    if (selectedCategory == null) return [];

    final validIds = getCategoryIdsIncludingChildren(selectedCategory);
    return allProducts.where((p) {
      return p.categoryIds.any((id) => validIds.contains(id));
    }).toList();
  }
}
