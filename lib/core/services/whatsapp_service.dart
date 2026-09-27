import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:paya_app/core/services/auth_service.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/order_model.dart';
import 'package:paya_app/data/models/customer_model.dart';

class WhatsAppService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxMap<String, String> customTemplates = <String, String>{}.obs;
  final RxBool isLoadingTemplates = false.obs;

  static const String keyConfirmation = 'confirmation';
  static const String keyPaid = 'paid';
  static const String keyProcessing = 'processing';
  static const String keyDelivered = 'delivered';
  static const String keyUndelivered = 'undelivered';

  static const Map<String, String> defaultTemplates = {
    keyConfirmation:
        'Bonjour *{client_name}* ! 👋\n\nVotre commande *#{order_id}* a bien été confirmée auprès de *{business_name}*.\n\n📦 *Articles commandés :*\n{products}\n\n💰 *Total commande :* {total_amount} FCFA\n💵 *Montant déjà payé :* {amount_paid} FCFA\n⚖️ *Reste à régler :* {remaining_balance} FCFA\n\nNous préparons votre commande avec le plus grand soin. Merci pour votre confiance ! ✨',
    keyPaid:
        'Bonjour *{client_name}* ! 💳✅\n\nNous vous confirmons la bonne réception de votre paiement de *{amount_paid} FCFA* pour la commande *#{order_id}*.\n\n💰 *Montant total :* {total_amount} FCFA\n⚖️ *Reste à payer :* {remaining_balance} FCFA\n\nVotre reçu a été enregistré chez *{business_name}*. Merci beaucoup ! 🎉',
    keyProcessing:
        'Bonne nouvelle *{client_name}* ! 🛍️✨\n\nLe produit lié à votre commande *#{order_id}* est maintenant *disponible et prêt* chez *{business_name}*.\n\n📦 *Articles :*\n{products}\n📍 *Lieu / Modalités :* {delivery_address}\n⚖️ *Reste à régler :* {remaining_balance} FCFA\n\nMerci de nous contacter pour convenir du créneau de retrait ou de livraison. À tout de suite ! 🚀',
    keyDelivered:
        'Félicitations *{client_name}* ! 📦🎉\n\nVotre commande *#{order_id}* a bien été livrée avec succès.\n\nToute l\'équipe de *{business_name}* vous remercie chaleureusement pour votre achat. À très bientôt pour vos prochaines commandes ! ⭐',
    keyUndelivered:
        'Bonjour *{client_name}*,\n\nNous avons tenté de vous contacter pour la livraison de votre commande *#{order_id}*, mais la remise n\'a pas pu être effectuée.\n\nMerci de nous recontacter au plus vite afin de replanifier votre livraison avec *{business_name}*. Excellente journée !',
  };

  static const Map<String, String> templateLabels = {
    keyConfirmation: 'Confirmation de commande',
    keyPaid: 'Paiement reçu / Encaissé',
    keyProcessing: 'Produit disponible / En traitement',
    keyDelivered: 'Commande livrée',
    keyUndelivered: 'Commande non livrée / Relance',
  };

  static const List<Map<String, String>> availableVariables = [
    {'tag': '{client_name}', 'desc': 'Nom complet du client'},
    {'tag': '{order_id}', 'desc': 'Numéro de commande (ex: #1234)'},
    {'tag': '{products}', 'desc': 'Liste des articles & quantités'},
    {'tag': '{total_amount}', 'desc': 'Montant total'},
    {'tag': '{amount_paid}', 'desc': 'Montant déjà versé'},
    {'tag': '{remaining_balance}', 'desc': 'Reste à payer'},
    {'tag': '{business_name}', 'desc': 'Nom de la boutique'},
    {'tag': '{wave_name}', 'desc': 'Nom de la campagne'},
    {'tag': '{delivery_address}', 'desc': 'Adresse de livraison'},
    {'tag': '{date}', 'desc': 'Date du jour'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    try {
      isLoadingTemplates.value = true;
      String? vendorId;
      if (Get.isRegistered<AuthService>()) {
        vendorId = Get.find<AuthService>().currentVendorId;
      }
      if (vendorId != null) {
        final doc = await _firestore
            .collection('vendors')
            .doc(vendorId)
            .collection('settings')
            .doc('whatsapp_templates')
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final map = <String, String>{};
          for (final key in defaultTemplates.keys) {
            if (data[key] != null && data[key].toString().trim().isNotEmpty) {
              map[key] = data[key].toString();
            }
          }
          customTemplates.assignAll(map);
        }
      }
    } catch (e) {
      debugPrint('[WhatsAppService] Erreur chargement templates: $e');
    } finally {
      isLoadingTemplates.value = false;
    }
  }

  String getTemplate(String key) {
    return customTemplates[key] ?? defaultTemplates[key] ?? '';
  }

  Future<void> saveTemplate(String key, String templateText) async {
    try {
      customTemplates[key] = templateText;
      String? vendorId;
      if (Get.isRegistered<AuthService>()) {
        vendorId = Get.find<AuthService>().currentVendorId;
      }
      if (vendorId != null) {
        await _firestore
            .collection('vendors')
            .doc(vendorId)
            .collection('settings')
            .doc('whatsapp_templates')
            .set({key: templateText}, SetOptions(merge: true));
      }
      Get.snackbar(
        'Succès',
        'Modèle WhatsApp enregistré',
        backgroundColor: AppTheme.payaGreen,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('[WhatsAppService] Erreur sauvegarde template: $e');
      Get.snackbar(
        'Erreur',
        'Échec de l\'enregistrement : $e',
        backgroundColor: AppTheme.softRed,
        colorText: Colors.white,
      );
    }
  }

  Future<void> resetToDefaults() async {
    try {
      customTemplates.clear();
      String? vendorId;
      if (Get.isRegistered<AuthService>()) {
        vendorId = Get.find<AuthService>().currentVendorId;
      }
      if (vendorId != null) {
        await _firestore
            .collection('vendors')
            .doc(vendorId)
            .collection('settings')
            .doc('whatsapp_templates')
            .delete();
      }
      Get.snackbar(
        'Réinitialisé',
        'Les modèles par défaut ont été restaurés',
        backgroundColor: AppTheme.payaBlue,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('[WhatsAppService] Erreur reset: $e');
    }
  }

  /// Rend le template avec les variables réelles de la commande et du client
  String renderMessage({
    required String templateKey,
    required OrderModel order,
    required CustomerModel customer,
    String? vendorName,
    String? waveName,
  }) {
    String template = getTemplate(templateKey);

    final currencyFormatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '',
      decimalDigits: 0,
    );

    final productsList = order.items.map((item) {
      return '• ${item.name} x${item.quantity} (${currencyFormatter.format(item.totalPrice).trim()} F)';
    }).join('\n');

    final orderIdShort = order.id.length > 6
        ? order.id.substring(order.id.length - 6)
        : order.id;

    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());

    final replacements = {
      '{client_name}': customer.name,
      '{order_id}': orderIdShort,
      '{products}': productsList.isNotEmpty ? productsList : 'Articles',
      '{total_amount}': currencyFormatter.format(order.totalAmount).trim(),
      '{amount_paid}': currencyFormatter.format(order.totalPaid).trim(),
      '{remaining_balance}':
          currencyFormatter.format(order.remainingBalance).trim(),
      '{business_name}': vendorName?.trim().isNotEmpty == true
          ? vendorName!
          : 'notre boutique',
      '{wave_name}':
          waveName?.trim().isNotEmpty == true ? waveName! : 'Campagne active',
      '{delivery_address}': customer.address?.trim().isNotEmpty == true
          ? customer.address!
          : 'À convenir avec le vendeur',
      '{date}': today,
    };

    replacements.forEach((key, value) {
      template = template.replaceAll(key, value);
    });

    return template;
  }

  /// Nettoie et prépare le numéro de téléphone pour WhatsApp
  static String cleanPhoneNumber(String rawPhone) {
    String clean = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.startsWith('+')) {
      clean = clean.substring(1);
    }
    // Si l'utilisateur a saisi un numéro local à 8 chiffres (ex: Burkina Faso 70000000), ajouter 226 par défaut
    if (clean.length == 8) {
      clean = '226$clean';
    }
    return clean;
  }

  /// Ouvre directement WhatsApp (Standard ou Business) via scheme natif ou fallback wa.me
  static Future<bool> launchWhatsAppMessage({
    required String phone,
    required String message,
  }) async {
    final cleanPhone = cleanPhoneNumber(phone);
    final encodedMessage = Uri.encodeComponent(message);

    // 1. Tenter le protocole natif whatsapp:// (permet la détection de WhatsApp et WhatsApp Business)
    final nativeUri = Uri.parse(
      'whatsapp://send?phone=$cleanPhone&text=$encodedMessage',
    );

    try {
      if (await canLaunchUrl(nativeUri)) {
        final success = await launchUrl(
          nativeUri,
          mode: LaunchMode.externalApplication,
        );
        if (success) return true;
      }
    } catch (e) {
      debugPrint('[WhatsAppService] Echec deep link natif: $e');
    }

    // 2. Fallback universel vers https://wa.me/
    final webUri = Uri.parse(
      'https://wa.me/$cleanPhone?text=$encodedMessage',
    );

    try {
      if (await canLaunchUrl(webUri)) {
        return await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('[WhatsAppService] Echec web fallback: $e');
    }

    // 3. Dernier fallback: Copie dans le presse-papier
    await Clipboard.setData(ClipboardData(text: message));
    Get.snackbar(
      'WhatsApp non accessible',
      'Le message a été copié dans le presse-papier.',
      backgroundColor: AppTheme.payaOrange,
      colorText: Colors.white,
    );
    return false;
  }

  /// Affiche la feuille modale de prévisualisation et d'édition avant envoi
  static void showPreviewAndSend({
    required BuildContext context,
    required String title,
    required String recipientName,
    required String recipientPhone,
    required String initialMessage,
    VoidCallback? onSent,
  }) {
    final textController = TextEditingController(text: initialMessage);

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppTheme.slate300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Color(0xFF1EBE5D),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.slate900,
                        ),
                      ),
                      Text(
                        'Destinataire : $recipientName ($recipientPhone)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.slate500,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded, color: AppTheme.slate400),
                  splashRadius: 20,
                ),
              ],
            ),

            const SizedBox(height: 14),

            const Text(
              'Personnalisez le message avant l\'envoi :',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.slate600,
              ),
            ),
            const SizedBox(height: 6),

            // Message Editor
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.slate50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.slate200),
                ),
                child: TextField(
                  controller: textController,
                  maxLines: null,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(14),
                    border: InputBorder.none,
                    hintText: 'Écrivez votre message WhatsApp...',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: textController.text),
                      );
                      Get.snackbar(
                        'Copié !',
                        'Le texte a été copié dans le presse-papier',
                        backgroundColor: AppTheme.payaBlue,
                        colorText: Colors.white,
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copier'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.slate700,
                      side: const BorderSide(color: AppTheme.slate300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Get.back();
                      final text = textController.text.trim();
                      if (text.isNotEmpty) {
                        await launchWhatsAppMessage(
                          phone: recipientPhone,
                          message: text,
                        );
                        if (onSent != null) {
                          onSent();
                        }
                      }
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text(
                      'Ouvrir WhatsApp',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: const Color(0xFF25D366).withValues(alpha: 0.4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
