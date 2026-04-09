import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/services/auth_service.dart';
import 'package:paya_app/data/models/customer_model.dart';
import 'package:paya_app/data/models/order_model.dart';
import 'package:paya_app/data/models/product_model.dart';
import 'package:paya_app/data/models/wave_model.dart';
import 'package:paya_app/data/repositories/customer_repository.dart';
import 'package:paya_app/data/repositories/order_repository.dart';
import 'package:paya_app/data/repositories/wave_repository.dart';

class ProductDetailsController extends GetxController {
  final OrderRepository _orderRepository = OrderRepository();
  final CustomerRepository _customerRepository = CustomerRepository();
  final WaveRepository _waveRepository = WaveRepository();
  final AuthService _authService = Get.find<AuthService>();

  var isLoading = false.obs;
  var product = Rxn<ProductModel>();
  var waves = <WaveModel>[].obs;
  var allVendorOrders = <OrderModel>[].obs; // All orders from vendor
  var customers = <CustomerModel>[].obs;

  // Filtering
  final Rx<String?> selectedWaveId = Rx<String?>(null);

  // Computed list of customer payments for display
  final RxList<CustomerPaymentEntry> customerPayments =
      <CustomerPaymentEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ProductModel) {
      product.value = args;
      _loadData();
    }
  }

  void _loadData() {
    final vendorId = _authService.currentVendorId;
    if (vendorId == null) return;

    isLoading.value = true;

    // Load waves for this vendor
    _waveRepository.watchWavesByVendor(vendorId).listen((waveList) {
      waves.value = waveList;
    });

    // Load customers
    _customerRepository.watchCustomersByVendor(vendorId).listen((customerList) {
      customers.value = customerList;
    });

    // Load ALL orders for this vendor (we'll filter by product locally)
    _orderRepository.watchOrdersByVendor(vendorId).listen((orderList) {
      allVendorOrders.value = orderList;
      _buildCustomerPayments();
    });

    isLoading.value = false;
  }

  /// Builds the list of customer payments with wave filtering
  void _buildCustomerPayments() {
    final currentProduct = product.value;
    if (currentProduct == null) return;

    // Step 1: Filter orders that contain this product
    final ordersWithProduct = allVendorOrders.where((order) {
      return order.items.any((item) => item.productId == currentProduct.id);
    }).toList();

    debugPrint('Product: ${currentProduct.name} (${currentProduct.id})');
    debugPrint('Total vendor orders: ${allVendorOrders.length}');
    debugPrint('Orders with this product: ${ordersWithProduct.length}');
    debugPrint('Customers loaded: ${customers.length}');

    // Step 2: Filter by wave if selected
    List<OrderModel> filteredOrders = ordersWithProduct;
    if (selectedWaveId.value != null) {
      filteredOrders = ordersWithProduct
          .where((o) => o.waveId == selectedWaveId.value)
          .toList();
      debugPrint('Filtered by wave: ${filteredOrders.length}');
    }

    // Step 3: Extract customer payment entries
    final Map<String, CustomerPaymentEntry> customerMap = {};

    for (final order in filteredOrders) {
      // Find items matching this product
      for (final item in order.items) {
        if (item.productId == currentProduct.id) {
          final customerId = order.customerId;
          final customer = customers.firstWhere(
            (c) => c.id == customerId,
            orElse: () => CustomerModel(
              id: customerId,
              vendorId: '',
              name: 'Client inconnu',
              phone: '',
              createdAt: DateTime.now(),
            ),
          );

          final key = '${order.id}_${item.id}';
          if (!customerMap.containsKey(key)) {
            customerMap[key] = CustomerPaymentEntry(
              customer: customer,
              order: order,
              orderItem: item,
            );
            debugPrint(
              'Added: ${customer.name} - Qty: ${item.quantity} - Paid: ${item.paidAmount}',
            );
          }
        }
      }
    }

    debugPrint('Total customer entries: ${customerMap.length}');
    customerPayments.value = customerMap.values.toList();
  }

  void setWaveFilter(String? waveId) {
    selectedWaveId.value = waveId;
    _buildCustomerPayments();
  }

  /// Gets the wave name for a given wave ID
  String getWaveName(String? waveId) {
    if (waveId == null) return 'Aucune vague';
    final wave = waves.firstWhere(
      (w) => w.id == waveId,
      orElse: () => WaveModel(
        id: waveId,
        name: 'Vague inconnue',
        status: WaveStatus.draft,
        createdAt: DateTime.now(),
      ),
    );
    return wave.name;
  }

  /// Gets wave status color
  String getWaveStatusColor(String? waveId) {
    if (waveId == null) return 'grey';
    final wave = waves.firstWhere(
      (w) => w.id == waveId,
      orElse: () => WaveModel(
        id: waveId,
        name: 'Vague inconnue',
        status: WaveStatus.draft,
        createdAt: DateTime.now(),
      ),
    );

    switch (wave.status) {
      case WaveStatus.active:
        return 'green';
      case WaveStatus.closed:
        return 'red';
      case WaveStatus.draft:
        return 'orange';
    }
    return 'grey';
  }

  /// Generates formatted text for WhatsApp sharing
  String generateWhatsAppMessage() {
    final currentProduct = product.value;
    if (currentProduct == null) return '';

    final prixTTC = currentProduct.prixTTC ?? currentProduct.price;
    final waveName = selectedWaveId.value != null
        ? getWaveName(selectedWaveId.value)
        : 'Toutes les vagues';

    // Get close date from selected wave or first wave with a close date
    DateTime? closeDate;
    if (selectedWaveId.value != null) {
      final selectedWave = waves.firstWhere(
        (w) => w.id == selectedWaveId.value,
        orElse: () => WaveModel(
          id: selectedWaveId.value!,
          name: waveName,
          status: WaveStatus.draft,
          createdAt: DateTime.now(),
        ),
      );
      closeDate = selectedWave.closeDate;
    }

    final closeDateString = closeDate != null
        ? '${closeDate.day} ${_getMonthName(closeDate.month)} ${closeDate.year}'
        : '25 avril 2026'; // Default fallback

    StringBuffer message = StringBuffer();
    message.writeln('Nouvelle commande du ${currentProduct.name} 😁😇');
    message.writeln('');
    message.writeln(
      'PTT(toutes taxes comprises) : ${prixTTC.toStringAsFixed(0)}f',
    );
    message.writeln('Vague : $waveName');
    message.writeln('');

    int index = 1;
    for (final entry in customerPayments) {
      final status = entry.orderItem.isReadyForDelivery
          ? '(payé ou confirmé)'
          : entry.orderItem.paidAmount > 0
          ? '(partiel: ${entry.orderItem.paidAmount.toStringAsFixed(0)}f)'
          : '(en attente)';

      final colorInfo = _getColorInfo(entry.orderItem.name);
      message.writeln(
        '$index- ${entry.customer.name} : ${entry.orderItem.quantity} ($colorInfo) $status',
      );
      index++;
    }

    // Add empty slots up to 10
    for (int i = index; i <= 10; i++) {
      message.writeln('$i-');
    }

    message.writeln('');
    message.writeln('Date de clôture : $closeDateString');

    return message.toString();
  }

  String _getMonthName(int month) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  /// Extracts color information from item name (assuming it's stored in the name field)
  String _getColorInfo(String itemName) {
    // Try to extract color from parentheses in the item name
    final match = RegExp(r'\(([^)]+)\)').firstMatch(itemName);
    if (match != null) {
      return match.group(1) ?? 'couleur standard';
    }
    return 'couleur standard';
  }

  void refreshData() {
    _loadData();
  }
}

/// Helper class to hold customer payment information
class CustomerPaymentEntry {
  final CustomerModel customer;
  final OrderModel order;
  final OrderItemModel orderItem;

  CustomerPaymentEntry({
    required this.customer,
    required this.order,
    required this.orderItem,
  });
}
