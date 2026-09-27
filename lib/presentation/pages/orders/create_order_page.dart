import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/order_model.dart';
import 'package:paya_app/data/models/product_model.dart';
import 'package:paya_app/data/models/wave_model.dart';
import 'package:paya_app/presentation/controllers/customer_controller.dart';
import 'package:paya_app/presentation/controllers/order_controller.dart';
import 'package:paya_app/presentation/controllers/product_controller.dart';
import 'package:paya_app/presentation/controllers/wave_controller.dart';
import 'package:paya_app/presentation/widgets/product_image.dart';
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

  void _showProductSelector() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.slate200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sélectionner un produit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkerBlue,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final products = _productController.products;
                if (products.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun produit disponible dans le catalogue',
                      style: TextStyle(color: AppTheme.slate500),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.slate50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.slate200),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        leading: ProductImage(
                          product: product,
                          width: 48,
                          height: 48,
                          borderRadius: BorderRadius.circular(10),
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        subtitle: Text(
                          '${product.price.toStringAsFixed(0)} FCFA • Stock: ${product.stock}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.slate500),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.payaBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add_rounded, color: AppTheme.payaBlue, size: 20),
                        ),
                        onTap: () {
                          Get.back();
                          _showQuantityDialog(product);
                        },
                      ),
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
    final index = _cartItems.indexWhere((item) => item.productId == product.id);
    if (index != -1) {
      final existing = _cartItems[index];
      final newQty = existing.quantity + quantity;
      _cartItems[index] = existing.copyWith(quantity: newQty);
    } else {
      _cartItems.add(
        OrderItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
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
    if (_selectedCustomerId == null || _cartItems.isEmpty) return;
    _orderController.createOrder(
      customerId: _selectedCustomerId!,
      items: _cartItems.toList(),
      waveId: _selectedWaveId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.payaCream,
      appBar: AppBar(
        title: const Text(
          'Nouvelle Commande',
          style: TextStyle(
            color: AppTheme.darkerBlue,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.slate200, width: 1),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppTheme.payaBlue),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // 1. Customer & Wave Selection Header Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: AppTheme.modernCardDecoration(borderRadius: 20),
              child: Obx(() {
                if (_customerController.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(color: AppTheme.payaBlue),
                    ),
                  );
                }

                final customers = _customerController.customers;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations de la vente',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.slate800,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Customer Selection Row
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedCustomerId,
                            decoration: const InputDecoration(
                              labelText: 'Sélectionner le client',
                              prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.payaBlue, size: 20),
                              fillColor: AppTheme.slate50,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            items: customers
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(
                                      c.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedCustomerId = val;
                              });
                            },
                            hint: const Text('Choisir un client'),
                            validator: (value) => value == null ? 'Client requis' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.payaBlue,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.payaBlue.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.person_add_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => Get.toNamed('/customers/create'),
                            tooltip: 'Nouveau client',
                          ),
                        ),
                      ],
                    ),

                    if (customers.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Aucun client enregistré. Créez-en un via le bouton (+).',
                          style: TextStyle(color: AppTheme.payaRed, fontSize: 12),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Wave Selection
                    Obx(() {
                      if (_waveController.isLoading.value) {
                        return const SizedBox.shrink();
                      }

                      final waves = _waveController.waves
                          .where((w) => w.status == WaveStatus.active)
                          .toList();

                      return DropdownButtonFormField<String>(
                        initialValue: _selectedWaveId,
                        decoration: const InputDecoration(
                          labelText: 'Vague associée (optionnel)',
                          prefixIcon: Icon(Icons.waves_rounded, color: AppTheme.payaOrange, size: 20),
                          fillColor: AppTheme.slate50,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Aucune vague (Vente directe)'),
                          ),
                          ...waves.map(
                            (w) => DropdownMenuItem(
                              value: w.id,
                              child: Text(
                                w.name,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
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
                  ],
                );
              }),
            ),
          ),

          // 2. Cart Items Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Panier de la commande',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkerBlue,
                  ),
                ),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.payaBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_cartItems.length} article(s)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.payaBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cart Items List
          Expanded(
            child: Obx(() {
              if (_cartItems.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.slate200),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 48,
                            color: AppTheme.slate400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Le panier est vide',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.slate700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Ajoutez un produit du catalogue pour démarrer la vente',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppTheme.slate500),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _showProductSelector,
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text('Choisir un produit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.payaBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: _cartItems.length + 1,
                itemBuilder: (context, index) {
                  if (index == _cartItems.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: OutlinedButton.icon(
                        onPressed: _showProductSelector,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Ajouter un autre produit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.payaBlue,
                          side: const BorderSide(color: AppTheme.payaBlue, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    );
                  }

                  final item = _cartItems[index];
                  final itemTotal = item.quantity * item.unitPrice;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.slate200.withValues(alpha: 0.8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.payaBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.inventory_2_rounded,
                            size: 22,
                            color: AppTheme.payaBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppTheme.slate900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${item.quantity} x ${item.unitPrice.toStringAsFixed(0)} FCFA',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.slate500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${itemTotal.toStringAsFixed(0)} F',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: AppTheme.darkerBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () => _cartItems.removeAt(index),
                              borderRadius: BorderRadius.circular(8),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppTheme.payaRed,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),

          // 3. Modern Sticky Footer
          Obx(() {
            final total = _cartItems.fold(
              0.0,
              (sum, item) => sum + (item.unitPrice * item.quantity),
            );

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                border: Border(
                  top: BorderSide(color: AppTheme.slate200.withValues(alpha: 0.8), width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.payaBlue.withValues(alpha: 0.05),
                    offset: const Offset(0, -5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total à payer :',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.slate600,
                          ),
                        ),
                        Text(
                          '${total.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.darkerBlue,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            _cartItems.isEmpty || _selectedCustomerId == null
                            ? null
                            : _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.payaBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          shadowColor: AppTheme.payaBlue.withValues(alpha: 0.35),
                          disabledBackgroundColor: AppTheme.slate200,
                          disabledForegroundColor: AppTheme.slate400,
                        ),
                        child: _orderController.isLoading.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Valider la commande',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
