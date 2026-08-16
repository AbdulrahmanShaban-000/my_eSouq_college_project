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

  // ✅ Pagination variables
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  // ✅ تحميل المنتجات مع Pagination
  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      products.clear();
    }

    if (currentPage.value > totalPages.value && !refresh) {
      print('✅ All products loaded');
      return;
    }

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final response = await _api.get(
        EndPoints.products,
        queryParameters: {
          'page': currentPage.value,
          'per_page': 20, // ✅ زيادة عدد المنتجات
          '_': DateTime.now().millisecondsSinceEpoch, // ✅ منع Cache
        },
      );

      print('📦 Page ${currentPage.value} Response: $response');

      if (response is Map<String, dynamic>) {
        final data = response['data'];

        if (data is Map<String, dynamic>) {
          // ✅ Paginated response
          final productsData = data['data'] as List? ?? [];
          final pagination = data;

          totalPages.value = pagination['last_page'] ?? 1;
          final currentPageData = pagination['current_page'] ?? 1;

          final pageProducts = productsData.map((json) {
            return Product.fromJson(Map<String, dynamic>.from(json));
          }).toList();

          if (refresh) {
            products.value = pageProducts;
          } else {
            products.addAll(pageProducts);
          }

          print(
            '✅ Page $currentPageData: ${pageProducts.length} products loaded',
          );
          print('✅ Total products: ${products.length}');

          currentPage.value = currentPageData + 1;
        } else if (data is List) {
          // ✅ Non-paginated response
          final pageProducts = data.map((json) {
            return Product.fromJson(Map<String, dynamic>.from(json));
          }).toList();

          if (refresh) {
            products.value = pageProducts;
          } else {
            products.addAll(pageProducts);
          }

          totalPages.value = 1;
          currentPage.value = 2;
        }
      }

      // ✅ طباعة المنتجات للتأكد
      for (var product in products) {
        print('📱 Product: ${product.name} - ID: ${product.id}');
      }
    } on ServerException catch (e) {
      hasError.value = true;
      errorMessage.value = e.errorModel.errorMessage;
      Get.snackbar('خطأ', e.errorModel.errorMessage);
      print('❌ Server Error: ${e.errorModel.errorMessage}');
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'فشل تحميل المنتجات: ${e.toString()}';
      Get.snackbar('خطأ', errorMessage.value);
      print('❌ Error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // ✅ تحميل الصفحة التالية
  Future<void> loadMoreProducts() async {
    if (isLoadingMore.value) return;
    if (currentPage.value > totalPages.value) return;

    isLoadingMore.value = true;
    await loadProducts();
  }

  // ✅ تحديث المنتجات (Pull to Refresh)
  Future<void> refreshProducts() async {
    await loadProducts(refresh: true);
    Get.snackbar(
      'تم التحديث',
      'تم تحميل ${products.length} منتج',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ✅ إعادة المحاولة
  Future<void> retryFetch() async {
    await loadProducts(refresh: true);
  }

  // ✅ البحث عن منتج
  Product? findProductById(int id) {
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
}
