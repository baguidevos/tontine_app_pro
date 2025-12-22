import 'package:get/get.dart';
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

  Future<void> createCustomer({
    required String name,
    required String phone,
    String? address,
  }) async {
    final vendorId = _authService.currentVendorId;
    if (vendorId == null) return;

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

      Get.snackbar('Succès', 'Client créé avec succès');
      Get.back();
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la création: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await _customerRepository.updateCustomer(customer);
      Get.snackbar('Succès', 'Client mis à jour');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la mise à jour: $e');
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      await _customerRepository.deleteCustomer(customerId);
      Get.snackbar('Succès', 'Client supprimé');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la suppression: $e');
    }
  }
}
