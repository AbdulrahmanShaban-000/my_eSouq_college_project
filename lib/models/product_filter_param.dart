class ProductFilterParams {
  String? search;
  List<int> categories;
  double? minPrice;
  double? maxPrice;
  bool? inStock;
  String sort;
  String order;
  int page;
  int limit;

  ProductFilterParams({
    this.search,
    this.categories = const [],
    this.minPrice,
    this.maxPrice,
    this.inStock,
    this.sort = 'id',
    this.order = 'asc',
    this.page = 1,
    this.limit = 10,
  });

  bool get hasActiveFilters =>
      (search?.trim().isNotEmpty ?? false) ||
      categories.isNotEmpty ||
      minPrice != null ||
      maxPrice != null ||
      inStock != null ||
      sort != 'id' ||
      order != 'asc';

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (search != null && search!.isNotEmpty) map['search'] = search;
    if (categories.isNotEmpty) {
      map['categories'] = categories;
    }
    if (minPrice != null) map['min_price'] = minPrice;
    if (maxPrice != null) map['max_price'] = maxPrice;
    if (inStock != null) map['in_stock'] = inStock! ? 1 : 0;
    if (sort != 'id') map['sort'] = sort;
    if (order != 'asc') map['order'] = order;
    map['page'] = page;
    map['per_page'] = limit;
    return map;
  }

  ProductFilterParams copyWith({
    String? search,
    List<int>? categories,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    String? sort,
    String? order,
    int? page,
    int? limit,
  }) {
    return ProductFilterParams(
      search: search ?? this.search,
      categories: categories ?? this.categories,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      inStock: inStock ?? this.inStock,
      sort: sort ?? this.sort,
      order: order ?? this.order,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}
