import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/wave_model.dart';
import 'package:paya_app/presentation/controllers/product_details_controller.dart';
import 'package:paya_app/presentation/widgets/product_image.dart';
import 'package:share_plus/share_plus.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductDetailsController());

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.product.value?.name ?? 'Détail du produit',
            style: const TextStyle(color: AppTheme.deepBlue),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.deepBlue),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppTheme.deepBlue),
            onPressed: () => _shareToWhatsApp(controller),
            tooltip: 'Partager sur WhatsApp',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Product Info Card
            _buildProductInfoCard(controller),

            // Wave Filter
            _buildWaveFilter(controller),

            // Customer Payment List
            Expanded(child: _buildCustomerPaymentList(controller)),

            // Share Button at Bottom
            _buildShareButton(controller),
          ],
        );
      }),
    );
  }

  Widget _buildProductInfoCard(ProductDetailsController controller) {
    final product = controller.product.value;
    if (product == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ProductImage(
            product: product,
            width: 80,
            height: 80,
            borderRadius: BorderRadius.circular(12),
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 16),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Prix: ${product.price.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.payaGray,
                  ),
                ),
                if (product.prixTTC != null)
                  Text(
                    'PTT: ${product.prixTTC!.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successGreen,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveFilter(ProductDetailsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: AppTheme.deepBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Obx(() {
              final waves = controller.waves;
              return DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: controller.selectedWaveId.value,
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
                    controller.setWaveFilter(value);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerPaymentList(ProductDetailsController controller) {
    return Obx(() {
      final payments = controller.customerPayments;

      if (payments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 80,
                color: AppTheme.deepBlue.withOpacity(0.2),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun client n\'a encore commandé ce produit',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final entry = payments[index];
          final customer = entry.customer;
          final orderItem = entry.orderItem;
          final order = entry.order;

          final isPaid = orderItem.isReadyForDelivery;
          final hasPartialPayment = orderItem.paidAmount > 0 && !isPaid;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPaid
                    ? AppTheme.successGreen.withOpacity(0.3)
                    : hasPartialPayment
                    ? AppTheme.payaOrange.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isPaid
                    ? AppTheme.successGreen
                    : hasPartialPayment
                    ? AppTheme.payaOrange
                    : AppTheme.payaGray,
                child: Text(
                  customer.name.isNotEmpty
                      ? customer.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                customer.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Quantité: ${orderItem.quantity}'),
                  if (hasPartialPayment)
                    Text(
                      'Payé: ${orderItem.paidAmount.toStringAsFixed(0)} / ${orderItem.totalPrice.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(color: AppTheme.payaOrange),
                    ),
                  Text('Vague: ${controller.getWaveName(order.waveId)}'),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isPaid
                      ? AppTheme.successGreen.withOpacity(0.1)
                      : hasPartialPayment
                      ? AppTheme.payaOrange.withOpacity(0.1)
                      : AppTheme.payaGray.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPaid
                      ? 'Payé ✓'
                      : hasPartialPayment
                      ? 'Partiel'
                      : 'En attente',
                  style: TextStyle(
                    color: isPaid
                        ? AppTheme.successGreen
                        : hasPartialPayment
                        ? AppTheme.payaOrange
                        : AppTheme.payaGray,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildShareButton(ProductDetailsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _shareToWhatsApp(controller),
        icon: const Icon(Icons.share, color: Colors.white),
        label: const Text(
          'Copier / Partager sur WhatsApp',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.successGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Future<void> _shareToWhatsApp(ProductDetailsController controller) async {
    String? chosenWaveId = controller.selectedWaveId.value;
    final currentProduct = controller.product.value;

    if (chosenWaveId == null) {
      final activeWavesForProduct = controller.waves.where((w) {
        return w.status == WaveStatus.active &&
            (w.productIds.contains(currentProduct?.id) ||
                (currentProduct?.waveIds.contains(w.id) ?? false));
      }).toList();

      if (activeWavesForProduct.length > 1) {
        final selected = await Get.bottomSheet<String>(
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choisir la vague à partager',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ce produit est associé à plusieurs vagues actives. Choisissez celle pour laquelle vous lancez les commandes :',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ...activeWavesForProduct.map((w) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading:
                          const Icon(Icons.waves, color: AppTheme.deepBlue),
                      title: Text(
                        w.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: w.closeDate != null
                          ? Text(
                              'Clôture le ${w.closeDate!.day}/${w.closeDate!.month}/${w.closeDate!.year}',
                            )
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: AppTheme.warmCream.withOpacity(0.5),
                      trailing:
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: () => Get.back(result: w.id),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Annuler'),
                  ),
                ),
              ],
            ),
          ),
        );

        if (selected == null) {
          return; // Annulé par l'utilisateur
        }
        chosenWaveId = selected;
      }
    }

    final message =
        controller.generateWhatsAppMessage(overrideWaveId: chosenWaveId);

    if (message.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Aucune donnée à partager',
        backgroundColor: AppTheme.softRed,
        colorText: Colors.white,
      );
      return;
    }

    // Show bottom sheet with options
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Partager sur WhatsApp',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepBlue,
              ),
            ),
            const SizedBox(height: 24),
            // Preview
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  message,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Copy button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: message));
                  Get.back();
                  Get.snackbar(
                    'Copié !',
                    'Texte copié dans le presse-papiers',
                    backgroundColor: AppTheme.successGreen,
                    colorText: Colors.white,
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copier le texte'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.deepBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // WhatsApp share button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Get.back();
                  await Share.share(message);
                },
                icon: const Icon(Icons.share),
                label: const Text('Partager'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: AppTheme.payaGray),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}
