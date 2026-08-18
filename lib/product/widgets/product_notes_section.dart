// lib/product/widgets/product_notes_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductNotesSection extends StatelessWidget {
  const ProductNotesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            'Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: null,
            keyboardType: TextInputType.multiline,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.6,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'rnh'.tr,
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
