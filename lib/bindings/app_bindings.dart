import 'package:get/get.dart';

import 'package:my_esouq/controllers/auth_controller.dart';
import 'package:my_esouq/controllers/cart_controller.dart';
import 'package:my_esouq/controllers/favourits_controller.dart';
import 'package:my_esouq/controllers/product_controller.dart';
import 'package:my_esouq/controllers/recent_orders_controller.dart';
import 'package:my_esouq/controllers/profile_controller.dart';
import 'package:my_esouq/controllers/theme_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(ProductController(), permanent: true);
    Get.put(CartController(), permanent: true);
    Get.put(FavouriteController(), permanent: true);
    Get.put(RecentOrdersController(), permanent: true);
    Get.put(ThemeController(), permanent: true);

    // ProfileController requires AuthController.
    Get.put(
      ProfileController(authController: Get.find<AuthController>()),
      permanent: true,
    );
  }
}
