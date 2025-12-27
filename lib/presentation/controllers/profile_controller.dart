import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/vendor_model.dart';
import '../../data/repositories/vendor_repository.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final VendorRepository _vendorRepository = VendorRepository();

  final businessNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  var isLoading = false.obs;

  VendorModel? get vendor => _authService.currentVendor.value;

  @override
  void onInit() {
    super.onInit();
    _initControllers();

    // Listen to vendor changes to keep text fields in sync if updated from elsewhere
    ever(_authService.currentVendor, (_) => _initControllers());
  }

  void _initControllers() {
    if (vendor != null) {
      businessNameController.text = vendor!.businessName;
      phoneController.text = vendor!.phone;
      emailController.text = vendor!.email;
    }
  }

  Future<void> updateProfile() async {
    if (vendor == null) return;

    try {
      isLoading.value = true;

      final updatedVendor = vendor!.copyWith(
        businessName: businessNameController.text.trim(),
        phone: phoneController.text.trim(),
      );

      await _vendorRepository.updateVendor(updatedVendor);

      Get.snackbar(
        'Succès',
        'Profil mis à jour avec succès',
        backgroundColor: AppTheme.successGreen,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la mise à jour: $e',
        backgroundColor: AppTheme.softRed,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    Get.defaultDialog(
      title: 'Déconnexion',
      middleText: 'Voulez-vous vraiment vous déconnecter ?',
      textConfirm: 'Déconnexion',
      textCancel: 'Annuler',
      confirmTextColor: Colors.white,
      buttonColor: AppTheme.softRed,
      onConfirm: () async {
        Get.back(); // close dialog
        await _authService.logout();
        // Get.offAllNamed('/splash') is usually handled by auth listener if set up
        // but explicit navigation if needed:
        Get.offAllNamed('/login');
      },
    );
  }

  @override
  void onClose() {
    businessNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
