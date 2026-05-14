import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_esouq/home/screens/cart_page.dart';
import 'package:my_esouq/home/screens/home_page.dart';
import 'package:my_esouq/home/screens/profile_page.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF0F2027),
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.white54,
      currentIndex: currentIndex,
      onTap: onTap,

      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'home'.tr),
        BottomNavigationBarItem(
          icon: const Icon(Icons.favorite),
          label: 'favourites'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.shopping_cart),
          label: 'cart'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: 'profile'.tr,
        ),
      ],
    );
  }
}

final List<Widget> pages = [HomePage(), CartPage(), ProfilePage()];
