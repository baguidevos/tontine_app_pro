import 'package:get/get.dart';
import 'package:paya_app/core/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var isLoading = false.obs;

  // Login form fields
  var loginEmail = ''.obs;
  var loginPassword = ''.obs;

  // Registration form fields
  var registerEmail = ''.obs;
  var registerPassword = ''.obs;
  var registerBusinessName = ''.obs;
  var registerPhone = ''.obs;

  Future<void> login() async {
    if (loginEmail.value.isEmpty || loginPassword.value.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez remplir tous les champs');
      return;
    }

    isLoading.value = true;
    final success = await _authService.login(
      email: loginEmail.value,
      password: loginPassword.value,
    );
    isLoading.value = false;

    if (success) {
      Get.offAllNamed('/'); // Navigate to main layout
    }
  }

  Future<void> register() async {
    if (registerEmail.value.isEmpty ||
        registerPassword.value.isEmpty ||
        registerBusinessName.value.isEmpty ||
        registerPhone.value.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez remplir tous les champs');
      return;
    }

    isLoading.value = true;
    final success = await _authService.register(
      email: registerEmail.value,
      password: registerPassword.value,
      businessName: registerBusinessName.value,
      phone: registerPhone.value,
    );
    isLoading.value = false;

    if (success) {
      Get.offAllNamed('/'); // Navigate to main layout
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed('/login');
  }
}
