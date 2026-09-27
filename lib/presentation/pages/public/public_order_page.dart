import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/public_order_controller.dart';
import '../../widgets/product_image.dart';

class PublicOrderPage extends StatelessWidget {
  const PublicOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PublicOrderController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppTheme.deepBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Paya Commande',
              style: TextStyle(
                color: AppTheme.deepBlue,
                fontWeight: FontWeight.w800,
                fontSize: 17,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.deepBlue),
                ),
                SizedBox(height: 16),
                Text(
                  'Chargement du produit...',
                  style: TextStyle(color: AppTheme.slate500, fontSize: 13),
                ),
              ],
            ),
          );
        }

        if (controller.errorMessage.value != null) {
          return _buildErrorState(controller);
        }

        if (controller.isOrderSubmitted.value) {
          return _buildSuccessState(context, controller);
        }

        return _buildOrderForm(context, controller);
      }),
    );
  }

  Widget _buildErrorState(PublicOrderController controller) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.slate200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.softRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: AppTheme.softRed,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Commande indisponible',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.slate900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.slate500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.loadData(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderForm(
    BuildContext context,
    PublicOrderController controller,
  ) {
    final product = controller.product.value!;
    final wave = controller.wave.value;
    final vendor = controller.vendor.value;
    final currencyFormatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Hero Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.slate200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: ProductImage(
                          product: product,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badges (Vendor & Wave)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (vendor != null && vendor.businessName.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.deepBlue.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.verified_user_rounded,
                                        size: 13,
                                        color: AppTheme.deepBlue,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        vendor.businessName,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.deepBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (wave != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.payaOrange.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.waves_rounded,
                                        size: 13,
                                        color: AppTheme.payaOrange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Vague : ${wave.name}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFC67C00),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Product Name
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.slate900,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Unit Price
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                currencyFormatter.format(controller.unitPrice),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.deepBlue,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '/ unité',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.slate500,
                                  fontWeight: FontWeight.w500,
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

              const SizedBox(height: 18),

              // Quantity & Order Form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.slate200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1. Quantité souhaitée',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.slate900,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Quantity Stepper
                      Row(
                        children: [
                          _buildQtyButton(
                            icon: Icons.remove_rounded,
                            onTap: controller.decrementQuantity,
                          ),
                          Container(
                            width: 54,
                            alignment: Alignment.center,
                            child: Obx(
                              () => Text(
                                '${controller.quantity.value}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.deepBlue,
                                ),
                              ),
                            ),
                          ),
                          _buildQtyButton(
                            icon: Icons.add_rounded,
                            onTap: controller.incrementQuantity,
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Total à régler',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.slate500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Obx(
                                () => Text(
                                  currencyFormatter.format(controller.totalAmount),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.payaOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Divider(height: 1, color: AppTheme.slate200),
                      ),

                      const Text(
                        '2. Vos coordonnées',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.slate900,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Full Name
                      TextFormField(
                        controller: controller.nameController,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        decoration: _inputDecoration(
                          label: 'Nom et Prénom(s) *',
                          hint: 'Ex: Jean Dupont',
                          icon: Icons.person_outline_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez saisir votre nom complet';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      // Phone (WhatsApp)
                      TextFormField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        decoration: _inputDecoration(
                          label: 'Numéro WhatsApp *',
                          hint: 'Ex: 70 00 00 00',
                          icon: Icons.phone_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez saisir votre numéro de téléphone';
                          }
                          if (value.trim().length < 8) {
                            return 'Numéro de téléphone incomplet';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      // Notes / Preferences
                      TextFormField(
                        controller: controller.noteController,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 14),
                        decoration: _inputDecoration(
                          label: 'Note ou préférences (Optionnel)',
                          hint: 'Ex: Couleur, taille, lieu de livraison...',
                          icon: Icons.edit_note_rounded,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Submit CTA
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: controller.isSubmitting.value
                                ? null
                                : controller.submitOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.deepBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: controller.isSubmitting.value
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle_rounded, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Valider ma commande • ${currencyFormatter.format(controller.totalAmount)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.handshake_outlined,
                            size: 15,
                            color: AppTheme.slate500,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Paiement direct avec le commerçant à la livraison',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.slate500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppTheme.slate100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, color: AppTheme.deepBlue, size: 18),
        ),
      ),
    );
  }

  Widget _buildSuccessState(
    BuildContext context,
    PublicOrderController controller,
  ) {
    final order = controller.createdOrder.value;
    final product = controller.product.value;
    final currencyFormatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.slate200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.payaGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 54,
                  color: AppTheme.payaGreen,
                ),
              ),
              const SizedBox(height: 18),

              const Text(
                'Commande Enregistrée ! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.slate900,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                'Merci ${controller.nameController.text.trim()}, votre commande a été transmise au commerçant.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppTheme.slate500),
              ),
              const SizedBox(height: 22),

              // Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.slate50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.slate200),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      'Produit',
                      product?.name ?? '',
                      isBold: true,
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Quantité', '${controller.quantity.value}'),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Montant total',
                      currencyFormatter.format(controller.totalAmount),
                      valueColor: AppTheme.deepBlue,
                      isBold: true,
                    ),
                    if (order != null) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, color: AppTheme.slate200),
                      ),
                      _buildSummaryRow(
                        'N° Commande',
                        '#${order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0)}',
                        valueColor: AppTheme.slate500,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Notify via WhatsApp CTA
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final url = controller.whatsappUrl;
                    if (url != null) {
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        await Clipboard.setData(
                          ClipboardData(
                            text: controller.buildWhatsAppConfirmationMessage(),
                          ),
                        );
                        Get.snackbar(
                          'Copié !',
                          'Message copié dans le presse-papier',
                          backgroundColor: AppTheme.payaGreen,
                          colorText: Colors.white,
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text(
                    'Confirmer au vendeur sur WhatsApp',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.payaGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Copy summary CTA
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(
                        text: controller.buildWhatsAppConfirmationMessage(),
                      ),
                    );
                    Get.snackbar(
                      'Copié !',
                      'Le texte récapitulatif a été copié',
                      backgroundColor: AppTheme.deepBlue,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copier le récapitulatif'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.deepBlue,
                    side: const BorderSide(color: AppTheme.deepBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.slate500),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? AppTheme.slate900,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: AppTheme.slate600),
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppTheme.slate400),
      prefixIcon: Icon(icon, color: AppTheme.deepBlue, size: 20),
      filled: true,
      fillColor: AppTheme.slate50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        borderSide: const BorderSide(color: AppTheme.deepBlue, width: 1.8),
      ),
    );
  }
}
