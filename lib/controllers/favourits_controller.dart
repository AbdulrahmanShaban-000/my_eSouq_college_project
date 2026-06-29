import 'package:get/get.dart';
import 'package:zad/core/api/api_consumer.dart';
import 'package:zad/core/api/end_points.dart';
import 'package:zad/models/Product.dart';
import 'package:dio/dio.dart';
import 'package:zad/services/guest_mix.dart';


class FavouriteController extends GetxController with GuestMixin {
  final ApiConsumer api;

  FavouriteController() : api = Get.find<ApiConsumer>();

  var favourites = <Product>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavourites();
  }

  Future<void> fetchFavourites() async {
    // ✅ إذا كان المستخدم ضيفاً، نعرض قائمة فارغة
    if (!isLoggedIn) {
      favourites.clear();
      return;
    }

    try {
      isLoading.value = true;

      final response = await api.get(EndPoints.favourites);

      final data = response['data'];

      if (data is! List) {
        favourites.clear();
        return;
      }

      favourites.value = data
          .map<Product?>((item) {
            final productJson = item is Map<String, dynamic>
                ? (item['product'] ?? item)
                : item;

            if (productJson is Map<String, dynamic>) {
              return Product.fromJson(productJson);
            }

            return null;
          })
          .whereType<Product>()
          .toList();
    } on DioException {
      rethrow;
    } catch (_) {
      favourites.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToFavourite(Product product) async {
    await addToFavouriteByProductId(product.id);
  }

  Future<void> addToFavouriteByProductId(int productId) async {
    // ✅ إذا كان المستخدم ضيفاً، نعرض رسالة
    if (!isLoggedIn) {
      Get.snackbar(
        'Login Required',
        'Please login to add to favourites',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final response = await api.post(
        EndPoints.favourites,
        data: {'product_id': productId},
      );

      final status = response['status'];
      if (status == true) {
        Get.snackbar(
          'Added',
          response['message'] ?? 'Product added to favourites',
        );
        await fetchFavourites();
        return;
      }

      Get.snackbar('Info', response['message'] ?? 'Already added');
    } catch (e) {
      final raw = e.toString();
      Get.snackbar('Error adding favourite', raw);
    }
  }

  Future<void> addToFavouriteById(int productId) async {
    await addToFavouriteByProductId(productId);
  }

  Future<void> removeFavourite(int productId) async {
    // ✅ إذا كان المستخدم ضيفاً، نعرض رسالة
    if (!isLoggedIn) {
      Get.snackbar(
        'Login Required',
        'Please login to remove from favourites',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await api.delete('${EndPoints.favourites}/$productId');
      Get.snackbar('Removed', 'Product removed from favourites');
      await fetchFavourites();
    } catch (_) {
      Get.snackbar('Error', 'Failed to remove favourite');
    }
  }

  Future<void> addToFavouriteProduct(Product product) async {
    await addToFavouriteByProductId(product.id);
  }

  Future<void> clearAll() async {
    // ✅ إذا كان المستخدم ضيفاً، نعرض رسالة
    if (!isLoggedIn) {
      Get.snackbar(
        'Login Required',
        'Please login to manage favourites',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await fetchFavourites();
    favourites.clear();
  }

  bool isFavourite(int id) {
    return favourites.any((item) => item.id == id);
  }
}
