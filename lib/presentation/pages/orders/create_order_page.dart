import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/wave_controller.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/wave_model.dart';
import 'widgets/quantity_dialog.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  late final CustomerController _customerController;
  late final ProductController _productController;
  late final WaveController _waveController;
  final OrderController _orderController = Get.find<OrderController>();

  String? _selectedCustomerId;
  String? _selectedWaveId;
  final RxList<OrderItemModel> _cartItems = <OrderItemModel>[].obs;

  @override
  void initState() {
    super.initState();
    _customerController = Get.find<CustomerController>();
    _productController = Get.find<ProductController>();
    _waveController = Get.find<WaveController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        title: const Text(
          'Nouvelle Commande',
          style: TextStyle(color: AppTheme.deepBlue),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.deepBlue),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // 1. Customer & Wave Selection
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              if (_customerController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final customers = _customerController.customers;

              return Column(
                children: [
                  // Customer Selection
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCustomerId,
                          decoration: InputDecoration(
                            labelText: 'Sélectionner le client',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          items: customers
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCustomerId = val;
                            });
                          },
                          hint: const Text('Choisir un client'),
                          validator: (value) => value == null ? 'Requis' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.deepBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.person_add,
                            color: Colors.white,
                          ),
                          onPressed: () => Get.toNamed('/customers/create'),
                          tooltip: 'Nouveau Client',
                        ),
                      ),
                    ],
                  ),
                  if (customers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                      child: Text(
                        'Aucun client trouvé. Veuillez en créer un.',
                        style: TextStyle(color: Colors.red[300], fontSize: 12),
                      ),
                    ),

                  // Wave Selection
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          if (_waveController.isLoading.value) {
                            return const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(),
                            );
                          }

                          final waves = _waveController.waves
                              .where((w) => w.status == WaveStatus.active)
                              .toList();

                          return DropdownButtonFormField<String>(
                            value: _selectedWaveId,
                            decoration: InputDecoration(
                              labelText: 'Vague (optionnel)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.waves),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Aucune vague'),
                              ),
                              ...waves.map(
                                (w) => DropdownMenuItem(
                                  value: w.id,
                                  child: Text(w.name),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedWaveId = val;
                              });
                            },
                            hint: const Text('Choisir une vague'),
                          );
                        }),
                      ),
                    ],
                  ),
                  Obx(() {
                    if (_waveController.isLoading.value) {
                      return const SizedBox.shrink();
                    }
                    final waves = _waveController.waves
                        .where((w) => w.status == WaveStatus.active)
                        .toList();
                    if (waves.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Aucune vague active. Créez une vague pour organiser vos commandes.',
                          style: TextStyle(
                            color: Colors.red[800],
                            fontSize: 14,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              );
            }),
          ),

          const Divider(),

          // 2. Cart Items List
          Expanded(
            child: Obx(() {
              if (_cartItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 60,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text('Le panier est vide'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showProductSelector,
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter un produit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.deepBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _cartItems.length + 1, // +1 for Add button
                itemBuilder: (context, index) {
                  if (index == _cartItems.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton.icon(
                        onPressed: _showProductSelector,
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter un autre produit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.deepBlue,
                          side: const BorderSide(color: AppTheme.deepBlue),
                        ),
                      ),
                    );
                  }

                  final item = _cartItems[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                        '${item.quantity} x ${item.unitPrice.toStringAsFixed(0)} FCFA',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(item.quantity * item.unitPrice).toStringAsFixed(0)} FCFA',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _cartItems.removeAt(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // 3. Footer Summary & Action
          Obx(() {
            final total = _cartItems.fold(
              0.0,
              (sum, item) => sum + (item.unitPrice * item.quantity),
            );

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Commande:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${total.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.deepBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          _cartItems.isEmpty || _selectedCustomerId == null
                          ? null
                          : _submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: _orderController.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Valider la Commande',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showProductSelector() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Sélectionner un produit',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            // Search Bar could go here
            Expanded(
              child: Obx(() {
                final products = _productController.products;
                // Filter out out-of-stock products logic if needed

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey.shade200,
                        child: product.localImagePath.isNotEmpty
                            ? Image.file(
                                File(product.localImagePath),
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image),
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                        'Stock: ${product.stock} | Prix: ${product.price.toStringAsFixed(0)}',
                      ),
                      onTap: () {
                        Get.back();
                        _showQuantityDialog(product);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showQuantityDialog(ProductModel product) {
    Get.dialog(
      QuantityDialog(
        product: product,
        onConfirm: (quantity) {
          _addToCart(product, quantity);
        },
      ),
    );
  }

  void _addToCart(ProductModel product, int quantity) {
    // Check if item already exists
    final index = _cartItems.indexWhere((item) => item.productId == product.id);
    if (index != -1) {
      // Update quantity
      final existing = _cartItems[index];
      final newQty = existing.quantity + quantity;
      // Re-check stock constraint if needed
      _cartItems[index] = existing.copyWith(quantity: newQty);
    } else {
      _cartItems.add(
        OrderItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
          productId: product.id,
          name: product.name,
          unitPrice: product.price,
          quantity: quantity,
          paidAmount: 0,
        ),
      );
    }
  }

  void _submitOrder() {
    _orderController.createOrder(
      customerId: _selectedCustomerId!,
      items: _cartItems.toList(),
      waveId: _selectedWaveId,
    );
  }
}
