import 'package:get/get.dart';
import 'package:zad/core/api/api_consumer.dart';
import 'package:zad/core/api/end_points.dart';
import 'package:zad/models/Product.dart';
import 'package:dio/dio.dart';

class FavouriteController extends GetxController {
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
    await fetchFavourites();
    favourites.clear();
  }

  bool isFavourite(int id) {
    return favourites.any((item) => item.id == id);
  }
}
