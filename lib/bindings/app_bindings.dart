import 'package:get/get.dart';
import 'package:my_esouq/controllers/auth_controller.dart';
import 'package:my_esouq/controllers/cart_controller.dart';
import 'package:my_esouq/controllers/favourits_controller.dart';
import 'package:my_esouq/controllers/product_controller.dart';
import 'package:my_esouq/home/screens/profile_page.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ProductController(), permanent: true);
    Get.put(CartController(), permanent: true);
    Get.put(FavouriteController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(RecentOrdersController(), permanent: true);
  }
}
