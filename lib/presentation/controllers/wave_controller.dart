import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/subscription_service.dart';
import '../../data/models/wave_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/wave_repository.dart';
import '../../data/repositories/product_repository.dart';

class WaveController extends GetxController {
  final WaveRepository waveRepository = WaveRepository();
  final ProductRepository productRepository = ProductRepository();
  final AuthService _authService = Get.find<AuthService>();
  final SubscriptionService _subscriptionService =
      Get.find<SubscriptionService>();

  var waves = <WaveModel>[].obs;
  var isLoading = false.obs;

  // Products liés à la vague en cours d'édition/création
  final RxList<String> selectedProductIds = <String>[].obs;
  final RxList<ProductModel> linkedProducts = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadWaves();
  }

  void _loadWaves() {
    final vendorId = _authService.currentVendorId;
    if (vendorId != null) {
      waveRepository.watchWavesByVendor(vendorId).listen((waveList) {
        waves.value = waveList;
      });
    }
  }

  void setSelectedProducts(List<String> productIds) {
    selectedProductIds.value = productIds;
  }

  void addSelectedProduct(String productId) {
    if (!selectedProductIds.contains(productId)) {
      selectedProductIds.add(productId);
    }
  }

  void removeSelectedProduct(String productId) {
    selectedProductIds.remove(productId);
  }

  void clearSelectedProducts() {
    selectedProductIds.clear();
  }

  Future<void> loadLinkedProducts(List<String> productIds) async {
    try {
      final products = await productRepository.getProductsByIds(productIds);
      linkedProducts.value = products;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les produits: $e');
    }
  }

  Future<void> createWave(WaveModel wave) async {
    final vendorId = _authService.currentVendorId;
    if (vendorId == null) return;

    final currentCount = await waveRepository.getWaveCountByVendor(vendorId);
    if (!_subscriptionService.canCreateWave(currentCount)) {
      Get.snackbar(
        'Limite Atteinte',
        'Vous avez atteint votre limite de vagues. Passez au Premium pour plus.',
        duration: const Duration(seconds: 1),
      );
      Get.toNamed('/subscription');
      return;
    }

    try {
      isLoading.value = true;
      final waveToCreate = wave.id.isEmpty
          ? wave.copyWith(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              createdAt: DateTime.now(),
            )
          : wave;

      await waveRepository.createWave(waveToCreate, vendorId);

      // Lier les produits sélectionnés à la nouvelle vague en une seule opération
      if (selectedProductIds.isNotEmpty) {
        await waveRepository.setWaveProducts(
          waveToCreate.id,
          selectedProductIds.toList(),
        );
        clearSelectedProducts();
      }

      Get.back();
      Get.snackbar(
        'Succès',
        'Vague créée avec succès',
        backgroundColor: AppTheme.successGreen,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la création: $e',
        backgroundColor: AppTheme.softRed,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateWave(WaveModel wave) async {
    try {
      await waveRepository.updateWave(wave);
      Get.back();
      Get.snackbar(
        'Succès',
        'Vague mise à jour',
        backgroundColor: AppTheme.successGreen,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la mise à jour: $e',
        backgroundColor: AppTheme.softRed,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }
  }

  Future<void> updateWaveStatus(WaveModel wave, WaveStatus newStatus) async {
    try {
      final updatedWave = WaveModel(
        id: wave.id,
        name: wave.name,
        status: newStatus,
        createdAt: wave.createdAt,
      );

      await waveRepository.updateWave(updatedWave);
      Get.back();
      Get.snackbar(
        'Succès',
        'Statut mis à jour',
        backgroundColor: AppTheme.successGreen,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la mise à jour: $e',
        backgroundColor: AppTheme.softRed,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }
  }

  Future<void> deleteWave(String waveId) async {
    try {
      await waveRepository.deleteWave(waveId);
      Get.snackbar(
        'Succès',
        'Vague supprimée',
        backgroundColor: AppTheme.successGreen,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la suppression: $e',
        backgroundColor: AppTheme.softRed,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }
  }

  Future<void> addProductToWave(String waveId, String productId) async {
    try {
      await waveRepository.addProductToWave(waveId, productId);
      Get.snackbar(
        'Succès',
        'Produit ajouté à la vague',
        backgroundColor: AppTheme.successGreen,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de l\'ajout: $e',
        backgroundColor: AppTheme.softRed,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }
  }

  Future<void> removeProductFromWave(String waveId, String productId) async {
    try {
      await waveRepository.removeProductFromWave(waveId, productId);
      Get.snackbar(
        'Succès',
        'Produit retiré de la vague',
        backgroundColor: AppTheme.successGreen,
        colorText: Colors.white,
        duration: const Duration(seconds: 0),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la suppression: $e',
        backgroundColor: AppTheme.softRed,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }
  }

  Future<void> setWaveProducts(String waveId, List<String> productIds) async {
    try {
      await waveRepository.setWaveProducts(waveId, productIds);
      Get.snackbar(
        'Succès',
        'Produits mis à jour',
        backgroundColor: AppTheme.successGreen,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la mise à jour: $e',
        backgroundColor: AppTheme.softRed,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }
  }
}
