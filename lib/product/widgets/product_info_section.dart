// lib/product/widgets/product_info_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/models/Product.dart';

class ProductInfoSection extends StatelessWidget {
  final Product product;

  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleAndPrice(theme),
        const SizedBox(height: 6),
        _buildSku(theme),
        const SizedBox(height: 8),
        _buildStockStatus(theme),
        const SizedBox(height: 20),
        _buildDescription(theme),
      ],
    );
  }

  Widget _buildTitleAndPrice(ThemeData theme) {
    return Row(
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
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
    );
  }

  Widget _buildSku(ThemeData theme) {
    if (product.sku == null || product.sku!.isEmpty)
      return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
    );
  }

  Widget _buildStockStatus(ThemeData theme) {
    final bool inStock = product.stock > 0;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: inStock
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: inStock
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                inStock ? Icons.check_circle_outline : Icons.cancel_outlined,
                size: 16,
                color: inStock ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 6),
              Text(
                inStock
                    ? '${'in_stock'.tr} (${product.stock})'
                    : 'out_of_stock'.tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: inStock ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme) {
    if (product.description == null || product.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
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
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.6,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
