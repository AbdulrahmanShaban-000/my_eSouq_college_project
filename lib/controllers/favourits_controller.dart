import 'package:get/get.dart';

class FavouriteController extends GetxController {
  var favourites = <Map<String, dynamic>>[].obs;

  void addToFavourite(Map<String, dynamic> product) {
    final exists = favourites.any((item) => item['id'] == product['id']);

    if (exists) {
      Get.snackbar(
        'Already Added',
        '${product['name']} is already in favourites',
      );

      return;
    }

    favourites.add(product);

    Get.snackbar('Added', '${product['name']} added to favourites');
  }

  void removeFavourite(int id) {
    favourites.removeWhere((item) => item['id'] == id);

    Get.snackbar('Removed', 'Item removed from favourites');
  }

  bool isFavourite(int id) {
    return favourites.any((item) => item['id'] == id);
  }
}
