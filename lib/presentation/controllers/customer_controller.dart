import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tontine_app/core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/customer_model.dart';
import '../../data/repositories/customer_repository.dart';

class CustomerController extends GetxController {
  final CustomerRepository _customerRepository = CustomerRepository();
  final AuthService _authService = Get.find<AuthService>();

  var customers = <CustomerModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCustomers();
  }

  void _loadCustomers() {
    final vendorId = _authService.currentVendorId;
    if (vendorId != null) {
      _customerRepository.watchCustomersByVendor(vendorId).listen((
        customerList,
      ) {
        customers.value = customerList;
      });
    }
  }

  Future<bool> createCustomer({
    required String name,
    required String phone,
    String? address,
  }) async {
    final vendorId = _authService.currentVendorId;
    if (vendorId == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez vous reconnecter',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isLoading.value = true;

      final customer = CustomerModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        vendorId: vendorId,
        name: name,
        phone: phone,
        address: address,
        createdAt: DateTime.now(),
      );

      await _customerRepository.createCustomer(customer);

      Get.snackbar(
        'Succès',
        'Client créé avec succès',
        backgroundColor: AppTheme.deepBlue,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la création: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateCustomer(CustomerModel customer) async {
    try {
      isLoading.value = true;
      await _customerRepository.updateCustomer(customer);
      Get.snackbar(
        'Succès',
        'Client mis à jour',
        backgroundColor: AppTheme.deepBlue,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la mise à jour: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteCustomer(String customerId) async {
    try {
      await _customerRepository.deleteCustomer(customerId);
      Get.snackbar(
        'Succès',
        'Client supprimé',
        backgroundColor: AppTheme.deepBlue,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la suppression: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
}
