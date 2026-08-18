// lib/home/widgets/category_button.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 28.0 : 20.0),
        margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : (isDark ? Colors.white.withOpacity(0.08) : Colors.white),
          borderRadius: BorderRadius.circular(isSelected ? 16 : 25),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.2)),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : theme.colorScheme.onSurface),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: isSelected ? 15 : 14,
            fontFamily: Get.locale?.languageCode == 'ar' ? 'Cairo' : null,
          ),
          child: Text(title),
        ),
      ),
    );
  }
}
