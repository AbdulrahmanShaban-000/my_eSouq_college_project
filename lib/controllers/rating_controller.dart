
import 'package:get/get.dart';
import 'package:zad/core/api/api_consumer.dart';

class RatingController extends GetxController {
  final ApiConsumer api;

  RatingController() : api = Get.find<ApiConsumer>();


  final RxMap<int, double> productRatings = <int, double>{}.obs;

  
  final RxMap<int, int> userRatings = <int, int>{}.obs;

  
  final RxSet<int> loadingProducts = <int>{}.obs;

  
  double getAverageRating(int productId) {
    return productRatings[productId] ?? 0.0;
  }

  
  int getUserRating(int productId) {
    return userRatings[productId] ?? 0;
  }

 
  bool isLoadingProduct(int productId) {
    return loadingProducts.contains(productId);
  }


  Future<void> fetchAverageRating(int productId) async {
    try {
      loadingProducts.add(productId);

      final response = await api.get('rating/average/$productId');

      if (response != null && response['average_rating'] != null) {
        final avg = double.parse(response['average_rating'].toString());
    
        productRatings[productId] = avg;
      }
    } catch (e) {
      print('Error fetching average rating for product $productId: $e');
   
      productRatings[productId] = 0.0;
    } finally {
      loadingProducts.remove(productId);
    }
  }


  Future<void> fetchUserRating(int productId) async {
    try {
    
      if (!userRatings.containsKey(productId)) {
        userRatings[productId] = 0;
      }
    } catch (e) {
      print('Error fetching user rating for product $productId: $e');
      userRatings[productId] = 0;
    }
  }

 
  Future<void> addOrUpdateRating({
    required int productId,
    required int rating,
  }) async {
    try {
      await api.post(
        'rating/add',
        data: {'product_id': productId, 'rating': rating},
        isFormData: false,
      );

     
      userRatings[productId] = rating;

      await fetchAverageRating(productId);
    } catch (e) {
      print('Error adding/updating rating for product $productId: $e');
      rethrow;
    }
  }


  Future<void> deleteRating(int productId) async {
    try {
     
      userRatings[productId] = 0;
      await fetchAverageRating(productId);
    } catch (e) {
      print('Error deleting rating for product $productId: $e');
      rethrow;
    }
  }


  Future<void> fetchRatingsForProducts(List<int> productIds) async {

    for (final id in productIds) {
      await fetchAverageRating(id);
    }
  }
}
