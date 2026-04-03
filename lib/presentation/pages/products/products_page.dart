import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/product_model.dart';
import 'package:paya_app/presentation/controllers/product_controller.dart';
import 'package:paya_app/presentation/controllers/wave_controller.dart';
import 'widgets/wave_selection_dialog.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controllers are loaded via MainLayoutBinding
    final productController = Get.put(ProductController());
    final waveController = Get.find<WaveController>();

    // Refresh products on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productController.loadProducts();
    });

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/products/create'),
        backgroundColor: AppTheme.deepBlue,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text(
          'Nouveau Produit',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.filter_list, color: AppTheme.deepBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() {
                    final waves = waveController.waves;
                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: productController.filterWaveId.value,
                        hint: const Text('Toutes les vagues'),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Toutes les vagues'),
                          ),
                          ...waves.map((wave) {
                            return DropdownMenuItem(
                              value: wave.id,
                              child: Text(wave.name),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          productController.setWaveFilter(value);
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Product List
          Expanded(
            child: Obx(() {
              if (productController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (productController.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 80,
                        color: AppTheme.deepBlue.withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun produit',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: productController.products.length,
                itemBuilder: (context, index) {
                  final product = productController.products[index];
                  return _buildProductCard(context, product, productController);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductModel product,
    ProductController controller,
  ) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Get.toNamed('/products/edit', arguments: product),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  color: Colors.grey.shade200,
                  image: product.localImagePath.isNotEmpty
                      ? DecorationImage(
                          image: FileImage(File(product.localImagePath)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: product.localImagePath.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                      )
                    : null,
              ),
            ),

            // Info Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      color: AppTheme.deepBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stock: ${product.stock}',
                        style: TextStyle(
                          fontSize: 12,
                          color: product.stock > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Show simpler menu or duplication options
                          _showProductOptions(context, controller, product);
                        },
                        child: const Icon(
                          Icons.more_vert,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier'),
              onTap: () {
                Get.back();
                Get.toNamed('/products/edit', arguments: product);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Dupliquer vers une autre vague'),
              onTap: () {
                Get.back();
                _showDuplicateDialog(controller, product);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Get.back();
                controller.deleteProduct(product.id);
              },
            ),
          ],
        ),
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
          Get.back(); // Close dialog
          Get.snackbar(
            'Succès',
            'Produit dupliqué avec succès',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
          );
        },
      ),
    );
  }
}
