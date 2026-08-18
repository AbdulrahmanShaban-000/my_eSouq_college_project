// lib/home/widgets/category_list.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/controllers/categories_controller.dart';
import 'package:zad/home/widgets/category_button.dart';

class CategoryList extends StatelessWidget {
  final RxInt selectedCategoryId;

  const CategoryList({super.key, required this.selectedCategoryId});

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.find<CategoryController>();

    return Obx(() {
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
                return CategoryButton(
                  title: 'all'.tr,
                  isSelected: isSelected,
                  onTap: () => selectedCategoryId.value = 0,
                );
              });
            }

            final category = categories[index - 1];
            return Obx(() {
              final isSelected = selectedCategoryId.value == category.catid;
              return CategoryButton(
                title: category.name,
                isSelected: isSelected,
                onTap: () => selectedCategoryId.value = category.catid,
              );
            });
          },
        ),
      );
    });
  }
}
