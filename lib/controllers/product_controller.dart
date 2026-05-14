/*
class ProductController extends GetxController {
  var products = <Map<String, dynamic>>[].obs;
  var isLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (!isLoaded.value) {
      loadProducts();
      isLoaded.value = true;
    }
  }
}
*/



import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ProductController extends GetxController {
 var products = <Map<String, dynamic>>[].obs;
  var isLoaded = false.obs;


  bool _loaded = false; // 👈 مهم
 @override
  void onInit() {
    super.onInit();
    if (!isLoaded.value) {
      loadProducts();
      isLoaded.value = true;
    }
  }

  Future<void> loadProducts() async {
    if (_loaded) return; // 👈 يمنع إعادة التحميل

    try {
      isLoaded.value = true;

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

        _loaded = true; // 👈 تم التحميل مرة واحدة فقط
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products');
    } finally {
      isLoaded.value = false;
    }
  }

  String _mapCategory(String category) {
    if (category.contains('men') || category.contains('women')) {
      return 'shirts';
    }
    if (category.contains('jewelery')) {
      return 'accessories';
    }
    if (category.contains('shoe')) {
      return 'shoes';
    }
    return 'all';
  }
}
