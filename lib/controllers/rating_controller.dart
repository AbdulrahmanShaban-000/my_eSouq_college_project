import 'package:get/get.dart';
import 'package:zad/core/api/api_consumer.dart';

class RatingController extends GetxController {
  final ApiConsumer api;

  
  final Map<int, _CachedRating> _ratingCache = {};
  static const Duration cacheDuration = Duration(minutes: 5);

 
  final Set<int> _pendingRequests = {};

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

 
  bool _isCacheValid(int productId) {
    final cached = _ratingCache[productId];
    if (cached == null) return false;
    return DateTime.now().difference(cached.timestamp) < cacheDuration;
  }

  
  Future<void> fetchRatingsBatch(
    List<int> productIds, {
    bool forceRefresh = false,
  }) async {
  
    final idsToFetch = productIds
        .where((id) => forceRefresh || !_isCacheValid(id))
        .toList();

    if (idsToFetch.isEmpty) {
     
      for (final id in productIds) {
        if (_ratingCache.containsKey(id)) {
          productRatings[id] = _ratingCache[id]!.averageRating;
        }
      }
      return;
    }

    try {
    
      loadingProducts.addAll(idsToFetch);

  
      final response = await api.post(
        'ratings/bulk',
        data: {'product_ids': idsToFetch},
        isFormData: false,
      );

      if (response != null && response['ratings'] != null) {
        final ratings = response['ratings'] as Map;

        for (final entry in ratings.entries) {
          final id = int.parse(entry.key.toString());
          final avg = double.parse(entry.value['average_rating'].toString());

    
          _ratingCache[id] = _CachedRating(
            averageRating: avg,
            timestamp: DateTime.now(),
          );

         
          productRatings[id] = avg;
        }
      }
    } catch (e) {
      print('Error fetching batch ratings: $e');
    } finally {
      loadingProducts.removeAll(idsToFetch);
    }
  }

 
  Future<void> fetchAverageRating(
    int productId, {
    bool forceRefresh = false,
  }) async {

    if (_pendingRequests.contains(productId) && !forceRefresh) return;

 
    if (!forceRefresh && _isCacheValid(productId)) {
      final cached = _ratingCache[productId]!;
      productRatings[productId] = cached.averageRating;
      return;
    }

    try {
      _pendingRequests.add(productId);
      loadingProducts.add(productId);

      final response = await api.get('rating/average/$productId');

      if (response != null && response['average_rating'] != null) {
        final avg = double.parse(response['average_rating'].toString());

        // تحديث الكاش
        _ratingCache[productId] = _CachedRating(
          averageRating: avg,
          timestamp: DateTime.now(),
        );

        productRatings[productId] = avg;
      }
    } catch (e) {
      print('Error fetching average rating for product $productId: $e');
      if (!_ratingCache.containsKey(productId)) {
        productRatings[productId] = 0.0;
      }
    } finally {
      _pendingRequests.remove(productId);
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

  
      await fetchAverageRating(productId, forceRefresh: true);
    } catch (e) {
      print('Error adding/updating rating for product $productId: $e');
      rethrow;
    }
  }

  Future<void> deleteRating(int productId) async {
    try {
     
      await api.delete('rating/$productId');

      userRatings[productId] = 0;

      
      await fetchAverageRating(productId, forceRefresh: true);
    } catch (e) {
      print('Error deleting rating for product $productId: $e');
      rethrow;
    }
  }

 
  Future<void> refreshAllRatings(List<int> productIds) async {
    
    for (final id in productIds) {
      _ratingCache.remove(id);
    }

    
    await fetchRatingsBatch(productIds, forceRefresh: true);
  }


  void clearCache() {
    _ratingCache.clear();
    _pendingRequests.clear();
    productRatings.clear();
    userRatings.clear();
  }

  @override
  void onClose() {
    clearCache();
    super.onClose();
  }
}


class _CachedRating {
  final double averageRating;
  final DateTime timestamp;

  _CachedRating({required this.averageRating, required this.timestamp});
}
