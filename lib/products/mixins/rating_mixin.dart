// lib/product/mixins/rating_mixin.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/controllers/rating_controller.dart';

mixin RatingMixin {
  final RatingController ratingController = Get.find<RatingController>();

  Future<void> loadRatings(int productId) async {
    try {
      await ratingController.fetchAverageRating(productId);
      await ratingController.fetchUserRating(productId);
      print(
        '✅ Product $productId - User rating: ${ratingController.getUserRating(productId)}',
      );
    } catch (e) {
      print('❌ Error loading ratings: $e');
    }
  }

  Future<void> submitRating(int productId, int rating) async {
    if (rating < 0 || rating > 5) return;

    try {
      if (rating == 0) {
        if (ratingController.getUserRating(productId) == 0) return;
        ratingController.userRatings[productId] = 0;
        await ratingController.deleteRating(productId);
        await ratingController.fetchAverageRating(productId);
        return;
      }

      ratingController.userRatings[productId] = rating;
      await ratingController.addOrUpdateRating(
        productId: productId,
        rating: rating,
      );
      await ratingController.fetchAverageRating(productId);
      print('✅ Rating updated for product $productId to: $rating');
    } catch (e) {
      await ratingController.fetchUserRating(productId);
      Get.snackbar(
        'Error',
        'فشل في حفظ التقييم: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
