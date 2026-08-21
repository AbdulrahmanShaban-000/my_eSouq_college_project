import 'package:flutter/material.dart' show Colors, WidgetsBinding;
import 'package:get/get.dart';
import 'package:zad/core/api/api_consumer.dart';
import 'package:zad/core/api/end_points.dart';
import 'package:zad/models/Product.dart';
import 'package:zad/services/guest_mix.dart';

class CartController extends GetxController with GuestMixin {
  final ApiConsumer api;

  CartController() : api = Get.find<ApiConsumer>();

  var cartItems = <CartItem>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var isGuestUser = false.obs;

  @override
  void onInit() {
    super.onInit();
    // ✅ تأخير التحميل لضمان تهيئة كل شيء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserStatus();
      fetchCart();
    });
  }

  Future<void> _checkUserStatus() async {
    isGuestUser.value = !isLoggedIn;
    if (isGuestUser.value) {
      print('👤 CartController: Guest user mode');
    } else {
      print('👤 CartController: Registered user mode');
    }
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  int? _productIdFromCartItem(Map<String, dynamic> json) {
    final product = json['product'];
    return _toInt(json['product_id']) ??
        _toInt(json['productId']) ??
        _toInt(json['id']) ??
        (product is Map ? _toInt(product['id']) : null);
  }

  Future<Product?> _getProductById(int productId) async {
    try {
      final response = await api.get('${EndPoints.products}/$productId');
      if (response is! Map) return null;

      final responseMap = Map<String, dynamic>.from(response);
      dynamic data = responseMap['data'] ?? responseMap['product'];
      if (data is Map && data['product'] is Map) data = data['product'];

      if (data is Map) {
        return Product.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (_) {
      // Keep the cart item usable if the detail request fails.
    }
    return null;
  }

  Future<void> fetchCart() async {
    // ✅ إذا كان المستخدم ضيفاً، نعرض سلة فارغة
    if (isGuestUser.value) {
      print('👤 Fetching guest cart from local storage');
      cartItems.clear();
      update(); // ✅ تحديث الواجهة
      return;
    }

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      print('🔄 جاري جلب السلة...');

      final response = await api.get(EndPoints.cart);

      if (response == null) {
        cartItems.clear();
        update(); // ✅ تحديث الواجهة
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

      print('📊 عدد العناصر في السلة: ${listData.length}');

      final parsedCartItems = <CartItem>[];
      for (final rawItem in listData) {
        if (rawItem is! Map) continue;

        final json = Map<String, dynamic>.from(rawItem);
        var cartItem = CartItem.fromJson(json);
        final productId = _productIdFromCartItem(json);

        // Cart responses may contain a product summary without its
        // product_images/main_image relation.
        if (!cartItem.product.hasValidImage() && productId != null) {
          final detailedProduct = await _getProductById(productId);
          if (detailedProduct != null) {
            cartItem = CartItem(
              id: _toInt(json['id']),
              product: detailedProduct,
              quantity: _toInt(json['quantity']) ?? 1,
            );
          }
        }

        parsedCartItems.add(cartItem);
      }

      cartItems.assignAll(parsedCartItems);

      update(); // ✅ تحديث الواجهة
      print('✅ تم تحديث السلة بنجاح');
    } catch (e) {
      // إذا كان الخطأ 401 والمستخدم ضيف، نتجاهل
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        print('👤 Guest user, ignoring 401 error');
        cartItems.clear();
        update(); // ✅ تحديث الواجهة
      } else {
        print('❌ خطأ في جلب السلة: $e');
        hasError.value = true;
        errorMessage.value = e.toString();
        cartItems.clear();
        update(); // ✅ تحديث الواجهة
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addToCart(Product product, [int quantity = 1]) async {
    // ✅ إضافة للسلة محلياً أولاً (للمستخدم الضيف والمسجل على حد سواء)
    print('➕ Adding to cart: ${product.name}');

    final existingIndex = cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity += quantity;
    } else {
      cartItems.add(CartItem(product: product, quantity: quantity));
    }

    update();

    if (isGuestUser.value) {
      print('👤 Added to guest cart locally');

      return true;
    }

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

        final existingIndex2 = cartItems.indexWhere(
          (item) => item.product.id == updatedItem.product.id,
        );

        if (existingIndex2 >= 0) {
          cartItems[existingIndex2] = updatedItem;
        } else {
          cartItems.add(updatedItem);
        }

        update(); // ✅ تحديث الواجهة
      } else {
        await fetchCart();
      }

      return true;
    } catch (e) {
      // ✅ حتى لو فشل الخادم، المنتج موجود محلياً
      print('⚠️ Failed to add to server, but saved locally: $e');
      Get.snackbar(
        'Warning',
        'Product added locally but failed to sync with server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeItem(int productId) async {
    // ✅ حذف من التخزين المحلي أولاً
    final index = cartItems.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;

    final item = cartItems[index];
    cartItems.removeAt(index);
    update(); // ✅ تحديث الواجهة

    // إذا كان المستخدم ضيفاً، نكتفي بالتخزين المحلي
    if (isGuestUser.value) {
      Get.snackbar(
        'Removed',
        'Item removed from cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // للمستخدم المسجل، نحذف من الخادم أيضاً
    final itemId = item.id;
    if (itemId == null) return;

    try {
      isLoading.value = true;
      await api.delete('${EndPoints.cart}/$itemId');
      Get.snackbar(
        'Removed',
        'Item removed from cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      // ✅ حتى لو فشل الخادم، المنتج محذوف محلياً
      print('⚠️ Failed to remove from server, but removed locally: $e');
      Get.snackbar(
        'Warning',
        'Removed locally but failed to sync with server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
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

    // ✅ تحديث محلياً أولاً
    cartItems[index].quantity = newQuantity;
    update(); // ✅ تحديث الواجهة

    // إذا كان المستخدم ضيفاً، نكتفي بالتخزين المحلي
    if (isGuestUser.value) {
      return;
    }

    // للمستخدم المسجل، نحدث على الخادم أيضاً
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
        update(); // ✅ تحديث الواجهة
      }
    } catch (e) {
      // ✅ حتى لو فشل الخادم، التحديث محفوظ محلياً
      print('⚠️ Failed to update on server, but updated locally: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearCart() async {
    // ✅ مسح محلياً أولاً
    cartItems.clear();
    update(); // ✅ تحديث الواجهة

    // إذا كان المستخدم ضيفاً، نكتفي بالتخزين المحلي
    if (isGuestUser.value) {
      Get.snackbar(
        'Cart cleared',
        'All items removed from cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // للمستخدم المسجل، نمسح من الخادم أيضاً
    try {
      isLoading.value = true;
      await api.delete(EndPoints.cart);
      Get.snackbar(
        'Cart cleared',
        'All items removed from cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('⚠️ Failed to clear on server, but cleared locally: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ دالة لدمج السلة المحلية مع السلة على الخادم بعد تسجيل الدخول
  Future<void> mergeGuestCart() async {
    if (cartItems.isEmpty || !isLoggedIn) return;

    print('🔄 Merging guest cart with server cart');
    isLoading.value = true;

    try {
      final List<CartItem> itemsToMerge = List.from(cartItems);

      for (var item in itemsToMerge) {
        try {
          await api.post(
            EndPoints.cart,
            data: {'product_id': item.product.id, 'quantity': item.quantity},
          );
          print('✅ Merged product ${item.product.id}');
        } catch (e) {
          print('⚠️ Failed to merge product ${item.product.id}: $e');
        }
      }

      // ✅ مسح السلة المحلية بعد الدمج
      cartItems.clear();
      update(); // ✅ تحديث الواجهة

      // ✅ جلب السلة من الخادم
      await fetchCart();

      Get.snackbar(
        'Success',
        'Cart merged successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error merging cart: $e');
      Get.snackbar(
        'Error',
        'Failed to merge cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ دالة لتحديث السلة
  Future<void> refreshCart() async {
    await fetchCart();
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

  // ✅ دالة لتحديث حالة المستخدم
  Future<void> refreshUserStatus() async {
    final loggedIn = await checkLoginStatus();
    isGuestUser.value = !loggedIn;
    if (loggedIn) {
      await fetchCart();
    }
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

    if (productJson is Map) {
      productMap = Map<String, dynamic>.from(productJson);
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
        'product_images': json['product_images'],
        'main_image': json['main_image'],
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
