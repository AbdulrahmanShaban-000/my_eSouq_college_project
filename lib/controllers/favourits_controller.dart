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

      print('🔄 جاري جلب المفضلات...'); // ✅ للتتبع

      final response = await api.get(EndPoints.favourites);

      print('📦 البيانات المستلمة: $response'); // ✅ للتتبع

      final data = response['data'];

      if (data is! List) {
        print('❌ البيانات ليست List'); // ✅ للتتبع
        favourites.clear();
        isFirstLoad.value = false;
        update();
        return;
      }

      // ✅ تحويل البيانات إلى منتجات
      final List<Product> productList = data
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

      print('✅ عدد المنتجات: ${productList.length}'); // ✅ للتتبع

      // ✅ استخدام assignAll بدلاً من تعيين القيمة مباشرة
      favourites.assignAll(productList);
      isFirstLoad.value = false;

      // ✅ تحديث الواجهة
      update();

      print('✅ تم تحديث المفضلات بنجاح'); // ✅ للتتبع
    } on DioException catch (e) {
      print('❌ خطأ في Dio: ${e.message}'); // ✅ للتتبع
      favourites.clear();
      isFirstLoad.value = false;
      update();
      rethrow;
    } catch (e) {
      print('❌ خطأ عام: $e'); // ✅ للتتبع
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
    // ✅ إذا كان المستخدم ضيفاً، نعرض رسالة
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

        // ✅ تحديث محلي سريع
        final product = await _getProductById(productId);
        if (product != null && !isFavourite(productId)) {
          favourites.add(product);
          update();
        }

        // ✅ ثم جلب من الخادم للتأكد
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

  // ✅ دالة مساعدة لجلب منتج بواسطة ID
  Future<Product?> _getProductById(int productId) async {
    try {
      final response = await api.get('${EndPoints.products}/$productId');
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        return Product.fromJson(data);
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
    // ✅ إذا كان المستخدم ضيفاً، نعرض رسالة
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

      // ✅ إزالة المنتج محلياً أولاً
      favourites.removeWhere((item) => item.id == productId);
      update(); // تحديث الواجهة

      Get.snackbar(
        'Removed',
        'Product removed from favourites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      // ثم جلب البيانات من الخادم للتأكد
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
    // ✅ إذا كان المستخدم ضيفاً، نعرض رسالة
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

  // ✅ دالة لتحديث حالة المنتج المفضل محلياً (دون طلب من الخادم)
  void toggleFavouriteLocal(Product product) {
    if (isFavourite(product.id)) {
      favourites.removeWhere((item) => item.id == product.id);
    } else {
      favourites.add(product);
    }
    update();
  }

  // ✅ دالة لجلب المفضلات مع إعادة المحاولة
  Future<void> refreshFavourites() async {
    isFirstLoad.value = true;
    await fetchFavourites();
  }
}
