import 'package:get/get.dart';

class CartController extends GetxController {
  var cartItems = <Map<String, dynamic>>[].obs;

  void addToCart(Map<String, dynamic> product) {
    final existingIndex = cartItems.indexWhere(
      (item) => item['id'] == product['id'],
    );

    if (existingIndex >= 0) {
      cartItems[existingIndex]['quantity']++;

      cartItems.refresh();
    } else {
      cartItems.add({...product, 'quantity': 1});
    }

    Get.snackbar('Added', '${product['name']} added to cart');
  }

  void removeItem(int id) {
    cartItems.removeWhere((item) => item['id'] == id);

    Get.snackbar('Removed', 'Item removed from cart');
  }

  void updateQuantity(int id, int change) {
    final index = cartItems.indexWhere((item) => item['id'] == id);

    if (index == -1) return;

    cartItems[index]['quantity'] += change;

    if (cartItems[index]['quantity'] <= 0) {
      cartItems.removeAt(index);
    } else {
      cartItems.refresh();
    }
  }

  double get subtotal {
    return cartItems.fold(0.0, (sum, item) {
      final price =
          double.tryParse(item['price'].toString().replaceAll('\$', '')) ?? 0;

      return sum + (price * item['quantity']);
    });
  }
}
