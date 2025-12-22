import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/subscription_service.dart';
import '../../data/models/wave_model.dart';
import '../../data/repositories/wave_repository.dart';

class WaveController extends GetxController {
  final WaveRepository _waveRepository = WaveRepository();
  final AuthService _authService = Get.find<AuthService>();
  final SubscriptionService _subscriptionService =
      Get.find<SubscriptionService>();

  var waves = <WaveModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadWaves();
  }

  void _loadWaves() {
    final vendorId = _authService.currentVendorId;
    if (vendorId != null) {
      _waveRepository.watchWavesByVendor(vendorId).listen((waveList) {
        waves.value = waveList;
      });
    }
  }

  Future<void> createWave(WaveModel wave) async {
    final vendorId = _authService.currentVendorId;
    if (vendorId == null) return;

    // Check subscription limits if it's a new wave (not sure if we need this check here if we pass the whole object, but safety first)
    // Actually, usually creation implies +1.
    final currentCount = await _waveRepository.getWaveCountByVendor(vendorId);
    if (!_subscriptionService.canCreateWave(currentCount)) {
      Get.snackbar(
        'Limite Atteinte',
        'Vous avez atteint votre limite de vagues. Passez au Premium pour plus.',
      );
      Get.toNamed('/subscription');
      return;
    }

    try {
      isLoading.value = true;
      // Ensure the wave has the correct ID (or we can generate it here if empty)
      final waveToCreate = wave.id.isEmpty
          ? wave.copyWith(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              createdAt: DateTime.now(),
            )
          : wave;

      await _waveRepository.createWave(waveToCreate, vendorId);

      Get.snackbar('Succès', 'Vague créée avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la création: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateWave(WaveModel wave) async {
    try {
      await _waveRepository.updateWave(wave);
      Get.snackbar('Succès', 'Vague mise à jour');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la mise à jour: $e');
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

      await _waveRepository.updateWave(updatedWave);
      Get.snackbar('Succès', 'Statut mis à jour');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la mise à jour: $e');
    }
  }

  Future<void> deleteWave(String waveId) async {
    try {
      await _waveRepository.deleteWave(waveId);
      Get.snackbar('Succès', 'Vague supprimée');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la suppression: $e');
    }
  }
}
