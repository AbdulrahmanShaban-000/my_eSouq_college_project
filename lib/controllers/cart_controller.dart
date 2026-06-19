import 'package:get/get.dart';
import 'package:zad/core/api/api_consumer.dart';
import 'package:zad/core/api/end_points.dart';
import 'package:zad/models/Product.dart';

class CartController extends GetxController {
  final ApiConsumer api;

  CartController() : api = Get.find<ApiConsumer>();

  var cartItems = <CartItem>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  Future<void> fetchCart() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final response = await api.get(EndPoints.cart);

      if (response == null) {
        cartItems.clear();
        return;
      }

      final dynamic rawData =
          response['cart_items'] ?? response['data'] ?? response;
      List<dynamic> listData;

      if (rawData is List) {
        listData = rawData;
      } else if (rawData is Map && rawData['data'] is List) {
        listData = rawData['data'] as List;
      } else {
        listData = <dynamic>[];
      }

      cartItems.value = listData
          .whereType<Map<String, dynamic>>()
          .map((json) => CartItem.fromJson(json))
          .toList();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      cartItems.clear();
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addToCart(Product product, [int quantity = 1]) async {
    isLoading.value = true;
    try {
      final response = await api.post(
        EndPoints.cart,
        data: {'product_id': product.id, 'quantity': quantity},
      );

      final dynamic cartItemJson =
          response is Map<String, dynamic> &&
              response['cart_item'] is Map<String, dynamic>
          ? response['cart_item']
          : response;

      if (cartItemJson is Map<String, dynamic>) {
        final updatedItem = CartItem.fromJson(
          Map<String, dynamic>.from(cartItemJson),
          fallbackProduct: product,
        );

        final existingIndex = cartItems.indexWhere(
          (item) => item.product.id == updatedItem.product.id,
        );

        if (existingIndex >= 0) {
          cartItems[existingIndex] = updatedItem;
        } else {
          cartItems.add(updatedItem);
        }

        cartItems.refresh();
      } else {
        await fetchCart();
      }

      Get.snackbar(
        'Added to cart',
        '${product.name} added to cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add item to cart');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeItem(int productId) async {
    final index = cartItems.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;

    final item = cartItems[index];
    final itemId = item.id;

    try {
      isLoading.value = true;
      if (itemId != null) {
        await api.delete('${EndPoints.cart}/$itemId');
      }
      cartItems.removeAt(index);
      cartItems.refresh();
      Get.snackbar(
        'Removed',
        'Item removed from cart',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove item from cart');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateQuantity(int productId, int change) async {
    final index = cartItems.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;

    final item = cartItems[index];
    final newQuantity = item.quantity + change;

    if (newQuantity <= 0) {
      await removeItem(productId);
      return;
    }

    final itemId = item.id;
    if (itemId == null) {
      await fetchCart();
      return;
    }

    try {
      isLoading.value = true;
      final response = await api.put(
        '${EndPoints.cart}/$itemId',
        data: {'quantity': newQuantity},
      );

      final Map<String, dynamic> updatedJson =
          response is Map<String, dynamic> &&
              response['cart_item'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(response['cart_item'])
          : response is Map<String, dynamic>
          ? Map<String, dynamic>.from(response)
          : {};

      if (updatedJson.isNotEmpty) {
        cartItems[index] = CartItem.fromJson(
          updatedJson,
          fallbackProduct: item.product,
        );
      } else {
        cartItems[index].quantity = newQuantity;
      }

      cartItems.refresh();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update cart quantity');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearCart() async {
    try {
      isLoading.value = true;
      await api.delete(EndPoints.cart);
      cartItems.clear();
      cartItems.refresh();
      Get.snackbar(
        'Cart cleared',
        'All items removed from cart',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear cart');
    } finally {
      isLoading.value = false;
    }
  }

  double get subtotal {
    return cartItems.fold(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  int get totalItems {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  
  List<Map<String, dynamic>> get cartAsMapList {
    return cartItems.map((item) {
      return {
        'id': item.id,
        'product_id': item.product.id,
        'name': item.product.name,
        'price': item.product.price,
        'quantity': item.quantity,
        'stock': item.product.stock,
      };
    }).toList();
  }
}


class CartItem {
  final int? id;
  final Product product;
  int quantity;

  CartItem({this.id, required this.product, this.quantity = 1});

  factory CartItem.fromJson(
    Map<String, dynamic> json, {
    Product? fallbackProduct,
  }) {
    final dynamic productJson = json['product'];
    late final Map<String, dynamic> productMap;

    final hasName = json['name'] != null && json['name'].toString().isNotEmpty;
    final hasPrice =
        json['price'] != null && json['price'].toString().isNotEmpty;

    if (productJson is Map<String, dynamic>) {
      productMap = productJson;
    } else if (hasName && hasPrice) {
      productMap = Map<String, dynamic>.from(json);
    } else if (fallbackProduct != null) {
      return CartItem(
        id: (json['id'] as num?)?.toInt(),
        product: fallbackProduct,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      );
    } else {
      productMap = {
        'id':
            (json['product_id'] as num?)?.toInt() ??
            (json['id'] as num?)?.toInt() ??
            0,
        'name': json['name']?.toString() ?? 'Product',
        'description': json['description']?.toString(),
        'price': json['price'] ?? 0,
        'stock': (json['stock'] as num?)?.toInt() ?? 0,
        'is_active': json['is_active'] ?? 1,
        'images': json['images'] ?? [],
        'image_path': json['image_path'],
      };
    }

    final parsedProduct = Product.fromJson(productMap);

    return CartItem(
      id: (json['id'] as num?)?.toInt(),
      product: parsedProduct,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  double get totalPrice => product.price * quantity;

  
  Map<String, dynamic> toMap() {
    return {'id': id, 'product_id': product.id, 'quantity': quantity};
  }
}
