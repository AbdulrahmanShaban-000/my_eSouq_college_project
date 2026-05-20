import 'package:get/get.dart';

class RecentOrdersController extends GetxController {
  RxList<Map<String, dynamic>> recentOrders = <Map<String, dynamic>>[].obs;

  void addOrder(Map<String, dynamic> product) {
     
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
}
