import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/core/utils/platform_file_image.dart';
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
      backgroundColor: AppTheme.payaCream,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.product.value?.name ?? 'Détail du produit',
            style: const TextStyle(
              color: AppTheme.darkerBlue,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
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
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.slate200, width: 1),
              ),
              child: const Icon(Icons.share_rounded, size: 20, color: AppTheme.payaGreen),
            ),
            onPressed: () => _shareToWhatsApp(controller),
            tooltip: 'Partager sur WhatsApp',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.payaBlue));
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.modernCardDecoration(borderRadius: 22, hasShadow: true),
      child: Row(
        children: [
          // Product Image
          ProductImage(
            product: product,
            width: 84,
            height: 84,
            borderRadius: BorderRadius.circular(16),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkerBlue,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.payaBlue,
                      ),
                    ),
                    if (product.prixTTC != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.greenLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'TTC: ${product.prixTTC!.toStringAsFixed(0)} F',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.payaGreen,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: product.stock > 0 ? AppTheme.greenLight : AppTheme.redLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.stock > 0 ? 'Stock: ${product.stock}' : 'Rupture de stock',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: product.stock > 0 ? AppTheme.payaGreen : AppTheme.payaRed,
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

  Widget _buildWaveFilter(ProductDetailsController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slate200),
      ),
      child: Row(
        children: [
          const Icon(Icons.waves_rounded, color: AppTheme.payaOrange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(() {
              final waves = controller.waves;
              return DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: controller.selectedWaveId.value,
                  hint: const Text('Toutes les vagues', style: TextStyle(fontSize: 13)),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.slate500),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Toutes les vagues', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    ...waves.map((wave) {
                      return DropdownMenuItem(
                        value: wave.id,
                        child: Text(wave.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.slate100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_outline_rounded,
                  size: 44,
                  color: AppTheme.slate400,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Aucune commande client',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.slate700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Aucun client n\'a encore commandé ce produit.',
                style: TextStyle(fontSize: 12, color: AppTheme.slate500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final entry = payments[index];
          final customer = entry.customer;
          final orderItem = entry.orderItem;
          final order = entry.order;

          final isPaid = orderItem.isReadyForDelivery;
          final hasPartialPayment = orderItem.paidAmount > 0 && !isPaid;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isPaid
                    ? AppTheme.payaGreen.withValues(alpha: 0.3)
                    : hasPartialPayment
                    ? AppTheme.payaOrange.withValues(alpha: 0.3)
                    : AppTheme.slate200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isPaid
                      ? AppTheme.greenLight
                      : hasPartialPayment
                      ? AppTheme.orangeLight
                      : AppTheme.slate100,
                  child: Text(
                    customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: isPaid
                          ? AppTheme.payaGreen
                          : hasPartialPayment
                          ? AppTheme.payaOrange
                          : AppTheme.slate600,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.slate900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Qté: ${orderItem.quantity} • Vague: ${controller.getWaveName(order.waveId)}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.slate500),
                      ),
                      if (hasPartialPayment) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Payé: ${orderItem.paidAmount.toStringAsFixed(0)} / ${orderItem.totalPrice.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            color: AppTheme.payaOrange,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? AppTheme.greenLight
                        : hasPartialPayment
                        ? AppTheme.orangeLight
                        : AppTheme.slate100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isPaid
                        ? 'Soldé ✓'
                        : hasPartialPayment
                        ? 'Partiel'
                        : 'En attente',
                    style: TextStyle(
                      color: isPaid
                          ? AppTheme.payaGreen
                          : hasPartialPayment
                          ? AppTheme.payaOrange
                          : AppTheme.slate600,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildShareButton(ProductDetailsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.slate200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _shareToWhatsApp(controller),
            icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
            label: const Text(
              'Partager sur WhatsApp',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366), // WhatsApp Brand Green
              elevation: 2,
              shadowColor: const Color(0xFF25D366).withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choisir la vague à partager',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkerBlue,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ce produit est associé à plusieurs vagues actives. Choisissez celle pour laquelle vous lancez les commandes :',
                  style: TextStyle(fontSize: 13, color: AppTheme.slate500),
                ),
                const SizedBox(height: 16),
                ...activeWavesForProduct.map((w) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.slate50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.slate200),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.waves_rounded, color: AppTheme.payaOrange),
                      title: Text(
                        w.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: w.closeDate != null
                          ? Text(
                              'Clôture le ${w.closeDate!.day}/${w.closeDate!.month}/${w.closeDate!.year}',
                              style: const TextStyle(fontSize: 11),
                            )
                          : null,
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.slate400),
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
          return;
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
        backgroundColor: AppTheme.payaRed,
        colorText: Colors.white,
      );
      return;
    }

    Get.bottomSheet(
      Container(
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
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.slate200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Partager sur WhatsApp',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkerBlue,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.slate50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.slate200),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  message,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: message));
                  Get.back();
                  Get.snackbar(
                    'Copié !',
                    'Texte copié dans le presse-papiers',
                    backgroundColor: AppTheme.payaGreen,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 14,
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copier le texte'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Get.back();
                  await _shareWithImage(controller, message);
                },
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text('Partager avec la photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _shareWithImage(
    ProductDetailsController controller,
    String message,
  ) async {
    final currentProduct = controller.product.value;
    final localPath = currentProduct?.localImagePath;

    if (hasValidPlatformFile(localPath)) {
      try {
        await Share.shareXFiles([XFile(localPath!)], text: message);
        return;
      } catch (e) {
        debugPrint('[Share] Échec partage image locale: $e');
      }
    }

    final onlineUrl = currentProduct?.imageUrl;
    if (onlineUrl != null && onlineUrl.isNotEmpty) {
      try {
        final res = await http.get(Uri.parse(onlineUrl));
        if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
          final xFile = XFile.fromData(
            res.bodyBytes,
            mimeType: 'image/jpeg',
            name: '${currentProduct?.name ?? "produit"}.jpg',
          );
          await Share.shareXFiles([xFile], text: message);
          return;
        }
      } catch (e) {
        debugPrint('[Share] Échec récupération image distante pour partage: $e');
      }
    }

    await Share.share(message);
  }
}
