import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/controllers/filtering_controller.dart';
import 'package:zad/models/product_filter_param.dart';

class FilterBottomSheet extends StatefulWidget {
  final ProductFilterParams initialParams;
  const FilterBottomSheet({super.key, required this.initialParams});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _minPrice;
  late double _maxPrice;
  late bool? _inStock;
  late String _sort;
  late String _order;
  late List<int> _selectedCategories;

  final FilterController filterController = Get.find();

  List<Map<String, dynamic>> get _categoryOptions {
    final raw =
        filterController.filterOptions['categories'] ??
        filterController.filterOptions['category'] ??
        const <dynamic>[];
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((item) {
          return Map<String, dynamic>.from(item);
        })
        .where((item) => item['id'] != null)
        .toList();
  }

  String _categoryName(Map<String, dynamic> category) {
    final isArabic = Get.locale?.languageCode == 'ar';
    final localized = isArabic
        ? (category['name_ar'] ?? category['ar_name'])
        : (category['name_en'] ?? category['en_name']);
    return (localized ?? category['name'] ?? category['title'] ?? '')
        .toString();
  }

  @override
  void initState() {
    super.initState();
    _minPrice = widget.initialParams.minPrice ?? 0;
    _maxPrice = widget.initialParams.maxPrice ?? 10000;
    _inStock = widget.initialParams.inStock;
    _sort = widget.initialParams.sort;
    _order = widget.initialParams.order;
    _selectedCategories = List.from(widget.initialParams.categories);
  }

  // --- دالة مساعدة لتجميل عناوين الأقسام ---
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 24.0,
        top: 12.0,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- مؤشر السحب أعلى النافذة (Drag Handle) ---
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // --- ترويسة النافذة ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'filter_products'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    filterController.resetFilters();
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  label: Text(
                    'reset_filters'.tr,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // --- قسم الأقسام (Categories) ---
            Obx(() {
              final categories = _categoryOptions;
              if (categories.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('categories'.tr, Icons.category_outlined),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: categories.map((category) {
                        final id = int.tryParse(category['id'].toString());
                        if (id == null) return const SizedBox.shrink();
                        return CheckboxListTile(
                          dense: true,
                          activeColor: theme.primaryColor,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            _categoryName(category),
                            style: const TextStyle(fontSize: 15),
                          ),
                          value: _selectedCategories.contains(id),
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedCategories.add(id);
                              } else {
                                _selectedCategories.remove(id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }),

            // --- قسم السعر (Price Range) ---
            _buildSectionHeader(
              'price_range'.tr,
              Icons.account_balance_wallet_outlined,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  RangeSlider(
                    values: RangeValues(_minPrice, _maxPrice),
                    min: 0,
                    max: 10000,
                    divisions: 100,
                    activeColor: theme.primaryColor,
                    inactiveColor: theme.primaryColor.withOpacity(0.2),
                    labels: RangeLabels(
                      '${_minPrice.toStringAsFixed(0)} \$',
                      '${_maxPrice.toStringAsFixed(0)} \$',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _minPrice = values.start;
                        _maxPrice = values.end;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_minPrice.toStringAsFixed(0)} \$',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_maxPrice.toStringAsFixed(0)} \$',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- قسم حالة المتجر (In Stock) ---
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: CheckboxListTile(
                activeColor: theme.primaryColor,
                title: Text(
                  'in_stock_only'.tr,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                secondary: Icon(
                  Icons.inventory_2_outlined,
                  color: theme.primaryColor,
                ),
                value: _inStock ?? false,
                onChanged: (val) {
                  setState(() {
                    _inStock = val == true ? true : null;
                  });
                },
              ),
            ),

            // --- قسم الترتيب (Sort & Order) دمجناهم بجانب بعض ---
            _buildSectionHeader('sort_by'.tr, Icons.sort_rounded),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sort,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        items: [
                          DropdownMenuItem(
                            value: 'id',
                            child: Text('sort_default'.tr),
                          ),
                          DropdownMenuItem(
                            value: 'price',
                            child: Text('sort_price'.tr),
                          ),
                          DropdownMenuItem(
                            value: 'name',
                            child: Text('sort_name'.tr),
                          ),
                          DropdownMenuItem(
                            value: 'created_at',
                            child: Text('sort_newest'.tr),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _sort = val);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _order,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        items: [
                          DropdownMenuItem(
                            value: 'asc',
                            child: Text('ascending'.tr),
                          ),
                          DropdownMenuItem(
                            value: 'desc',
                            child: Text('descending'.tr),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _order = val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // --- زر التطبيق الرئيسي ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.filter_alt_outlined),
                label: Text(
                  'apply_filter'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  final newParams = widget.initialParams.copyWith(
                    minPrice: _minPrice == 0 ? null : _minPrice,
                    maxPrice: _maxPrice == 10000 ? null : _maxPrice,
                    inStock: _inStock,
                    sort: _sort,
                    order: _order,
                    categories: _selectedCategories,
                  );
                  filterController.applyFilter(newParams.copyWith(page: 1));
                  Get.back();
                },
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
