import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ProductController extends GetxController {
  var products = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs; // يبدأ بـ true لأن التحميل يبدأ فوراً

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;

    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/products'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        products.value = data.map<Map<String, dynamic>>((product) {
          return {
            'id': product['id'],
            'name': product['title'],
            'description': product['description'],
            'price': '\$${product['price']}',
            'category': _mapCategory(product['category']),
            'image': product['image'],
            'rating': product['rating'] != null
                ? product['rating']['rate']
                : 4.0,
          };
        }).toList();
      } else {
        Get.snackbar('Error', 'Failed to load products');
      }
    } catch (e) {
      Get.snackbar('Error', 'Check your internet connection');
    } finally {
      isLoading.value = false;
    }
  }

  String _mapCategory(String category) {
    if (category.contains('men') || category.contains('women')) return 'shirts';
    if (category.contains('jewelery')) return 'accessories';
    if (category.contains('shoe')) return 'shoes';
    return 'all';
  }
}
