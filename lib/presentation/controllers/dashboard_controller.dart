import 'package:get/get.dart';
import 'order_controller.dart';
import 'wave_controller.dart';
import 'package:paya_app/data/models/wave_model.dart';
import 'package:paya_app/data/models/order_model.dart';

class DashboardController extends GetxController {
  final OrderController _orderController = Get.find<OrderController>();
  final WaveController _waveController = Get.find<WaveController>();

  // Observable stats
  var monthlyRevenue = 0.0.obs;
  var pendingDebt = 0.0.obs;
  var activeWavesCount = 0.obs;
  var totalOrdersCount = 0.obs;
  var recentOrders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Setup workers to update stats whenever orders or waves change
    ever(_orderController.orders, (_) => _updateStats());
    ever(_waveController.waves, (_) => _updateStats());

    // Initial update
    _updateStats();
  }

  void _updateStats() {
    final orders = _orderController.orders;
    final waves = _waveController.waves;

    // 1. Total Orders
    totalOrdersCount.value = orders.length;

    // 2. Pending Debt (Total Balance)
    double debt = 0;
    for (var order in orders) {
      if (order.status != 'cancelled') {
        debt += (order.totalAmount - order.totalPaid);
      }
    }
    pendingDebt.value = debt;

    // 3. Monthly Revenue (Total Paid this month)
    // For now, let's assume totalPaid is what we want,
    // but ideally we'd track actual transactions dates.
    // Let's just sum up totalPaid for simplified revenue for now.
    double revenue = 0;
    final now = DateTime.now();
    for (var order in orders) {
      if (order.createdAt.month == now.month &&
          order.createdAt.year == now.year &&
          order.status != 'cancelled') {
        revenue += order.totalPaid;
      }
    }
    monthlyRevenue.value = revenue;

    // 4. Active Waves
    activeWavesCount.value = waves
        .where((w) => w.status == WaveStatus.active)
        .length;

    // 5. Recent Orders (last 5)
    final sortedOrders = List<OrderModel>.from(orders);
    sortedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    recentOrders.value = sortedOrders.take(5).toList();

    print(
      'DEBUG: Dashboard stats updated - Revenue: $revenue, Debt: $debt, Waves: ${activeWavesCount.value}, Recent: ${recentOrders.length}',
    );
  }
}
