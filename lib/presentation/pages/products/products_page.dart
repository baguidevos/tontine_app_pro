import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/product_model.dart';
import 'package:paya_app/presentation/controllers/product_controller.dart';
import 'package:paya_app/presentation/controllers/wave_controller.dart';
import 'package:paya_app/presentation/widgets/main_layout.dart';
import 'widgets/wave_selection_dialog.dart';
import 'widgets/product_card_modern.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final productController = Get.put(ProductController());
  final waveController = Get.find<WaveController>();
  bool _isFabExpanded = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productController.loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.payaCream,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/products/create'),
        backgroundColor: AppTheme.payaBlue,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: _isFabExpanded
            ? const Text(
                'Nouveau Produit',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              )
            : const SizedBox.shrink(),
        isExtended: _isFabExpanded,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  if (notification.direction == ScrollDirection.forward) {
                    if (!_isFabExpanded) setState(() => _isFabExpanded = true);
                  } else if (notification.direction == ScrollDirection.reverse) {
                    if (_isFabExpanded) setState(() => _isFabExpanded = false);
                  }
                  return true;
                },
                child: Obx(() {
                  if (productController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.payaBlue));
                  }

                  if (productController.products.isEmpty) {
                    return _buildEmptyState();
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16).copyWith(bottom: 80),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: productController.products.length,
                    itemBuilder: (context, index) {
                      final product = productController.products[index];
                      return ProductCardModern(
                        product: product,
                        onTap: () => Get.toNamed('/products/edit', arguments: product),
                        onViewDetails: () => Get.toNamed('/products/details', arguments: product),
                        onOptionsTap: () => _showProductOptions(context, productController, product),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.slate200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.payaBlue.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.slate200, width: 1),
                  ),
                  child: const Icon(Icons.menu_rounded, size: 20, color: AppTheme.payaBlue),
                ),
                onPressed: () {
                  MainLayout.scaffoldKey.currentState?.openDrawer();
                },
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Catalogue Produits',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkerBlue,
                  ),
                ),
              ),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.payaBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${productController.products.length} articles',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.payaBlue,
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 14),
          Obx(() {
            final waves = waveController.waves;
            final currentFilter = productController.filterWaveId.value;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'Tous les produits',
                    isSelected: currentFilter == null,
                    onTap: () => productController.setWaveFilter(null),
                  ),
                  const SizedBox(width: 8),
                  ...waves.map((wave) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip(
                        label: wave.name,
                        isSelected: currentFilter == wave.id,
                        onTap: () => productController.setWaveFilter(wave.id),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.payaBlue : AppTheme.slate50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppTheme.payaBlue : AppTheme.slate200,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.slate700,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
                Icons.inventory_2_outlined,
                size: 48,
                color: AppTheme.slate400,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Catalogue vide',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.slate800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ajoutez votre premier produit pour alimenter vos vagues et vos ventes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.slate500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/products/create'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Créer un produit'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductOptions(
    BuildContext context,
    ProductController controller,
    ProductModel product,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.slate200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkerBlue,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            _buildModalAction(
              icon: Icons.edit_rounded,
              iconColor: AppTheme.payaBlue,
              bgColor: AppTheme.payaBlue.withValues(alpha: 0.1),
              title: 'Modifier le produit',
              onTap: () {
                Get.back();
                Get.toNamed('/products/edit', arguments: product);
              },
            ),
            const SizedBox(height: 8),
            _buildModalAction(
              icon: Icons.copy_rounded,
              iconColor: AppTheme.payaOrange,
              bgColor: AppTheme.payaOrange.withValues(alpha: 0.1),
              title: 'Dupliquer vers une autre vague',
              onTap: () {
                Get.back();
                _showDuplicateDialog(controller, product);
              },
            ),
            const SizedBox(height: 8),
            _buildModalAction(
              icon: Icons.delete_outline_rounded,
              iconColor: AppTheme.payaRed,
              bgColor: AppTheme.redLight,
              title: 'Supprimer ce produit',
              textColor: AppTheme.payaRed,
              onTap: () {
                Get.back();
                Get.defaultDialog(
                  title: 'Supprimer le produit',
                  middleText: 'Êtes-vous sûr de vouloir supprimer "${product.name}" ?',
                  textConfirm: 'Supprimer',
                  textCancel: 'Annuler',
                  buttonColor: AppTheme.payaRed,
                  confirmTextColor: Colors.white,
                  onConfirm: () {
                    Get.back();
                    controller.deleteProduct(product.id);
                  },
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildModalAction({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slate200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: textColor ?? AppTheme.slate800,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.slate400),
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showDuplicateDialog(
    ProductController controller,
    ProductModel product,
  ) {
    Get.dialog(
      WaveSelectionDialog(
        onWaveSelected: (waveId) {
          controller.duplicateProduct(product, waveId);
          Get.back();
          Get.snackbar(
            'Succès',
            'Produit dupliqué avec succès',
            backgroundColor: AppTheme.payaGreen,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 14,
            icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
          );
        },
      ),
    );
  }
}
