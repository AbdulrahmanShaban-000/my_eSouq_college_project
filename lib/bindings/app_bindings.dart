import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'package:zad/controllers/auth_controller.dart';
import 'package:zad/controllers/cart_controller.dart';
import 'package:zad/controllers/categories_controller.dart';
import 'package:zad/controllers/favourits_controller.dart';
import 'package:zad/controllers/product_controller.dart';
import 'package:zad/controllers/rating_controller.dart';
import 'package:zad/controllers/recent_orders_controller.dart';
import 'package:zad/controllers/profile_controller.dart';
import 'package:zad/controllers/theme_controller.dart';
import 'package:zad/controllers/orders_controller.dart';
import 'package:zad/core/api/api_consumer.dart';
import 'package:zad/core/api/dio_consumer.dart';
import 'package:zad/models/adress_model.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiConsumer>(DioConsumer(Dio()), permanent: true);

    Get.put(AuthController(api: Get.find<ApiConsumer>()), permanent: true);
    Get.put(ProductController(), permanent: true);
    Get.put(CartController(), permanent: true);
    Get.put(FavouriteController(), permanent: true);
    Get.put(RecentOrdersController(), permanent: true);
    Get.put(ThemeController(), permanent: true);
    Get.put(OrdersController(), permanent: true);
    Get.put(AddressController(), permanent: true);
    Get.put(RatingController(), permanent: true);
    // Get.put<CategoriesService>(CategoriesService(api: Get.find<ApiConsumer>()), permanent: true);
    Get.put<CategoryController>(CategoryController(), permanent: true);

    Get.put(
      ProfileController(authController: Get.find<AuthController>()),
      permanent: true,
    );
  }
}
