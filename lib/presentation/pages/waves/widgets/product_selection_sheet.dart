import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/product_model.dart';
import 'package:paya_app/presentation/controllers/product_controller.dart';
import 'package:paya_app/presentation/controllers/wave_controller.dart';
import 'package:paya_app/presentation/widgets/product_image.dart';

class ProductSelectionSheet extends StatefulWidget {
  final List<String> initialProductIds;
  final String? waveId;
  final VoidCallback? onProductsUpdated;

  const ProductSelectionSheet({
    super.key,
    this.initialProductIds = const [],
    this.waveId,
    this.onProductsUpdated,
  });

  @override
  State<ProductSelectionSheet> createState() => _ProductSelectionSheetState();
}

class _ProductSelectionSheetState extends State<ProductSelectionSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProductController _productController;
  late WaveController _waveController;
  final RxSet<String> _selectedIds = <String>{}.obs;
  final RxString _searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize controllers if not already registered
    if (!Get.isRegistered<ProductController>()) {
      Get.put(ProductController());
    }
    if (!Get.isRegistered<WaveController>()) {
      Get.put(WaveController());
    }

    _productController = Get.find<ProductController>();
    _waveController = Get.find<WaveController>();
    _selectedIds.addAll(widget.initialProductIds);

    // Load products if not already loaded
    if (_productController.products.isEmpty) {
      _productController.loadProducts();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ProductModel> get _filteredProducts {
    final query = _searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      return _productController.products;
    }
    return _productController.products
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Sélectionner des produits',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choisissez les produits à lier à cette vague',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (value) => _searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.deepBlue),
                filled: true,
                fillColor: AppTheme.warmCream.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.deepBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.deepBlue,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Produits existants'),
              Tab(text: 'Nouveau produit'),
            ],
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildExistingProductsTab(), _buildNewProductTab()],
            ),
          ),

          // Action button
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Obx(() {
                    final hasSelection = _selectedIds.isNotEmpty;
                    return ElevatedButton(
                      onPressed: hasSelection
                          ? () async {
                              _waveController.setSelectedProducts(
                                _selectedIds.toList(),
                              );

                              // If waveId is provided, persist the products to Firestore
                              if (widget.waveId != null) {
                                await _waveController.setWaveProducts(
                                  widget.waveId!,
                                  _selectedIds.toList(),
                                );
                              }

                              // Close the bottom sheet
                              Navigator.of(context).pop();

                              // Notify parent to reload products
                              if (widget.onProductsUpdated != null) {
                                widget.onProductsUpdated!();
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: Text(
                        'Valider (${_selectedIds.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingProductsTab() {
    return Obx(() {
      final products = _filteredProducts;

      if (products.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.value.isEmpty
                    ? 'Aucun produit'
                    : 'Aucun produit trouvé',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              if (_searchQuery.value.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Créez votre premier produit dans l\'onglet "Nouveau produit"',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final product = products[index];
          return Obx(() {
            final isSelected = _selectedIds.contains(product.id);
            return _ProductItem(
              product: product,
              isSelected: isSelected,
              onToggleSelect: () {
                if (isSelected) {
                  _selectedIds.remove(product.id);
                } else {
                  _selectedIds.add(product.id);
                }
              },
            );
          });
        },
      );
    });
  }

  Widget _buildNewProductTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.warmCream,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 64,
                  color: AppTheme.deepBlue.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Créer un nouveau produit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajoutez un produit qui sera automatiquement lié à cette vague',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Get.toNamed('/products/create');
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Créer un produit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.deepBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final ProductModel product;
  final bool isSelected;
  final VoidCallback onToggleSelect;

  const _ProductItem({
    required this.product,
    required this.isSelected,
    required this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggleSelect,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.deepBlue.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.deepBlue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            ProductImage(
              product: product,
              width: 48,
              height: 48,
              borderRadius: BorderRadius.circular(12),
              fit: BoxFit.cover,
              errorWidget: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.warmCream,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppTheme.deepBlue,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(0)} FCFA • ${product.stock} en stock',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.deepBlue,
                        border: Border.all(color: AppTheme.deepBlue, width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      ),
                    )
                  : Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
