import 'package:get/get.dart';

class OrderTrackingStep {
  final String label;
  final bool done;

  OrderTrackingStep({required this.label, required this.done});

  @override
  String toString() => 'OrderTrackingStep(label: $label, done: $done)';
}

class OrdersController extends GetxController {
  /// current UI state
  final isLoading = false.obs;
  final currentOrderId = ''.obs;
  final trackingSteps = <OrderTrackingStep>[].obs;

  /// This is a temporary mock until Laravel APIs are ready.
  /// When backend is ready, replace this method with API call that:
  /// 1) creates an order
  /// 2) returns order_id
  Future<String> createOrderMock({required String paymentMethod}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final mockOrderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    return mockOrderId;
  }

  /// This is a temporary mock until Laravel APIs are ready.
  /// When backend is ready, replace this method with API call that fetches status/timeline.
  Future<void> trackOrderMock(String orderId) async {
    isLoading.value = true;

    await Future.delayed(const Duration(milliseconds: 500));

    currentOrderId.value = orderId;

    // Mock timeline steps
    trackingSteps.value = [
      OrderTrackingStep(label: 'Order received', done: true),
      OrderTrackingStep(label: 'Preparing your order', done: true),
      OrderTrackingStep(label: 'Shipped', done: false),
      OrderTrackingStep(label: 'Delivered', done: false),
    ];

    isLoading.value = false;
  }

  /// Called by UI when user wants refresh.
  Future<void> refreshTracking() async {
    final orderId = currentOrderId.value;
    if (orderId.isEmpty) return;
    await trackOrderMock(orderId);
  }

  Future<void> startTrackingAfterCheckout({
    required String paymentMethod,
  }) async {
    final orderId = await createOrderMock(paymentMethod: paymentMethod);
    await trackOrderMock(orderId);
  }
}
