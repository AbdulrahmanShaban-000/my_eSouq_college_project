import 'package:flutter/material.dart';

class AppTheme {
  static const List<Color> darkGradient = [
    Color(0xFF0F2027),
    Color(0xFF203A43),
    Color(0xFF2C5364),
  ];

  static const List<Color> lightGradient = [
    Color(0xFFFAFAFA),
    Color(0xFFE0E0E0),
    Color(0xFFBDBDBD),
  ];

  static BoxDecoration background(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark ? darkGradient : lightGradient,
      ),
    );
  }
}
