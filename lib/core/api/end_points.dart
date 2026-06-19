class EndPoints {
  static const String baseUrl = 'http://localhost:8000/api/';
  static const String products = 'products';
  static const String searchProducts = 'products/search';
  static const String filterProducts = 'products/filter';
  static const String register = 'register';
  static const String login = 'login';
  static const String logout = 'logout';
  static String productDetails(dynamic id) => 'products/$id';
  static String productCategories(int id) => 'products/$id/categories';
  static String productsByCategory(int id) => 'products/category/$id';
  static const String lowStockProducts = 'products/low-stock';
  static const String productStatistics = 'products/statistics';
  static const String priceStats = 'products/price-stats';
  static const String availableCategories = 'products/available-categories';
  static const String filterOptions = 'products/filter-options';
  static const String bulkUpdateStatus = 'products/bulk-update-status';
  static const String favourites = 'favorites';
  static const String cart = 'cart';
  static const String addRate = 'rate/add';
   static const String categories = 'categories'; 
}

class ApiKeys {
  static const String message = 'message';
  static const String data = 'data';
  static const String product = 'product';
  static const String token = 'token';
  static const String id = 'id';
  static const String name = 'name';
  static const String slug = 'slug';
  static const String description = 'description';
  static const String price = 'price';
  static const String stock = 'stock';
  static const String sku = 'sku';
  static const String isActive = 'is_active';
  static const String categories = 'categories';
  static const String images = 'images';
  static const String statusCode = 'status';
  static const String currentPage = 'current_page';
  static const String lastPage = 'last_page';
  static const String total = 'total';
  static const String errors = 'errors';
}
