import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:my_esouq/core/api/dio_consumer.dart';
import 'package:my_esouq/core/api/end_points.dart';
import 'package:my_esouq/core/errors/exception.dart';
import 'package:my_esouq/core/api/api_consumer.dart';

class ProductController extends GetxController {
  final ApiConsumer _api = DioConsumer(Dio());

  var products = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;

    try {
      final data = await _api.get(EndPoints.products);
      final List listData = data is List ? data : (data as List).toList();

      products.value = listData.map<Map<String, dynamic>>((product) {
        return {
          'id': product['id'],
          'name': product['title'],
          'description': product['description'],
          'price': '\$${product['price']}',
          'category': _mapCategory(product['category']),
          'image': product['image'],
          'rating': product['rating'] != null ? product['rating']['rate'] : 4.0,
        };
      }).toList();
    } on ServerException catch (e) {
      Get.snackbar('Error', e.errorModel.errorMessage);
    } catch (_) {
      Get.snackbar('Error', 'Failed to load products');
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
