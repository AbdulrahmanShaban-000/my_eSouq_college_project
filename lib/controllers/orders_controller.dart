import 'package:get/get.dart';

class OrderTrackingStep {
  final String label;
  final bool done;

  OrderTrackingStep({required this.label, required this.done});

  @override
  String toString() => 'OrderTrackingStep(label: $label, done: $done)';
}

class OrdersController extends GetxController {

  final isLoading = false.obs;
  final currentOrderId = ''.obs;
  final trackingSteps = <OrderTrackingStep>[].obs;

 
  Future<String> createOrderMock({required String paymentMethod}) async {
   
    await Future.delayed(const Duration(milliseconds: 600));

    final mockOrderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    return mockOrderId;
  }

  Future<void> trackOrderMock(String orderId) async {
    isLoading.value = true;

    await Future.delayed(const Duration(milliseconds: 500));

    currentOrderId.value = orderId;

    trackingSteps.value = [
      OrderTrackingStep(label: 'Order received', done: true),
      OrderTrackingStep(label: 'Preparing your order', done: true),
      OrderTrackingStep(label: 'Shipped', done: false),
      OrderTrackingStep(label: 'Delivered', done: false),
    ];

    isLoading.value = false;
  }


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
