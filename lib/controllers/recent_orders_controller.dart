import 'package:get/get.dart';
import 'package:zad/models/Product.dart';

class RecentOrdersController extends GetxController {
  RxList<Map<String, dynamic>> recentOrders = <Map<String, dynamic>>[].obs;

  // إضافة دالة جديدة تقبل Product
  void addOrder(Product product) {
    // تحويل Product إلى Map
    final productMap = {
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'stock': product.stock,
      'is_active': product.isActive,
      'sku': product.sku,
      'slug': product.slug,
      'added_at': DateTime.now().toIso8601String(),
    };

    final exists = recentOrders.any((item) => item['id'] == product.id);
    if (exists) return;

    recentOrders.insert(0, productMap);

    if (recentOrders.length > 10) {
      recentOrders.removeLast();
    }

    Get.snackbar(
      'Added to Recent Orders',
      '${product.name} has been added to your recent orders',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  
  void addOrderFromMap(Map<String, dynamic> product) {
    final exists = recentOrders.any((item) => item['id'] == product['id']);
    if (exists) return;

    recentOrders.insert(0, product);

    if (recentOrders.length > 10) {
      recentOrders.removeLast();
    }
  }

  void removeOrder(int id) {
    recentOrders.removeWhere((item) => item['id'] == id);
  }

  void clearOrders() {
    recentOrders.clear();
  }


  List<Product> get recentProducts {
    return recentOrders.map((map) => Product.fromJson(map)).toList();
  }
}
