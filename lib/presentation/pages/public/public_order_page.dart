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
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.deepBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Paya Commande',
              style: TextStyle(
                color: AppTheme.deepBlue,
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.deepBlue),
                ),
                SizedBox(height: 16),
                Text(
                  'Chargement du produit...',
                  style: TextStyle(color: AppTheme.payaGray, fontSize: 14),
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
        constraints: const BoxConstraints(maxWidth: 480),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
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
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Oups ! Impossible d\'accéder à la commande',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.payaGray),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.loadData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
              // 1. Fiche Produit
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Hero
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
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
                          // Badges (Vendeur & Vague)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (vendor != null &&
                                  vendor.businessName.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.deepBlue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.verified_user_rounded,
                                        size: 14,
                                        color: AppTheme.deepBlue,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        vendor.businessName,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.deepBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (wave != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.payaOrange.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.waves,
                                        size: 14,
                                        color: AppTheme.payaOrange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Vague: ${wave.name}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF8C6D00),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Nom du produit
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepBlue,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Prix unitaire
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                currencyFormatter.format(controller.unitPrice),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.deepBlue,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '/ unité',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.payaGray,
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

              const SizedBox(height: 20),

              // 2. Sélecteur de Quantité & Formulaire
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
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
                        '1. Choisissez la quantité',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.deepBlue,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Boutons Quantité
                      Row(
                        children: [
                          _buildQtyButton(
                            icon: Icons.remove,
                            onTap: controller.decrementQuantity,
                          ),
                          Container(
                            width: 60,
                            alignment: Alignment.center,
                            child: Obx(
                              () => Text(
                                '${controller.quantity.value}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.deepBlue,
                                ),
                              ),
                            ),
                          ),
                          _buildQtyButton(
                            icon: Icons.add,
                            onTap: controller.incrementQuantity,
                          ),
                          const Spacer(),
                          // Sous-total
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Total à régler',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.payaGray,
                                ),
                              ),
                              Obx(
                                () => Text(
                                  currencyFormatter.format(
                                    controller.totalAmount,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 20,
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
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(),
                      ),

                      const Text(
                        '2. Vos coordonnées',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.deepBlue,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Champ Nom
                      TextFormField(
                        controller: controller.nameController,
                        decoration: InputDecoration(
                          labelText: 'Nom et Prénom(s) *',
                          hintText: 'Ex: Jean Dupont',
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: AppTheme.deepBlue,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.deepBlue,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez saisir votre nom complet';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Champ Téléphone
                      TextFormField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Numéro de téléphone WhatsApp *',
                          hintText: 'Ex: 90 00 00 00',
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            color: AppTheme.deepBlue,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.deepBlue,
                              width: 2,
                            ),
                          ),
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

                      const SizedBox(height: 16),

                      // Champ Note / Préférences
                      TextFormField(
                        controller: controller.noteController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Note ou préférences (optionnel)',
                          hintText: 'Ex: Couleur bleue, taille M, lieu de livraison...',
                          prefixIcon: const Icon(
                            Icons.edit_note_outlined,
                            color: AppTheme.deepBlue,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.deepBlue,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bouton de validation
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: controller.isSubmitting.value
                                ? null
                                : controller.submitOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.deepBlue,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: controller.isSubmitting.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Valider ma commande • ${currencyFormatter.format(controller.totalAmount)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Note rassurante pour le client
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.handshake_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Paiement direct avec le vendeur à la livraison',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
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
      color: const Color(0xFFF0F4F8),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, color: AppTheme.deepBlue, size: 20),
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icone Succès
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 64,
                  color: AppTheme.successGreen,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Commande Enregistrée ! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepBlue,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Merci ${controller.nameController.text.trim()}, votre commande a été transmise au vendeur.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppTheme.payaGray),
              ),
              const SizedBox(height: 24),

              // Récapitulatif
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
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
                        child: Divider(),
                      ),
                      _buildSummaryRow(
                        'N° Commande',
                        '#${order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0)}',
                        valueColor: AppTheme.payaGray,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bouton Notifier sur WhatsApp
              SizedBox(
                width: double.infinity,
                height: 52,
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
                        // Fallback : copier dans le presse-papier
                        await Clipboard.setData(
                          ClipboardData(
                            text: controller
                                .buildWhatsAppConfirmationMessage(),
                          ),
                        );
                        Get.snackbar(
                          'Copié !',
                          'Message copié dans le presse-papier',
                          backgroundColor: AppTheme.successGreen,
                          colorText: Colors.white,
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 20),
                  label: const Text(
                    'Confirmer au vendeur sur WhatsApp',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Bouton Copier le récapitulatif
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
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copier le récapitulatif'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.deepBlue,
                    side: const BorderSide(color: AppTheme.deepBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
          style: const TextStyle(fontSize: 14, color: AppTheme.payaGray),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? AppTheme.deepBlue,
            ),
          ),
        ),
      ],
    );
  }
}
