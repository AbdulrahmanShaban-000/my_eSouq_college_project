import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/controllers/orders_controller.dart';

class TrackOrderPage extends StatefulWidget {
  final String? initialOrderId;
  const TrackOrderPage({super.key, this.initialOrderId});

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  final OrdersController ordersController = Get.find<OrdersController>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ordersController.fetchMyOrders());

    final orderId =
        widget.initialOrderId ?? ordersController.currentOrderId.value;
    if (orderId.isNotEmpty) {
      ordersController.fetchOrderDetails(orderId);
    } else {
      ordersController.loadLatestOrder();
    }
  }

  List<Map<String, dynamic>> _buildOrderHistoryItems() {
    final allItems = <Map<String, dynamic>>[];

    for (final order in ordersController.myOrders) {
      final items = order['items'] ?? order['products'] ?? <dynamic>[];
      if (items is! List) continue;

      for (final item in items) {
        if (item is! Map<String, dynamic>) continue;

        final product = item['product'];
        final name =
            (product is Map<String, dynamic>
                ? product['name']
                : item['name'] ?? item['product_name']) ??
            'Product';

        allItems.add({
          'name': name.toString(),
          'status': (order['status'] ?? 'pending').toString(),
        });
      }
    }

    return allItems;
  }

  void _openHistorySheet(BuildContext context, ThemeData theme) {
    final historyItems = _buildOrderHistoryItems();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Previous order products',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (historyItems.isEmpty)
                    const Expanded(
                      child: Center(child: Text('No previous orders yet')),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: historyItems.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final item = historyItems[index];
                          final itemStatus = item['status'].toString();
                          final statusColor = _statusColor(itemStatus, theme);

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),

                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),

                             title: Text(
                                item['name'].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: theme
                                      .colorScheme
                                      .onSurface, 
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _statusLabel(itemStatus),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  Color _statusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'track_order'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: () => _openHistorySheet(context, theme),
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Previous orders',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0F2027),
                    const Color(0xFF203A43),
                    const Color(0xFF2C5364),
                  ]
                : [Colors.grey[50]!, Colors.grey[200]!, Colors.grey[300]!],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            final steps = ordersController.trackingSteps;
            final orderId = ordersController.currentOrderId.value;
            final status = ordersController.currentOrderStatus.value;
            final total = ordersController.orderTotal.value;
            final address = ordersController.orderAddress.value;
            final phone = ordersController.orderPhone.value;
            final products = ordersController.orderProducts;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.shopping_bag,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                orderId.isEmpty ? 'Order' : 'Order #$orderId',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Status: ${_statusLabel(status.isEmpty ? 'pending' : status)}',
                                style: TextStyle(
                                  color: _statusColor(
                                    status.isEmpty ? 'pending' : status,
                                    theme,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total: \$${total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _statusColor(
                        status.isEmpty ? 'pending' : status,
                        theme,
                      ).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _statusColor(
                          status.isEmpty ? 'pending' : status,
                          theme,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          color: _statusColor(
                            status.isEmpty ? 'pending' : status,
                            theme,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _statusLabel(status.isEmpty ? 'pending' : status),
                            style: TextStyle(
                              color: _statusColor(
                                status.isEmpty ? 'pending' : status,
                                theme,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: List.generate(steps.length, (index) {
                        final step = steps[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Icon(
                                  step.done
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: step.done ? Colors.green : Colors.grey,
                                ),
                                if (index != steps.length - 1)
                                  Container(
                                    width: 2,
                                    height: 40,
                                    color: Colors.grey[300],
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  step.label,
                                  style: TextStyle(
                                    fontWeight: step.done
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Products',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (products.isEmpty)
                          const Text('No products available')
                        else
                          ...products.map((product) {
                            final name = product['name'] ?? 'Product';
                            final itemStatus = _statusLabel(
                              (product['status'] ?? status).toString(),
                            );
                            final itemColor = _statusColor(
                              (product['status'] ?? status).toString(),
                              theme,
                            );

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Status: $itemStatus',
                                          style: TextStyle(
                                            color: itemColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.location_on_outlined),
                          title: const Text('Address'),
                          subtitle: Text(
                            address.isEmpty ? 'No address provided' : address,
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.phone_outlined),
                          title: const Text('Phone'),
                          subtitle: Text(
                            phone.isEmpty ? 'No phone number' : phone,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  OutlinedButton.icon(
                    onPressed: () {
                      Get.defaultDialog(
                        title: "تواصل معنا",
                        titleStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        content: Column(
                          children: [
                            const Icon(
                              Icons.support_agent,
                              size: 70,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              "هل تحتاج إلى مساعدة؟",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "+963-995-715-948",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        confirm: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Get.back(),
                          child: const Text("حسناً"),
                        ),
                        radius: 20,
                      );
                    },
                    icon: const Icon(Icons.support_agent),
                    label: const Text("Contact Support"),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 35),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
