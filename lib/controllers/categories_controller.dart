import 'package:get/get.dart';
import 'package:zad/core/api/api_consumer.dart';
import 'package:zad/models/categories.dart';
import 'package:zad/models/product.dart';

class CategoryController extends GetxController {
  final ApiConsumer api;

  CategoryController() : api = Get.find<ApiConsumer>();

  var categoriesTree = <Category>[].obs;
  var isLoading = true.obs;

  var categoryProducts = <Product>[].obs;
  var isProductsLoading = false.obs;

  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategoriesTree();
  }

  Future<void> fetchCategoriesTree() async {
    try {
      isLoading(true);
      errorMessage.value = '';

      final response = await api.get('categories/tree');

      if (response != null && response['data'] != null) {
        List data = response['data'];

        categoriesTree.value = data
            .map((category) => Category.fromJson(category))
            .toList();
      } else {
        errorMessage.value = 'حدث خطأ أثناء جلب الأقسام';
      }
    } catch (e) {
      print('Error fetching categories tree: $e');
      errorMessage.value = 'تأكد من الاتصال بالإنترنت';
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchCategoryProducts(int categoryId, {int page = 1}) async {
    try {
      isProductsLoading(true);
      errorMessage.value = '';

      if (page == 1) {
        categoryProducts.clear();
      }

      final response = await api.get(
        'categories/$categoryId/products',
        queryParameters: {'page': page},
      );

      if (response != null && response['data'] != null) {
        List productsList = [];
        if (response['data'] is List) {
          productsList = response['data'];
        } else if (response['data']['data'] != null) {
          productsList = response['data']['data'];
        }

        final newProducts = productsList
            .map((product) => Product.fromJson(product))
            .toList();

        categoryProducts.addAll(newProducts);
      }
    } catch (e) {
      print('Error fetching products for category $categoryId: $e');
      errorMessage.value = 'حدث خطأ أثناء جلب منتجات القسم';
    } finally {
      isProductsLoading(false);
    }
  }
}
