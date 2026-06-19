import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:zad/core/api/dio_consumer.dart';
import 'package:zad/core/api/end_points.dart';
import 'package:zad/core/errors/exception.dart';
import 'package:zad/core/api/api_consumer.dart';
import 'package:zad/models/Product.dart';

class ProductController extends GetxController {
  final ApiConsumer _api = DioConsumer(Dio());

  
  var products = <Product>[].obs;
  var isLoading = true.obs;

  
  var hasError = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final response = await _api.get(EndPoints.products);

      
      final dynamic listOrObject = response is Map ? response : {};

      
      List<dynamic> listData;
      if (response is List) {
        listData = response;
      } else {
        final dynamic data = listOrObject['data'];

        if (data is List) {
          listData = data;
        } else if (data is Map && data['data'] is List) {
          listData = data['data'] as List;
        } else if (data == null) {
          listData = <dynamic>[];
        } else {
        
          listData = <dynamic>[];
        }
      }

      products.value = listData
          .map(
            (json) =>
                Product.fromJson(Map<String, dynamic>.from(json as dynamic)),
          )
          .toList();
    } on ServerException catch (e) {
      hasError.value = true;
      errorMessage.value = e.errorModel.errorMessage;
      Get.snackbar('Error', e.errorModel.errorMessage);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load products: ${e.toString()}';
      Get.snackbar('Error', 'Failed to load products: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  
  Future<void> retryFetch() async {
    await loadProducts();
  }
}
