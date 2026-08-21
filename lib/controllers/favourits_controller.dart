import 'package:flutter/material.dart' show Colors, WidgetsBinding;
import 'package:get/get.dart';
import 'package:zad/core/api/api_consumer.dart';
import 'package:zad/core/api/end_points.dart';
import 'package:zad/models/Product.dart';
import 'package:dio/dio.dart';
import 'package:zad/services/guest_mix.dart';

class FavouriteController extends GetxController with GuestMixin {
  final ApiConsumer api;

  var favourites = <Product>[].obs;
  var isLoading = false.obs;
  var isFirstLoad = true.obs;

  FavouriteController() : api = Get.find<ApiConsumer>();

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchFavourites();
    });
  }

  @override
  void onReady() {
    super.onReady();
    // ✅ تحميل البيانات عند جاهزية الصفحة
    if (isFirstLoad.value) {
      fetchFavourites();
    }
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  List<dynamic> _extractFavouriteItems(dynamic response) {
    if (response is List) return response;
    if (response is! Map) return const [];

    final map = Map<String, dynamic>.from(response);
    final candidates = [
      map['data'],
      map['favorites'],
      map['favourites'],
      map['wishlist'],
      map['items'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) return candidate;

      if (candidate is Map) {
        final nested = Map<String, dynamic>.from(candidate);
        if (nested['data'] is List) return nested['data'] as List;
        if (nested['items'] is List) return nested['items'] as List;
        if (nested.values.every((value) => value is Map || value is List)) {
          return nested.values.toList();
        }
      }
    }

    return const [];
  }

  Product? _productFromFavouriteItem(dynamic item) {
    if (item is! Map) return null;
    final map = Map<String, dynamic>.from(item);

    final nestedProduct =
        map['product'] ??
        map['item'] ??
        map['product_data'] ??
        map['favourite'] ??
        map['favorite'];

    if (nestedProduct is Map) {
      return Product.fromJson(Map<String, dynamic>.from(nestedProduct));
    }

    final looksLikeProduct =
        map.containsKey('name') &&
        map.containsKey('price') &&
        map.containsKey('id');

    if (looksLikeProduct) {
      return Product.fromJson(map);
    }

    return null;
  }

  int? _productIdFromFavouriteItem(dynamic item) {
    if (item is! Map) return null;
    final map = Map<String, dynamic>.from(item);

    return _toInt(map['product_id']) ??
        _toInt(map['productId']) ??
        _toInt(map['id']) ??
        (map['product'] is Map ? _toInt((map['product'] as Map)['id']) : null);
  }

  Future<void> fetchFavourites() async {
    // ✅ إذا كان المستخدم ضيفاً، نعرض قائمة فارغة
    if (!isLoggedIn) {
      favourites.clear();
      isFirstLoad.value = false;
      update();
      return;
    }

    try {
      isLoading.value = true;

      final response = await api.get(EndPoints.favourites);

      final data = _extractFavouriteItems(response);
      final seenIds = <int>{};
      final productList = <Product>[];

      for (final item in data) {
        Product? product = _productFromFavouriteItem(item);
        final productId = _productIdFromFavouriteItem(item);

        // Favourite endpoints often return a product summary without its
        // product_images/main_image relation. Load the full product in that case.
        if ((product == null || !product.hasValidImage()) &&
            productId != null) {
          final detailedProduct = await _getProductById(productId);
          if (detailedProduct != null) product = detailedProduct;
        }

        if (product != null && seenIds.add(product.id)) {
          productList.add(product);
        }
      }

      print('✅ عدد المنتجات: ${productList.length}');

      favourites.assignAll(productList);
      isFirstLoad.value = false;

      update();

      print('✅ تم تحديث المفضلات بنجاح');
    } on DioException catch (e) {
      print('❌ خطأ في Dio: ${e.message}');
      favourites.clear();
      isFirstLoad.value = false;
      update();
    } catch (e) {
      print('❌ خطأ عام: $e');
      favourites.clear();
      isFirstLoad.value = false;
      update();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToFavourite(Product product) async {
    await addToFavouriteByProductId(product.id);
  }

  Future<void> addToFavouriteByProductId(int productId) async {
    if (!isLoggedIn) {
      Get.snackbar(
        'Login Required',
        'Please login to add to favourites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
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
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        final product = await _getProductById(productId);
        if (product != null && !isFavourite(productId)) {
          favourites.add(product);
          update();
        }

        await fetchFavourites();
        return;
      }

      Get.snackbar(
        'Info',
        response['message'] ?? 'Already added',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      final raw = e.toString();
      Get.snackbar(
        'Error adding favourite',
        raw,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<Product?> _getProductById(int productId) async {
    try {
      final response = await api.get('${EndPoints.products}/$productId');
      if (response is! Map) return null;

      final responseMap = Map<String, dynamic>.from(response);
      dynamic data = responseMap['data'] ?? responseMap['product'];

      if (data is Map && data['product'] is Map) {
        data = data['product'];
      }

      if (data is Map) {
        return Product.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> addToFavouriteById(int productId) async {
    await addToFavouriteByProductId(productId);
  }

  Future<void> removeFavourite(int productId) async {
    if (!isLoggedIn) {
      Get.snackbar(
        'Login Required',
        'Please login to remove from favourites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await api.delete('${EndPoints.favourites}/$productId');

      favourites.removeWhere((item) => item.id == productId);
      update();
      Get.snackbar(
        'Removed',
        'Product removed from favourites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      await fetchFavourites();
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to remove favourite',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> addToFavouriteProduct(Product product) async {
    await addToFavouriteByProductId(product.id);
  }

  Future<void> clearAll() async {
    if (!isLoggedIn) {
      Get.snackbar(
        'Login Required',
        'Please login to manage favourites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    favourites.clear();
    update();
    await fetchFavourites();
  }

  bool isFavourite(int id) {
    return favourites.any((item) => item.id == id);
  }

  void toggleFavouriteLocal(Product product) {
    if (isFavourite(product.id)) {
      favourites.removeWhere((item) => item.id == product.id);
    } else {
      favourites.add(product);
    }
    update();
  }

  Future<void> refreshFavourites() async {
    isFirstLoad.value = true;
    await fetchFavourites();
  }
}
