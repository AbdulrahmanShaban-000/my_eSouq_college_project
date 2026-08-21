import 'package:get/get.dart';
import 'package:zad/core/api/end_points.dart';
import 'package:zad/models/product_filter_param.dart';
import 'package:zad/models/product.dart';
import 'package:zad/controllers/product_controller.dart';
import 'package:dio/dio.dart';

class FilterController extends GetxController {
  var params = ProductFilterParams().obs;

  // النوع <Product> محدد بدقة ليتوافق مع ProductGrid
  RxList<Product> filteredProducts = <Product>[].obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var filterOptions = {}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFilterOptions();
  }

  Future<void> fetchFilterOptions() async {
    try {
      final response = await Dio().get(
        '${EndPoints.baseUrl}/products/filter-options',
      );
      if (response.statusCode == 200) {
        final options = response.data['filter_options'];
        filterOptions.value = options is Map
            ? Map<String, dynamic>.from(options)
            : {};
      }
    } catch (e) {
      errorMessage.value = 'filter_options_error'.tr;
    }
  }

  Future<void> applyFilter(ProductFilterParams newParams) async {
    params.value = newParams;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await Dio().get(
        '${EndPoints.baseUrl}/products/filter',
        queryParameters: params.value.toJson(),
      );

      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        if (responseData is Map) {
          responseData =
              responseData['data'] ??
              responseData['products'] ??
              responseData['items'] ??
              responseData;
        }
        final dynamic rawProducts = responseData is Map
            ? (responseData['data'] ??
                  responseData['items'] ??
                  responseData['products'])
            : responseData;
        final productList = rawProducts is List
            ? rawProducts
            : const <dynamic>[];

        filteredProducts.assignAll(
          productList.whereType<Map>().map(
            (json) => Product.fromJson(Map<String, dynamic>.from(json)),
          ),
        );
      }
    } catch (e) {
      filteredProducts.clear();
      errorMessage.value = 'filter_error'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  void resetFilters() {
    params.value = ProductFilterParams();
    filteredProducts.clear();
    try {
      Get.find<ProductController>().refreshProducts();
    } catch (_) {}
  }
}
