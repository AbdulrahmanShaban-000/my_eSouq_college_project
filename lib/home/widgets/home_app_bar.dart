// lib/home/widgets/home_app_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/controllers/cart_controller.dart';
import 'package:zad/screens/cart_page.dart';
import 'package:zad/models/Product.dart';
import 'package:zad/services/product_search_delegate.dart';
import 'package:zad/services/storage_service.dart';

class HomeAppBar extends StatelessWidget {
  final List<Product> products;
  final RxBool isSearching;

  const HomeAppBar({
    super.key,
    required this.products,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cartController = Get.find<CartController>();

    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: isDark
          ? const Color(0xFF0F2027).withOpacity(0.95)
          : Colors.white.withOpacity(0.92),
      elevation: 0,
      iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      flexibleSpace: FlexibleSpaceBar(
        title: _buildTitle(theme),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF0F2027), const Color(0xFF203A43)]
                  : [Colors.white, const Color(0xFFF0F4FF)],
            ),
          ),
        ),
      ),
      actions: [
        _buildSearchButton(theme),
        _buildLanguageButton(theme),
        _buildCartButton(theme, cartController, isDark),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Obx(
          () => isSearching.value
              ? _buildSearchTextField(theme, isDark)
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.shopping_bag, color: theme.colorScheme.primary, size: 28),
        const SizedBox(width: 8),
        Text(
          'zad'.tr,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchButton(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () => _openSearch(),
        icon: Icon(
          Icons.search_rounded,
          color: theme.colorScheme.primary,
          size: 22,
        ),
      ),
    );
  }

  void _openSearch() {
    FocusScope.of(Get.context!).unfocus();

    Navigator.of(Get.context!).push(
      MaterialPageRoute(
        builder: (context) => SearchPage(products: products),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _buildLanguageButton(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: _toggleLanguage,
        icon: Icon(
          Icons.translate_rounded,
          color: theme.colorScheme.primary,
          size: 22,
        ),
      ),
    );
  }

  void _toggleLanguage() async {
    final newLang = Get.locale?.languageCode == 'en' ? 'ar' : 'en';
    await StorageService.setLanguage(newLang);
    Get.updateLocale(Locale(newLang));
  }

  Widget _buildCartButton(
    ThemeData theme,
    CartController cartController,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Obx(() {
        final itemCount = cartController.totalItems;
        return Stack(
          children: [
            IconButton(
              onPressed: () => Get.to(() => CartPage()),
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            if (itemCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.black : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      itemCount > 99 ? '99+' : '$itemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildSearchTextField(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: TextField(
          onTap: _openSearch,
          decoration: InputDecoration(
            hintText: 'search_products'.tr,
            hintStyle: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: theme.colorScheme.primary.withOpacity(0.6),
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}
