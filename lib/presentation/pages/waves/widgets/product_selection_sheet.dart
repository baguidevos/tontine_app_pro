import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/services/auth_service.dart';
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
  final RxList<ProductModel> _vendorProducts = <ProductModel>[].obs;
  final RxBool _isLoadingProducts = true.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (!Get.isRegistered<ProductController>()) {
      Get.put(ProductController());
    }
    if (!Get.isRegistered<WaveController>()) {
      Get.put(WaveController());
    }

    _productController = Get.find<ProductController>();
    _waveController = Get.find<WaveController>();
    _selectedIds.addAll(widget.initialProductIds);

    _loadVendorProducts();
  }

  Future<void> _loadVendorProducts() async {
    _isLoadingProducts.value = true;
    try {
      String? vendorId;
      if (Get.isRegistered<AuthService>()) {
        vendorId = Get.find<AuthService>().currentVendorId;
      }
      if (vendorId != null) {
        final all =
            await _productController.productRepository.getProductsByVendor(vendorId);
        _vendorProducts.value = all;
      }
    } catch (e) {
      debugPrint('[ProductSelectionSheet] Erreur chargement produits: $e');
    } finally {
      _isLoadingProducts.value = false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ProductModel> get _filteredProducts {
    final query = _searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) {
      return _vendorProducts;
    }
    return _vendorProducts
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.slate300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sélectionner des produits',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.slate900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Associez des produits du catalogue à cette vague',
                        style: TextStyle(fontSize: 12, color: AppTheme.slate500),
                      ),
                    ],
                  ),
                ),
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.deepBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedIds.length} sélectionné(s)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.deepBlue,
                    ),
                  ),
                )),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextField(
              onChanged: (value) => _searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                hintStyle: const TextStyle(fontSize: 13, color: AppTheme.slate400),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.slate400, size: 20),
                suffixIcon: Obx(() => _searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: AppTheme.slate400),
                        onPressed: () => _searchQuery.value = '',
                      )
                    : const SizedBox.shrink()),
                filled: true,
                fillColor: AppTheme.slate50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.slate200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.slate200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.deepBlue, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppTheme.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.slate600,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppTheme.deepBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.all(3),
              tabs: const [
                Tab(text: 'Produits existants'),
                Tab(text: 'Nouveau produit'),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildExistingProductsTab(), _buildNewProductTab()],
            ),
          ),

          const Divider(height: 1, color: AppTheme.slate200),

          // Footer actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.slate700,
                      side: const BorderSide(color: AppTheme.slate300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Obx(() {
                    return ElevatedButton(
                      onPressed: () async {
                        _waveController.setSelectedProducts(
                          _selectedIds.toList(),
                        );

                        if (widget.waveId != null) {
                          await _waveController.setWaveProducts(
                            widget.waveId!,
                            _selectedIds.toList(),
                            previousProductIds: widget.initialProductIds,
                          );
                        }

                        Get.back();

                        if (widget.onProductsUpdated != null) {
                          widget.onProductsUpdated!();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Enregistrer (${_selectedIds.length})',
                        style: const TextStyle(fontWeight: FontWeight.w700),
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
      if (_isLoadingProducts.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.deepBlue),
              ),
              SizedBox(height: 12),
              Text(
                'Chargement des produits...',
                style: TextStyle(fontSize: 13, color: AppTheme.slate500),
              ),
            ],
          ),
        );
      }

      final products = _filteredProducts;

      if (products.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.slate100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 40,
                    color: AppTheme.slate400,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _searchQuery.value.isEmpty
                      ? 'Aucun produit dans votre catalogue'
                      : 'Aucun produit ne correspond à votre recherche',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.slate700),
                  textAlign: TextAlign.center,
                ),
                if (_searchQuery.value.isEmpty) ...[
                  const SizedBox(height: 6),
                  const Text(
                    'Vous pouvez créer votre premier produit dans l\'onglet "Nouveau produit"',
                    style: TextStyle(fontSize: 12, color: AppTheme.slate500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.slate50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.slate200),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.deepBlue.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart_rounded,
                    size: 36,
                    color: AppTheme.deepBlue,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Créer un nouveau produit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slate900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Le produit sera ajouté à votre catalogue et automatiquement associé à cette vague.',
                  style: TextStyle(fontSize: 12, color: AppTheme.slate500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await Future.delayed(const Duration(milliseconds: 200));
                    await Get.toNamed(
                      '/products/create',
                      arguments: {
                        'preselectedWaveId': widget.waveId,
                      },
                    );
                    if (widget.onProductsUpdated != null) {
                      widget.onProductsUpdated!();
                    }
                  },
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Remplir la fiche produit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.deepBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggleSelect,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.deepBlue.withValues(alpha: 0.04)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppTheme.deepBlue : AppTheme.slate200,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ProductImage(
                  product: product,
                  width: 46,
                  height: 46,
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.slate100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppTheme.deepBlue,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isSelected ? AppTheme.deepBlue : AppTheme.slate900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.price.toStringAsFixed(0)} FCFA • Stock: ${product.stock}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppTheme.deepBlue : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppTheme.deepBlue : AppTheme.slate300,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
