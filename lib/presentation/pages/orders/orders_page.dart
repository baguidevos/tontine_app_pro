import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/order_controller.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.warmCream,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Commandes',
            style: TextStyle(
              color: AppTheme.deepBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            labelColor: AppTheme.deepBlue,
            indicatorColor: AppTheme.deepBlue,
            tabs: [
              Tab(text: 'En attente'),
              Tab(text: 'Payées'),
              Tab(text: 'Annulées'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrdersList(status: 'pending'),
            OrdersList(status: 'completed'),
            OrdersList(status: 'cancelled'),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.toNamed('/orders/create'),
          backgroundColor: AppTheme.deepBlue,
          icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
          label: const Text(
            'Nouvelle Commande',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  final String status;

  const OrdersList({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<OrderController>();
    // The instruction implies adding waveController, but orderController is still used below.
    // Assuming the intent was to add waveController alongside orderController, or a future refactor.
    // For now, keeping orderController as it's used.
    // final waveController = Get.find<WaveController>(); // If this was meant to replace, subsequent lines would need changing.

    return Obx(() {
      if (orderController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final orders = orderController.orders.where((o) {
        if (status == 'pending') {
          return o.status == 'pending' || o.status == 'active';
        }
        return o.status == status;
      }).toList();

      if (orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: AppTheme.deepBlue.withOpacity(0.2),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune commande',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                'Commande #${order.id.substring(order.id.length - 6)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('Client: ${order.customerId}'), // Ideally fetch name
                  Text('${order.items.length} articles'),
                  const SizedBox(height: 4),
                  Text(
                    'Total: ${order.totalAmount.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      color: AppTheme.deepBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_buildStatusChip(order.status)],
              ),
              onTap: () {
                Get.toNamed('/orders/details', arguments: order);
              },
            ),
          );
        },
      );
    });
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'completed':
        color = Colors.green;
        label = 'Terminée';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Annulée';
        break;
      case 'pending':
      default:
        color = Colors.orange;
        label = 'En cours';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
