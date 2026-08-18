// lib/product/widgets/product_quantity_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/models/Product.dart';

class ProductQuantitySection extends StatelessWidget {
  final Product product;
  final RxInt quantity;

  const ProductQuantitySection({
    super.key,
    required this.product,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final total = product.price * quantity.value;
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
            _buildQuantitySelector(theme),
            const Divider(height: 20),
            _buildTotal(theme, total),
          ],
        ),
      );
    });
  }

  Widget _buildQuantitySelector(ThemeData theme) {
    return Row(
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
            color: theme.colorScheme.onSurface.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (quantity.value > 1) {
                    quantity.value--;
                  }
                },
                icon: Icon(
                  Icons.remove,
                  color: theme.colorScheme.onSurface,
                  size: 20,
                ),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotal(ThemeData theme, double total) {
    return Row(
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
    );
  }
}
