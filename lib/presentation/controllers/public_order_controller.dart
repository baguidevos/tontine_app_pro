import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/vendor_model.dart';
import '../../data/models/wave_model.dart';

class PublicOrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // URL parameters
  String productId = '';
  String vendorId = '';
  String waveId = '';

  // State
  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final isOrderSubmitted = false.obs;
  final errorMessage = RxnString();

  // Data
  final product = Rxn<ProductModel>();
  final wave = Rxn<WaveModel>();
  final vendor = Rxn<VendorModel>();
  final createdOrder = Rxn<OrderModel>();

  // Quantity selection
  final quantity = 1.obs;

  // Form controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final noteController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  double get unitPrice =>
      product.value?.prixTTC ?? product.value?.price ?? 0.0;
  double get totalAmount => unitPrice * quantity.value;

  @override
  void onInit() {
    super.onInit();
    _parseParameters();
    loadData();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    noteController.dispose();
    super.onClose();
  }

  void _parseParameters() {
    // 1. GetX route parameters
    productId = Get.parameters['p'] ?? Get.parameters['productId'] ?? '';
    vendorId = Get.parameters['v'] ?? Get.parameters['vendorId'] ?? '';
    waveId = Get.parameters['w'] ?? Get.parameters['waveId'] ?? '';

    // 2. Standard Uri query parameters (before #)
    final uri = Uri.base;
    if (productId.isEmpty) {
      productId =
          uri.queryParameters['p'] ?? uri.queryParameters['productId'] ?? '';
    }
    if (vendorId.isEmpty) {
      vendorId =
          uri.queryParameters['v'] ?? uri.queryParameters['vendorId'] ?? '';
    }
    if (waveId.isEmpty) {
      waveId =
          uri.queryParameters['w'] ?? uri.queryParameters['waveId'] ?? '';
    }

    // 3. Fragment query string (after #, e.g. /#/order?p=123)
    final fragment = uri.fragment;
    if (fragment.contains('?')) {
      final fragmentQuery = fragment.substring(fragment.indexOf('?') + 1);
      final params = Uri.splitQueryString(fragmentQuery);
      if (productId.isEmpty) {
        productId = params['p'] ?? params['productId'] ?? '';
      }
      if (vendorId.isEmpty) {
        vendorId = params['v'] ?? params['vendorId'] ?? '';
      }
      if (waveId.isEmpty) {
        waveId = params['w'] ?? params['waveId'] ?? '';
      }
    }

    // 4. Regex fallback on the full URL string to guarantee resolution
    final fullUrl = uri.toString();
    if (productId.isEmpty) {
      final pMatch =
          RegExp(r'[?&](?:p|productId)=([^&#]+)').firstMatch(fullUrl);
      if (pMatch != null) productId = Uri.decodeComponent(pMatch.group(1)!);
    }
    if (vendorId.isEmpty) {
      final vMatch =
          RegExp(r'[?&](?:v|vendorId)=([^&#]+)').firstMatch(fullUrl);
      if (vMatch != null) vendorId = Uri.decodeComponent(vMatch.group(1)!);
    }
    if (waveId.isEmpty) {
      final wMatch =
          RegExp(r'[?&](?:w|waveId)=([^&#]+)').firstMatch(fullUrl);
      if (wMatch != null) waveId = Uri.decodeComponent(wMatch.group(1)!);
    }

    debugPrint(
      '[PublicOrderController] Paramètres résolus: productId=$productId, vendorId=$vendorId, waveId=$waveId (depuis $fullUrl)',
    );
  }

  Future<void> loadData() async {
    if (productId.isEmpty) {
      errorMessage.value =
          'Lien invalide : aucun identifiant de produit spécifié.';
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;

      // Connexion anonyme Firebase pour autoriser la lecture Firestore publique
      if (FirebaseAuth.instance.currentUser == null) {
        try {
          await FirebaseAuth.instance.signInAnonymously();
        } catch (authEx) {
          debugPrint('[PublicOrderController] Note anonyme auth: $authEx');
        }
      }

      // 1. Charger le produit
      final prodDoc =
          await _firestore.collection('products').doc(productId).get();
      if (!prodDoc.exists || prodDoc.data() == null) {
        errorMessage.value = 'Ce produit n\'est plus disponible.';
        isLoading.value = false;
        return;
      }

      final loadedProduct = ProductModel.fromMap(prodDoc.data()!, prodDoc.id);
      product.value = loadedProduct;

      // Si le vendorId n'était pas dans l'URL mais dans le produit ou la vague
      if (vendorId.isEmpty &&
          loadedProduct.waveId != null &&
          loadedProduct.waveId!.isNotEmpty) {
        final waveDoc = await _firestore
            .collection('waves')
            .doc(loadedProduct.waveId!)
            .get();
        if (waveDoc.exists && waveDoc.data() != null) {
          vendorId = waveDoc.data()!['vendorId'] ?? '';
        }
      }

      // 2. Déterminer la vague
      String? targetWaveId = waveId.isNotEmpty ? waveId : loadedProduct.waveId;

      // Si aucune vague n'est spécifiée, chercher automatiquement une vague active du vendeur
      if ((targetWaveId == null || targetWaveId.isEmpty) &&
          vendorId.isNotEmpty) {
        try {
          final wavesSnapshot = await _firestore
              .collection('waves')
              .where('vendorId', isEqualTo: vendorId)
              .get();

          final allWaves = wavesSnapshot.docs
              .map((doc) => WaveModel.fromMap(doc.data(), doc.id))
              .toList();

          // 1. Chercher une vague active contenant ce produit
          for (final w in allWaves) {
            if (w.status == WaveStatus.active &&
                (w.productIds.contains(productId) ||
                    loadedProduct.waveIds.contains(w.id))) {
              targetWaveId = w.id;
              break;
            }
          }

          // 2. Si non trouvée, chercher la première vague active du vendeur
          if (targetWaveId == null || targetWaveId.isEmpty) {
            for (final w in allWaves) {
              if (w.status == WaveStatus.active) {
                targetWaveId = w.id;
                break;
              }
            }
          }
        } catch (e) {
          debugPrint('[PublicOrderController] Erreur recherche vagues: $e');
        }
      }

      if (targetWaveId != null && targetWaveId.isNotEmpty) {
        waveId = targetWaveId;
        final waveDoc =
            await _firestore.collection('waves').doc(targetWaveId).get();
        if (waveDoc.exists && waveDoc.data() != null) {
          wave.value = WaveModel.fromMap(waveDoc.data()!, waveDoc.id);
          if (vendorId.isEmpty && waveDoc.data()!['vendorId'] != null) {
            vendorId = waveDoc.data()!['vendorId'] ?? '';
          }
        }
      }

      // 3. Charger les informations du vendeur
      if (vendorId.isNotEmpty) {
        final vendorDoc =
            await _firestore.collection('vendors').doc(vendorId).get();
        if (vendorDoc.exists && vendorDoc.data() != null) {
          vendor.value = VendorModel.fromMap(vendorDoc.data()!, vendorDoc.id);
        }
      }
    } catch (e) {
      debugPrint('[PublicOrderController] Erreur chargement: $e');
      errorMessage.value =
          'Impossible de charger les détails de la commande. Veuillez vérifier votre connexion.';
    } finally {
      isLoading.value = false;
    }
  }

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  Future<void> submitOrder() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final currentProduct = product.value;
    if (currentProduct == null) {
      Get.snackbar('Erreur', 'Produit introuvable.');
      return;
    }

    final cleanName = nameController.text.trim();
    final cleanPhone = phoneController.text.trim();
    final notes = noteController.text.trim();

    try {
      isSubmitting.value = true;

      // 1. Rechercher ou créer le client chez ce vendeur
      String customerId = '';
      if (vendorId.isNotEmpty) {
        final existingCustomersQuery = await _firestore
            .collection('customers')
            .where('vendorId', isEqualTo: vendorId)
            .where('phone', isEqualTo: cleanPhone)
            .limit(1)
            .get();

        if (existingCustomersQuery.docs.isNotEmpty) {
          customerId = existingCustomersQuery.docs.first.id;
        } else {
          // Nouveau client
          final newCustomerRef = _firestore.collection('customers').doc();
          final newCustomer = CustomerModel(
            id: newCustomerRef.id,
            vendorId: vendorId,
            name: cleanName,
            phone: cleanPhone,
            totalCredit: 0.0,
            createdAt: DateTime.now(),
          );
          await newCustomerRef.set(newCustomer.toMap());
          customerId = newCustomerRef.id;
        }
      } else {
        // Fallback si pas de vendorId explicite
        final customerRef = _firestore.collection('customers').doc();
        customerId = customerRef.id;
      }

      // 2. Créer l'élément de commande (OrderItemModel)
      final itemName = notes.isNotEmpty
          ? '${currentProduct.name} ($notes)'
          : currentProduct.name;

      final orderItem = OrderItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: currentProduct.id,
        name: itemName,
        unitPrice: unitPrice,
        quantity: quantity.value,
        paidAmount: 0.0,
      );

      // 3. Créer la commande (OrderModel)
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      final finalWaveId = waveId.isNotEmpty
          ? waveId
          : (wave.value?.id ??
              (currentProduct.waveId != null &&
                      currentProduct.waveId!.isNotEmpty
                  ? currentProduct.waveId
                  : (currentProduct.waveIds.isNotEmpty
                      ? currentProduct.waveIds.first
                      : null)));

      final order = OrderModel(
        id: orderId,
        vendorId: vendorId,
        customerId: customerId,
        waveId: (finalWaveId != null && finalWaveId.isNotEmpty)
            ? finalWaveId
            : null,
        items: [orderItem],
        totalAmount: totalAmount,
        totalPaid: 0.0,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('orders').doc(orderId).set(order.toMap());

      createdOrder.value = order;
      isOrderSubmitted.value = true;
    } catch (e) {
      debugPrint('[PublicOrderController] Erreur soumission commande: $e');
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de l\'enregistrement de votre commande. Veuillez réessayer.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Génère le message WhatsApp récapitulatif pour notifier le vendeur
  String buildWhatsAppConfirmationMessage() {
    final currentProduct = product.value;
    final order = createdOrder.value;
    final orderNum = order != null ? order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0) : '';

    final buffer = StringBuffer();
    buffer.writeln('Bonjour ! Je viens de valider ma commande sur Paya :');
    buffer.writeln('');
    buffer.writeln('📦 *Produit :* ${currentProduct?.name ?? ''}');
    buffer.writeln('🔢 *Quantité :* ${quantity.value}');
    buffer.writeln('💰 *Total :* ${totalAmount.toStringAsFixed(0)} FCFA');
    if (noteController.text.trim().isNotEmpty) {
      buffer.writeln('📝 *Détails :* ${noteController.text.trim()}');
    }
    buffer.writeln('');
    buffer.writeln('👤 *Nom :* ${nameController.text.trim()}');
    buffer.writeln('📱 *Téléphone :* ${phoneController.text.trim()}');
    if (orderNum.isNotEmpty) {
      buffer.writeln('🔖 *N° Commande :* #$orderNum');
    }
    buffer.writeln('');
    buffer.writeln('Merci de me confirmer la prise en compte !');

    return buffer.toString();
  }

  /// Retourne le lien WhatsApp avec le message pré-rempli
  String? get whatsappUrl {
    final vendorPhone = vendor.value?.phone ?? '';
    final message = buildWhatsAppConfirmationMessage();
    final encodedMessage = Uri.encodeComponent(message);

    if (vendorPhone.isNotEmpty) {
      // Nettoyer le numéro (retirer espaces, +, tirets)
      final cleanNumber = vendorPhone.replaceAll(RegExp(r'[^0-9]'), '');
      return 'https://wa.me/$cleanNumber?text=$encodedMessage';
    }

    return 'https://wa.me/?text=$encodedMessage';
  }
}
