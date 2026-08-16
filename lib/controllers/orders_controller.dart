import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/core/api/api_consumer.dart';
import 'package:zad/core/api/end_points.dart';

class OrderTrackingStep {
  final String label;
  bool done;

  OrderTrackingStep({required this.label, required this.done});

  @override
  String toString() => 'OrderTrackingStep(label: $label, done: $done)';
}

class OrdersController extends GetxController {
  final ApiConsumer api;

  OrdersController({ApiConsumer? api}) : api = api ?? Get.find<ApiConsumer>();

  final isLoading = false.obs;
  final currentOrderId = ''.obs;
  final trackingSteps = <OrderTrackingStep>[].obs;
  final currentOrderStatus = ''.obs;
  final orderTotal = 0.0.obs;
  final orderAddress = ''.obs;
  final orderPhone = ''.obs;
  final orderProducts = <Map<String, dynamic>>[].obs;
  final myOrders = <Map<String, dynamic>>[].obs;

  bool _isValidOrderId(dynamic value) {
    if (value == null) return false;
    if (value is int) return value > 0;
    if (value is num) return value > 0;
    final text = value.toString().trim();
    return text.isNotEmpty && RegExp(r'^\d+$').hasMatch(text);
  }

  String _normalizeStatus(dynamic value) {
    final status = value?.toString() ?? 'pending';
    return status.trim().isEmpty ? 'pending' : status.trim();
  }

  double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  List<String> _extractProductNames(dynamic items) {
    if (items is! List) return const [];

    final names = <String>[];
    for (final item in items) {
      if (item is Map<String, dynamic>) {
        final product = item['product'];
        if (product is Map<String, dynamic>) {
          final name = product['name'] ?? item['name'] ?? 'Product';
          if (name is String && name.trim().isNotEmpty) {
            names.add(name.trim());
          }
          continue;
        }

        final name = item['name'] ?? item['product_name'] ?? 'Product';
        if (name is String && name.trim().isNotEmpty) {
          names.add(name.trim());
        }
      }
    }

    return names;
  }

  List<OrderTrackingStep> _buildStepsFromStatus(String rawStatus) {
    final status = rawStatus.trim().toLowerCase();
    final steps = [
      OrderTrackingStep(label: 'Order received', done: false),
      OrderTrackingStep(label: 'Preparing your order', done: false),
      OrderTrackingStep(label: 'Shipped', done: false),
      OrderTrackingStep(label: 'Delivered', done: false),
    ];

    switch (status) {
      case 'pending':
        steps[0].done = true;
        break;
      case 'paid':
        steps[0].done = true;
        steps[1].done = true;
        break;
      case 'shipped':
        steps[0].done = true;
        steps[1].done = true;
        steps[2].done = true;
        break;
      case 'delivered':
        steps[0].done = true;
        steps[1].done = true;
        steps[2].done = true;
        steps[3].done = true;
        break;
      case 'cancelled':
        steps[0].done = true;
        steps[1].done = false;
        steps[2].done = false;
        steps[3].done = false;
        break;
      default:
        steps[0].done = true;
        break;
    }

    return steps;
  }

  Future<Map<String, dynamic>?> createOrder({
    required String address,
    required String phone,
    double shippingCost = 0.0,
    String paymentMethod = 'cash',
  }) async {
    isLoading.value = true;

    try {
      final response = await api.post(
        EndPoints.orders,
        data: {
          'address': address.trim(),
          'phone': phone.trim(),
          'shipping_cost': shippingCost,
          'payment_method': paymentMethod,
        },
      );

      final payload = response is Map<String, dynamic>
          ? response
          : <String, dynamic>{'message': response.toString()};

      final orderData = payload['order'] ?? payload['data'] ?? payload;
      if (orderData is Map<String, dynamic>) {
        final id = orderData['id'];
        if (_isValidOrderId(id)) {
          currentOrderId.value = id.toString();
          currentOrderStatus.value = (orderData['status'] ?? 'pending')
              .toString();
          trackingSteps.value = _buildStepsFromStatus(currentOrderStatus.value);
        } else {
          currentOrderId.value = '';
          currentOrderStatus.value = 'pending';
          trackingSteps.value = _buildStepsFromStatus(currentOrderStatus.value);
        }
      }

      return payload;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create order: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchMyOrders() async {
    isLoading.value = true;

    try {
      final response = await api.get(EndPoints.orders);
      final payload = response is Map<String, dynamic>
          ? response
          : <String, dynamic>{};
      final rawOrders = payload['orders'] ?? payload['data'] ?? payload;
      final orders = (rawOrders is List)
          ? rawOrders.whereType<Map<String, dynamic>>().toList()
          : <Map<String, dynamic>>[];

      myOrders.assignAll(orders);
      return orders;
    } catch (_) {
      myOrders.clear();
      return const <Map<String, dynamic>>[];
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> loadLatestOrder() async {
    final orders = await fetchMyOrders();
    if (orders.isEmpty) return null;

    final latestOrder = orders.first;
    final orderId = latestOrder['id'];
    if (!_isValidOrderId(orderId)) return null;

    currentOrderId.value = orderId.toString();
    return fetchOrderDetails(currentOrderId.value);
  }

  Future<Map<String, dynamic>?> fetchOrderDetails(String orderId) async {
    if (!_isValidOrderId(orderId)) {
      currentOrderId.value = '';
      currentOrderStatus.value = 'pending';
      trackingSteps.value = _buildStepsFromStatus(currentOrderStatus.value);
      return null;
    }

    isLoading.value = true;

    try {
      final response = await api.get(EndPoints.orderShow(orderId));
      final payload = response is Map<String, dynamic>
          ? response
          : <String, dynamic>{};
      final order = payload['order'] ?? payload['data'] ?? payload;

      if (order is! Map<String, dynamic>) {
        currentOrderId.value = orderId;
        currentOrderStatus.value = 'pending';
        trackingSteps.value = _buildStepsFromStatus(currentOrderStatus.value);
        orderProducts.clear();
        return null;
      }

      final normalizedStatus = _normalizeStatus(order['status']);

      currentOrderId.value = order['id']?.toString() ?? orderId;
      currentOrderStatus.value = normalizedStatus;
      orderTotal.value = _parsePrice(order['total_price']);
      orderAddress.value = (order['address'] ?? '').toString();
      orderPhone.value = (order['phone'] ?? '').toString();

      final items = order['items'] ?? order['products'] ?? <dynamic>[];
      final productNames = _extractProductNames(items);
      orderProducts.assignAll(
        productNames
            .map((name) => {'name': name, 'status': normalizedStatus})
            .toList(),
      );

      trackingSteps.value = _buildStepsFromStatus(currentOrderStatus.value);

      return order;
    } catch (_) {
      currentOrderId.value = orderId;
      currentOrderStatus.value = 'pending';
      trackingSteps.value = _buildStepsFromStatus(currentOrderStatus.value);
      if (orderProducts.isEmpty) {
        orderProducts.assignAll([
          {'name': 'Product', 'status': 'pending'},
        ]);
      }
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTracking() async {
    final orderId = currentOrderId.value;
    if (orderId.isEmpty) return;
    await fetchOrderDetails(orderId);
  }

  Future<void> startTrackingAfterCheckout({
    required String paymentMethod,
  }) async {
    await loadLatestOrder();
  }
}
